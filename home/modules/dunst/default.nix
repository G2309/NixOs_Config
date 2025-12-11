{ pkgs, ... }:

{
  services.dunst = {
    enable = true;
    catppuccin.enable = true;

    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        width = 300;
        height = 300;
        origin = "top-right";
        offset = "10x10";
        notification_limit = 5;
        progress_bar = true;
        
        padding = 10;
        horizontal_padding = 10;
        text_icon_padding = 10;
        frame_width = 2;
        gap_size = 5;
        separator_height = 2;

        font = "JetBrainsMono Nerd Font 10";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;

        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 64;

        sticky_history = true;
        history_length = 20;

        browser = "firefox";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";

        corner_radius = 10;
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };

      urgency_low = {
        timeout = 5;
      };

      urgency_normal = {
        timeout = 10;
      };

      urgency_critical = {
        timeout = 0; 
      };
    };
  };

  home.packages = [ pkgs.libnotify ];
}
