{ pkgs, hostname, ... }:
let
  model = (import ../local-model.nix hostname).chat;

  resumirPy = pkgs.writers.writePython3 "resumir.py" {
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./resumir.py);

  resumir = pkgs.writeShellScriptBin "resumir" ''
    export PATH=${pkgs.poppler-utils}/bin:$PATH
    export OLLAMA_URL=http://127.0.0.1:11434
    export OLLAMA_MODEL=${model}
    exec ${resumirPy} "$@"
  '';
in
{
  home.packages = [
    resumir
    pkgs.glow
  ];

  programs.newsboat = {
    enable = true;
    autoReload = true;
    reloadTime = 60;
    browser = "xdg-open %u";
    urls = [
      { url = "https://github.com/NVIDIA/open-gpu-kernel-modules/releases.atom"; tags = [ "nvidia" "drivers" ]; title = "NVIDIA drivers"; }
      { url = "https://nvidianews.nvidia.com/releases.xml"; tags = [ "nvidia" ]; title = "NVIDIA news"; }
      { url = "https://developer.nvidia.com/blog/feed"; tags = [ "nvidia" ]; title = "NVIDIA developer blog"; }
      { url = "https://github.com/GloriousEggroll/proton-ge-custom/releases.atom"; tags = [ "gaming" "proton" ]; title = "GE-Proton"; }
      { url = "https://github.com/ValveSoftware/Proton/releases.atom"; tags = [ "gaming" "proton" ]; title = "Proton (Valve)"; }
      { url = "https://github.com/doitsujin/dxvk/releases.atom"; tags = [ "gaming" "proton" ]; title = "DXVK"; }
      { url = "https://github.com/HansKristian-Work/vkd3d-proton/releases.atom"; tags = [ "gaming" "proton" ]; title = "VKD3D-Proton"; }
      { url = "https://www.gamingonlinux.com/article_rss.php"; tags = [ "gaming" "linux" ]; title = "GamingOnLinux"; }
      { url = "https://www.phoronix.com/rss.php"; tags = [ "linux" ]; title = "Phoronix"; }
      { url = "https://nixos.org/blog/announcements-rss.xml"; tags = [ "linux" "nixos" ]; title = "NixOS"; }
    ];
    extraConfig = ''
      bind-key j down
      bind-key k up
      bind-key J next-feed
      bind-key K prev-feed
      bind-key g home
      bind-key G end
      bind-key l open
      bind-key h quit
      macro s set browser "${resumir}/bin/resumir --pausa %u" ; open-in-browser ; set browser "xdg-open %u"
    '';
  };
}
