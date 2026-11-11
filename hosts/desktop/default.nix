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
    ../../modules/nixos/keyring.nix
    ../../modules/nixos/android.nix
    ../../modules/nixos/security.nix
  ];

  # =========================================================================
  # === Bloque NVIDIA (RTX 3080 ) =====================================
  # =========================================================================

  # Turing en adelante permite apagar la GPU si no se usa (fine-grained PM),
  # y activar el driver open-source de Nvidia.
  hardware.nvidia = {
    open = true;
    # 2026-11-11: driver FIJO en la rama 595. Con 615.78.08 Cyberpunk (RT/RR + FG) da Xid 109
    # aun con VKD3D_DISABLE_EXTENSIONS=VK_KHR_opacity_micromap,VK_NV_raw_access_chains.
    # NVIDIA/open-gpu-kernel-modules#1409. Hashes de `production` en nixpkgs (soporta kernel 7.3).
    # Para volver al último: package = config.boot.kernelPackages.nvidiaPackages.latest;
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "595.112.07";
      sha256_64bit = "sha256-Gjjs1Tii2mIypzMBhAY69Z6fyUbJCMylVb0HkJhIufA=";
      sha256_aarch64 = "sha256-7qQuOKX9xS/wpKa+bEOqsS2euJjJu182vl+6UU6bxR0=";
      openSha256 = "sha256-nQnXGCcvo4i7eGaVft3Xc9dRUPPH0v9Zi87cfI4i/Ys=";
      settingsSha256 = "sha256-2bWSou/9J3EojhSRXBol/+yGGu2XZ6EuCptb5qXHM14=";
      persistencedSha256 = "sha256-cGMEUXN7WPu822zZDLTSu6Owj8VXG4PNmhe9oKqMMKI=";
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_7_3;

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

  systemd.services.display-manager.preStart = ''
    for _ in $(seq 1 15); do
      for d in /sys/class/drm/card*/device/driver; do
        if readlink "$d" | grep -q nvidia; then
          exit 0
        fi
      done
      sleep 1
    done
  '';

  services.lsfg-vk = {
    enable = true;
    ui.enable = true;
  };
}
