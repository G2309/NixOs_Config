{ config, lib, pkgs, ... }:

{
  wayland.windowManager.sway.config.startup = [
    { command = "change-wallpaper --restore"; always = true; }
    { command = "${pkgs.autotiling}/bin/autotiling"; }
    { command = "quickshell"; }
    { command = "bluetoothctl power on"; }
    { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
    { command = "openrgb -p purple"; }
    { command = "sway-refresh-daemon"; }
  ];
}
