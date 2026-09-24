{ config, lib, pkgs, ... }:
let
  jq = "${pkgs.jq}/bin/jq";
  notify = "${pkgs.libnotify}/bin/notify-send";

  refresh-rate = pkgs.writeShellScriptBin "refresh-rate" ''
    set -u

    if [ -z "''${SWAYSOCK:-}" ]; then
      SWAYSOCK=$(find "/run/user/$(id -u)" -maxdepth 1 -name 'sway-ipc.*.sock' 2>/dev/null | head -n1)
      export SWAYSOCK
    fi

    if [ -z "''${SWAYSOCK:-}" ] || [ ! -S "$SWAYSOCK" ]; then
      echo "refresh-rate: sway no esta corriendo" >&2
      exit 1
    fi

    STATE_DIR="''${XDG_RUNTIME_DIR:-/tmp}"
    MODE_FILE="$STATE_DIR/refresh-rate.mode"
    GAMING_FILE="$STATE_DIR/refresh-rate.gaming"
    LOW_HZ="''${REFRESH_LOW_HZ:-60}"

    plan() {
      swaymsg -r -t get_outputs | ${jq} -r --arg want "$1" --argjson lowhz "$LOW_HZ" '
        .[]
        | select(.active and .current_mode != null)
        | . as $o
        | $o.current_mode as $cur
        | [ $o.modes[] | select(.width == $cur.width and .height == $cur.height) ] as $m
        | select(($m | length) > 0)
        | (if $want == "high" then
             ($m | max_by(.refresh))
           else
             (($lowhz * 1000) as $t
              | ([ $m[] | select(.refresh >= ($t - 500)) ]) as $ge
              | if ($ge | length) > 0 then ($ge | min_by(.refresh)) else ($m | max_by(.refresh)) end)
           end) as $sel
        | "\($o.name)\t\($sel.width)x\($sel.height)@\($sel.refresh / 1000)Hz\t\($cur.refresh)\t\($sel.refresh)"
      '
    }

    apply() {
      plan "$1" | while IFS=$'\t' read -r name mode cur sel; do
        if [ "$cur" != "$sel" ]; then
          swaymsg -q output "$name" mode "$mode" || true
        fi
      done
    }

    gaming() {
      if [ -e "$GAMING_FILE" ]; then
        return 0
      fi
      swaymsg -r -t get_tree | ${jq} -e '
        [ recurse(.nodes[]?, .floating_nodes[]?)
          | select(((.fullscreen_mode // 0) != 0) and (.visible // false)) ] | length > 0
      ' >/dev/null 2>&1
    }

    mode_now() {
      cat "$MODE_FILE" 2>/dev/null || echo auto
    }

    tick() {
      case "$(mode_now)" in
        high) apply high ;;
        low) apply low ;;
        *) if gaming; then apply high; else apply low; fi ;;
      esac
    }

    case "''${1:-tick}" in
      high)
        echo high > "$MODE_FILE"
        apply high
        ;;
      low)
        echo low > "$MODE_FILE"
        apply low
        ;;
      auto)
        echo auto > "$MODE_FILE"
        tick
        ;;
      tick)
        tick
        ;;
      toggle)
        case "$(mode_now)" in
          auto)
            echo high > "$MODE_FILE"
            apply high
            ${notify} -t 2000 "Refresco" "Fijo en el maximo" || true
            ;;
          high)
            echo low > "$MODE_FILE"
            apply low
            ${notify} -t 2000 "Refresco" "Fijo en ''${LOW_HZ}Hz" || true
            ;;
          *)
            echo auto > "$MODE_FILE"
            tick
            ${notify} -t 2000 "Refresco" "Automatico (sube solo al jugar)" || true
            ;;
        esac
        ;;
      status)
        echo "modo: $(mode_now)"
        swaymsg -r -t get_outputs | ${jq} -r '
          .[] | select(.active)
          | "\(.name)\t\(.current_mode.width)x\(.current_mode.height)@\(.current_mode.refresh / 1000)Hz\tvrr=\(.adaptive_sync_status)"'
        ;;
      *)
        echo "uso: refresh-rate [auto|low|high|toggle|tick|status]" >&2
        exit 1
        ;;
    esac
  '';

  sway-refresh-daemon = pkgs.writeShellScriptBin "sway-refresh-daemon" ''
    set -u

    RR="${refresh-rate}/bin/refresh-rate"

    "$RR" tick || true

    (
      while sleep 30; do
        "$RR" tick || true
      done
    ) &
    POLL_PID=$!
    trap 'kill "$POLL_PID" 2>/dev/null || true' EXIT

    swaymsg -t subscribe -m '["window","workspace"]' \
      | ${jq} --unbuffered -r '.change // "other"' \
      | while read -r change; do
          case "$change" in
            new|close|focus|move|floating|fullscreen_mode|init|empty|urgent|reload)
              "$RR" tick || true
              ;;
          esac
        done
  '';
in
{
  home.packages = [
    refresh-rate
    sway-refresh-daemon
    pkgs.autotiling
  ];
}
