{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lutris
    wine
    winetricks
  ];
}
