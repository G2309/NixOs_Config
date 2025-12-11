{ pkgs, ... }:

{
  programs.ranger = {
    enable = true;
    
    settings = {
      preview_images = true;
      preview_images_method = "kitty";
      show_hidden = true;
      draw_borders = "both";
      column_ratios = "1,3,4";
      hidden_filter = "^\\.|\\.(?:pyc|pyo|bak|swp)$|^lost\\+found$|^__(py)?cache__$";
      confirm_on_delete = "multiple";
      use_preview_script = true;
      vcs_aware = true;
      vcs_backend_git = "enabled";
    };

    rifle = [
      # Editores
      { condition = "mime ^text, label editor"; command = ''nvim -- "$@"''; }
      { condition = "mime ^text, label pager"; command = ''$PAGER -- "$@"''; }
      { condition = "ext py"; command = ''nvim -- "$@"''; }
      { condition = "ext nix"; command = ''nvim -- "$@"''; }
      
      # imagenes 
      { condition = "mime ^image, has imv"; command = ''imv -- "$@"''; }
      
      # Video/Audio
      { condition = "mime ^video, has mpv"; command = ''mpv -- "$@"''; }
      { condition = "mime ^audio, has mpv"; command = ''mpv -- "$@"''; }
      
      # PDF
      { condition = "ext pdf, has firefox"; command = ''firefox -- "$@"''; }
      
      # Web
      { condition = "ext html?, has firefox"; command = ''firefox -- "$@"''; }
    ];

    mappings = {
      # Copiar al clipboard con yy luego yc
      yc = ''shell wl-copy < %f'';
      # Copiar path al clipboard
      yp = ''shell echo -n %f | wl-copy'';
      # Copiar nombre al clipboard  
      yn = ''shell echo -n %s | wl-copy'';
      # Extraer archivos
      ex = ''shell unar %f'';
      # Comprimir
      cz = ''shell zip -r %f.zip %s'';
      ct = ''shell tar -cvzf %f.tar.gz %s'';
      # Abrir terminal aquí
      st = ''shell kitty --detach'';
      # Bulk rename
      br = ''bulkrename %s'';
    };

    extraConfig = ''
      set viewmode miller
      set unicode_ellipsis true
      set dirname_in_tabs true
      set update_title true
      set max_history_size 20
      set max_console_history_size 50
      set scroll_offset 8
      set tilde_in_titlebar true
      set save_console_history true
      set status_bar_on_top false
      set draw_progress_bar_in_status_bar true
      set line_numbers relative
    '';
  };

  home.packages = with pkgs; [
    wl-clipboard  
    unar         
    file        
  ];
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
