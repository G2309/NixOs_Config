import email
import html
import json
import os
import re
import sys
import urllib.request
from email import policy

PROMPT = """Resume en espanol este correo en 3 a 5 vinetas cortas.
Al final agrega una linea "Accion:" diciendo si requiere que yo haga algo y para cuando, o "Accion: ninguna".

De: {sender}
Asunto: {subject}

{body}
"""


def extract(msg):
    part = msg.get_body(preferencelist=("plain", "html"))
    if part is None:
        return ""
    try:
        text = part.get_content()
    except Exception:
        return ""
    if part.get_content_type() == "text/html":
        text = re.sub(r"(?is)<(script|style).*?</\1>", " ", text)
        text = re.sub(r"(?s)<[^>]+>", " ", text)
        text = html.unescape(text)
    return re.sub(r"\s+", " ", text).strip()[:12000]


def main():
    msg = email.message_from_bytes(sys.stdin.buffer.read(), policy=policy.default)
    body = extract(msg)
    if not body:
        print("No encontre texto en este correo.")
        return 1
    prompt = PROMPT.format(sender=msg.get("From", ""), subject=msg.get("Subject", ""), body=body)
    req = urllib.request.Request(
        os.environ["OLLAMA_URL"] + "/api/chat",
        data=json.dumps({
            "model": os.environ["OLLAMA_MODEL"],
            "messages": [{"role": "user", "content": prompt}],
            "stream": True,
            "think": False,
            "keep_alive": "2m",
            "options": {"temperature": 0.2, "num_ctx": 8192},
        }).encode(),
        headers={"Content-Type": "application/json"},
    )
    print("Resumen (%s)\n" % os.environ["OLLAMA_MODEL"])
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            for line in r:
                chunk = json.loads(line)
                sys.stdout.write(chunk.get("message", {}).get("content", ""))
                sys.stdout.flush()
    except Exception as e:
        print("\nError con ollama: %s" % e)
        return 1
    print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
