{ yandex-music-with
, isHm ? false
}:
{ lib, pkgs, config, ... }:
let
  cfg = config.programs.yandex-music;

in
{
  imports = [{
    nixpkgs.overlays = [
      (final: prev: {
        yandex-music = yandex-music-with prev;
      })
    ];
  }];

  options = {
    programs.yandex-music = {
      enable = lib.mkEnableOption "yandex music application";
      tray.enable = lib.mkEnableOption "tray icon for yandex music application";
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
          electronArguments = cfg.electronArguments;
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
