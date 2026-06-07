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

  # Super+Tab: para/inicia el servicio systemd de caelestia
  toggle-caelestia = pkgs.writeShellScriptBin "toggle-caelestia" ''
    if systemctl --user is-active --quiet caelestia.service; then
      systemctl --user stop caelestia.service
    else
      systemctl --user start caelestia.service
    fi
  '';

in
{
  home.packages = [ change-wallpaper toggle-caelestia pkgs.jq ];
}
