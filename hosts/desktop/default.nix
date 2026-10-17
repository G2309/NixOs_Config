{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
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
    ../../modules/nixos/realtek.nix
    ../../modules/nixos/ddc.nix
    ../../modules/nixos/kdeconnect.nix
    ../../modules/nixos/lact.nix
    ../../modules/nixos/ollama.nix
  ];

  # =========================================================================
  # === Bloque NVIDIA (RTX 3080 ) =====================================
  # =========================================================================

  # Turing en adelante permite apagar la GPU si no se usa (fine-grained PM),
  # y activar el driver open-source de Nvidia.
  hardware.nvidia = {
    open = true;
    # 2026-10-15: driver FIJO en 595.104.02. Las ramas 610/615 dan Xid 109
    # (CTX SWITCH TIMEOUT) con ray tracing en Proton: NVIDIA/open-gpu-kernel-modules#1409.
    # Fijado con mkDriver (no `.stable`, que es un alias y puede saltar a 610/615 al
    # actualizar nixpkgs). Hashes copiados de `production` en nixpkgs 26.11.20261008.
    # Para volver al último: package = config.boot.kernelPackages.nvidiaPackages.latest;
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "595.104.02";
      sha256_64bit = "sha256-5CHCAuTHn1jDx/MWG75xRU67PYiTb4ggWg4yfNBMWco=";
      sha256_aarch64 = "sha256-PafStmwNMufeDp3VtpTGGCoW+53Gor/mieO1m1pI7gI=";
      openSha256 = "sha256-FWk5ra2yjz8VAxAA8GXrSoeBj/XC1BKvsKsBKR09joE=";
      settingsSha256 = "sha256-4Kxro6tvI5aX4nu2RspgyBsW+Jq3/VYjSAS5UGdzTCU=";
      persistencedSha256 = "sha256-JsMLPqJuZwAtHngsQODMsmgO7F2tVkQ2arc7fYa2bwo=";
    };
  };

  # Fijado en la serie 7.2 (recibe parches 7.2.x) para que el driver 595 no quede con un
  # kernel nuevo que no soporte. Antes: pkgs.linuxPackages_latest.
  boot.kernelPackages = pkgs.linuxPackages_7_2;

  boot.kernelParams = [
    "nvidia.NVreg_DynamicPowerManagement=0x02"
  ];
  nixpkgs.config.allowUnfreePredicate = pkg: 
    builtins.elem (pkgs.lib.getName pkg) [ "claude" ];

  #===

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
