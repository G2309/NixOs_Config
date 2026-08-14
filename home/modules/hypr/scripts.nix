{ pkgs, ... }:
let
  change-wallpaper = pkgs.writeShellScriptBin "change-wallpaper" ''
    DIR="$HOME/Pictures/Wallpaper"
    STATE_FILE="$HOME/.cache/current_wallpaper_idx"

    mapfile -t PICS < <(find "$DIR" -maxdepth 1 -name "*.png" | sort -V)
    TOTAL="''${#PICS[@]}"

    if [ "$TOTAL" -eq 0 ]; then
      echo "No wallpapers in $DIR"
      exit 1
    fi

    if [ -f "$STATE_FILE" ]; then
      IDX=$(cat "$STATE_FILE")
      IDX=$(( (IDX + 1) % TOTAL ))
    else
      IDX=0
    fi

    NEXT_WP="''${PICS[$IDX]}"
    echo "$IDX" > "$STATE_FILE"

    hyprctl hyprpaper preload "$NEXT_WP"
    hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[].name' | while read -r monitor; do
      hyprctl hyprpaper wallpaper "$monitor,$NEXT_WP"
    done
    sleep 0.5
    hyprctl hyprpaper unload unused
  '';

  # quickshell runs as a wrapped binary (.quickshell-wrapped under the hood),
  # so pgrep/pkill must match on the substring rather than -x the exact
  # "quickshell" name, or they'd never find the running process.
  toggle-quickshell = pkgs.writeShellScriptBin "toggle-quickshell" ''
    if ${pkgs.procps}/bin/pgrep quickshell > /dev/null; then
      ${pkgs.procps}/bin/pkill quickshell
    else
      ${pkgs.quickshell}/bin/quickshell &
      disown
    fi
  '';

in
{
  home.packages = [ change-wallpaper toggle-quickshell pkgs.jq ];
}
