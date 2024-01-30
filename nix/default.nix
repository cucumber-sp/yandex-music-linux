{ fetchurl
, runCommand
, writeShellApplication
, makeDesktopItem
, symlinkJoin

, p7zip
, asar
, electron
, jq

, ymExe
}:
let
  app = runCommand "yandex-music-app"
    {
      nativeBuildInputs = [ p7zip asar jq ];
      repack = ./../repack.sh;
      src = ymExe;
    } ''
    bash "$repack" -x -o "$out" "$src"
  '';
  launcher = writeShellApplication {
      name = "yandex-music";
      runtimeInputs = [ electron ];
      text = ''
        electron ${app} "$@"
      '';
    };
  desktopItem = makeDesktopItem {
    name = "yandex-music";
    desktopName = "Yandex Music";
    comment = "Yandex Music - we collect music for you";
    exec = "${launcher}/bin/yandex-music";
    terminal = false;
    icon = "${app}/build/next-desktop/favicon.svg";
    categories = [ "Audio" "Music" "Player" "AudioVideo" ];
    extraConfig = {
      "Name[ru]" = "Яндекс Музыка";
      "Comment[ru]" = "Яндекс Музыка — собираем музыку для вас";
    };
  };
in
symlinkJoin {
  name = "yandex-music";
  paths = [ launcher desktopItem ];
}
