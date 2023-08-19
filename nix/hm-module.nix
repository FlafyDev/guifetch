self: {
  pkgs,
  lib,
  config,
  ...
}: let
  inherit
    (lib)
    mkOption
    mkEnableOption
    types
    concatStringsSep
    optional
    mkIf
    ;
  cfg = config.programs.guifetch;
in {
  options = {
    programs.guifetch = {
      enable = mkEnableOption "guifetch";
      config = {
        backgroundColor = mkOption {
          type = with types; nullOr str;
          default = null;
          description = ''
            Background color of the application in ARGB format.
          '';
        };
        osId = mkOption {
          type = with types; nullOr str;
          default = null;
          description = ''
            Override the OS Id.
          '';
        };
        osImage = mkOption {
          type = with types; nullOr str;
          default = null;
          description = ''
            Override the OS Image.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [self.packages.${pkgs.stdenv.hostPlatform.system}.default];
    xdg.configFile."guifetch/guifetch.toml".text = concatStringsSep "\n" (
      (optional (cfg.config.backgroundColor != null) "background_color = 0x${cfg.config.backgroundColor}")
      ++ (optional (cfg.config.osId != null) "os_id = ${cfg.config.osId}")
      ++ (optional (cfg.config.osImage != null) "os_image = ${cfg.config.osImage}")
    );
  };
}
