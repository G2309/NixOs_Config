{ pkgs, ... }:

let
  revisar-modelos-go = pkgs.writeShellScriptBin "revisar-modelos-go" ''
    set -u
    export PATH=${pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.gnugrep pkgs.gnused ]}:$PATH
    STATE="''${XDG_STATE_HOME:-$HOME/.local/state}/opencode-go"
    LISTA="$STATE/modelos.txt"
    mkdir -p "$STATE"

    nuevos=$(${pkgs.curl}/bin/curl -sf --max-time 30 https://opencode.ai/inference/go/v1/models \
      | ${pkgs.jq}/bin/jq -r '.data[].id' 2>/dev/null | sort)
    [ -n "$nuevos" ] || exit 0

    if [ ! -f "$LISTA" ]; then
      printf '%s\n' "$nuevos" > "$LISTA"
      exit 0
    fi

    entraron=$(comm -13 "$LISTA" <(printf '%s\n' "$nuevos") | paste -sd ',' | sed 's/,/, /g')
    salieron=$(comm -23 "$LISTA" <(printf '%s\n' "$nuevos"))
    [ -n "$entraron$salieron" ] || exit 0

    usados=$(grep -rhoE 'opencode-go/[A-Za-z0-9._-]+' "$HOME/.config/opencode/opencode.json" "$HOME/.config/opencode/agents" 2>/dev/null \
      | sed 's|opencode-go/||' | sort -u)
    afectados=$(comm -12 <(printf '%s\n' "$salieron" | sed '/^$/d') <(printf '%s\n' "$usados") | paste -sd ',' | sed 's/,/, /g')
    salieron=$(printf '%s\n' "$salieron" | paste -sd ',' | sed 's/,/, /g')

    cuerpo=""
    [ -n "$entraron" ] && cuerpo="Nuevos: $entraron"
    [ -n "$salieron" ] && cuerpo="''${cuerpo:+$cuerpo
}Retirados: $salieron"
    urgencia=normal
    if [ -n "$afectados" ]; then
      cuerpo="$cuerpo
Tus agentes usan modelos retirados: $afectados"
      urgencia=critical
    fi
    ${pkgs.libnotify}/bin/notify-send -a OpenCode -u "$urgencia" "Cambió la lista de OpenCode Go" "$cuerpo
Corre /reevaluar en opencode." || true
    printf '%s\n' "$nuevos" > "$LISTA"
  '';
in
{
  home.packages = [ revisar-modelos-go ];

  systemd.user.services.revisar-modelos-go = {
    Unit.Description = "Detecta modelos nuevos o retirados en OpenCode Go";
    Service = {
      Type = "oneshot";
      ExecStart = "${revisar-modelos-go}/bin/revisar-modelos-go";
    };
  };
  systemd.user.timers.revisar-modelos-go = {
    Unit.Description = "Revision semanal de la lista de modelos de OpenCode Go";
    Timer = {
      OnCalendar = "Mon 10:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  xdg.configFile = {
    "opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      model = "opencode-go/hy3";
      small_model = "opencode-go/hy4-flash-free";
      permission = {
        bash = {
          "*" = "allow";
          "git commit*" = "deny";
          "git push*" = "deny";
          "sudo *" = "deny";
        };
        read = {
          "*" = "allow";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.env.example" = "allow";
        };
        "playwright_*" = "deny";
      };
      mcp = {
        context7 = {
          type = "remote";
          url = "https://mcp.context7.com/mcp";
          enabled = true;
        };
        memory = {
          type = "local";
          command = [ "npx" "-y" "@modelcontextprotocol/server-memory" ];
          environment.MEMORY_FILE_PATH = "/home/gustavo/.local/share/mcp-memory/memory.jsonl";
          enabled = true;
        };
        fetch = {
          type = "local";
          command = [ "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch" ];
          enabled = true;
        };
        nixos = {
          type = "local";
          command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
          enabled = true;
        };
        playwright = {
          type = "local";
          command = [ "${pkgs.playwright-mcp}/bin/playwright-mcp" "--headless" ];
          enabled = true;
        };
        railway = {
          type = "remote";
          url = "https://mcp.railway.com";
          enabled = true;
        };
      };
    };
    "opencode/AGENTS.md".source = ./AGENTS.md;
    "opencode/agents" = {
      source = ./agents;
      recursive = true;
    };
    "opencode/commands" = {
      source = ./commands;
      recursive = true;
    };
  };
}
