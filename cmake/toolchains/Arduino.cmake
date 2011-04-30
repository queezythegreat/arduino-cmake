set(CMAKE_SYSTEM_NAME Arduino)

set(CMAKE_C_COMPILER   avr-gcc)
set(CMAKE_CXX_COMPILER avr-g++)

set(CMAKE_C_FLAGS   "-g -Os -w -ffunction-sections -fdata-sections")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}  -fno-exceptions")

set(CMAKE_EXE_LINKER_FLAGS "-Os -Wl,--gc-sections")
set(CMAKE_SHARED_LINKER_FLAGS)
set(CMAKE_MODULE_LINKER_FLAGS)

set(ARDUINO_PATHS)
foreach(VERSION RANGE 22 1)
    list(APPEND ARDUINO_PATHS arduino-00${VERSION})
endforeach()

find_path(ARDUINO_SDK_PATH
          NAMES lib/version.txt
          PATH_SUFFIXES share/arduino
                        Arduino.app/Contents/Resources/Java/
                        ${ARDUINO_PATHS}
          DOC "Arduino Development Kit path.")

include(Platform/ArduinoPaths)
