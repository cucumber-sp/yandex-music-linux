{
  description = "Native Yandex Music desktop client";
  inputs = {
    ymExe = {
      url = https://music-desktop-application.s3.yandex.net/stable/Yandex_Music_x64_5.0.8.exe;
      flake = false;
    };
  };
  outputs = { self, ymExe, nixpkgs, flake-utils }:
    let
      yandex-music-with = pkgs: pkgs.callPackage ./nix {
        inherit ymExe;
      };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          packages = rec {
            yandex-music = yandex-music-with pkgs;
            yandex-music-backgroud = yandex-music.override {
              fixQuit = false;
            };
            default = yandex-music;
          };
        }
      ) // {
      modules = [{
        nixpkgs.overlays = [
          (final: prev: {
            yandex-music = yandex-music-with prev;
          })
        ];
      }];
    };
}
