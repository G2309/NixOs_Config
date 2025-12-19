{ config, pkgs, ... }:

{
  imports = [
    ./treesitter.nix
    ./lsp.nix
    ./cmp.nix
    ./telescope.nix
    ./ui.nix
    ./misc.nix
  ];
}
