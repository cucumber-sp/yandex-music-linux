# Maintainer: Andrey Onischenko loraner123@gmail.com

pkgname=yandex-music
pkgver="5.0.13"
pkgrel="1"
pkgdesc="Yandex Music - Personal recommendations, selections for any occasion and new music"
arch=("any")
url="https://github.com/cucumber-sp/yandex-music-linux"
license=("custom")
depends=("electron27" "libpulse" "xdg-utils")
makedepends=("p7zip" "nodejs" "asar" "jq" "python")

source=("https://music-desktop-application.s3.yandex.net/stable/Yandex_Music_x64_5.0.13.exe" "git+https://github.com/cucumber-sp/yandex-music-linux")
sha256sums=("37eb4f1f346a2faa317bc4660c7cda17bc6aaa4a2f8cf6bc190ea8d80fe980eb" "SKIP")

build() {
    sh "$srcdir/yandex-music-linux/repack.sh" "$srcdir/Yandex_Music_x64_5.0.13.exe"
}

package() {
    mkdir -p "$pkgdir/usr/lib/yandex-music"
    mkdir -p "$pkgdir/usr/share/applications"
    mkdir -p "$pkgdir/usr/bin"

    install -Dm644 "$srcdir/app/yandex-music.asar" "$pkgdir/usr/lib/yandex-music/yandex-music.asar"

    install -Dm644 "$srcdir/app/favicon.png" "$pkgdir/usr/share/pixmaps/yandex-music.png"
    install -Dm644 "$srcdir/app/favicon.png" "$pkgdir/usr/share/icons/hicolor/48x48/apps/yandex-music.png"
    install -Dm644 "$srcdir/app/favicon.svg" "$pkgdir/usr/share/icons/hicolor/scalable/apps/yandex-music.svg"

    install -Dm644 "$srcdir/yandex-music-linux/templates/desktop" "$pkgdir/usr/share/applications/yandex-music.desktop"
    install -Dm644 "$srcdir/yandex-music-linux/LICENSE.md" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"

    # Create a script to launch the app with Electron
    echo "#!/bin/sh" > "$pkgdir/usr/bin/yandex-music"
    echo 'exec electron27 /usr/lib/yandex-music/yandex-music.asar "$@"' >> "$pkgdir/usr/bin/yandex-music"
    chmod 755 "$pkgdir/usr/bin/yandex-music"
}
