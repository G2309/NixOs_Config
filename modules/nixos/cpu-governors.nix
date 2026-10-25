{ pkgs, ... }:

{
  boot.kernelParams = [ "amd_pstate=active" ];

  powerManagement.cpuFreqGovernor = "schedutil";

  hardware.cpu.amd.updateMicrocode = true;

  # Las reglas polkit de gamemode sólo dejan cambiar governor / split_lock a
  # miembros del grupo "gamemode"; sin esto pkexec responde "Not authorized".
  users.users.gustavo.extraGroups = [ "gamemode" ];

  programs.gamemode = {
    enable = true;
    settings = {
      general.renice = 10;
      # Sin sección gpu: gpu_device=0 apuntaba a /sys/class/drm/card0 (no existe,
      # la 3080 es card1) y las optimizaciones NVIDIA de gamemode usan
      # nvidia-settings, que no funciona en Wayland.
      custom = {
        # gamemoded corre como servicio de systemd sin coreutils en el PATH.
        start = toString (
          pkgs.writeShellScript "gamemode-refresh-start" ''
            ${pkgs.coreutils}/bin/touch "''${XDG_RUNTIME_DIR:-/run/user/$(${pkgs.coreutils}/bin/id -u)}/refresh-rate.gaming"
          ''
        );
        end = toString (
          pkgs.writeShellScript "gamemode-refresh-end" ''
            ${pkgs.coreutils}/bin/rm -f "''${XDG_RUNTIME_DIR:-/run/user/$(${pkgs.coreutils}/bin/id -u)}/refresh-rate.gaming"
          ''
        );
      };
    };
  };
}
