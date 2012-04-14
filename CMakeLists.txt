#=============================================================================#
# Author: QueezyTheGreat                                                      #
# Date:   26.04.2011                                                          #
#                                                                             #
# Description: Arduino CMake example                                          #
#                                                                             #
#=============================================================================#
set(CMAKE_MODULE_PATH    ${CMAKE_SOURCE_DIR}/cmake/modules)  # CMake module search path
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/cmake/toolchains/Arduino.cmake) # Arduino Toolchain


cmake_minimum_required(VERSION 2.8)
#====================================================================#
#  Setup Project                                                     #
#====================================================================#
project(ArduinoExample C CXX)
find_package(Arduino 1.0 REQUIRED)

add_subdirectory(example)  # Add example directory to build

# modify flags from default toolchain flags
set(APM_OPT_FLAGS "-Wformat -Wall -Wshadow -Wpointer-arith -Wcast-align -Wwrite-strings -Wformat=2")

set(ARDUINO_C_FLAGS "${APM_OPT_FLAGS} -mcall-prologues -ffunction-sections -fdata-sections")
set(ARDUINO_CXX_FLAGS "${APM_OPT_FLAGS} -mcall-prologues -ffunction-sections -fdata-sections -fno-exceptions -Wno-reorder")
set(ARDUINO_LINKER_FLAGS "-lc -lm ${APM_OPT_FLAGS} -Wl,--gc-sections")

# projects
set(ARDUPLANE_SKETCH ${CMAKE_SOURCE_DIR}/ArduPlane)
set(ARDUPLANE_BOARD mega2560)
set(ARDUPLANE_PORT /dev/ttyUSB0)
generate_arduino_firmware(ARDUPLANE)

set(ARDUCOPTER_SKETCH ${CMAKE_SOURCE_DIR}/ArduCopter)
set(ARDUCOPTER_BOARD mega2560)
set(ARDUCOPTER_PORT /dev/ttyUSB0)
generate_arduino_firmware(ARDUCOPTER)
