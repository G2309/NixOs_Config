{ pkgs, ... }:

{
  nixpkgs.config.android_sdk.accept_license = true;

  environment.systemPackages = [ pkgs.android-tools ];

  users.users.gustavo.extraGroups = [ "kvm" ];
}
