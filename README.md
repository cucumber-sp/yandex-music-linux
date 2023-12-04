# yandex-music-linux

Нативный клиент Яндекс Музыки для Linux. Создан с помощью перепаковки бета-версии клиента для OSX/Windows

## Скриншоты
![image](https://github.com/cucumber-sp/yandex-music-linux/assets/100789522/ab2f69ee-efc4-4a33-8110-131b4c4ff4de)
![image](https://github.com/cucumber-sp/yandex-music-linux/assets/100789522/de618654-15d1-4103-a323-faa00086d0a2)

## Установка
Доступные архитектуры: x64, arm64. Установка возможна с помощью deb и rpm пакетов или распаковкой архива. Актуальная версия клиента доступна в https://github.com/cucumber-sp/yandex-music-linux/releases

## Самостоятельная сборка
Скачайте файл `repack.sh` и .exe файл клиента. Запустите скрипт с помощью `bash repack.sh <path_to_exe>`. В процессе выберите сборку для нужных архитектур (x64, arm64). Зависимости которые могут понадобиться: `nodejs`, `jq`, `npm`, `7z`, `npm asar`, `rpm-tools`
