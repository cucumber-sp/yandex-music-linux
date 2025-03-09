/*
  This is set of tests of yandex-music application. The main purpose of this
  test is to check the NixOS module for yandex-music and whether its runs
  successfully with such configuration.
*/
{
  pkgs,
  yandex-music-with,
  nixosModule,
  linkFarm,
  lib,
}:
let
  # Extend packages with our package to overcome the limitation of nixOSTest
  # modules regarding the overlays.
  pkgs' = pkgs.extend (cur: prev: { yandex-music = yandex-music-with prev; });
  removeNameAttr = attrs: lib.removeAttrs attrs [ "name" ];
  test-suite =
    {
      name ? "yandex-music-test",
      ...
    }@configuration:
    pkgs'.callPackage ./test-suite.nix {
      inherit nixosModule name;
      configuration = removeNameAttr configuration;
    };
  yandex-music-config = cfg: {
    programs.yandex-music = cfg;
  };
  yandex-music-test-suite =
    {
      name,
      ...
    }@cfg:
    test-suite (
      (yandex-music-config (removeNameAttr cfg))
      // {
        name = "yandex-music-test-${name}";
      }
    );
  /*
    This is set of similar tests with slightly different configuration options
    for yandex-music module. All they will be joined together to package with
    symlinks to all results.
  */
  tests = {
    base = test-suite { };
    trayDefault = yandex-music-test-suite {
      tray.enable = true;
      name = "tray-default";
    };
    trayAlways = yandex-music-test-suite {
      tray.enable = true;
      tray.always = true;
      name = "tray-always";
    };
    trayMonoBlack = yandex-music-test-suite {
      tray.enable = true;
      tray.style = 2;
      name = "tray-mono-black";
    };
    trayMonoWhite = yandex-music-test-suite {
      tray.enable = true;
      tray.style = 3;
      name = "tray-mono-white";
    };
    devTools = yandex-music-test-suite {
      devTools.enable = true;
      name = "dev-tools";
    };
    customTitleBar = yandex-music-test-suite {
      customTitleBar.enable = true;
      name = "custom-title-bar";
    };
    animatiosFpsZero = yandex-music-test-suite {
      vibeAnimationMaxFps = 0;
      name = "animation-fps-zero";
    };
  };
in
(linkFarm "yandex-music-test-all" tests) // tests
