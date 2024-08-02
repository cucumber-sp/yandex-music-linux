{
  description = "Native Yandex Music desktop client";

  inputs = {
    ymExe.url = "https://music-desktop-application.s3.yandex.net/stable/Yandex_Music_x64_5.8.3.exe";
    ymExe.flake = false;
  };

  outputs = { self, ymExe, nixpkgs, flake-utils }:
    let
      yandex-music-with = pkgs: pkgs.callPackage ./nix {
        inherit ymExe;
      };
      modules = isHm: rec {
        yandex-music = {
          imports = [ (import ./nix/module.nix { inherit isHm yandex-music-with; }) ];
        };
        default = yandex-music;
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
            yandex-music-noflakes = pkgs.callPackage ./nix { };
            default = yandex-music;
          };
        }
      ) // {
      nixosModules = modules false;
      homeManagerModules = modules true;

      nixosModule = self.nixosModules.default;
    };
}
