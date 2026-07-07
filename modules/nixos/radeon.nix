{ config, lib, pkgs, ... }:

# Módulo específico para GPUs AMD (RDNA) 

{
  hardware.amdgpu.initrd.enable = true;

  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff"
  ];

  services.lact.enable = true;

  environment.systemPackages = with pkgs; [
    amdgpu_top       # top interactivo de utilización, memoria, sensores
    radeontop        # alternativa liviana en TUI
    vulkan-tools     # vulkaninfo, vkcube — verificar RADV
    clinfo           # verificar OpenCL (ROCm)
    libva-utils      # vainfo — verificar decodificación de video HW
  ];

  # ROCm / HIP 
  systemd.tmpfiles.rules = [
    "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
  ];
}
