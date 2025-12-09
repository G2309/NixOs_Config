{ config, lib, pkgs, inputs, hostname, ... }:

{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    ./profiles/${hostname}.nix
  ];

  home = {
    username = "gustavo";
    homeDirectory = "/home/gustavo";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "mauve";
  };

  home.packages = with pkgs; [
    firefox
    mpv
    imv
    fastfetch
    btop
    hyprpaper
    swaylock-effects
    wlogout
    waybar
    libnotify
    dunst
    neovim
  ];

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.catppuccin-cursors.macchiatoMauve;
    name = "catppuccin-macchiato-mauve-cursors";
    size = 24;
  };

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-macchiato-mauve-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "macchiato";
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };
}
