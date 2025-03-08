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
, electronArguments ? ""
, trayEnabled ? false
, trayStyle ? 1
, trayAlways ? false
, devTools ? false
, vibeAnimationMaxFps ? 25
, customTitleBar ? false
}:
let
  inherit (lib) optionalString assertMsg;
  version_info = with builtins; fromJSON (readFile ../utility/version_info.json);
in
assert assertMsg (trayStyle >= 1 && trayStyle <= 3) "Tray style must be withing 1 and 3";
assert assertMsg (vibeAnimationMaxFps >= 0) "Vibe animation max FPS must be greater then 0";
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

  config =''
    ELECTRON_ARGS="${electronArguments}"
    VIBE_ANIMATION_MAX_FPS=${toString vibeAnimationMaxFps}
  '' + optionalString trayEnabled ''
    TRAY_ENABLED=${toString trayStyle}
  '' + optionalString trayAlways ''
    ALWAYS_LEAVE_TO_TRAY=1
  '' + optionalString devTools ''
    DEV_TOOLS=1
  '' + optionalString customTitleBar ''
    CUSTOM_TITLE_BAR=1
  '';

  installPhase = ''
    mkdir -p "$out/share/nodejs"
    mv app/yandex-music.asar "$out/share/nodejs"

    CONFIG_FILE="$out/share/yandex-music.conf"
    echo "$config" >> "$CONFIG_FILE"

    install -Dm755 "$ymScript" "$out/bin/yandex-music"
    sed -i "s|%electron_path%|${electron}/bin/electron|g" "$out/bin/yandex-music"
    sed -i "s|%asar_path%|$out/share/nodejs/yandex-music.asar|g" "$out/bin/yandex-music"

    wrapProgram "$out/bin/yandex-music" \
      --set-default YANDEX_MUSIC_CONFIG "$CONFIG_FILE"

    install -Dm644 "./app/favicon.png" "$out/share/pixmaps/yandex-music.png"
    install -Dm644 "./app/favicon.png" "$out/share/icons/hicolor/48x48/apps/yandex-music.png"
    install -Dm644 "./app/favicon-512x512.png" "$out/usr/share/icons/hicolor/512x512/apps/yandex-music.png"
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
