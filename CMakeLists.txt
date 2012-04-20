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

option(TEST "Enable testing" ON)
option(DEBUG "Enable debug" ON)

# modify flags from default toolchain flags
set(APM_OPT_FLAGS "-Wformat -Wall -Wshadow -Wpointer-arith -Wcast-align -Wwrite-strings -Wformat=2")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${APM_OPT_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${APM_OPT_FLAGS} -Wno-reorder")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${APM_OPT_FLAGS} -Wl,--relax")

#add_subdirectory(example)  # Add example directory to build

# debug output
if (DEBUG)
    arduino_debug_on()
endif()

# projects
set(BLINK_SKETCH ${CMAKE_SOURCE_DIR}/example/Blink)
set(BLINK_BOARD mega2560)
set(BLINK_PORT /dev/ttyUSB0)
generate_arduino_firmware(BLINK)

if (TEST)
    set(BLINK2_SKETCH ${CMAKE_SOURCE_DIR}/test/Blink2)
    set(BLINK2_BOARD mega)
    set(BLINK2_PORT /dev/ttyUSB0)
    generate_arduino_firmware(BLINK2)

    set(ARDUPLANE_SKETCH ${CMAKE_SOURCE_DIR}/test/ArduPlane)
    set(ARDUPLANE_BOARD mega2560)
    set(ARDUPLANE_PORT /dev/ttyUSB0)
    generate_arduino_firmware(ARDUPLANE)

    #set(ARDUCOPTER_SKETCH ${CMAKE_SOURCE_DIR}/test/ArduCopter)
    #set(ARDUCOPTER_BOARD mega2560)
    #set(ARDUCOPTER_PORT /dev/ttyUSB0)
    #generate_arduino_firmware(ARDUCOPTER)
endif()
