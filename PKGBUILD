# Maintainer: Andrey Onischenko loraner123@gmail.com

pkgname=yandexmusic
pkgver="5.0.10"
pkgrel="1"
pkgdesc="Yandex Music - Personal recommendations, selections for any occasion and new music"
arch=("any")
url="https://github.com/cucumber-sp/yandex-music-linux"
license=("custom")
depends=("electron" "libpulse" "xdg-utils")
makedepends=("p7zip" "nodejs" "asar" "jq")

source=("https://music-desktop-application.s3.yandex.net/stable/Yandex_Music_x64_5.0.10.exe" "git+https://github.com/cucumber-sp/yandex-music-linux")
sha256sums=("cd8d86ab8cc27c215726599e40482b2aab90a33fb0a98d883e4f7e985d7cb725" "SKIP")

build() {
    sh "$srcdir/yandex-music-linux/repack.sh" "$srcdir/Yandex_Music_x64_5.0.10.exe"
}

package() {
    mkdir -p "$pkgdir/usr/lib/yandexmusic"
    mkdir -p "$pkgdir/usr/share/applications"
    mkdir -p "$pkgdir/usr/bin"

    install -Dm644 "$srcdir/app/yandexmusic.asar" "$pkgdir/usr/lib/yandexmusic/yandexmusic.asar"
    install -Dm644 "$srcdir/app/favicon.png" "$pkgdir/usr/share/pixmaps/yandexmusic.png"
    install -Dm644 "$srcdir/yandex-music-linux/templates/desktop" "$pkgdir/usr/share/applications/yandexmusic.desktop"
    install -Dm644 "$srcdir/yandex-music-linux/LICENSE.md" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"

    # Create a script to launch the app with Electron
    echo "#!/bin/sh" > "$pkgdir/usr/bin/yandexmusic"
    echo 'exec electron /usr/lib/yandexmusic/yandexmusic.asar "$@"' >> "$pkgdir/usr/bin/yandexmusic"
    chmod 755 "$pkgdir/usr/bin/yandexmusic"
}
