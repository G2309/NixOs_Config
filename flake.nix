{
  description = "NixOS Configuration - Gustavo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    
    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
   };
  };

  outputs = { self, nixpkgs, home-manager, catppuccin, silentSDDM, ... }@inputs:
  let
    system = "x86_64-linux";
    
    mkHost = hostname: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs hostname; };
      modules = [
        ./hosts/common
        ./hosts/${hostname}
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
	    backupFileExtension = "backup";
            extraSpecialArgs = { inherit inputs hostname; };
            users.gustavo = import ./home;
          };
        }
        catppuccin.nixosModules.catppuccin
      ];
    };
  in
  {
    nixosConfigurations = {
      laptop = mkHost "laptop";
      desktop = mkHost "desktop";
    };
  };
}
