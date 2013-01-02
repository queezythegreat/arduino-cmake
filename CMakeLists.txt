#=============================================================================#
# Author: QueezyTheGreat                                                      #
# Date:   26.04.2011                                                          #
#                                                                             #
# Description: Arduino CMake example                                          #
#                                                                             #
#=============================================================================#
# set(CMAKE_TOOLCHAIN_FILE cmake/ArduinoToolchain.cmake) # Arduino Toolchain


cmake_minimum_required(VERSION 2.8)
#====================================================================#
#  Setup Project                                                     #
#====================================================================#
project(ARDUINO C CXX)

# -----------------------------------------------------------------------------
# Path to IBTK cmake modules
# -----------------------------------------------------------------------------
set(ARDUINO_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

#-----------------------------------------------------------------------------
# Update CMake module path
#
set(CMAKE_MODULE_PATH ${ARDUINO_MODULE_PATH} ${CMAKE_MODULE_PATH})


include(cmake/SuperBuild/CMakeLists.txt)

# print_board_list()
# print_programmer_list()
# 
# add_subdirectory(example)   #add the example directory into build
