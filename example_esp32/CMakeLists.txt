# ESP32 needs some special compilers. Set them here
SET(CMAKE_C_COMPILER "${ARDUINO_SDK_PATH}/hardware/espressif/esp32/tools/xtensa-esp32-elf/bin/xtensa-esp32-elf-gcc")
SET(CMAKE_C_COMPILER_WORKS 1)
SET(CMAKE_CXX_COMPILER "${ARDUINO_SDK_PATH}/hardware/espressif/esp32/tools/xtensa-esp32-elf/bin/xtensa-esp32-elf-g++")
SET(CMAKE_CXX_COMPILER_WORKS 1)
SET(CMAKE_AR "${ARDUINO_SDK_PATH}/hardware/espressif/esp32/tools/xtensa-esp32-elf/bin/xtensa-esp32-elf-ar")
SET(CMAKE_RANLIB "${ARDUINO_SDK_PATH}/hardware/espressif/esp32/tools/xtensa-esp32-elf/bin/xtensa-esp32-elf-ranlib")


# Set a variable for commands below
set(PROJECT_NAME example_esp32)

# Define your project and language
project(${PROJECT_NAME})

set(${PROJECT_NAME}_BOARD featheresp32)

# Define the source code
set(${PROJECT_NAME}_SRCS example_esp32.cpp)

# Define the port for uploading code to the Arduino
set(${PROJECT_NAME}_PORT /dev/ttyUSB2)

# Select a specific upload speed for the board
set(${${PROJECT_NAME}_BOARD}.upload.speed 921600)

# Select a specific flash frequence for the board
set(${${PROJECT_NAME}_BOARD}.build.flash_freq 80m)

# Command to generate code arduino firmware (.hex file)
generate_arduino_firmware(${PROJECT_NAME})
