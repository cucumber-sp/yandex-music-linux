# Maintainer: Andrey Onischenko loraner123@gmail.com

pkgname=yandex-music
pkgver=5.69.1
pkgrel=1
pkgdesc="Yandex Music - Personal recommendations, selections for any occasion and new music"
arch=("any")
url="https://github.com/cucumber-sp/yandex-music-linux"
license=("Unlicense")
depends=("electron" "libpulse" "xdg-utils" "bash" "hicolor-icon-theme")
makedepends=("p7zip" "nodejs" "asar" "jq" "python" "git")

source=("https://music-desktop-application.s3.yandex.net/stable/Yandex_Music_x64_5.69.1.exe" "git+${url}#tag=v${pkgver}")
sha256sums=("e565ccf3bd836005e2f40f4488c3e4e7bf217b65c50fd83f98d7d7903e7f4f76" "SKIP")

build() {
    bash "$srcdir/yandex-music-linux/repack.sh" "$srcdir/Yandex_Music_x64_5.69.1.exe"
}

package() {
    mkdir -p "$pkgdir/usr/lib/yandex-music"
    mkdir -p "$pkgdir/usr/share/applications"
    mkdir -p "$pkgdir/usr/bin"

    install -Dm644 "$srcdir/app/yandex-music.asar" "$pkgdir/usr/lib/yandex-music/yandex-music.asar"

    install -Dm644 "$srcdir/app/favicon.png" "$pkgdir/usr/share/pixmaps/yandex-music.png"
    install -Dm644 "$srcdir/app/favicon.png" "$pkgdir/usr/share/icons/hicolor/48x48/apps/yandex-music.png"
    install -Dm644 "$srcdir/app/favicon-512x512.png" "$pkgdir/usr/share/icons/hicolor/512x512/apps/yandex-music.png"
    install -Dm644 "$srcdir/app/favicon.svg" "$pkgdir/usr/share/icons/hicolor/scalable/apps/yandex-music.svg"

    install -Dm644 "$srcdir/yandex-music-linux/templates/desktop" "$pkgdir/usr/share/applications/yandex-music.desktop"

    install -Dm644 "$srcdir/yandex-music-linux/templates/default.conf" "$pkgdir/usr/lib/yandex-music/default.conf"

    install -Dm644 "$srcdir/yandex-music-linux/LICENSE.md" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"

    install -Dm755 "$srcdir/yandex-music-linux/templates/yandex-music.sh" "$pkgdir/usr/bin/yandex-music"
    sed -i "s|%electron_path%|/usr/bin/electron|g" "$pkgdir/usr/bin/yandex-music"
    sed -i "s|%asar_path%|/usr/lib/yandex-music/yandex-music.asar|g" "$pkgdir/usr/bin/yandex-music"
}
