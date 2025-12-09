{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      "suppressevent maximize, class:.*"
      "float, class:^(pavucontrol)$"
      "float, class:^(blueman-manager)$"
      "float, class:^(nm-connection-editor)$"
      "float, class:^(file-roller)$"
      "float, title:^(Picture-in-Picture)$"
      "float, title:^(Volume Control)$"
      "float, title:^(Open File)$"
      "float, title:^(Save File)$"
      "size 800 600, class:^(pavucontrol)$"
      "center, class:^(pavucontrol)$"
      "float, class:^(Rofi)$"
      "center, class:^(Rofi)$"
      "stayfocused, class:^(Rofi)$"
      "float, title:^(Firefox — Sharing Indicator)$"
      "opacity 0.95 0.85, class:^(kitty)$"
      "opacity 0.95 0.85, class:^(Alacritty)$"
    ];

    layerrule = [
      "blur, waybar"
      "blur, rofi"
      "blur, notifications"
      "ignorezero, waybar"
      "ignorezero, rofi"
    ];
  };
}
