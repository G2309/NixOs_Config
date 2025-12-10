{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/kitty
    ../modules/hypr
    ../modules/rofi
    ../modules/zsh
    ../modules/gaming
  ];

  wayland.windowManager.hyprland.settings.monitor = lib.mkForce [
    "DP-2,2560x1440@120,0x0,1,bitdepth,10"
  ];

  home.file.".config/hypr/hyprpaper.conf".text = lib.mkForce ''
    preload = ~/Pictures/Wallpaper/1.png
    wallpaper = DP-2,~/Pictures/Wallpaper/1.png
  '';

  home.packages = with pkgs; [
    nvtopPackages.nvidia
  ];
}
