{ pkgs, ... }:

{
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire."10-clock" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 192000 ];
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 2048;
      };
    };

    extraConfig.client."10-quality" = {
      "stream.properties" = {
        "resample.quality" = 10;
        "resample.disable" = false;
        "channelmix.upmix" = false;
        "channelmix.normalize" = false;
        "channelmix.lfe-cutoff" = 150;
        "dither.method" = "wannamaker3";
        "dither.noise" = 0;
      };
    };

    extraConfig.pipewire-pulse."10-quality" = {
      "pulse.properties" = {
        "pulse.min.req" = "256/48000";
        "pulse.default.req" = "1024/48000";
        "pulse.min.quantum" = "256/48000";
      };
      "stream.properties" = {
        "resample.quality" = 10;
        "channelmix.upmix" = false;
        "channelmix.normalize" = false;
      };
    };

    wireplumber.extraConfig."50-alsa-no-suspend" = {
      "monitor.alsa.rules" = [
        {
          matches = [ { "node.name" = "~alsa_(output|input)\\..*"; } ];
          actions.update-props = {
            "session.suspend-timeout-seconds" = 0;
          };
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
    pulseaudio
  ];
}
