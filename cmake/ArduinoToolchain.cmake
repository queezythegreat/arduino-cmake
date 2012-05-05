#=============================================================================#
# Author: Tomasz Bogdal (QueezyTheGreat)
# Home:   https://github.com/queezythegreat/arduino-cmake
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#=============================================================================#
set(CMAKE_SYSTEM_NAME Arduino)

set(CMAKE_C_COMPILER   avr-gcc)
set(CMAKE_CXX_COMPILER avr-g++)

# Add current directory to CMake Module path automatically
if(EXISTS  ${CMAKE_CURRENT_LIST_DIR}/Platform/Arduino.cmake)
    set(CMAKE_MODULE_PATH  ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR})
endif()

#=============================================================================#
#                         System Paths                                        #
#=============================================================================#
if(UNIX)
    include(Platform/UnixPaths)
    if(APPLE)
        list(APPEND CMAKE_SYSTEM_PREFIX_PATH ~/Applications
                                             /Applications
                                             /Developer/Applications
                                             /sw        # Fink
                                             /opt/local) # MacPorts
    endif()
elseif(WIN32)
    include(Platform/WindowsPaths)
endif()


#=============================================================================#
#                         Detect Arduino SDK                                  #
#=============================================================================#
if(NOT ARDUINO_SDK_PATH)
    set(ARDUINO_PATHS)
    foreach(VERSION 22 1)
        list(APPEND ARDUINO_PATHS arduino-00${VERSION})
    endforeach()

    file(GLOB SDK_PATH_HINTS /usr/share/arduino*
                             /opt/local/ardiuno*
                             /usr/local/share/arduino*)
    list(SORT SDK_PATH_HINTS)
    list(REVERSE SDK_PATH_HINTS)
endif()

find_path(ARDUINO_SDK_PATH
          NAMES lib/version.txt
          PATH_SUFFIXES share/arduino
                        Arduino.app/Contents/Resources/Java/
                        ${ARDUINO_PATHS}
          HINTS ${SDK_PATH_HINTS}
          DOC "Arduino SDK path.")

if(ARDUINO_SDK_PATH)
    list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${ARDUINO_SDK_PATH}/hardware/tools/avr/bin)
    list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${ARDUINO_SDK_PATH}/hardware/tools/avr/utils/bin)
else()
    message(FATAL_ERROR "Could not find Arduino SDK (set ARDUINO_SDK_PATH)!")
endif()
