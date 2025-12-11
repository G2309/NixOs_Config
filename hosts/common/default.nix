{ config, lib, pkgs, inputs, hostname, ... }:

{
  imports = [
    ../../modules/nixos
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  time.timeZone = "America/Guatemala";
  
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "es_GT.UTF-8";
      LC_IDENTIFICATION = "es_GT.UTF-8";
      LC_MEASUREMENT = "es_GT.UTF-8";
      LC_MONETARY = "es_GT.UTF-8";
      LC_NAME = "es_GT.UTF-8";
      LC_NUMERIC = "es_GT.UTF-8";
      LC_PAPER = "es_GT.UTF-8";
      LC_TELEPHONE = "es_GT.UTF-8";
      LC_TIME = "es_GT.UTF-8";
    };
  };

  console.keyMap = "us";

  users.users.gustavo = {
    isNormalUser = true;
    description = "Gustavo";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell = pkgs.zsh;
  };
  
  programs.zsh.enable = true;

  security = {
    rtkit.enable = true;
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };
    polkit.enable = true;
  };

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    dbus.enable = true;
  };

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    unzip
    ripgrep
    fd
    tree
    wl-clipboard
    grim
    slurp
    polkit_gnome
    bat
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      fira-code
      nerd-fonts.fira-code
    ];
    fontconfig.defaultFonts = {
      monospace = [ "FiraCode Nerd Font" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };

  system.stateVersion = "25.05";
}
