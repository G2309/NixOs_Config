{ pkgs, inputs, ... }:

{
  # Paquetes de sistema (NixOS) especificos de desktop.
  environment.systemPackages = with pkgs; [
    mangohud
    azahar
    lact
    inputs.claude-code.packages.x86_64-linux.default
    inputs.opencode.packages.x86_64-linux.default
  ];

  # Paquetes de home-manager especificos de desktop.
  home-manager.users.gustavo.home.packages = with pkgs; [
    nvtopPackages.nvidia
    qemu_kvm
    python3
    keet
  ];
}
