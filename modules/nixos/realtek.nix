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

  environment.systemPackages = with pkgs; [
    alsa-tools
  ];
}
