{ ... }:

{
  networking.firewall.allowedTCPPortRanges = [ 
    { from = 47984; to = 48010; }
  ];
  
  networking.firewall.allowedUDPPortRanges = [ 
    { from = 47998; to = 48010; }
  ];

  boot.kernelModules = [ "uinput" ];
}
