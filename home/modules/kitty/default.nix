{ config, lib, pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    settings = {
      background_opacity = "0.92";
      window_padding_width = 10;
      confirm_os_window_close = 0;
      cursor_shape = "beam";
      cursor_blink_interval = "0.5";
      scrollback_lines = 10000;
      url_style = "curly";
      open_url_with = "default";
      detect_urls = "yes";
      enable_audio_bell = "no";
      visual_bell_duration = "0.0";
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";
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
      "ctrl+shift+backspace" = "change_font_size 0";
    };
  };

  catppuccin.kitty.enable = true;
}
