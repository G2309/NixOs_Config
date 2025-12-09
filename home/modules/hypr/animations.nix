{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    animations = {
      enabled = true;

      bezier = [
        "myBezier, 0.05, 0.9, 0.1, 1.05"
        "linear, 0.0, 0.0, 1.0, 1.0"
        "easeInOut, 0.42, 0, 0.58, 1"
        "easeOut, 0, 0, 0.58, 1"
        "easeIn, 0.42, 0, 1, 1"
        "overshot, 0.05, 0.9, 0.1, 1.1"
      ];

      animation = [
        "windows, 1, 7, myBezier"
        "windowsIn, 1, 5, easeOut, slide"
        "windowsOut, 1, 7, default, slide 80%"
        "windowsMove, 1, 5, easeInOut"
        "border, 1, 10, default"
        "borderangle, 1, 5, default, once"
        "fade, 1, 7, default"
        "fadeIn, 1, 5, easeOut"
        "fadeOut, 1, 5, easeIn"
        "fadeDim, 1, 5, easeInOut"
        "workspaces, 1, 7, default, fade"
        "specialWorkspace, 1, 5, easeOut, slidevert"
      ];
    };
  };
}
