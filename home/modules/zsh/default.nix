{ config, lib, pkgs, ... }:

{
  imports = [
    ./aliases.nix
  ];

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      theme = "arrow";
      plugins = [ "git" "sudo" "dirhistory" ];
    };

    initContent = ''
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward
    '';
  };
  
  home.packages = with pkgs; [
    eza
    bat
    fd
    ripgrep
    fzf
  ];
}
