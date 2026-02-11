{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/gaming.nix
    inputs.lsfg-vk-flake.nixosModules.default
    ../../modules/nixos/coolercontrol.nix
    ../../modules/nixos/cpu-governors.nix
    ../../modules/nixos/sunshine.nix
    ../../modules/nixos/openrgb.nix
    ../../modules/nixos/docker.nix
  ];

   # nvidia desktop - con graficas turing en adelante las puede apagar si no se usan
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # CUDA para cuando toque 
  environment.systemPackages = with pkgs; [
  #   cudatoolkit
  #   nvtopPackages.nvidia
      mangohud
      azahar
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  services.lsfg-vk = {
    enable = true;
    ui.enable = true;
  };
}
