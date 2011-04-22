
set(CMAKE_MODULE_PATH    ${CMAKE_SOURCE_DIR}/cmake/modules)
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/cmake/toolchains/Arduino.cmake)

cmake_minimum_required(VERSION 2.8)



project(BarServer C CXX)
find_package(Arduino 22 REQUIRED)

set(FIRMWARE_NAME wire_master_reader)

set(${FIRMWARE_NAME}_BOARD mega2560)
set(${FIRMWARE_NAME}_SRCS wire_master_reader.cpp)
set(${FIRMWARE_NAME}_NO_AUTOLIBS False)

set(${FIRMWARE_NAME}_PORT /dev/ttyUSB0)
set(${FIRMWARE_NAME}_SERIAL picocom @INPUT_PORT@ -b 9600 -l )


generate_arduino_firmware(${FIRMWARE_NAME})
