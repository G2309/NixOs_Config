{ pkgs, inputs, ... }:
let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
      cudaSupport = true;
    };
  };

  llamaCpp = unstable.llama-cpp;

  revision = "3d29af2ad166f8299c2d820937e47dc0add20ffc";

  hf = file: hash: pkgs.fetchurl {
    url = "https://huggingface.co/LiquidAI/LFM3-Omni-2B-GGUF/resolve/${revision}/${file}";
    inherit hash;
  };

  model = hf "LFM3-Omni-2B-Q8_0.gguf" "sha256-WRGPZh6qy5PSBHI9djVbUzR/CUC1CMEUEvYpD9SRWNQ=";
  mmproj = hf "mmproj-LFM3-Omni-2B-Q8_0.gguf" "sha256-iiX50ZMSREKd5AT8ys+3+5M5cKNqpWiNL1Bp8pxrJ7E=";

  decir = pkgs.writeShellScriptBin "decir" ''
    set -u
    if [ "$#" -gt 0 ]; then
      TEXT="$*"
    else
      TEXT=$(${pkgs.coreutils}/bin/cat)
    fi
    if [ -z "$TEXT" ]; then
      echo "uso: decir <texto>  (o por stdin)" >&2
      exit 1
    fi
    RUN="''${XDG_RUNTIME_DIR:-/tmp}"
    exec 9>"$RUN/decir.lock"
    ${pkgs.util-linux}/bin/flock 9
    OUT=$(${pkgs.coreutils}/bin/mktemp -p "$RUN" decir.XXXXXX.wav)
    trap '${pkgs.coreutils}/bin/rm -f "$OUT"' EXIT
    if ! ${llamaCpp}/bin/llama-tts -m ${model} -mm ${mmproj} -ngl 99 \
      --tts-lang es --tts-voice female -p "$TEXT" -o "$OUT" >/dev/null 2>&1; then
      ${pkgs.libnotify}/bin/notify-send -a Voz "Voz" "No se pudo generar el audio" || true
      exit 1
    fi
    ${pkgs.pipewire}/bin/pw-play "$OUT"
  '';
  voz-asistente = pkgs.writeShellScriptBin "voz-asistente" ''
    set -u
    export PATH=${pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.gnused pkgs.gnugrep pkgs.jq pkgs.curl pkgs.libnotify pkgs.pipewire pkgs.procps ]}:$PATH
    DIR="''${XDG_RUNTIME_DIR:-/tmp}/voz-asistente"
    mkdir -p "$DIR"
    PIDF="$DIR/rec.pid"
    WAV="$DIR/entrada.wav"
    NIDF="$DIR/nid"

    say() {
      notify-send -a Voz -r "$(cat "$NIDF" 2>/dev/null || echo 0)" "$1" "$2" || true
    }

    case "''${1:-}" in
      start)
        if [ -f "$PIDF" ] && kill -0 "$(cat "$PIDF")" 2>/dev/null; then
          exit 0
        fi
        rm -f "$WAV"
        pw-record --rate 16000 --channels 1 --format s16 "$WAV" &
        echo $! > "$PIDF"
        notify-send -a Voz -p -u low "Voz" "Escuchando…" > "$NIDF" || true
        ;;
      stop)
        [ -f "$PIDF" ] || exit 0
        PID=$(cat "$PIDF")
        rm -f "$PIDF"
        kill -INT "$PID" 2>/dev/null || true
        while kill -0 "$PID" 2>/dev/null; do sleep 0.05; done
        if [ "$(stat -c %s "$WAV" 2>/dev/null || echo 0)" -lt 16000 ]; then
          say "Voz" "Muy corto, manten Super+a mientras hablas"
          exit 0
        fi
        say "Voz" "Entendiendo…"
        TEXT=$(${llamaCpp}/bin/llama-mtmd-cli -m ${model} --mmproj ${mmproj} -ngl 99 \
          --audio "$WAV" -sys "Perform ASR in Spanish." -p "<__media__>" --temp 0 2>/dev/null \
          | tr '\n' ' ' | sed -e 's/<think>.*<\/think>//' -e 's/^ *//' -e 's/ *$//')
        if [ -z "$TEXT" ]; then
          say "Voz" "No te entendi"
          ${decir}/bin/decir "No te entendí"
          exit 0
        fi
        say "Tú" "$TEXT"
        if printf '%s' "$TEXT" | grep -qiE 'correo|email|e-mail|mail|bandeja'; then
          mail-digest --pregunta "$TEXT" --voz
          exit 0
        fi
        ANS=$(jq -n --arg q "$TEXT" '{
            model: "qwen3.5:4b", stream: false, think: false, keep_alive: "2m",
            options: { temperature: 0.3, num_ctx: 8192 },
            messages: [
              { role: "system", content: "Eres un asistente de voz en una computadora con Linux. Responde en espanol en maximo 3 frases cortas, sin listas, sin markdown y sin emojis, porque tu respuesta se lee en voz alta." },
              { role: "user", content: $q }
            ]
          }' | curl -s --max-time 180 http://127.0.0.1:11434/api/chat -d @- | jq -r '.message.content // empty' | sed 's/[*_`#]//g')
        if [ -z "$ANS" ]; then
          ANS="No pude obtener respuesta del modelo."
        fi
        say "Respuesta" "$ANS"
        ${decir}/bin/decir "$ANS"
        ;;
      *)
        echo "uso: voz-asistente start|stop" >&2
        exit 1
        ;;
    esac
  '';
in
{
  home.packages = [
    decir
    voz-asistente
    llamaCpp
  ];

  wayland.windowManager.sway.extraConfig = ''
    bindsym --no-repeat Mod4+a exec voz-asistente start
    bindsym --release Mod4+a exec voz-asistente stop
  '';
}
