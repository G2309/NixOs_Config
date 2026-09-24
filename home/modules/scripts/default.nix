{ pkgs, ... }:
let
  change-wallpaper = pkgs.writeShellScriptBin "change-wallpaper" ''
    set -u

    DIR="$HOME/Pictures/Wallpaper"
    STATE_FILE="$HOME/.cache/current_wallpaper_idx"

    mapfile -t PICS < <(find "$DIR" -maxdepth 1 -name "*.png" | sort -V)
    TOTAL="''${#PICS[@]}"

    if [ "$TOTAL" -eq 0 ]; then
      echo "No wallpapers in $DIR"
      exit 1
    fi

    if [ "''${1:-}" = "--restore" ]; then
      IDX=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
      case "$IDX" in
        ""|*[!0-9]*) IDX=0 ;;
      esac
      if [ "$IDX" -ge "$TOTAL" ]; then IDX=0; fi
    elif [ -f "$STATE_FILE" ]; then
      IDX=$(cat "$STATE_FILE")
      IDX=$(( (IDX + 1) % TOTAL ))
    else
      IDX=0
    fi

    NEXT_WP="''${PICS[$IDX]}"
    echo "$IDX" > "$STATE_FILE"

    if [ -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
      hyprctl hyprpaper preload "$NEXT_WP"
      hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[].name' | while read -r monitor; do
        hyprctl hyprpaper wallpaper "$monitor,$NEXT_WP"
      done
      sleep 0.5
      hyprctl hyprpaper unload unused
    elif [ -n "''${SWAYSOCK:-}" ]; then
      swaymsg output '*' bg "$NEXT_WP" fill
    else
      echo "change-wallpaper: no se detecto ni Hyprland ni Sway" >&2
      exit 1
    fi
  '';

  toggle-quickshell = pkgs.writeShellScriptBin "toggle-quickshell" ''
    if ${pkgs.procps}/bin/pgrep quickshell > /dev/null; then
      ${pkgs.procps}/bin/pkill quickshell
    else
      ${pkgs.quickshell}/bin/quickshell &
      disown
    fi
  '';

  screenshot-full = pkgs.writeShellScriptBin "screenshot-full" ''
    set -eu
    OUT="$HOME/Pictures/Screenshots"
    mkdir -p "$OUT"
    FILE="$OUT/$(date +%Y-%m-%d_%H-%M-%S).png"
    ${pkgs.grim}/bin/grim "$FILE"
    ${pkgs.libnotify}/bin/notify-send "Captura" "Guardada en $FILE" || true
  '';

  screenshot-area = pkgs.writeShellScriptBin "screenshot-area" ''
    set -eu
    GEOM=$(${pkgs.slurp}/bin/slurp) || exit 0
    ${pkgs.grim}/bin/grim -g "$GEOM" - | ${pkgs.wl-clipboard}/bin/wl-copy
    ${pkgs.libnotify}/bin/notify-send "Captura" "Region copiada al portapapeles" || true
  '';
in
{
  home.packages = [
    change-wallpaper
    toggle-quickshell
    screenshot-full
    screenshot-area
    pkgs.jq
  ];
}
