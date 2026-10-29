{ pkgs, ... }:

{
  # Paquetes de sistema (NixOS) y de home-manager especificos de laptop.
  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
    ffmpeg
    (python3.withPackages (ps: with ps; [
      torch
      librosa
      audioread
      numpy
      fastapi
      uvicorn
      python-multipart
    ]))
  ];
}
