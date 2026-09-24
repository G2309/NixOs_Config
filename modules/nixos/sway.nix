{ pkgs, ... }:

{
  programs.sway = {
    enable = true;
    xwayland.enable = true;

    extraOptions = [ "--unsupported-gpu" ];

    wrapperFeatures.gtk = true;

    extraSessionCommands = ''
      export XDG_SESSION_DESKTOP=sway
      export XDG_SESSION_TYPE=wayland

      export NIXOS_OZONE_WL=1
      export GDK_BACKEND=wayland,x11
      export QT_QPA_PLATFORM="wayland;xcb"
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export SDL_VIDEODRIVER=wayland
      export CLUTTER_BACKEND=wayland
      export MOZ_ENABLE_WAYLAND=1

      export XCURSOR_THEME=catppuccin-macchiato-mauve-cursors
      export XCURSOR_SIZE=18
    '';

    extraPackages = with pkgs; [
      brightnessctl
    ];
  };
}
