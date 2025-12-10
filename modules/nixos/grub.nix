{ pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;
    
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      gfxmodeEfi = "auto";
      gfxpayloadEfi = "keep";
      
      # theme
      theme = pkgs.catppuccin-grub.override {
        flavor = "macchiato";
      };
      
      extraConfig = ''
        GRUB_TIMEOUT_STYLE=menu
        GRUB_TERMINAL_INPUT=console
        GRUB_DISABLE_RECOVERY=true
      '';
    };
  };
  
  # grub param
  boot.kernelParams = [ "quiet" "loglevel=3"];
}
