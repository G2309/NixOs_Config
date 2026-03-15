{ pkgs, ... }:

{
  plugins.jupytext = {
    enable = true;
  };

  plugins.molten = {
    enable = true;
  };

  extraPackages = with pkgs; [
    jupytext
  ];

  extraPython3Packages = p: with p; [
    pynvim
    jupyter-client
    pyperclip 
  ];
}
