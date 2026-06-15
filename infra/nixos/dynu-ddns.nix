{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.dynu-ddns;
in {
  options.services.dynu-ddns = {
    enable = mkEnableOption "Dynu DDNS IP monitor and updater service";

    scriptPath = mkOption {
      type = types.path;
      default = ../../scripts/dynu/ip-monitor.sh;
      description = "Path to the ip-monitor.sh script.";
    };

    environmentFile = mkOption {
      type = types.path;
      default = /etc/conf.d/dynu-environment;
      description = ''
        Path to the environment file containing the Dynu credentials.
        The file must define:
        DYNU_HOST=your-domain.mywire.org
        DYNU_USER=your-dynu-username
        DYNU_PASSWORD=your-dynu-password
      '';
    };

    interval = mkOption {
      type = types.str;
      default = "5min";
      description = "Interval at which to run the updater service.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.dynu-ddns = {
      description = "Dynu IP Monitor & Updater";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = with pkgs; [
        bash
        curl
        coreutils
        dnsutils   # provides dig
        util-linux # provides flock
        gawk
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
        StateDirectory = "dynu";
        EnvironmentFile = cfg.environmentFile;
        ExecStart = "${pkgs.bash}/bin/bash ${cfg.scriptPath}";
        TimeoutSec = 30;
        
        # Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = "/var/lib/dynu";
      };
    };

    systemd.timers.dynu-ddns = {
      description = "Run Dynu updater periodically";
      timerConfig = {
        OnBootSec = "30s";
        OnUnitActiveSec = cfg.interval;
        AccuracySec = "10s";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
