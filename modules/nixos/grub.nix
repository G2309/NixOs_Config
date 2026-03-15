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
      extraEntries = ''
        # Arch Linux
        menuentry "Arch Linux" --class arch --class gnu-linux --class gnu --class os {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --no-floppy --fs-uuid --set=root 79AD-DCA4
          chainloader /EFI/BOOT/BOOTX64.EFI 
        }

        # FreeBSD
        menuentry "FreeBSD" --class freebsd --class bsd --class os {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --no-floppy --fs-uuid --set=root 79AD-DCA4
          chainloader /EFI/freebsd/loader.efi
        }
      '';
    };
  };
  
  # grub param
  boot.kernelParams = [ "quiet" "loglevel=3"];
}
