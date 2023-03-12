{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.snapraid-aio-script;
  snapraid-aio-script-package = pkgs.callPackage ../../packages/snapraid-aio-script {
    snapraid-aio-config = cfg;
  };
in
{
  options = {
    services.snapraid-aio-script = {
      enable = mkEnableOption (mdDoc "Enable snapraid-aio-script");

      emailAddress = mkOption {
        type = types.str;
        description = mdDoc ''
          The receiver email address.
        '';
      };

      fromEmailAddress = mkOption {
        type = types.str;
        description = mdDoc ''
          The sender email address.
        '';
      };

      startAt = mkOption {
        type = types.str;
        default = "01:00";
        description = mdDoc ''
          When to run the script.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      snapraid-aio-script-package
    ];

    systemd.services."snapraid-aio-script" = {
      description = "snapraid-aio-script";
      startAt = cfg.startAt;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${snapraid-aio-script-package}/bin/snapraid-aio-script";
      };
    };

    systemd.services."snapraid-sync".enable = false;
    systemd.services."snapraid-scrub".enable = false;
  };
}
