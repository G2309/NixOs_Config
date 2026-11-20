{ pkgs, ... }:

{
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0 power_save_controller=N
    options snd_hda_codec_realtek power_save=0
  '';

  services.pipewire.wireplumber.extraConfig."51-alc897" = {
    "monitor.alsa.rules" = [
      {
        matches = [ { "node.name" = "alsa_output.pci-0000_0a_00.4.analog-stereo"; } ];
        actions.update-props = {
          "priority.driver" = 2000;
          "priority.session" = 2000;
          "audio.format" = "S32LE";
          "audio.rate" = 48000;
          "audio.allowed-rates" = [ 44100 48000 88200 96000 192000 ];
          "api.alsa.period-size" = 1024;
          "api.alsa.headroom" = 512;
          "api.alsa.disable-batch" = true;
          "session.suspend-timeout-seconds" = 0;
        };
      }
      {
        matches = [ { "node.name" = "alsa_input.pci-0000_0a_00.4.analog-stereo"; } ];
        actions.update-props = {
          "audio.format" = "S32LE";
          "api.alsa.period-size" = 1024;
          "api.alsa.headroom" = 512;
          "session.suspend-timeout-seconds" = 0;
        };
      }
    ];
  };

  services.pipewire.extraConfig.pipewire."60-mic-sin-ruido" = {
    "context.modules" = [
      {
        name = "libpipewire-module-filter-chain";
        args = {
          "node.description" = "Micrófono sin ruido";
          "media.name" = "Micrófono sin ruido";
          "filter.graph" = {
            nodes = [
              { type = "builtin"; name = "hp"; label = "bq_highpass"; control = { Freq = 80.0; Q = 0.707; }; }
              { type = "builtin"; name = "n60"; label = "bq_notch"; control = { Freq = 60.0; Q = 8.0; }; }
              { type = "builtin"; name = "n120"; label = "bq_notch"; control = { Freq = 120.0; Q = 8.0; }; }
              { type = "builtin"; name = "n180"; label = "bq_notch"; control = { Freq = 180.0; Q = 8.0; }; }
              {
                type = "ladspa";
                name = "rnn";
                plugin = "${pkgs.rnnoise-plugin.ladspa}/lib/ladspa/librnnoise_ladspa.so";
                label = "noise_suppressor_mono";
                control = {
                  "VAD Threshold (%)" = 50.0;
                  "VAD Grace Period (ms)" = 200;
                  "Retroactive VAD Grace (ms)" = 0;
                };
              }
            ];
            links = [
              { output = "hp:Out"; input = "n60:In"; }
              { output = "n60:Out"; input = "n120:In"; }
              { output = "n120:Out"; input = "n180:In"; }
              { output = "n180:Out"; input = "rnn:Input"; }
            ];
          };
          "capture.props" = {
            "node.name" = "capture.mic_sin_ruido";
            "node.passive" = true;
            "audio.position" = [ "FL" "FR" ];
            "target.object" = "alsa_input.pci-0000_0a_00.4.analog-stereo";
          };
          "playback.props" = {
            "node.name" = "mic_sin_ruido";
            "media.class" = "Audio/Source";
            "audio.position" = [ "FL" "FR" ];
            "priority.session" = 2500;
            "priority.driver" = 2500;
          };
        };
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    alsa-tools
  ];
}
