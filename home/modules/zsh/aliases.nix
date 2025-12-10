{ pkgs, ... }:

{
  programs.zsh.shellAliases = {
    # -- Navigation -- 
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";

    # -- Listing -- 
    ls = "eza --icons";
    ll = "eza -la --icons";
    la = "eza -a --icons";
    lt = "eza --tree --icons";

    rm = "rm -i";
    cp = "cp -i";
    mv = "mv -i";

    # -- NixOS -- 
    nrs = "sudo nixos-rebuild switch --flake ~/Progra/NixOs_Config#$(hostname)";
    nrt = "sudo nixos-rebuild test --flake ~/Progra/NixOs_Config#$(hostname)";
    nfu = "nix flake update";
    ncg = "sudo nix-collect-garbage -d";

    # -- Git -- 
    g = "git";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git pull";
    gs = "git status";
    gd = "git diff";
    glog = "git log --oneline --graph";

    # -- Apps -- 
    vim = "nvim";
    v = "nvim";
    cat = "bat";
    icat = "kitty icat";

    # -- Misc -- 
    grep = "rg";
    find = "fd";
    c = "clear";
  };
}
