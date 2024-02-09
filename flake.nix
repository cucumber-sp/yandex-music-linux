{
  description = "Native Yandex Music desktop client";
  inputs = {
    ymExe.url = https://music-desktop-application.s3.yandex.net/stable/Yandex_Music_x64_5.0.10.exe;
    ymExe.flake = false;
  };
  outputs = { self, ymExe, nixpkgs, flake-utils }:
    let
      yandexmusic-with = pkgs: pkgs.callPackage ./nix {
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
            yandexmusic = yandexmusic-with pkgs;
            yandexmusic-background = yandexmusic.override {
              fixQuit = false;
            };
            yandexmusic-noflakes = pkgs.callPackage ./nix {};
            generate_packages = pkgs.callPackage ./nix/generate_packages.nix {};
            default = yandexmusic;
          };
        }
      ) // {
      modules = [{
        nixpkgs.overlays = [
          (final: prev: {
            yandexmusic = yandexmusic-with prev;
          })
        ];
      }];
    };
}
