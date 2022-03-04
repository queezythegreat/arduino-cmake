# Add current directory to CMake Module path automatically
if(EXISTS  ${CMAKE_CURRENT_LIST_DIR}/Platform/Arduino.cmake)
    set(CMAKE_MODULE_PATH  ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR})
endif()
 
include(ArduinoToolchain)

set(TEENSY "" CACHE STRING "Using one of the Teensy boards")

set(CMAKE_C_COMPILER "avr-gcc")
set(CMAKE_CXX_COMPILER "avr-g++")
set(CMAKE_AR "avr-ar")
set(CMAKE_LINKER "avr-ld")
set(CMAKE_NM "avr-nm")
set(CMAKE_OBJCOPY "avr-objcopy")
set(CMAKE_OBJDUMP "avr-objdump")
set(CMAKE_STRIP "avr-strip")
set(CMAKE_RANLIB "avr-ranlib")

set(CMAKE_EXE_LINKER_FLAGS "--specs=nosys.specs" CACHE INTERNAL "")

set(ARDUINO_C_FLAGS "-ffunction-sections -fdata-sections")
set(ARDUINO_CXX_FLAGS "-fno-exceptions -fpermissive -felide-constructors -std=gnu++11")
