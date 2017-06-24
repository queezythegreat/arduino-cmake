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
#              Toolchain file variable scope workaround                       #
#=============================================================================#
foreach(VAR
        ARDUINO_SDK_PATH
        ARDUINO_AVRDUDE_CONFIG_PATH
        ARDUINO_AVRDUDE_FLAGS
        ARDUINO_AVRDUDE_PROGRAM
        ARDUINO_BOARDS_PATH
        ARDUINO_BOOTLOADERS_PATH
        ARDUINO_CORES_PATH
        ARDUINO_LIBRARIES_PATH
        ARDUINO_OBJCOPY_EEP_FLAGS
        ARDUINO_OBJCOPY_HEX_FLAGS
        ARDUINO_PLATFORMS
        ARDUINO_PROGRAMMERS_PATH
        ARDUINO_VARIANTS_PATH
        ARDUINO_VERSION_PATH
        AVRSIZE_PROGRAM)
    if(${VAR})
        # Environment variables are always preserved.
        set(ENV{_ARDUINO_CMAKE_WORKAROUND_${VAR}} "${${VAR}}")
    else()
        if($ENV{_ARDUINO_CMAKE_WORKAROUND_${VAR}})
            set(${VAR} "$ENV{_ARDUINO_CMAKE_WORKAROUND_${VAR}}")
            message(DEBUG "RESTORED ${VAR} from env: ${${VAR}}")
        endif()
    endif()
endforeach()

#=============================================================================#
#                         Detect Arduino SDK                                  #
#=============================================================================#
if(NOT ARDUINO_SDK_PATH)
    set(ARDUINO_PATHS)

    foreach(DETECT_VERSION_MAJOR 1)
        foreach(DETECT_VERSION_MINOR RANGE 5 0)
            list(APPEND ARDUINO_PATHS arduino-${DETECT_VERSION_MAJOR}.${DETECT_VERSION_MINOR})
            foreach(DETECT_VERSION_PATCH  RANGE 3 0)
                list(APPEND ARDUINO_PATHS arduino-${DETECT_VERSION_MAJOR}.${DETECT_VERSION_MINOR}.${DETECT_VERSION_PATCH})
            endforeach()
        endforeach()
    endforeach()

    foreach(VERSION RANGE 23 19)
        list(APPEND ARDUINO_PATHS arduino-00${VERSION})
    endforeach()

    if(UNIX)
        file(GLOB SDK_PATH_HINTS /usr/share/arduino*
            /opt/local/arduino*
            /opt/arduino*
            /usr/local/share/arduino*)
    elseif(WIN32)
        set(SDK_PATH_HINTS "C:\\Program Files\\Arduino"
            "C:\\Program Files (x86)\\Arduino"
            )
    endif()
    list(SORT SDK_PATH_HINTS)
    list(REVERSE SDK_PATH_HINTS)

    if(DEFINED ENV{ARDUINO_SDK_PATH})
        list(APPEND SDK_PATH_HINTS $ENV{ARDUINO_SDK_PATH})
    endif()
endif()

find_path(ARDUINO_SDK_PATH
          NAMES lib/version.txt
          PATH_SUFFIXES share/arduino
                        Arduino.app/Contents/Resources/Java/
                        ${ARDUINO_PATHS}
          HINTS ${SDK_PATH_HINTS}
          DOC "Arduino SDK path.")

if(ARDUINO_SDK_PATH)
    list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${ARDUINO_SDK_PATH}/hardware/tools/avr)
    list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${ARDUINO_SDK_PATH}/hardware/tools/avr/utils)
else()
    message(FATAL_ERROR "Could not find Arduino SDK (set ARDUINO_SDK_PATH)!")
endif()

