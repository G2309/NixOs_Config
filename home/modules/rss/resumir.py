import html
import json
import os
import re
import subprocess
import sys
import urllib.request

PROMPT = """Resume en espanol el siguiente contenido en 4 a 6 vinetas cortas.
Empieza con una linea que diga de que trata en una frase.

{texto}
"""


def limpiar_html(texto):
    texto = re.sub(r"(?is)<(script|style|nav|header|footer|aside|form|noscript).*?</\1>", " ", texto)
    texto = re.sub(r"(?s)<[^>]+>", " ", texto)
    return html.unescape(texto)


def leer(origen):
    if origen in ("", "-"):
        return sys.stdin.read()
    if re.match(r"https?://", origen):
        req = urllib.request.Request(origen, headers={"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) resumir"})
        with urllib.request.urlopen(req, timeout=30) as r:
            crudo = r.read().decode(r.headers.get_content_charset() or "utf-8", "replace")
        return limpiar_html(crudo)
    if origen.lower().endswith(".pdf"):
        return subprocess.run(["pdftotext", "-layout", origen, "-"], capture_output=True, text=True, check=True).stdout
    with open(origen, encoding="utf-8", errors="replace") as f:
        texto = f.read()
    return limpiar_html(texto) if origen.lower().endswith((".html", ".htm")) else texto


def main():
    args = [a for a in sys.argv[1:] if a != "--pausa"]
    pausa = "--pausa" in sys.argv[1:]
    origen = args[0] if args else "-"
    try:
        texto = re.sub(r"\s+", " ", leer(origen)).strip()[:20000]
    except Exception as e:
        print("No pude leer %s: %s" % (origen, e))
        texto = ""
    if texto:
        body = json.dumps({
            "model": os.environ["OLLAMA_MODEL"],
            "messages": [{"role": "user", "content": PROMPT.format(texto=texto)}],
            "stream": True,
            "think": False,
            "keep_alive": "2m",
            "options": {"temperature": 0.2, "num_ctx": 16384},
        }).encode()
        req = urllib.request.Request(os.environ["OLLAMA_URL"] + "/api/chat", data=body, headers={"Content-Type": "application/json"})
        print("Resumen (%s)\n" % os.environ["OLLAMA_MODEL"])
        try:
            with urllib.request.urlopen(req, timeout=300) as r:
                for linea in r:
                    sys.stdout.write(json.loads(linea).get("message", {}).get("content", ""))
                    sys.stdout.flush()
            print()
        except Exception as e:
            print("\nError con ollama: %s" % e)
    if pausa:
        input("\nEnter para volver...")
    return 0


if __name__ == "__main__":
    sys.exit(main())
