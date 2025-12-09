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
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };

  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ~/Pictures/Wallpaper/1.png
    wallpaper = ,~/Pictures/Wallpaper/1.png
  '';
}
