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

print_board_list()
print_programmer_list()

generate_arduino_example(Wire master_writer uno /dev/ttyACM0)

generate_arduino_firmware(blink
    SKETCH ${CMAKE_SOURCE_DIR}/example/Blink
    BOARD diecimila
    PORT /dev/ttyUSB0
    PROGRAMMER usbtinyisp
    AFLAGS -V
    NO_AUTOLIBS)


# Alternative way of specifying options:
#
#set(blink_SKETCH ${CMAKE_SOURCE_DIR}/example/Blink)
#set(blink_BOARD diecimila)
#set(blink_PORT /dev/ttyUSB0)
#set(blink_NO_AUTOLIBS True)
#set(blink_PROGRAMMER usbtinyisp)
#set(blink_AFLAGS -V)
#
#generate_arduino_firmware(blink)
