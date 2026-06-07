{ pkgs, inputs, hostname, ... }:

{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;

    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };

    settings = {
      paths.wallpaperDir = "~/Pictures/Wallpaper";

      general.apps = {
        terminal = [ "kitty" ];
        audio    = [ "pavucontrol" ];
        playback = [ "mpv" ];
        explorer = [ "ranger" ];
      };

      general.battery.warnLevels =
        if hostname == "laptop"
        then [
          { level = 20; title = "Low battery";      message = "Plug in a charger";        icon = "battery_android_frame_2"; }
          { level = 10; title = "Battery almost dead"; message = "Plug in NOW";            icon = "battery_android_frame_1"; }
          { level =  5; title = "Critical battery"; message = "PLUG THE CHARGER NOW!!";    icon = "battery_android_alert"; critical = true; }
        ]
        else []; 

      notifs = {
        expire = true;
        fullscreen = "on";
        defaultExpireTimeout = 5000;
      };

      bar = {
        persistent = true;
        status = {
          showBattery  = hostname == "laptop";
          showNetwork  = true;
          showWifi     = true;
          showBluetooth = true;
        };
      };

      services = {
        useTwelveHourClock = false;
        audioIncrement     = 0.05;
        brightnessIncrement = 0.05;
        maxVolume          = 1.5;
        smartScheme        = true;
        defaultPlayer      = "Spotify";
      };

    };
  };

  home.packages = with pkgs; [
    ddcutil
    swappy
    imagemagick
    fish
  ];
}
