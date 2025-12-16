{ pkgs, ... }:

{
  boot.kernelParams = [ "amd_pstate=active" ];

  powerManagement.cpuFreqGovernor = "schedutil";

  hardware.cpu.amd.updateMicrocode = true;

  programs.gamemode = {
    enable = true;
    settings = {
      general.renice = 10;
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
      };
    };
  };
}
