{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "bcache" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/335c90ae-7da6-46c9-85b2-6ab543630e8b";
      fsType = "f2fs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6B4B-0EAE";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  # === Bcache ===

  fileSystems."/mnt/Bcache0" =
    { device = "/dev/disk/by-uuid/117eb366-077c-418b-860b-f947a99cee18";
      fsType = "ext4";
    };

  fileSystems."/mnt/Bcache1" =
    { device = "/dev/disk/by-uuid/931df02f-25be-4258-af8e-aa2e3ca0f281";
      fsType = "ext4";
    };

  fileSystems."/mnt/NVME" =
    { device = "/dev/disk/by-uuid/a27a1b51-4fcf-4889-b7ae-bac25058f706";
      fsType = "f2fs";
    };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
