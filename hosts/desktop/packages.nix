{ pkgs, inputs, ... }:

{
  # Paquetes de sistema (NixOS) especificos de desktop.
  environment.systemPackages = with pkgs; [
    mangohud
    azahar
    inputs.claude-code.packages.x86_64-linux.default
    opencode
    railway
  ];

  # Paquetes de home-manager especificos de desktop.
  home-manager.users.gustavo.home.packages = with pkgs; [
    nvtopPackages.nvidia
    qemu_kvm
    python3
    keet
    qbittorrent
    nodejs_22
    uv
    gh
    ffmpeg
    google-chrome
    bun
    texliveFull
  ];

  home-manager.users.gustavo.home.sessionVariables.CHROME_EXECUTABLE = "${pkgs.google-chrome}/bin/google-chrome-stable";

  home-manager.users.gustavo.programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.flutter-tools-nvim;
      type = "lua";
      config = ''
        require("flutter-tools").setup({
          lsp = {
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
          },
        })
      '';
    }
  ];
}
