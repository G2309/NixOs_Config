{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/kitty
    ../modules/hypr
    ../modules/rofi
    ../modules/zsh
    ../modules/ranger
    ../modules/gaming
    ../modules/spotify
    ../modules/neovim
    ../modules/sunshine
    ../modules/dunst
    ../modules/gdrive
    ../modules/quickshell
  ];

  wayland.windowManager.hyprland.settings.monitor = lib.mkForce [
    "DP-2,2560x1440@120,0x0,1"
    "HDMI-A-2,1024x768@75,-1024x0,1"
  ];

  home.file.".config/hypr/hyprpaper.conf".text = lib.mkForce ''
  wallpaper {
    monitor = DP-2
    path = /home/gustavo/Pictures/Wallpaper/1.png
    fit_mode = cover
  }
  
  wallpaper {
    monitor =
    path = /home/gustavo/Pictures/Wallpaper/1.png
    fit_mode = cover
  }
  '';
}
