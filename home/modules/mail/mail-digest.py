import argparse
import datetime
import email
import fcntl
import html
import imaplib
import json
import os
import subprocess
import sys
import urllib.request
from email.header import decode_header, make_header
from email.utils import parseaddr

CONFIG = json.loads(os.environ["MAIL_DIGEST_CONFIG"])
CATEGORIES = ["urgente", "importante", "normal", "publicidad", "spam"]
MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
CHUNK = 25
MAX_MAILS = 150
MAX_LINES = 14

PROMPT = """Clasificas correos electronicos recibidos hoy. Para cada correo de la lista devuelve:
- id: el mismo numero que trae el correo.
- categoria: una de urgente, importante, normal, publicidad, spam.
- remitente: nombre corto de la empresa, servicio o persona (ej. "AliExpress", "Railway", "Google", "Juan Perez").
- resumen: maximo 8 palabras en espanol sobre de que trata.

Criterios:
- urgente: servicios caidos, fallos de despliegue o build, alertas de seguridad, inicios de sesion sospechosos, pagos rechazados, algo que vence hoy.
- importante: personas reales escribiendo directamente, trabajo, clientes, facturas, cobros, envios y pedidos en camino, cuentas.
- normal: notificaciones rutinarias, boletines o avisos automaticos sin accion necesaria.
- publicidad: ofertas, descuentos, promociones, marketing, recomendaciones de productos.
- spam: estafas, phishing, premios falsos, remitentes sospechosos.

Correos:
"""

SCHEMA = {
    "type": "object",
    "properties": {
        "correos": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "id": {"type": "integer"},
                    "categoria": {"type": "string", "enum": CATEGORIES},
                    "remitente": {"type": "string"},
                    "resumen": {"type": "string"},
                },
                "required": ["id", "categoria", "remitente", "resumen"],
            },
        }
    },
    "required": ["correos"],
}


def decode(value):
    if not value:
        return ""
    try:
        return str(make_header(decode_header(value))).strip()
    except Exception:
        return value.strip()


def password(account):
    out = subprocess.run(
        ["secret-tool", "lookup", "service", "mail", "account", account["address"]],
        capture_output=True, text=True,
    )
    if out.returncode != 0 or not out.stdout:
        raise RuntimeError("sin contrasena en el keyring")
    return out.stdout.rstrip("\n")


def oauth_token(account):
    out = subprocess.run(account["oauthCommand"], shell=True, capture_output=True, text=True)
    if out.returncode != 0 or not out.stdout.strip():
        raise RuntimeError("token OAuth2 invalido")
    return out.stdout.strip()


def fetch(account):
    imap = imaplib.IMAP4_SSL(account["host"], account["port"], timeout=30)
    try:
        if account["auth"] == "oauth2":
            token = oauth_token(account)
            auth = "user=%s\1auth=Bearer %s\1\1" % (account["address"], token)
            imap.authenticate("XOAUTH2", lambda _: auth.encode())
        else:
            imap.login(account["address"], password(account))
        imap.select("INBOX", readonly=True)
        today = datetime.date.today()
        since = "%02d-%s-%d" % (today.day, MONTHS[today.month - 1], today.year)
        _, data = imap.search(None, "SINCE", since)
        ids = data[0].split()[-MAX_MAILS:]
        if not ids:
            return []
        _, resp = imap.fetch(b",".join(ids), "(BODY.PEEK[HEADER.FIELDS (FROM SUBJECT)])")
        mails = []
        for part in resp:
            if not isinstance(part, tuple):
                continue
            msg = email.message_from_bytes(part[1])
            name, addr = parseaddr(decode(msg.get("From")))
            mails.append({
                "from": "%s <%s>" % (name, addr) if name else addr,
                "fallback": name or addr.split("@")[-1],
                "subject": decode(msg.get("Subject")) or "(sin asunto)",
            })
        return mails
    finally:
        try:
            imap.logout()
        except Exception:
            pass


