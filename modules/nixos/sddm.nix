{ pkgs, ... }:

let
  sddm-sugar-candy = pkgs.stdenv.mkDerivation {
    pname = "sddm-sugar-candy";
    version = "1.6";
    src = pkgs.fetchFromGitHub {
      owner = "Kangie";
      repo = "sddm-sugar-candy";
      rev = "v1.6";
      sha256 = "sha256-p2d7I0UBP63baW/q9MexYJQcqSmZ0L5rkwK3n66gmqM=";
    };
    installPhase = ''
      mkdir -p $out/share/sddm/themes/sugar-candy
      cp -r * $out/share/sddm/themes/sugar-candy
      
      # Configuración del tema
      cat > $out/share/sddm/themes/sugar-candy/theme.conf << EOF
      [General]
      Background="/usr/share/sddm/videos/video.mp4"
      ScreenWidth="1920"
      ScreenHeight="1080"
      FullBlur="true"
      PartialBlur="false"
      BlurRadius="100"
      
      Font="FiraCode Nerd Font"
      FontSize="10"
      
      MainColor="#cad3f5"
      AccentColor="#c6a0f6"
      BackgroundColor="#24273a"
      
      OverrideLoginButtonTextColor="#24273a"
      
      ForceLastUser="true"
      ForcePasswordFocus="true"
      ForceHideCompletePassword="true"
      EOF
    '';
  };
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sugar-candy";
  };

  environment.systemPackages = [
    sddm-sugar-candy
    pkgs.libsForQt5.qt5.qtgraphicaleffects
    pkgs.libsForQt5.qt5.qtmultimedia
  ];
}
