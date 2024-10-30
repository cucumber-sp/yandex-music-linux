{ fetchurl
, stdenvNoCC
, lib
, makeWrapper

, p7zip
, asar
, jq
, python3
, electron
, python-pkgs.requests

, ymExe ? null
, electronArguments ? ""
, trayEnabled ? false
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
    python-pkgs.requests
  ];

  repack = ./../repack.sh;
  patches = ./../patches;
  utility = ./../utility;
  icons = ./../icons;
  desktopItem = ../templates/desktop;
  ymScript = ../templates/yandex-music.sh;
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
    cp -r $icons ./icons
    bash "./repack.sh" -o "./app" "$src"
  '';
  dontPatch = true;

  installPhase = ''
    mkdir -p "$out/share/nodejs"
    mv app/yandex-music.asar "$out/share/nodejs"

    CONFIG_FILE="$out/share/yandex-music.conf"
    echo "TRAY_ENABLED=${if trayEnabled then "1" else "0"}" >> "$CONFIG_FILE"
    echo "ELECTRON_ARGS=\"${electronArguments}\"" >> "$CONFIG_FILE"


    install -Dm755 "$ymScript" "$out/bin/yandex-music"
    sed -i "s|%electron_path%|${electron}/bin/electron|g" "$out/bin/yandex-music"
    sed -i "s|%asar_path%|$out/share/nodejs/yandex-music.asar|g" "$out/bin/yandex-music"

    wrapProgram "$out/bin/yandex-music" \
      --set-default YANDEX_MUSIC_CONFIG "$CONFIG_FILE"

    install -Dm644 "./app/favicon.png" "$out/share/pixmaps/yandex-music.png"
    install -Dm644 "./app/favicon.png" "$out/share/icons/hicolor/48x48/apps/yandex-music.png"
    install -Dm644 "./app/favicon.svg" "$out/share/icons/hicolor/scalable/apps/yandex-music.svg"

    install -Dm644 "$desktopItem" "$out/share/applications/yandex-music.desktop"
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
