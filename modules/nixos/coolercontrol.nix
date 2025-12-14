{ pkgs, ... }:

{
  programs.coolercontrol = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    liquidctl
    lm_sensors
  ];

  boot.kernelModules = [
    "nct6775"
    "it87"
    "k10temp"
  ];
}
