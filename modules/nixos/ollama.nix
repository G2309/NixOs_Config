{ config, pkgs, lib, ... }:

{
  options = {
  };

  config = {
    # LLM local como respaldo para OpenCode (RTX 3080, 10 GB VRAM).
    # Un modelo de ~8B en Q4 (~5 GB) + 16k de contexto cabe sin saturar la GPU.
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      host = "127.0.0.1";
      loadModels = [ "qwen3:8b" ];
      environmentVariables = {
        # OpenCode manda un system prompt grande; el default de Ollama se queda corto.
        OLLAMA_CONTEXT_LENGTH = "16384";
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
