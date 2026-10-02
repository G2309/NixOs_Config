{ pkgs, ... }:

{
  hardware.i2c.enable = true;

  users.users.gustavo.extraGroups = [ "i2c" ];

  environment.systemPackages = [ pkgs.ddcutil ];
}
