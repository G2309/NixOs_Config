{ config, lib, pkgs, ... }:
let
  mauve = "#c6a0f6";
  red = "#ed8796";
  text = "#cad3f5";
  subtext0 = "#a5adcb";
  surface0 = "#363a4f";
  base = "#24273a";
  crust = "#181926";
  lavender = "#b7bdf8";
in
{
  wayland.windowManager.sway.config = {
    modifier = "Mod4";
    terminal = "kitty";
    menu = "rofi -show drun";

    left = "h";
    down = "j";
    up = "k";
    right = "l";

    fonts = {
      names = [ "FiraCode Nerd Font" ];
      size = 10.0;
    };

    gaps = {
      inner = 4;
      outer = 3;
      smartBorders = "on";
    };

    window = {
      titlebar = false;
      border = 2;
      hideEdgeBorders = "none";
    };

    floating = {
      titlebar = false;
      border = 2;
      modifier = "Mod4";
    };

    focus = {
      followMouse = true;
      newWindow = "smart";
    };

    colors = {
      background = base;

      focused = {
        border = mauve;
        background = mauve;
        childBorder = mauve;
        text = crust;
        indicator = lavender;
      };

      focusedInactive = {
        border = surface0;
        background = surface0;
        childBorder = surface0;
        text = text;
        indicator = surface0;
      };

      unfocused = {
        border = crust;
        background = crust;
        childBorder = crust;
        text = subtext0;
        indicator = crust;
      };

      urgent = {
        border = red;
        background = red;
        childBorder = red;
        text = crust;
        indicator = red;
      };

      placeholder = {
        border = crust;
        background = crust;
        childBorder = crust;
        text = text;
        indicator = crust;
      };
    };

    input = {
      "*" = {
        xkb_layout = "us,es";
        xkb_options = "grp:win_space_toggle";
      };

      "type:touchpad" = {
        natural_scroll = "disabled";
        tap = "enabled";
        drag_lock = "enabled";
        scroll_method = "two_finger";
      };

      "type:pointer" = {
        accel_profile = "flat";
        pointer_accel = "0";
      };
    };

    seat = {
      "*" = {
        xcursor_theme = "catppuccin-macchiato-mauve-cursors 18";
      };
    };

    bars = [ ];
    modes = { };
  };

  wayland.windowManager.sway.extraConfig = ''
    bindsym --whole-window --no-repeat Mod4+button4 workspace prev_on_output
    bindsym --whole-window --no-repeat Mod4+button5 workspace next_on_output
  '';
}
