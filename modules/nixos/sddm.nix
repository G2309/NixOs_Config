{ pkgs, inputs, ... }:

let
  sddm-theme = inputs.silentSDDM.packages.${pkgs.system}.default.override {
    theme = "rei";
  };
in
{
  environment.systemPackages = [ sddm-theme ];
  
  qt.enable = true;
  
  services.displayManager.sddm = {
    package = pkgs.kdePackages.sddm;
    enable = true;
    wayland.enable = true;
    theme = sddm-theme.pname;
    extraPackages = sddm-theme.propagatedBuildInputs;
    
    settings = {
      General = {
        GreeterEnvironment = "QML2_IMPORT_PATH=${sddm-theme}/share/sddm/themes/${sddm-theme.pname}/components/,QT_IM_MODULE=qtvirtualkeyboard";
        InputMethod = "qtvirtualkeyboard";
      };
    };
  };

  systemd.services.sddm-theme-fix = {
    description = "Restart SDDM to apply theme";
    wantedBy = [ "multi-user.target" ];
    after = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart display-manager";
      RemainAfterExit = true;
    };
  };
}
