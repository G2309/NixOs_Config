{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # --- Reglas Globales ---
      "suppress_event maximize, match:class .*"

      # --- Pavucontrol ---
      "float on, match:class ^(pavucontrol)$"
      "size 800 600, match:class ^(pavucontrol)$"
      "center on, match:class ^(pavucontrol)$"

      # --- Rofi ---
      "float on, match:class ^(Rofi)$"
      "center on, match:class ^(Rofi)$"
      "stay_focused on, match:class ^(Rofi)$"

      # --- Utilidades y Herramientas ---
      "float on, match:class ^(blueman-manager)$"
      "float on, match:class ^(nm-connection-editor)$"
      "float on, match:class ^(file-roller)$"

      # --- Reglas por Título de Ventana (Popups/Diálogos) ---
      "float on, match:title ^(Picture-in-Picture)$"
      "float on, match:title ^(Volume Control)$"
      "float on, match:title ^(Open File)$"
      "float on, match:title ^(Save File)$"
      "float on, match:title ^(Firefox — Sharing Indicator)$"
    ];
  };
}
