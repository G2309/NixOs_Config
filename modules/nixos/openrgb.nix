{ pkgs, ... }:

{
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
    motherboard = "amd";
  };

  systemd.services.openrgb.preStart = ''
    for _ in $(seq 1 30); do
      if grep -qs "NVIDIA i2c adapter" /sys/bus/i2c/devices/i2c-*/name; then
        exit 0
      fi
      sleep 1
    done
  '';
}
