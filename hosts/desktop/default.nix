{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/gaming.nix
  ];

   # nvidia desktop - con graficas turing en adelante las puede apagar si no se usan
   hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # CUDA para cuando toque 
  # environment.systemPackages = with pkgs; [
  #   cudatoolkit
  #   nvtopPackages.nvidia
  # ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
}
