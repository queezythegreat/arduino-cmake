#=============================================================================#
# Author: QueezyTheGreat                                                      #
# Date:   26.04.2011                                                          #
#                                                                             #
# Description: Arduino CMake example                                          #
#                                                                             #
#=============================================================================#
cmake_minimum_required(VERSION 2.8)
project(ARDUINO C CXX)

# -----------------------------------------------------------------------------
# Enable SuperBuild option
# -----------------------------------------------------------------------------
option(ARDUINO_SUPERBUILD "Superbuild option." ON)

if(ARDUINO_SUPERBUILD)
  include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/SuperBuild.cmake)
  return()
endif(ARDUINO_SUPERBUILD)

#====================================================================#
#  Setup Project                                                     #
#====================================================================#
print_board_list()
print_programmer_list()
#
add_subdirectory(example)   #add the example directory into build
