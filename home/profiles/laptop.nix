{ config, lib, pkgs, ... }:
let
  wallpaper = "${config.home.homeDirectory}/Pictures/Wallpaper/1.png";
in
{
  imports = [
    ../modules/kitty
    ../modules/hypr
    ../modules/sway
    ../modules/scripts
    ../modules/rofi
    ../modules/zsh
    ../modules/ranger
    ../modules/dunst
    ../modules/neovim
    ../modules/quickshell
  ];

  wayland.windowManager.hyprland.settings.monitor = lib.mkForce [
    ",1920x1080@60,auto,1"
  ];

  wayland.windowManager.sway.config.output = {
    "*" = {
      scale = "1";
      adaptive_sync = "off";
      bg = "${wallpaper} fill";
    };

    "eDP-1" = {
      mode = "1920x1080@60Hz";
      position = "0 0";
    };
  };

  home.file.".config/hypr/hyprpaper.conf".text = lib.mkForce ''
    preload = ~/Pictures/Wallpaper/1.png
    wallpaper = ,~/Pictures/Wallpaper/1.png
  '';
}
