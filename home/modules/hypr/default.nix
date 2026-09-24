{ config, lib, pkgs, ... }:

{
  imports = [
    ./settings.nix
    ./binds.nix
    ./rules.nix
    ./animations.nix
    ./autostart.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    configType = "hyprlang";
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ~/Pictures/Wallpaper/1.png
    wallpaper = ,~/Pictures/Wallpaper/1.png
  '';
}
