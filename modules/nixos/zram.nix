{ ... }:

{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
    "vm.max_map_count" = 2147483642;
  };

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 4;
    freeSwapThreshold = 4;
    enableNotifications = true;
    extraArgs = [
      "--avoid"
      "^(sway|Hyprland|sddm|systemd|quickshell|kitty|dbus-.*|pipewire.*|wireplumber)$"
      "--prefer"
      "^(firefox|\\.firefox-wrapp|chromium|electron|steam|vesktop|node|java)$"
    ];
  };
}
