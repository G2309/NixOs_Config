{ pkgs, ... }:
let
  change-wallpaper = pkgs.writeShellScriptBin "change-wallpaper" ''
    #!/usr/bin/env bash
    DIR="$HOME/Pictures/Wallpaper"
    STATE_FILE="$HOME/.cache/current_wallpaper_idx"
    
    PICS=("$DIR"/*.png)
    TOTAL=''${#PICS[@]}

    if [ -f "$STATE_FILE" ]; then
        IDX=$(cat "$STATE_FILE")
        IDX=$(( (IDX + 1) % TOTAL ))
    else
        IDX=0
    fi

    NEXT_WP="''${PICS[$IDX]}"
    echo "$IDX" > "$STATE_FILE"

    hyprctl hyprpaper preload "$NEXT_WP"
    
    hyprctl hyprpaper wallpaper ",$NEXT_WP"
    
    hyprctl hyprpaper unload all
    hyprctl hyprpaper preload "$NEXT_WP"
  '';
in
{
  home.packages = [ change-wallpaper ];
}
