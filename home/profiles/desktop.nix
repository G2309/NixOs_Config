{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/kitty
    ../modules/hypr
    ../modules/zsh
    ../modules/ranger
    ../modules/gaming
    ../modules/spotify
    ../modules/neovim
    ../modules/sunshine
    ../modules/caelestia
  ];

  wayland.windowManager.hyprland.settings.monitor = lib.mkForce [
    "DP-2,2560x1440@180,0x0,1"
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

  home.file.".config/caelestia/monitors/HDMI-A-2/shell.json".text = builtins.toJSON {
    bar.persistent = false;
  };

  home.packages = with pkgs; [
    nvtopPackages.nvidia
    qemu_kvm
    python3
  ];

}
