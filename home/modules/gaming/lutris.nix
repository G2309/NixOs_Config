{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (lutris.override { })
    wineWow64Packages.staging
    winetricks
  ];
}
