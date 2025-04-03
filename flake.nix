{
  description = "Native Yandex Music desktop client";

  inputs = {
    ymExe.url = "https://music-desktop-application.s3.yandex.net/stable/Yandex_Music_x64_5.44.3.exe";
    ymExe.flake = false;

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      ymExe,
      nixpkgs,
      flake-utils,
    }:
    let
      yandex-music-with =
        pkgs:
        pkgs.callPackage ./nix {
          inherit ymExe;
        };
      modules =
        {
          isHm ? false,
          isTest ? false,
        }:
        rec {
          yandex-music = {
            imports = [ (import ./nix/module.nix { inherit isHm isTest yandex-music-with; }) ];
          };
          default = yandex-music;
        };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = rec {
          yandex-music = yandex-music-with pkgs;
          yandex-music-noflakes = pkgs.callPackage ./nix { };
          default = yandex-music;
          tests = pkgs.callPackage ./nix/test.nix {
            nixosModule = (modules { isTest = true; }).yandex-music;
            inherit yandex-music-with;
          };
        };
        formatter = pkgs.nixfmt-rfc-style;
      }
    )
    // {
      nixosModules = modules { };
      homeManagerModules = modules { isHm = true; };

      nixosModule = self.nixosModules.default;
    };
}
