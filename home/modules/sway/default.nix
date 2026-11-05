{ config, lib, pkgs, ... }:

{
  imports = [
    ./settings.nix
    ./binds.nix
    ./rules.nix
    ./autostart.nix
    ./scripts.nix
    ./mirror.nix
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = null;
    checkConfig = false;
    xwayland = true;

    systemd = {
      enable = true;
      dbusImplementation = "broker";
    };
  };

  xdg.configFile."sway/config".onChange = ''
    for sock in /run/user/$UID/sway-ipc.*.sock; do
      [ -S "$sock" ] && ${pkgs.sway}/bin/swaymsg -s "$sock" reload >/dev/null || true
    done
  '';
}
