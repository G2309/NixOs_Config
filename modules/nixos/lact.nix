{ config, lib, pkgs, ... }:
let
  gpu = "10DE:2206-1043:87B2-0000:08:00.0";

  lact-headless = pkgs.lact.overrideAttrs (old: {
    pname = "lact-headless";
    cargoBuildFlags = [
      "-p"
      "lact"
    ];
    cargoBuildNoDefaultFeatures = true;
    cargoBuildFeatures = [
      "nvidia"
      "display-info"
    ];
    nativeBuildInputs = lib.remove pkgs.wrapGAppsHook4 old.nativeBuildInputs;
    buildInputs = lib.subtractLists [
      pkgs.gtk4
      pkgs.libadwaita
      pkgs.gdk-pixbuf
    ] old.buildInputs;
    doCheck = false;
    postInstall = ''
      install -Dm444 res/lactd.service -t $out/lib/systemd/system
    '';
    preFixup = "";
    postFixup = ''
      patchelf $out/bin/lact \
        --add-needed libvulkan.so \
        --add-needed libdrm.so \
        --add-needed libOpenCL.so \
        --add-rpath ${
          lib.makeLibraryPath [
            pkgs.vulkan-loader
            pkgs.libdrm
            pkgs.ocl-icd
          ]
        }
    '';
  });
in
{
  services.lact = {
    enable = true;
    package = lact-headless;
  };

  environment.etc."lact/config.yaml".text = ''
    version: 7
    daemon:
      log_level: info
      admin_group: wheel
      disable_clocks_cleanup: false
    apply_settings_timer: 5
    gpus:
      ${gpu}:
        fan_control_enabled: false
        power_cap: 215.0
        min_core_clock: 210
        max_core_clock: 1800
        gpu_clock_offsets:
          0: 210
        mem_clock_offsets:
          0: 350
  '';

  systemd.services.lactd.restartTriggers = [ config.environment.etc."lact/config.yaml".source ];
}
