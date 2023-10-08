{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.batttt;

  package = pkgs.bat;

  toConfigFile = generators.toKeyValue {
    mkKeyValue = k: v: "--${k}=${lib.escapeShellArg v}";
    listsAsDuplicateKeys = true;
  };

in
{
  meta.maintainers = [ ];

  options.programs.batttt = {
    enable = mkEnableOption "bat, a cat clone with wings";

    config = mkOption {
      type = with types; attrsOf (either str (listOf str));
      default = { };
      example = {
        theme = "TwoDark";
        pager = "less -FR";
        map-syntax = [ "*.jenkinsfile:Groovy" "*.props:Java Properties" ];
      };
      description = ''
        Bat configuration.
      '';
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = literalExpression
        "with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];";
      description = ''
        Additional bat packages to install.
      '';
    };

    themes = mkOption {
      type = types.attrsOf types.lines;
      default = { };
      example = literalExpression ''
        {
          dracula = builtins.readFile (pkgs.fetchFromGitHub {
            owner = "dracula";
            repo = "sublime"; # Bat uses sublime syntax for its themes
            rev = "26c57ec282abcaa76e57e055f38432bd827ac34e";
            sha256 = "019hfl4zbn4vm4154hh3bwk6hm7bdxbr1hdww83nabxwjn99ndhv";
          } + "/Dracula.tmTheme");
        }
      '';
      description = ''
        Additional themes to provide.
      '';
    };

  };

  config = mkIf cfg.enable {
    home.packages = [ package ] ++ cfg.extraPackages;

    xdg.configFile = mkMerge ([{
      "bat/config" =
        mkIf (cfg.config != { }) { text = toConfigFile cfg.config; };
    }] ++ flip mapAttrsToList cfg.themes
      (name: body: { "bat/themes/${name}.tmTheme" = { text = body; }; }));

    home.activation.batCache = hm.dag.entryAfter [ "linkGeneration" ] ''
      $VERBOSE_ECHO "Rebuilding bat theme cache"
      $DRY_RUN_CMD ${lib.getExe package} cache --build
    '';
  };
}
