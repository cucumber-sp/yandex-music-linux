Name: yandex-music
Version: %version%
Release: 1
Summary: Yandex Music Client
License: Custom
URL: https://github.com/cucumber-sp/yandex-music-linux

Source0: %source_tarball%

BuildArch: %arch%

Requires: (kde-cli-tools or kde-cli-tools5 or kde-runtime or trash-cli or glib2 or gvfs-client), (libXtst or libXtst6), (libnotify or libnotify4), (libxcb or libxcb1), (mesa-libgbm or libgbm1), (nss or mozilla-nss), at-spi2-core, gtk3, libdrm, xdg-utils

%description
Yandex Music - Personal recommendations, selections for any occasion and new music

%prep
%setup -q

%install

cp -r ./usr %{buildroot}/
chmod 755 %{buildroot}/usr/bin/yandex-music


%files
/usr/