{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/kitty
    ../modules/hypr
    ../modules/rofi
    ../modules/zsh
    ../modules/ranger
    ../modules/dunst
    ../modules/neovim
  ];

  wayland.windowManager.hyprland.settings.monitor = lib.mkForce [
    ",1920x1080@60,auto,1"
  ];

  home.file.".config/hypr/hyprpaper.conf".text = lib.mkForce ''
    preload = ~/Pictures/Wallpaper/1.png
    wallpaper = ,~/Pictures/Wallpaper/1.png
  '';

  home.packages = with pkgs; [
    brightnessctl
  ];
}
