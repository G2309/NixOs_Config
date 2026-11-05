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
    ../modules/gaming
    ../modules/spotify
    ../modules/neovim
    ../modules/sunshine
    ../modules/dunst
    ../modules/gdrive
    ../modules/quickshell
    ../modules/calendar
    ../modules/monitor
    ../modules/kdeconnect
    ../modules/mail
    ../modules/voice
  ];

  wayland.windowManager.hyprland.settings.monitor = lib.mkForce [
    "DP-2,2560x1440@180,0x0,1"
    "HDMI-A-2,1024x768@75,-1024x0,1"
  ];

  wayland.windowManager.sway.config.output = {
    "DP-2" = {
      mode = "2560x1440@180Hz";
      position = "0 0";
      scale = "1";
      adaptive_sync = "on";
      bg = "${wallpaper} fill";
    };

    "HDMI-A-2" = {
      mode = "1024x768@75Hz";
      position = "-1024 0";
      scale = "1";
      adaptive_sync = "off";
      bg = "${wallpaper} fill";
    };
  };

  xdg.configFile."xdg-desktop-portal-wlr/config".text = ''
    [screencast]
    output_name=DP-2
    chooser_type=none
    max_fps=30
  '';

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