def classify(mails):
    results = {}
    for start in range(0, len(mails), CHUNK):
        chunk = mails[start:start + CHUNK]
        listing = "\n".join(
            "%d. De: %s | Asunto: %s" % (start + i, m["from"], m["subject"][:160])
            for i, m in enumerate(chunk)
        )
        body = json.dumps({
            "model": CONFIG["model"],
            "messages": [{"role": "user", "content": PROMPT + listing}],
            "format": SCHEMA,
            "stream": False,
            "think": False,
            "keep_alive": "30s",
            "options": {"temperature": 0, "num_ctx": 8192},
        }).encode()
        req = urllib.request.Request(
            CONFIG["ollama"] + "/api/chat", data=body,
            headers={"Content-Type": "application/json"},
        )
        with urllib.request.urlopen(req, timeout=300) as r:
            content = json.loads(r.read())["message"]["content"]
        for item in json.loads(content).get("correos", []):
            if isinstance(item.get("id"), int) and item.get("categoria") in CATEGORIES:
                results[item["id"]] = item
    return results


def digest(mails, results):
    groups = {}
    for i, m in enumerate(mails):
        r = results.get(i, {})
        cat = r.get("categoria", "normal")
        sender = (r.get("remitente") or m["fallback"]).strip() or m["fallback"]
        key = (cat, sender.lower())
        g = groups.setdefault(key, {"cat": cat, "sender": sender, "count": 0, "summary": ""})
        g["count"] += 1
        if not g["summary"]:
            g["summary"] = (r.get("resumen") or m["subject"]).strip()
    ordered = sorted(groups.values(), key=lambda g: (CATEGORIES.index(g["cat"]), -g["count"]))
    lines = []
    for g in ordered:
        label = g["sender"]
        if g["cat"] in ("urgente", "importante"):
            label = "%s: %s" % (g["sender"], g["summary"])
        lines.append((g["cat"], "- %d [%s] %s" % (g["count"], g["cat"], label)))
    return lines


def notify(title, body, urgency="normal", replace=None):
    cmd = ["notify-send", "-a", "Correo", "-i", "mail-unread", "-u", urgency, "-p"]
    if replace:
        cmd += ["-r", replace]
    out = subprocess.run(cmd + [title, body], capture_output=True, text=True)
    return out.stdout.strip() or replace


def main():
    parser = argparse.ArgumentParser(prog="mail-digest")
    parser.add_argument("--stdout", action="store_true")
    args = parser.parse_args()

    lock = open(os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "mail-digest.lock"), "w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        return 0

    nid = None if args.stdout else notify("Correo", "Leyendo correos de hoy…", "low")

    mails, errors = [], []
    for account in CONFIG["accounts"]:
        try:
            mails += fetch(account)
        except Exception as e:
            errors.append("%s: %s" % (account["name"], e))

    lines = []
    if mails:
        try:
            if nid:
                notify("Correo", "Clasificando %d correos…" % len(mails), "low", nid)
            lines = digest(mails, classify(mails))
        except Exception as e:
            errors.append("ollama: %s" % e)
            lines = [("normal", "- %d correos sin clasificar" % len(mails))]

    title = "Correos de hoy · %d" % len(mails)
    if args.stdout:
        print(title)
        for _, line in lines:
            print(line)
        for e in errors:
            print("! " + e)
        return 0

    shown = lines[:MAX_LINES]
    body = []
    for cat, line in shown:
        text = html.escape(line)
        body.append("<b>%s</b>" % text if cat == "urgente" else text)
    if len(lines) > MAX_LINES:
        body.append("… y %d grupos más" % (len(lines) - MAX_LINES))
    if not mails and not errors:
        body.append("Nada nuevo hoy")
    body += ["⚠ " + html.escape(e) for e in errors]
    urgent = any(cat == "urgente" for cat, _ in lines)
    notify(title, "\n".join(body), "critical" if urgent else "normal", nid)
    return 0


if __name__ == "__main__":
    sys.exit(main())
