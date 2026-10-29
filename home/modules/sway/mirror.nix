{ config, lib, pkgs, ... }:
let
  jq = "${pkgs.jq}/bin/jq";

  mirror-screen = pkgs.writeShellScriptBin "mirror-screen" ''
    set -u

    SOURCE="''${MIRROR_SOURCE:-eDP-1}"

    if ${pkgs.procps}/bin/pkill -x wl-mirror; then
      exit 0
    fi

    TARGET=$(swaymsg -r -t get_outputs | ${jq} -r --arg src "$SOURCE" \
      '[.[] | select(.active and .name != $src)][0].name // empty')

    if [ -z "$TARGET" ]; then
      ${pkgs.libnotify}/bin/notify-send "mirror-screen" "No hay otra pantalla conectada"
      exit 1
    fi

    exec ${pkgs.wl-mirror}/bin/wl-mirror --fullscreen --fullscreen-output "$TARGET" "$SOURCE"
  '';
in
{
  home.packages = [ mirror-screen ];
}
