{ pkgs, inputs, hostname, lib, ... }:

let
  shellConfig = builtins.toJSON {
    paths.wallpaperDir = "~/Pictures/Wallpaper";
    appearance = {
      anim.durations.scale = 0.6;
      transparency.enabled = false;
    };
    background = {
      visualiser.enabled = false;
    };
    general.apps = {
      terminal  = [ "kitty" ];
      audio     = [ "pavucontrol" ];
      playback  = [ "mpv" ];
      explorer  = [ "ranger" ];
    };
    notifs = {
      expire = true;
      fullscreen = "on";
      defaultExpireTimeout = 5000;
    };
    bar = {
      persistent = true;
      status = {
        showBattery    = hostname == "laptop";
        showNetwork    = true;
        showWifi       = true;
        showBluetooth  = true;
      };
    };
    services = {
      useTwelveHourClock  = false;
      audioIncrement      = 0.05;
      brightnessIncrement = 0.05;
      maxVolume           = 1.5;
      smartScheme         = true;
      defaultPlayer       = "Spotify";
    };
    lock.enableFprint = hostname == "laptop";
  };
in
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;
    cli.enable = true;
    systemd = {
      enable = true;
      target = "hyprland-session.target";
      environment = [
        "QSG_RENDER_LOOP=basic"
        "QT_QPA_PLATFORM=wayland"
        "QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000"
      ];
    };
  };

  home.activation.caelestiaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/caelestia"
    mkdir -p "$HOME/.local/state/caelestia"
    mkdir -p "$HOME/.cache/caelestia/imagecache/notifs"

    if [ ! -f "$HOME/.config/caelestia/shell.json" ]; then
      cat > "$HOME/.config/caelestia/shell.json" << 'CAELESTIA_EOF'
${shellConfig}
CAELESTIA_EOF
      echo "caelestia: shell.json created"
    fi
  '';

  home.packages = with pkgs; [
    ddcutil swappy imagemagick fish
  ];
}
