#=============================================================================#
# Author: QueezyTheGreat                                                      #
# Date:   26.04.2011                                                          #
#                                                                             #
# Description: Arduino CMake example                                          #
#                                                                             #
#=============================================================================#
set(CMAKE_TOOLCHAIN_FILE cmake/ArduinoToolchain.cmake) # Arduino Toolchain


cmake_minimum_required(VERSION 2.8)
#====================================================================#
#  Setup Project                                                     #
#====================================================================#
project(ArduinoExample C CXX)

# modify flags from default toolchain flags
set(APM_OPT_FLAGS "-Wformat -Wall -Wshadow -Wpointer-arith -Wcast-align -Wwrite-strings -Wformat=2")
#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${APM_OPT_FLAGS} -mcall-prologues -ffunction-sections -fdata-sections")
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${APM_OPT_FLAGS} -mcall-prologues -ffunction-sections -fdata-sections -fno-exceptions -Wno-reorder")
set(CMAKE_EXE_LINKER_FLAGS "-lc -lm ${APM_OPT_FLAGS} -Wl,--gc-sections,--relax")

#add_subdirectory(example)  # Add example directory to build

# projects
#set(ARDUPLANE_SKETCH ${CMAKE_SOURCE_DIR}/ArduPlane)
#set(ARDUPLANE_BOARD mega2560)
#set(ARDUPLANE_PORT /dev/ttyUSB0)
#generate_arduino_firmware(ARDUPLANE)

set(BLINK_SKETCH ${CMAKE_SOURCE_DIR}/Blink)
set(BLINK_BOARD mega2560)
set(BLINK_PORT /dev/ttyUSB0)
generate_arduino_firmware(BLINK)

#set(ARDUCOPTER_SKETCH ${CMAKE_SOURCE_DIR}/ArduCopter)
#set(ARDUCOPTER_BOARD mega2560)
#set(ARDUCOPTER_PORT /dev/ttyUSB0)
#generate_arduino_firmware(ARDUCOPTER)
