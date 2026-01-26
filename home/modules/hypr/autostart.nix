{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "hyprpaper"
      "bluetoothctl power on"
      "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      "dunst"
      "openrgb -p purple"
    ];

    exec = [ ];
  };
}
