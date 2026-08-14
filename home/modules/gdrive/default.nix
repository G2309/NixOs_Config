{ config, lib, pkgs, ... }:

let
  remote = "gdrive";

  mountPoint = "${config.home.homeDirectory}/GoogleDrive";

  thesisRemote = "Trabajo de Graduación";
  thesisLocal = "${config.home.homeDirectory}/Documents/Tesis";

  rcloneConf = "${config.xdg.configHome}/rclone/rclone.conf";
  cacheDir = "${config.xdg.cacheHome}/rclone";
  stateDir = "${config.xdg.stateHome}/rclone-tesis";

  filters = pkgs.writeText "tesis-bisync-filters" ''
    - .git/**
    - *.aux
    - *.bbl
    - *.bcf
    - *.blg
    - *.fdb_latexmk
    - *.fls
    - *.lof
    - *.lot
    - *.log
    - *.out
    - *.run.xml
    - *.synctex.gz
    - *.toc
    - .DS_Store
    - ~$*
    - .~lock.*
  '';

  bisync = pkgs.writeShellApplication {
    name = "tesis-sync";
    runtimeInputs = [ pkgs.rclone pkgs.coreutils ];
    text = ''
      mkdir -p "${thesisLocal}" "${stateDir}"

      marker="${stateDir}/$(basename ${filters})"

      filtersFile="${stateDir}/filters.txt"
      install -m 644 "${filters}" "$filtersFile"

      args=(
        bisync "${thesisLocal}" "${remote}:${thesisRemote}"
        --config "${rcloneConf}"
        --filters-file "$filtersFile"
        --create-empty-src-dirs
        --conflict-resolve newer
        --conflict-loser pathname
        --max-delete 25
        # Los capitulos en Drive son Google Docs nativos. Sin este flag,
        # subir un .docx editado en local falla con "can't update google
        # document type" y aborta el bisync completo, dejandolo en estado
        # que exige --resync para recuperarse.
        --drive-import-formats docx
        --log-level INFO
      )

      if [ ! -e "$marker" ]; then
        echo "Primera sincronizacion: ejecutando --resync"
        rclone "''${args[@]}" --resync
        touch "$marker"
      else
        rclone "''${args[@]}"
      fi
    '';
  };
in
{
  home.packages = [
    pkgs.rclone
    bisync
  ];

  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "Google Drive (rclone mount)";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      ConditionPathExists = rcloneConf;
    };

    Service = {
      Type = "notify";
      Environment = [ "PATH=/run/wrappers/bin:${lib.makeBinPath [ pkgs.coreutils ]}" ];
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountPoint} ${cacheDir}";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount ${remote}: ${mountPoint} \
          --config ${rcloneConf} \
          --cache-dir ${cacheDir} \
          --vfs-cache-mode full \
          --vfs-cache-max-size 8G \
          --vfs-cache-max-age 168h \
          --vfs-read-chunk-size 32M \
          --dir-cache-time 12h \
          --poll-interval 1m \
          --umask 022 \
          --log-level INFO
      '';
      ExecStop = "/run/wrappers/bin/fusermount3 -uz ${mountPoint}";
      Restart = "on-failure";
      RestartSec = 15;
    };

    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.tesis-sync = {
    Unit = {
      Description = "Sincroniza la carpeta de tesis con Google Drive (rclone bisync)";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      ConditionPathExists = rcloneConf;
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${bisync}/bin/tesis-sync";
    };
  };

  systemd.user.timers.tesis-sync = {
    Unit.Description = "Sincronizacion periodica de la tesis con Google Drive";
    Timer = {
      OnBootSec = "3m";
      OnUnitActiveSec = "15m";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
