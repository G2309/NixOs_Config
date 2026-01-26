{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/kitty
    ../modules/hypr
    ../modules/rofi
    ../modules/zsh
    ../modules/ranger
    ../modules/dunst
    ../modules/gaming
    ../modules/spotify
    ../modules/neovim
    ../modules/sunshine
  ];

  wayland.windowManager.hyprland.settings.monitor = lib.mkForce [
    "DP-2,2560x1440@120,0x0,1,vrr,2"
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
  

  home.packages = with pkgs; [
    nvtopPackages.nvidia
    qemu_kvm
  ];

}
