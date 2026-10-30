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
      ${wallpaper-theme}/bin/wallpaper-theme "$NEXT_WP" || true
    else
      echo "change-wallpaper: no se detecto ni Hyprland ni Sway" >&2
      exit 1
    fi
  '';

  wallpaper-theme = pkgs.writeShellScriptBin "wallpaper-theme" ''
    set -u

    IMG="''${1:-}"
    if [ ! -f "$IMG" ]; then
      echo "uso: wallpaper-theme <imagen>" >&2
      exit 1
    fi

    DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-theme"
    mkdir -p "$DIR"

    if ! RAW=$(${pkgs.matugen}/bin/matugen image "$IMG" --mode dark --prefer saturation --dry-run --json hex 2>/dev/null); then
      echo "wallpaper-theme: matugen no pudo procesar $IMG" >&2
      exit 1
    fi

    THEME=$(printf '%s' "$RAW" | ${pkgs.jq}/bin/jq --arg img "$IMG" '.colors | with_entries(.value = .value.dark.color) | {
      mauve: .primary,
      lavender: .secondary,
      onAccent: .on_primary,
      crust: .surface_container_lowest,
      mantle: .surface_container_low,
      base: .surface,
      surface0: .surface_container,
      surface1: .surface_container_high,
      surface2: .surface_container_highest,
      overlay0: .outline,
      overlay1: .outline,
      overlay2: .on_surface_variant,
      text: .on_surface,
      subtext0: .on_surface_variant,
      subtext1: .on_surface_variant,
      red: .error,
      wallpaper: $img
    }')

    printf '%s\n' "$THEME" > "$DIR/colors.json"

    if [ -n "''${SWAYSOCK:-}" ]; then
      col() { printf '%s' "$THEME" | ${pkgs.jq}/bin/jq -r ".$1"; }
      A=$(col mauve); ONA=$(col onAccent); L=$(col lavender)
      S0=$(col surface0); CR=$(col crust); B=$(col base)
      T=$(col text); ST=$(col subtext0); R=$(col red)
      swaymsg -q "client.focused $A $A $ONA $L $A"
      swaymsg -q "client.focused_inactive $S0 $S0 $T $S0 $S0"
      swaymsg -q "client.unfocused $CR $CR $ST $CR $CR"
      swaymsg -q "client.urgent $R $R $CR $R $R"
      swaymsg -q "client.placeholder $CR $CR $T $CR $CR"
      swaymsg -q "client.background $B"
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
    wallpaper-theme
    toggle-quickshell
    screenshot-full
    screenshot-area
    pkgs.jq
  ];
}
