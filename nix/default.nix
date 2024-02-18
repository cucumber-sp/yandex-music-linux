{ fetchurl
, stdenvNoCC
, lib
, makeWrapper

, p7zip
, asar
, jq
, python3
, electron

, ymExe ? null
}:
let
  version_info = with builtins; fromJSON (readFile ../utility/version_info.json);
in
stdenvNoCC.mkDerivation
{
  name = "yandex-music";
  inherit (version_info.ym) version;

  nativeBuildInputs = [
    p7zip
    asar
    jq
    python3
    makeWrapper
  ];

  repack = ./../repack.sh;
  patches = ./../patches;
  utility = ./../utility;
  desktopItem = ../templates/desktop;
  src =
    if ymExe != null
    then ymExe
    else
      fetchurl {
        url = version_info.ym.exe_link;
        sha256 = version_info.ym.exe_sha256;
      };

  unpackPhase = ''
    cp -r $repack ./repack.sh
    cp -r $patches ./patches
    cp -r $utility ./utility
    bash "./repack.sh" -o "./app" "$src"
  '';
  dontPatch = true;

  installPhase = ''
    mkdir -p "$out/share/nodejs"
    mv app/yandex-music.asar "$out/share/nodejs"

    # use makeWrapper on electron binary to make it call our asar package
    makeWrapper "${electron}/bin/electron" "$out/bin/yandex-music" \
      --add-flags "$out/share/nodejs/yandex-music.asar"

    mkdir -p "$out/share/pixmaps"
    mkdir -p "$out/share/icons/hicolor/48x48/apps/"
    cp ./app/favicon.png "$out/share/icons/hicolor/48x48/apps/yandex-music.png"
    ln -s ../icons/hicolor/48x48/apps/yandex-music.png "$out/share/pixmaps"

    mkdir -p $out/share/applications
    cp $desktopItem $out/share/applications/yandex-music.desktop
  '';

  meta = {
    description = "Yandex Music - Personal recommendations, selections for any occasion and new music";
    homepage = "https://music.yandex.ru/";
    downloadPage = "https://music.yandex.ru/download/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = [
      {
        name = "Yury Shvedov";
        email = "mestofel13@gmail.com";
        github = "ein-shved";
        githubId = 3513222;
      }
      {
        github = "cucumber-sp";
        githubId = 100789522;
        name = "Andrey Onishchenko";
      }
    ];
  };
}
