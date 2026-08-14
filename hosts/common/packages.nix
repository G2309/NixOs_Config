{ pkgs, inputs, ... }:

{
  # Paquetes de sistema (NixOS) compartidos entre todos los hosts.
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
    app2unit
    fish
  ];

  # Paquetes de home-manager compartidos entre todos los hosts.
  home-manager.users.gustavo.home.packages = with pkgs; [
    firefox
    mpv
    imv
    fastfetch
    btop
    hyprpaper
    swaylock-effects
    ranger
    vesktop
    inputs.anicli-es.packages.x86_64-linux.default
    networkmanagerapplet
    quickshell
    lsof
    pavucontrol
  ];
}
