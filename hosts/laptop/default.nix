{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/keyring.nix
  ];

  services = {
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      };
    };
    thermald.enable = true;
  };

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-vaapi-driver
    libva-vdpau-driver
    libvdpau-va-gl
  ];

  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    host = "127.0.0.1";
    loadModels =
      let m = import ../../home/modules/local-model.nix "laptop"; in
      [ m.fim ] ++ lib.optional (lib.versionAtLeast pkgs.ollama.version "0.40.12") m.chat;
    syncModels = true;
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "32768";
      OLLAMA_KEEP_ALIVE = "5m";
      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_NO_CLOUD = "1";
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = false;
      tapping = true;
      scrollMethod = "twofinger";
    };
  };
}
