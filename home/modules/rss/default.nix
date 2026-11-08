{ pkgs, ... }:
let
  resumirPy = pkgs.writers.writePython3 "resumir.py" {
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./resumir.py);

  resumir = pkgs.writeShellScriptBin "resumir" ''
    export PATH=${pkgs.poppler-utils}/bin:$PATH
    export OLLAMA_URL=http://127.0.0.1:11434
    export OLLAMA_MODEL=qwen3.5:4b
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
