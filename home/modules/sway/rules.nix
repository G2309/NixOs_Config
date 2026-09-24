{ config, lib, pkgs, ... }:

{
  wayland.windowManager.sway.config = {
    floating.criteria = [
      { app_id = "^pavucontrol$"; }
      { class = "^Pavucontrol$"; }
      { app_id = "^blueman-manager$"; }
      { class = "^Blueman-manager$"; }
      { app_id = "^nm-connection-editor$"; }
      { class = "^Nm-connection-editor$"; }
      { app_id = "^file-roller$"; }
      { class = "^File-roller$"; }
      { class = "^Rofi$"; }
      { title = "^Picture-in-Picture$"; }
      { title = "^Volume Control$"; }
      { title = "^Open File$"; }
      { title = "^Save File$"; }
      { title = "^Firefox — Sharing Indicator$"; }
      { window_role = "^(pop-up|bubble|dialog)$"; }
    ];

    window.commands = [
      {
        criteria.app_id = "^pavucontrol$";
        command = "resize set 800 600, move position center";
      }
      {
        criteria.class = "^Pavucontrol$";
        command = "resize set 800 600, move position center";
      }
      {
        criteria.class = "^Rofi$";
        command = "move position center";
      }
      {
        criteria.title = "^Picture-in-Picture$";
        command = "sticky enable";
      }
    ];
  };
}
