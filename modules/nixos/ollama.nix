{ config, pkgs, lib, ... }:

{
  options = {
  };

  config = {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      host = "127.0.0.1";
      loadModels = [ "qwen2.5-coder:3b-base" ];
      syncModels = true;
      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = "4096";
        # Libera la VRAM a los 5 min sin uso (para jugar, etc.).
        OLLAMA_KEEP_ALIVE = "5m";
        OLLAMA_MAX_LOADED_MODELS = "1";
      };
    };

    # ollama-cuda no esta en cache.nixos.org; este cache oficial de CUDA si lo tiene.
    nix.settings = {
      extra-substituters = [ "https://cache.nixos-cuda.org" ];
      extra-trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
    };
  };
}
