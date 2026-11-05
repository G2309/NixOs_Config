{ pkgs, ... }:
let
  escanear = pkgs.writeShellScriptBin "escanear" ''
    set -u
    LOG="''${XDG_STATE_HOME:-$HOME/.local/state}/escanear/ultimo.log"
    mkdir -p "$(dirname "$LOG")"
    [ "$#" -gt 0 ] || set -- "$HOME"
    if ! ls /var/lib/clamav/*.c[lv]d >/dev/null 2>&1; then
      ${pkgs.libnotify}/bin/notify-send -a Seguridad -u critical "Antivirus" "Falta la base de virus: corre 'sudo systemctl start clamav-freshclam'" || true
      echo "Falta la base de virus: corre 'sudo systemctl start clamav-freshclam'" >&2
      exit 2
    fi
    ${pkgs.libnotify}/bin/notify-send -a Seguridad "Antivirus" "Analizando $*…" || true
    ${pkgs.util-linux}/bin/ionice -c3 ${pkgs.coreutils}/bin/nice -n19 \
      ${pkgs.clamav}/bin/clamscan --database=/var/lib/clamav -r -i --stdout \
      --exclude-dir='/\.cache/' --exclude-dir='/\.local/share/Steam/' --exclude-dir='/node_modules/' \
      "$@" > "$LOG" 2>&1
    case $? in
      0) ${pkgs.libnotify}/bin/notify-send -a Seguridad "Antivirus" "Sin amenazas. Detalle: $LOG" || true ;;
      1) ${pkgs.libnotify}/bin/notify-send -a Seguridad -u critical "Antivirus" "Archivos infectados, revisa $LOG" || true ;;
      *) ${pkgs.libnotify}/bin/notify-send -a Seguridad -u critical "Antivirus" "El analisis fallo, revisa $LOG" || true ;;
    esac
  '';
in
{
  services.clamav.updater = {
    enable = true;
    interval = "daily";
    frequency = 1;
  };

  environment.systemPackages = [ escanear pkgs.clamav pkgs.lynis ];

  systemd.user.services.escanear = {
    description = "Analisis antivirus semanal de la carpeta personal";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${escanear}/bin/escanear";
    };
  };

  systemd.user.timers.escanear = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sun 13:00";
      Persistent = true;
    };
  };
}
