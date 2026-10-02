{ config, lib, pkgs, ... }:
let
  connector = "DP-2";
  timezone = "America/Guatemala";
  minWriteGapMs = 300;

  schedule = {
    day = "06:00";
    night = "18:00";
  };

  limits = {
    brightness = {
      min = 0;
      max = 100;
      step = 5;
    };
    contrast = {
      min = 30;
      max = 100;
      step = 5;
    };
    sharpness = {
      min = 0;
      max = 100;
      step = 25;
    };
  };

  profiles = {
    day = {
      brightness = 70;
      contrast = 75;
      sharpness = 50;
      colorPreset = "";
    };
    night = {
      brightness = 25;
      contrast = 70;
      sharpness = 50;
      colorPreset = "";
    };
  };

  caseLines =
    attrs:
    lib.concatStrings (
      lib.mapAttrsToList (
        name: values:
        lib.concatStrings (
          lib.mapAttrsToList (
            key: value: "    ${name}:${key}) echo ${lib.escapeShellArg (toString value)} ;;\n"
          ) values
        )
      ) attrs
    );

  invalidSettings = lib.concatLists (
    lib.mapAttrsToList (
      pname: p:
      lib.concatLists (
        lib.mapAttrsToList (
          feature: l:
          let
            v = p.${feature};
          in
          lib.optional (v < l.min || v > l.max || lib.mod v l.step != 0) "${pname}.${feature} = ${toString v} (permitido: ${toString l.min}-${toString l.max} en pasos de ${toString l.step})"
        ) limits
      )
    ) profiles
  );

  monitor-ctl = pkgs.writeShellApplication {
    name = "monitor-ctl";
    runtimeInputs = with pkgs; [
      ddcutil
      jq
      util-linux
      coreutils
      gawk
      gnused
    ];
    text = ''
      export TZ=${lib.escapeShellArg timezone}
      CONNECTOR=${lib.escapeShellArg connector}
      DAY_START=${lib.escapeShellArg schedule.day}
      NIGHT_START=${lib.escapeShellArg schedule.night}
      MIN_WRITE_GAP_MS=${toString minWriteGapMs}
      LIMITS_JSON=${lib.escapeShellArg (builtins.toJSON limits)}

      profile_get() {
        case "$1:$2" in
      ${caseLines profiles}    *) echo "" ;;
        esac
      }

      limit_get() {
        case "$1:$2" in
      ${caseLines limits}    *) echo 1 ;;
        esac
      }

    ''
    + builtins.readFile ./monitor-ctl.sh;
  };
in
{
  assertions = [
    {
      assertion = invalidSettings == [ ];
      message = "monitor: valores fuera de lo que admite el monitor:\n  " + lib.concatStringsSep "\n  " invalidSettings;
    }
  ];

  home.packages = [ monitor-ctl ];

  systemd.user.services.monitor-profile-auto = {
    Unit.Description = "Perfil del monitor segun la hora de Guatemala";
    Service = {
      Type = "oneshot";
      ExecStart = "${monitor-ctl}/bin/monitor-ctl auto";
    };
  };

  systemd.user.timers.monitor-profile-auto = {
    Unit.Description = "Cambio de perfil dia/noche del monitor";
    Timer = {
      OnCalendar = [
        "*-*-* ${schedule.day}:00 ${timezone}"
        "*-*-* ${schedule.night}:00 ${timezone}"
      ];
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  wayland.windowManager.sway.config.startup = [
    { command = "monitor-ctl auto"; }
  ];
}
