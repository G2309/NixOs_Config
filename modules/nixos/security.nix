{ pkgs, lib, ... }:
let
  notify = "${pkgs.libnotify}/bin/notify-send -a Seguridad";
  clamdscan = "${pkgs.clamav}/bin/clamdscan --config-file=/etc/clamav/clamd.conf";

  escanear-interno = pkgs.writeShellScriptBin "escanear-interno" ''
    set -u
    export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
    STATE="''${XDG_STATE_HOME:-$HOME/.local/state}/escanear"
    LOG="$STATE/ultimo.log"
    LIST="$STATE/archivos.txt"
    mkdir -p "$STATE"
    if ! ls /var/lib/clamav/*.c[lv]d >/dev/null 2>&1; then
      ${notify} -u critical "Antivirus" "Falta la base de virus: corre 'sudo systemctl start clamav-freshclam'" || true
      echo "Falta la base de virus: corre 'sudo systemctl start clamav-freshclam'" >&2
      exit 2
    fi

    filtro=()
    if [ "$#" -gt 0 ]; then
      tipo=manual
    else
      set -- "$HOME"
      ultimo_completo=$(stat -c %Y "$STATE/completo" 2>/dev/null || echo 0)
      if [ -f "$STATE/ultimo" ] && [ $(( $(date +%s) - ultimo_completo )) -lt $(( 180 * 86400 )) ]; then
        tipo=incremental
        filtro=(-cnewer "$STATE/ultimo")
      else
        tipo=completo
      fi
    fi

    inicio=$(date +%s.%N)
    ${pkgs.findutils}/bin/find "$@" -xdev \
      \( -name .cache -o -name node_modules -o -path "$HOME/.local/share/Steam" -o -path "$STATE" \) -prune \
      -o -type f "''${filtro[@]}" -print > "$LIST"
    total=$(${pkgs.coreutils}/bin/wc -l < "$LIST")

    ${notify} "Antivirus" "Analisis $tipo: $total archivos" || true
    if [ "$total" -eq 0 ]; then
      : > "$LOG"
      rc=0
    elif ! ${clamdscan} --ping 120:1 > "$LOG" 2>&1; then
      rc=3
    else
      ${clamdscan} --multiscan --fdpass -i --stdout --file-list="$LIST" > "$LOG" 2>&1
      rc=$?
    fi

    if grep -q ' FOUND$' "$LOG"; then
      estado=infectado
    elif [ "$rc" -eq 0 ]; then
      estado=limpio
    elif [ "$rc" -eq 3 ] || grep -q 'connect to clamd' "$LOG"; then
      estado=fallo
    else
      estado=avisos
    fi

    if [ "$estado" != fallo ] && [ "$tipo" != manual ]; then
      touch -d "@$inicio" "$STATE/ultimo"
      [ "$tipo" = completo ] && touch -d "@$inicio" "$STATE/completo"
    fi

    case $estado in
      limpio) ${notify} "Antivirus" "Sin amenazas ($tipo, $total archivos)" || true ;;
      avisos) ${notify} "Antivirus" "Sin amenazas, algunos archivos no se pudieron leer. Detalle: $LOG" || true ;;
      infectado) ${notify} -u critical "Antivirus" "Archivos infectados, revisa $LOG" || true ;;
      fallo) ${notify} -u critical "Antivirus" "No se pudo conectar a clamd, revisa $LOG" || true ;;
    esac
    echo "Antivirus: $estado ($tipo, $total archivos). Detalle: $LOG"
    [ "$estado" = infectado ] && exit 1
    [ "$estado" = fallo ] && exit 2
    exit 0
  '';

  escanear = pkgs.writeShellScriptBin "escanear" ''
    set -u
    rutas=()
    for a in "$@"; do
      p=$(${pkgs.coreutils}/bin/realpath -e -- "$a") || exit 2
      rutas+=("$p")
    done
    exec sudo systemd-run --quiet --wait --pty --collect \
      --uid="$(id -u)" --gid="$(id -g)" \
      -p Requires=clamav-daemon.service -p After=clamav-daemon.service \
      --setenv=HOME="$HOME" \
      --setenv=XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}" \
      ${escanear-interno}/bin/escanear-interno "''${rutas[@]}"
  '';
in
{
  services.clamav.updater = {
    enable = true;
    interval = "daily";
    frequency = 1;
  };

  services.clamav.daemon = {
    enable = true;
    settings.MaxThreads = 12;
  };

  systemd.services.clamav-daemon = {
    wantedBy = lib.mkForce [ ];
    unitConfig.StopWhenUnneeded = true;
    serviceConfig = {
      Nice = 15;
      IOSchedulingClass = "idle";
    };
  };

  systemd.sockets.clamav-daemon = {
    wantedBy = lib.mkForce [ ];
    unitConfig.StopWhenUnneeded = true;
    socketConfig.SocketGroup = lib.mkForce "wheel";
  };

  environment.systemPackages = [ escanear pkgs.clamav pkgs.lynis ];

  systemd.services.escanear = {
    description = "Analisis antivirus mensual (incremental, completo cada 6 meses)";
    requires = [ "clamav-daemon.service" ];
    after = [ "clamav-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "gustavo";
      ExecStart = "${escanear-interno}/bin/escanear-interno";
    };
  };

  systemd.timers.escanear = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-01 13:00";
      Persistent = true;
    };
  };
}
