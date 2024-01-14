{
  description = "Native Yandex Music desktop client";
  inputs = {
    ymExe = {
      url = https://music-desktop-application.s3.yandex.net/stable/Yandex_Music_x64_5.0.6.exe;
      flake = false;
    };
  };
  outputs = { self, ymExe, nixpkgs, flake-utils }:
    let
      yandex_music_with = pkgs: pkgs.callPackage ./. {
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
            yandex_music = yandex_music_with pkgs;
            default = yandex_music;
          };
        }
      ) // {
      modules = [{
        nixpkgs.overlays = [
          (final: prev: {
            yandex_music = yandex_music_with prev;
          })
        ];
      }];
    };
}
