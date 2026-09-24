{ config, lib, pkgs, ... }:

{
  imports = [
    ./settings.nix
    ./binds.nix
    ./rules.nix
    ./autostart.nix
    ./scripts.nix
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
}
