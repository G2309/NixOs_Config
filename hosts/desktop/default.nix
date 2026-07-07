{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # GPU 
    ../../modules/nixos/nvidia.nix
    # ../../modules/nixos/radeon.nix
    ../../modules/nixos/gaming.nix
    inputs.lsfg-vk-flake.nixosModules.default
    ../../modules/nixos/coolercontrol.nix
    ../../modules/nixos/cpu-governors.nix
    ../../modules/nixos/sunshine.nix
    ../../modules/nixos/openrgb.nix
    ../../modules/nixos/docker.nix
  ];

  # =========================================================================
  # === Bloque NVIDIA (RTX 3080 ) =====================================
  # =========================================================================

  # Turing en adelante permite apagar la GPU si no se usa (fine-grained PM),
  # y activar el driver open-source de Nvidia.
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "nvidia.NVreg_DynamicPowerManagement=0x02"
  ];

  #===

  environment.systemPackages = with pkgs; [
    # cudatoolkit
    # nvtopPackages.nvidia
    mangohud
    azahar
  ];

  # =========================================================================
  # === Bloque AMD (RX 9070 XT ) ===============
  # =========================================================================

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  #
  # environment.systemPackages = with pkgs; [
  #   mangohud
  #   azahar
  # ];

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
