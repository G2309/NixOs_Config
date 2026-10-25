{ ... }:

{
  networking.firewall.allowedTCPPorts = [
    47984
    47989
    48010
  ];

  networking.firewall.allowedUDPPorts = [
    47998
    47999
    48000
    48002
    48010
  ];

  boot.kernelModules = [ "uinput" ];
}
