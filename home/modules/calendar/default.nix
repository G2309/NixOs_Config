{ pkgs, ... }:
let
  cuenta = "gustavoacruzbar@gmail.com";
  gcal = "${pkgs.gcalcli}/bin/gcalcli --nocolor";
  notify = "${pkgs.libnotify}/bin/notify-send";

  recordatorio = pkgs.writeShellScriptBin "recordatorio" ''
    set -u
    MSG="$*"
    SEEN="''${XDG_STATE_HOME:-$HOME/.local/state}/calendario/avisados-$(date +%F)"
    mkdir -p "$(dirname "$SEEN")"
    grep -qxF "$MSG" "$SEEN" 2>/dev/null && exit 0
    echo "$MSG" >> "$SEEN"
    ${notify} -a Calendario -u critical -i appointment-soon "Recordatorio" "$MSG" || true
    if [ "$(cat "$HOME/.local/state/mail-digest/voz" 2>/dev/null)" = 1 ] && command -v decir >/dev/null; then
      decir "Recordatorio: $MSG"
    fi
  '';

  calendario = pkgs.writeShellScriptBin "calendario" ''
    set -u
    case "''${1:-}" in
      mes)
        exec ${gcal} agenda --tsv --calendar ${cuenta} --calendar "Festivos en Guatemala" "$2" "$3"
        ;;
      agregar)
        DIA="$2"
        TEXT=$(${pkgs.rofi}/bin/rofi -dmenu -l 0 -p "$DIA" -mesg "Nota del dia, o 'HH:MM texto' para un recordatorio" < /dev/null) || exit 0
        [ -n "$TEXT" ] || exit 0
        if [[ "$TEXT" =~ ^([0-9]{1,2}:[0-9]{2})[[:space:]]+(.+)$ ]]; then
          ${gcal} add --noprompt --calendar ${cuenta} --title "''${BASH_REMATCH[2]}" \
            --when "$DIA ''${BASH_REMATCH[1]}" --duration 30 --reminder 10 >/dev/null
        else
          ${gcal} add --noprompt --calendar ${cuenta} --title "$TEXT" --when "$DIA" --allday --duration 1 >/dev/null
        fi || { ${notify} -a Calendario "Calendario" "No se pudo guardar en Google Calendar" || true; exit 1; }
        ;;
      *)
        echo "uso: calendario mes <desde> <hasta> | agregar <AAAA-MM-DD>" >&2
        exit 1
        ;;
    esac
  '';
in
{
  home.packages = [ pkgs.gcalcli calendario recordatorio ];

  systemd.user.services.calendario-recordatorios = {
    Unit = {
      Description = "Avisos de eventos de Google Calendar";
      ConditionPathExists = "%h/.local/share/gcalcli/oauth";
    };
    Service = {
      Type = "oneshot";
      Environment = "PATH=/etc/profiles/per-user/gustavo/bin:/run/current-system/sw/bin";
      ExecStart = "${pkgs.gcalcli}/bin/gcalcli --nocolor remind --calendar ${cuenta} 10 '${recordatorio}/bin/recordatorio %%s'";
    };
  };

  systemd.user.timers.calendario-recordatorios = {
    Install.WantedBy = [ "timers.target" ];
    Timer.OnCalendar = "*:0/5";
  };
}
