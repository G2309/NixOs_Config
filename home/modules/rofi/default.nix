{ config, lib, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    font = "FiraCode Nerd Font 14";
    
    plugins = [ pkgs.rofi-calc ];

    extraConfig = {
      modi = "drun,run,calc,filebrowser";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = " Apps";
      display-run = " Run";
      display-calc = " Calc";
      display-filebrowser = " Files";
      drun-display-format = "{icon} {name}";
      terminal = "kitty";
      matching = "fuzzy";
      sort = true;
      sorting-method = "fzf";
    };

    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg = mkLiteral "#191921";
        bg-alt = mkLiteral "#414161";
        fg = mkLiteral "#6677b3";
        fg-alt = mkLiteral "#5b6078";
        accent = mkLiteral "#c6a0f6";
        background-color = mkLiteral "@bg";
        text-color = mkLiteral "@fg";
      };

      window = {
        width = mkLiteral "50%";
        border = mkLiteral "2px solid";
        border-color = mkLiteral "@accent";
      };

      mainbox = {
        children = map mkLiteral [ "inputbar" "listview" ];
        padding = mkLiteral "15px";
      };

      inputbar = {
        children = map mkLiteral [ "prompt" "entry" ];
        background-color = mkLiteral "@bg";
      };

      prompt = {
        enabled = true;
        padding = mkLiteral "12px";
        background-color = mkLiteral "@bg-alt";
        text-color = mkLiteral "@fg";
        border-radius = mkLiteral "8px 0 0 8px";
      };

      entry = {
        padding = mkLiteral "12px";
        background-color = mkLiteral "@bg-alt";
        text-color = mkLiteral "@fg";
        placeholder = "Search...";
        border-radius = mkLiteral "0 8px 8px 0";
      };

      listview = {
        columns = 1;
        lines = 8;
        spacing = mkLiteral "5px";
        padding = mkLiteral "10px 0 0 0";
      };

      element = {
        padding = mkLiteral "10px";
        border-radius = mkLiteral "8px";
        text-color = mkLiteral "@fg-alt";
      };

      "element selected" = {
        background-color = mkLiteral "@bg-alt";
        text-color = mkLiteral "@accent";
      };

      element-icon = {
        size = mkLiteral "28px";
        padding = mkLiteral "0 10px 0 0";
      };

      element-text = {
        text-color = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
      };
    };
  };
}
