# Maintainer: Andrey Onischenko loraner123@gmail.com

pkgname=yandexmusic
pkgver="5.0.8"
pkgrel="1"
pkgdesc="Yandex Music Client"
arch=("any")
url="https://github.com/cucumber-sp/yandex-music-linux"
license=("custom")
depends=("electron" "libpulse")
makedepends=("p7zip" "nodejs" "jq")

source=("https://music-desktop-application.s3.yandex.net/stable/Yandex_Music_x64_5.0.8.exe" "git+https://github.com/cucumber-sp/yandex-music-linux")
sha256sums=("78b4e1acb61becbbddeb6f48e9d2b55ed7d718cd99c205b89a94f7c3af9df803" "SKIP")

prepare() {
    npm install @electron/asar;
}

build() {
    sh "$srcdir/yandex-music-linux/repack.sh" "$srcdir/Yandex_Music_x64_5.0.8.exe"
}

package() {
    mkdir -p "$pkgdir/usr/lib/yandexmusic"
    mkdir -p "$pkgdir/usr/share/applications"
    mkdir -p "$pkgdir/usr/bin"

    install -Dm644 "$srcdir/yandex-music-linux/out/yandexmusic.asar" "$pkgdir/usr/lib/yandexmusic/yandexmusic.asar"
    install -Dm644 "$srcdir/yandex-music-linux/templates/desktop" "$pkgdir/usr/share/applications/yandexmusic.desktop"
    install -Dm644 "$srcdir/yandex-music-linux/LICENSE.md" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
    install -Dm644 "$srcdir/yandex-music-linux/templates/icon.png" "$pkgdir/usr/share/pixmaps/yandexmusic.png"

    # Create a script to launch the app with Electron
    echo "#!/bin/sh" > "$pkgdir/usr/bin/yandexmusic"
    echo "electron /usr/lib/yandexmusic/yandexmusic.asar" >> "$pkgdir/usr/bin/yandexmusic"
    chmod 755 "$pkgdir/usr/bin/yandexmusic"
}
