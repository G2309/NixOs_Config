{ config, pkgs, lib, ... }:

let
  myUser = "gustavo"; 
in
{
  options = {
  };

  config = {
    virtualisation.docker.enable = true;
    virtualisation.docker.enableOnBoot = true;

    # rootless
    # virtualisation.docker.rootless = true;
    # virtualisation.docker.rootlessUser = myUser;

    # Docker con nvidia 
    # virtualisation.docker.enableNvidia = true;

    users.extraGroups.docker = {
      members = [ myUser ];
    };

    environment.systemPackages = with pkgs; [
      docker             
      docker-compose      
    ];

    # docker env 
    #environment.sessionVariables = lib.mkForce {
    #};

  };
}

