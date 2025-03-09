{
  yandex-music-with,
  isHm ? false,
  isTest ? false,
}:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.yandex-music;

in
{
  /*
    The NixOS test framework disallow to extend `nixpkgs.overlays` configuration
    option, so we make it here conditionally.
  */
  imports = [
    (lib.mkIf (!isTest) {
      nixpkgs.overlays = [
        (final: prev: {
          yandex-music = yandex-music-with prev;
        })
      ];
    })
  ];

  options = {
    programs.yandex-music = {
      enable = lib.mkEnableOption "yandex music application";
      tray.enable = lib.mkEnableOption "tray icon for yandex music application";
      tray.style = lib.mkOption {
        description = "Style of tray icon. 1 is default, 2 is mono black, 3 is mono white";
        default = 1;
        type = lib.types.ints.between 1 3;
      };
      tray.always = lib.mkEnableOption "leave in tray disregarding of play state";
      devTools.enable = lib.mkEnableOption "development tools";
      vibeAnimationMaxFps = lib.mkOption {
        description = ''
          Vibe animation FPS from 0 (black screen) to to any reasonable number.
          Recommended `25` - `144`
        '';
        default = 25;
        type = lib.types.ints.unsigned;
      };
      customTitleBar.enable = lib.mkEnableOption ''
        Yandex Music's custom Windows-styled titlebar
      '';
      electronArguments = lib.mkOption {
        description = "Extra electron arguments";
        example = "--no-sandbox --trace-warnings";
        type = lib.types.str;
        default = "";
      };
      package = lib.mkOption {
        description = "Finalized package of yandex music application";
        type = lib.types.package;
        default = pkgs.yandex-music.override {
          trayEnabled = cfg.tray.enable;
          trayStyle = cfg.tray.style;
          trayAlways = cfg.tray.always;
          devTools = cfg.devTools.enable;
          customTitleBar = cfg.customTitleBar.enable;

          inherit (cfg) electronArguments vibeAnimationMaxFps;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    if isHm then
      {
        home.packages = [
          cfg.package
        ];
      }
    else
      {
        environment.systemPackages = [
          cfg.package
        ];
      }
  );
}
