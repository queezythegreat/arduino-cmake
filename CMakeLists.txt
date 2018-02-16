#=============================================================================#
# Author: QueezyTheGreat                                                      #
# Date:   26.04.2011                                                          #
#                                                                             #
# Description: Arduino CMake example                                          #
#                                                                             #
#=============================================================================#

# this line is needed only if you use boards with selectable cpu (like mega, pro etc)
# and this line should go before call to "cmake/ArduinoToolchain.cmake"
# this is durty hack and should be fixed somewhen, because it should go to 
# particular cmake subdirectory

set(CMAKE_TOOLCHAIN_FILE cmake/ArduinoToolchain.cmake) # Arduino Toolchain


cmake_minimum_required(VERSION 2.8)
#====================================================================#
#  Setup Project                                                     #
#====================================================================#
project(ArduinoExample)

#print_board_list()
#print_programmer_list()

# add libraries to project
link_directories(${ARDUINO_SDK}/libraries)

# add the project directory into build
add_subdirectory(example)
#add_subdirectory(example_esp32)
#add_subdirectory(example_ap)
