#=============================================================================#
# Author: QueezyTheGreat                                                      #
# Date:   26.04.2011                                                          #
#                                                                             #
# Description: Arduino CMake example                                          #
#                                                                             #
#=============================================================================#
set(CMAKE_MODULE_PATH    ${CMAKE_SOURCE_DIR}/cmake/modules)  # CMake module search path
set(CMAKE_TOOLCHAIN_FILE ArduinoToolchain) # Arduino Toolchain


cmake_minimum_required(VERSION 2.8)
#====================================================================#
#  Setup Project                                                     #
#====================================================================#
project(ArduinoExample C CXX)
#find_package(Arduino 1.0 REQUIRED)

add_subdirectory(example)  # Add example directory to build
