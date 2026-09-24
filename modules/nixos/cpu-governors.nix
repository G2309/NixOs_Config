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
      custom = {
        start = toString (
          pkgs.writeShellScript "gamemode-refresh-start" ''
            touch "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/refresh-rate.gaming"
          ''
        );
        end = toString (
          pkgs.writeShellScript "gamemode-refresh-end" ''
            rm -f "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/refresh-rate.gaming"
          ''
        );
      };
    };
  };
}
