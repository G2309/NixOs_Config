{ pkgs, ... }:

{
  # Paquetes de sistema (NixOS) y de home-manager especificos de laptop.
  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
  ];
}
