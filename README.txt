Arduino Cmake Example Project
===============================

English readme: /README.english.txt

Здесь находится проект с примером настроек cmake для работы с arduino.
Корректно загружается и работает в CLion, используя toolchain 
из Arduino IDE 1.6+. 

Протестированные настройки работают на Windows и MinGW, но всё так же 
должно работать на linux и mac со стандартными пакетами cmake/make.

Оригинальный код проекта распространяется под лицензией
Mozilla Public License, v. 2.0 http://mozilla.org/MPL/2.0/

Список авторов и контрибьюторов оригинального проекта
описан в /README.original.rst

Полезные ссылки
-------------------------------
Оригинальный проект находится по адресу 
https://github.com/queezythegreat/arduino-cmake

В текущем же репозитории находится его копия с наложенными патчами, 
взятыми из pull requests отсюда 
https://github.com/queezythegreat/arduino-cmake/pulls
и написанными мной патчами, закрывающими ряд багов, 
и добавляющими ряд фич.

Некоторые примеры настроек проекта для CLion взяты из статьи 
http://habrahabr.ru/post/247017/

Изменения по сравнению с оригиналом
-------------------------------
1. Наложен патч "Adding support for SDK 1.5"
    https://github.com/queezythegreat/arduino-cmake/pull/104
    Добавлена поддержка Arduino 1.5-1.6.

2. Наложен патч "fixed bug in find_file method"
    https://github.com/queezythegreat/arduino-cmake/pull/109
    Стандартные пути окружения windows не учитываются при поиске Arduino IDE.

3. Наложен патч "Fix CMP0038 warnings on CMake >= 3.0"
    https://github.com/queezythegreat/arduino-cmake/pull/143

4. Исправлены пути windows для того, чтобы avr-size писал размер 
    скомпиллированного бинарника при сборке.

5. Исправлены пути, по которым ищутся настройки в boards.txt для остальных 
    плат кроме mega, так как заливка скетча работала только с mega, так как 
    неверно определялся программатор.

6. Все опции сборки взяты по максимому из оригинальной IDE, и скорее всего
    сделано не оптимально и требует более детального анализа.

7. Убрал различия между всеми видами сборки, и это деструктивное изменение, 
    которое не нужно мёрджить с основным проектом. Я так сделал потому-что 
    не стал разбираться как лучше всего выбрать опции и для каких режимов (debug, release).

8. Оригинальный Readme сохранён в README.original.rst

Установка CLion + Arduino IDE + MinGW
-----------------------------------
1. Установить MinGW (нужно для CLion, добавляет make, g++, cpp)

Этот пункт нужен только для установки на windows. Под другим OS его нужно пропустить 
и переходить к следующему пункту - "2. Установка Arduino IDE".

1.1. Установить MinGW
    http://sourceforge.net/projects/mingw/files/Installer/
    Тестировалось на версии mingw-get-0.6.2-mingw32-beta-20131004-1

1.2. Запустить MinGW Installation Manager

1.3. Выбрать пакеты из "Basic Setup"
    - mingw-developer-toolkit
    - mingw32-base
    - mingw32-gcc-g++
    - msys-base
и нажать "Apply Changes"

2. Установить Arduino IDE 1.6 (нужен для сборки проекта, включает avr toolchain)
    http://www.arduino.cc/en/Main/OldSoftwareReleases
    Тестировалось на версии 1.6.3

3. Установить и настроить JetBrains CLion 1.0

3.1. Установить JetBrains CLion 1.0
    https://www.jetbrains.com/clion/
    Тестировалось на версии 1.0

3.2. Запустить CLion

3.3. Настроить toolchain
    Меню настроек "File" -> "Settings"
    Выбрать "Build, Execudion, Deployment" -> "Toolchain"
    Дальше сконфигурировать
        - Env: MinGW "c:\mingw"
        - cmake: "bundled cmake"

Пункт MinGW доступен только в windows, поэтому для других OS меню с настройками 
будет проще, и скорее всего сдесь вообще ничего не придётся менять, и всё будет 
работать из коробки.

После этого cmake должен правильно собирать проект.
Всё, что для этого потребуется - это открыть проект в CLion.

Портирование вашего проекта из Arduino IDE
-----------------------------------
Предположим, у вас есть свой проект, с названием Robot и файлами
- /Robot.ino 
- /Chassis.cpp
- /Chassis.h
который уже работает в Arduino IDE, и вы хотите его перенести в CLion.

1. Создаём новый проект с названием arduino-cmake-robot
    git clone {THIS_REPO} arduino-cmake-robot
Нам больше не потребуется связь с оригинальным проектом, 
мы в дальнейшем будем работать со своим репозиторием.
    git remote rm origin

2. Копируем файлы проекта Robot
Создаём папку /robot в корне нового проекта.
Копируем файлы в эту папку, теперь у нас три новых файла в новом проекте
    - /robot/Robot.ino
    - /robot/Chassis.cpp
    - /robot/Chassis.h

3. Переименовываем Robot.ino в robot.cpp
Теперь у нас старые файлы в новом проекте с такими названиями
    - /robot/robot.cpp
    - /robot/Chassis.cpp
    - /robot/Chassis.h

4. Подключаем стандартную библиотеку Arduino
Добавляем в /robot/robot.cpp первой строчкой 
    #include "Arduino.h"

5. Создаём файл с настройками сборки проекта
Копируем /example/CMakeLists.txt в /robot/CMakeLists.txt

6. Настраиваем CMakeLists.txt проекта robot (/robot/CMakeLists.txt)
Указываем название проекта
    set(PROJECT_NAME robot)

Указываем название платформы, под которую собираем.
Пример 1. Для примера это Arduino Pro (Arduino Pro Mini)
    set(${PROJECT_NAME}_BOARD pro)
Пример 2. Для Arduino UNO это бы выглядело так
    set(${PROJECT_NAME}_BOARD uno)

Указываем название файла, который раньше был с расширением INO
    set(${PROJECT_NAME}_SRCS robot.cpp)
Указываем нужный COM порт, к которому подключается плата
    set(${PROJECT_NAME}_PORT COM3)

7. Настраиваем корневой CMakeLists.txt (/CMakeLists.txt)
Выбираем правильный вариант процессора для платы
Это название берётся из файла
    C:\Program Files (x86)\Arduino\hardware\arduino\avr\boards.txt
Этот путь для windows, а для других платформ будет другой путь, 
но похожий на "hardware\arduino\avr\boards.txt".

Пример 1. Для Arduino Pro 16Mhz 5V ATmega 328
нужно смотреть строчку "pro.menu.cpu.16MHzatmega328=ATmega328 (5V, 16 MHz)"
и брать соответствующий идентификатор "16MHzatmega328", а не название "ATmega328 (5V, 16 MHz)"
     set(ARDUINO_CPU 16MHzatmega328)
Пример 2. Для Arduino UNO нужно ничего не указывать, просто закомментировать строчку,
потому что для UNO нет выбора процессоров
    # (закомментировали) set(ARDUINO_CPU 16MHzatmega328)

Подключаем нужную папку, меняем example на robot
    # (закомментировали) add_subdirectory(example)
    add_subdirectory(robot)

8. Открываем проект в CLion и выбираем опцию сборки robot (для компилляции) 
или robot_upload (для компилляции и закрузки). 
Собираем проект (CTRL+F9). Проект загружается на плату.
