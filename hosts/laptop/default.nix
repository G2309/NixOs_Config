{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
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

  programs.light.enable = true;
  users.users.gustavo.extraGroups = [ "video" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
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

  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
  ];
}
