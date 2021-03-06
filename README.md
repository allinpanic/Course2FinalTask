# Дипломная работа по курсу iOS разработки
### Описание
* Авторизация пользователя
* Отображение ленты публикаций 
* Подписка отписка от пользователей
* Можно ставить и убирать лайки с постов
* Просмотр списков подписчиков/подписок/пользователей айкнувших пост
* Публикация нового изображения с наложением фильтра
* Просмотр профилей пользователей
* При успешной авторизации token сохраняется в keychain, при последующих запусках не нужно проходить этап авторизации, если token все еще валиден
* При отсутствии подключения к сети и наличии token в keychain приложение переходит в оффлайн режим - можно просматривать ленту и данные о текущем пользователе
* MVC архитектура

Приложение использует локальный сервер, для запуска сервера смотри инструкцию
### Demo
![Demo](Demo.GIF)

## Инструкция по запуску сервера
* Перед запуском вам необходимо установить Vapor. Это фреймворк для создания веб серверов на Swift. Для его установки можно воспользоваться пакетным менеджером brew. Если у вас его еще нет выполните в терминале эту команду /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
* Далее воспользуйтесь командой brew install vapor/tap/vapor для установки самого фреймворка. Если не установлена libressl произведите установку brew install libressl
* Для установки выполнить команду в директории проекта: sudo xattr -d com.apple.quarantine Run (файл Run должен быть в папке с проектом)
* Для деактивации, первый раз, Перегружаем комп
* Для запуска сервера откройте терминал, с помощью команды cd перейдите в папку с сервером и выполните ./Run. * Для остановки сервера нажмите ctrl+c либо просто закройте терминал.
* Запускать сервер нужно обязательно так иначе он не найдет изображения в папке Public. Папка Public должна обязательно находиться рядом с исполняемым файлом. После перезапуска сервер возвращается в исходное состояние.
* Для входа в приложение используйте логин user и пароль qwerty


