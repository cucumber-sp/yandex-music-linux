const commonOptions = {
  icon: {
    "48x48": "build/next-desktop/favicon.png",
    "scalable": "build/next-desktop/favicon.svg"
  },
  desktopTemplate: "./desktop.ejs"
}

module.exports = {
  packagerConfig: {
    asar: true,
  },
  rebuildConfig: {},
  makers: [
    {
      name: '@electron-forge/maker-zip',
      platforms: ['linux']
    },
    {
      name: '@electron-forge/maker-deb',
      config: {
        options: {
          ...commonOptions,
          maintainer: 'Cucumber Space',
          homepage: 'https://github.com/cucumber-sp/yandex-music-linux'
        }
      }
    },
    {
      name: '@electron-forge/maker-rpm',
      config: {
        options: {
          ...commonOptions,
          homepage: 'https://github.com/cucumber-sp/yandex-music-linux'
        }
      }
    }
  ],
  plugins: [
    {
      name: '@electron-forge/plugin-auto-unpack-natives',
      config: {},
    },
  ],
};