{ config, lib, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    
    font = {
      name = "FiraCode Nerd Font";
      size = 10;
    };

    settings = {
      window_padding_width = 2;
      confirm_os_window_close = 0;
      cursor_shape = "beam";
      cursor_blink_interval = "0.5";
      scrollback_lines = 10000;
      enable_audio_bell = "no";
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
    };

    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "close_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+plus" = "change_font_size +1";
      "ctrl+shift+minus" = "change_font_size -1";
    };
  };

  catppuccin.kitty.enable = true;
}
