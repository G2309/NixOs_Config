{ pkgs, ... }:
let
  quiver-launcher = pkgs.appimageTools.wrapType2 rec {
    pname = "quiver-launcher";
    version = "3.5.1";

    src = pkgs.fetchurl {
      url = "https://github.com/tgeorgiadis/quiver-launcher/releases/download/v${version}/QuiverLauncher-linux-x64.AppImage";
      hash = "sha256-qM1TmLba6SS87Ans4XgcA8v9cymGdUdvJvwcBy08Yps=";
    };

    extraInstallCommands =
      let
        contents = pkgs.appimageTools.extract { inherit pname version src; };
      in
      ''
        mkdir -p $out/share/applications
        for f in ${contents}/*.desktop; do
          sed -e "s|^Exec=.*|Exec=${pname} %U|" -e "s|^Icon=.*|Icon=${pname}|" "$f" > $out/share/applications/${pname}.desktop
          break
        done
        for icon in ${contents}/*.png ${contents}/.DirIcon; do
          if [ -f "$icon" ]; then
            install -Dm644 "$icon" $out/share/icons/hicolor/256x256/apps/${pname}.png
            break
          fi
        done
      '';
  };
in
{
  environment.systemPackages = [ quiver-launcher ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;
  hardware.steam-hardware.enable = true;

  hardware.graphics.enable32Bit = true;
}
