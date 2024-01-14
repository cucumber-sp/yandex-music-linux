{ fetchurl
, runCommand
, writeShellApplication

, p7zip
, asar
, electron
, jq

, ymExe
}:
let
  app = runCommand "yandex_music_app"
    {
      nativeBuildInputs = [ p7zip asar jq ];
      repack = ./repack.sh;
      src = ymExe;
    } ''
    bash "$repack" -xl "$src"
    mv ./app "$out"
  '';
in
writeShellApplication {
  name = "yandex_music";
  runtimeInputs = [ electron ];
  text = ''
    electron ${app}
  '';
}
