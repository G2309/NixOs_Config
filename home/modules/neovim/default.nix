{ config, pkgs, ... }:

{
  imports = [
    ./settings.nix
    ./plugins
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
