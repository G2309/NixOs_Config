{ config, lib, pkgs, ... }:
let
  mod = "Mod4";

  workspaceKeys = [
    { key = "1"; ws = "1"; }
    { key = "2"; ws = "2"; }
    { key = "3"; ws = "3"; }
    { key = "4"; ws = "4"; }
    { key = "5"; ws = "5"; }
    { key = "6"; ws = "6"; }
    { key = "7"; ws = "7"; }
    { key = "8"; ws = "8"; }
    { key = "9"; ws = "9"; }
    { key = "0"; ws = "10"; }
  ];

  focusWorkspace = lib.listToAttrs (
    map (w: lib.nameValuePair "${mod}+${w.key}" "workspace number ${w.ws}") workspaceKeys
  );

  moveToWorkspace = lib.listToAttrs (
    map (
      w: lib.nameValuePair "${mod}+Shift+${w.key}" "move container to workspace number ${w.ws}"
    ) workspaceKeys
  );
in
{
  wayland.windowManager.sway.config.keybindings = lib.mkForce (
    {
      "${mod}+Return" = "exec kitty";
      "${mod}+f" = "exec firefox";
      "${mod}+n" = "exec kitty -e nvim";
      "${mod}+e" = "exec kitty -e ranger";
      "${mod}+r" = "exec rofi -show drun";

      "${mod}+w" = "kill";
      "${mod}+Shift+e" = "exit";
      "${mod}+Shift+w" = "exec wlogout";

      "${mod}+Shift+p" = "exec screenshot-full";
      "${mod}+p" = "exec screenshot-area";

      "${mod}+Up" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
      "${mod}+Down" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
      "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

      "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
      "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

      "${mod}+Left" = "exec change-wallpaper";
      "${mod}+Tab" = "exec toggle-quickshell";

      "${mod}+v" = "floating toggle";
      "${mod}+b" = "layout toggle split";
      "${mod}+m" = "fullscreen toggle";
      "${mod}+Shift+m" = "fullscreen toggle global";

      "${mod}+h" = "focus left";
      "${mod}+l" = "focus right";
      "${mod}+k" = "focus up";
      "${mod}+j" = "focus down";

      "${mod}+Shift+h" = "move left";
      "${mod}+Shift+l" = "move right";
      "${mod}+Shift+k" = "move up";
      "${mod}+Shift+j" = "move down";

      "${mod}+Ctrl+h" = "resize shrink width 20px";
      "${mod}+Ctrl+l" = "resize grow width 20px";
      "${mod}+Ctrl+k" = "resize shrink height 20px";
      "${mod}+Ctrl+j" = "resize grow height 20px";

      "${mod}+t" = "scratchpad show";
      "${mod}+Shift+t" = "move scratchpad";

      "${mod}+Shift+r" = "exec refresh-rate toggle";
      "${mod}+Ctrl+r" = "reload";
    }
    // focusWorkspace
    // moveToWorkspace
  );
}
