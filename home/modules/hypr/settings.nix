# home/modules/hypr/settings.nix
{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Catppuccin Macchiato
    "$rosewater" = "rgb(f4dbd6)";
    "$flamingo" = "rgb(f0c6c6)";
    "$pink" = "rgb(f5bde6)";
    "$mauve" = "rgb(c6a0f6)";
    "$red" = "rgb(ed8796)";
    "$maroon" = "rgb(ee99a0)";
    "$peach" = "rgb(f5a97f)";
    "$yellow" = "rgb(eed49f)";
    "$green" = "rgb(a6da95)";
    "$teal" = "rgb(8bd5ca)";
    "$sky" = "rgb(91d7e3)";
    "$sapphire" = "rgb(7dc4e4)";
    "$blue" = "rgb(8aadf4)";
    "$lavender" = "rgb(b7bdf8)";
    "$text" = "rgb(cad3f5)";
    "$subtext1" = "rgb(b8c0e0)";
    "$subtext0" = "rgb(a5adcb)";
    "$overlay2" = "rgb(939ab7)";
    "$overlay1" = "rgb(8087a2)";
    "$overlay0" = "rgb(6e738d)";
    "$surface2" = "rgb(5b6078)";
    "$surface1" = "rgb(494d64)";
    "$surface0" = "rgb(363a4f)";
    "$base" = "rgb(24273a)";
    "$mantle" = "rgb(1e2030)";
    "$crust" = "rgb(181926)";

    "$terminal" = "kitty";
    "$fileManager" = "dolphin";
    "$menu" = "rofi -show drun";
    "$editor" = "nvim";
    "$mainMod" = "SUPER";

    monitor = [
      ",preferred,auto,1"
    ];

    general = {
      gaps_in = 2;
      gaps_out = 5;
      border_size = 2;
      "col.active_border" = "$mauve $maroon 45deg";
      "col.inactive_border" = "$surface0";
      resize_on_border = false;
      allow_tearing = false;
      layout = "dwindle";
    };

    decoration = {
      active_opacity = 1.0;
      inactive_opacity = 0.9;
      blur = {
        enabled = true;
        size = 3;
        passes = 1;
        vibrancy = 0.1696;
        new_optimizations = true;
      };
      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
        color = "$crust";
      };
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
      force_split = 2;
    };

    master = {
      new_status = "master";
    };

    misc = {
      disable_splash_rendering = true;
      disable_hyprland_logo = true;
      force_default_wallpaper = 0;
      vfr = true;
    };

    experimental = {
      xx_color_management_v4 = true;
    };

    input = {
      kb_layout = "us,es";
      kb_options = "grp:win_space_toggle";
      follow_mouse = 1;
      sensitivity = 0;
      touchpad = {
        natural_scroll = false;
        tap-to-click = true;
        drag_lock = true;
      };
    };

    cursor = {
      no_hardware_cursors = true;
    };

    env = [
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"
    ];
  };
}
