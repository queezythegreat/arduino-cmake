#=============================================================================#
# register_hardware_platform(HARDWARE_PLATFORM_PATH)
#=============================================================================#
#
#        HARDWARE_PLATFORM_PATH - Hardware platform path
#
# Registers a Hardware Platform path.
# See: http://code.google.com/p/arduino/wiki/Platforms
#
# This enables you to register new types of hardware platforms such as the
# Sagnuino, without having to copy the files into your Arduion SDK.
#
# A Hardware Platform is a directory containing the following:
#
#        HARDWARE_PLATFORM_PATH/
#            |-- bootloaders/
#            |-- cores/
#            |-- variants/
#            |-- boards.txt
#            `-- programmers.txt
#            
#  The board.txt describes the target boards and bootloaders. While
#  programmers.txt the programmer defintions.
#
#  A good example of a Hardware Platform is in the Arduino SDK:
#
#        ${ARDUINO_SDK_PATH}/hardware/arduino/
#
#=============================================================================#
# Author: Tomasz Bogdal (QueezyTheGreat)
# Home:   https://github.com/queezythegreat/arduino-cmake
# Version: 1.0.0
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#=============================================================================#
cmake_minimum_required(VERSION 2.8.5 FATAL_ERROR)

include(CMakeParseArguments)

#=============================================================================#
#                           User Functions                                    
#=============================================================================#

# Registers a hardware package directory.
#
# A hardware package is a directory containing one or more directories
# containing platforms.  A platform defines board definitions and code for a
# single hardware architecture (for example: arm or avr). The platform
# directory would contain the following:
#
#   * boards.txt       - file containing boards definitions
#   * cores/           - folder containing one or more folders with the
#                         implementation of the Arduino API
#   * platform.txt     - file that contains build process definitions
#                         (e.g. compiler and command-line arguments)
#   * programmers.txt  - file with programmer definitions
#   * system/          - folder containing system libraries (e.g. those
#                         supplied by the microcontroller manufacturer)
#   * tools/           - folder containing the toolchain binaries
#   * variants/        - folder containing one or more folders with code
#                         specific to particular hardware variations
#   * bootloaders/     - folder with bootloaders
#   * libraries/       - folder of architecture specific library
#                         implementations
#
#  For more detailed information:
#      http://code.google.com/p/arduino/wiki/Platforms1
#
function(REGISTER_HARDWARE_PACKAGE PACKAGE_PATH)
    string(REGEX REPLACE "/$" "" PACKAGE_PATH ${PACKAGE_PATH})
    get_filename_component(PACKAGE_NAME ${PACKAGE_PATH} NAME)

    if(PACKAGE_NAME)
        string(TOUPPER ${PACKAGE_NAME} PACKAGE_NAME)
        list(FIND ARDUINO_PACKAGES ${PACKAGE_NAME} package_exists)
        if (package_exists EQUAL -1)
            # Find all sub-directories containing `platform.txt` platform definition.
            file(GLOB PACKAGE_FILES "${PACKAGE_PATH}/*")
            foreach(PACKAGE_FILE)
                if (IS_DIRECTORY "${PACKAGE_FILE}" AND EXISTS "${PACKAGE_FILE}/platform.txt")
                    # Valid Hardware Platform...
                    register_hardware_platform("${PACKAGE_NAME}" "${PACKAGE_FILE}")
                endif()
            endforeach()
        endif()
    endif()
endfunction()

#=============================================================================#
# [PUBLIC/USER]
# see documentation at top
#=============================================================================#
function(REGISTER_HARDWARE_PLATFORM PACKAGE_NAME PLATFORM_PATH)
    string(REGEX REPLACE "/$" "" PLATFORM_PATH ${PLATFORM_PATH})
    get_filename_component(PLATFORM ${PLATFORM_PATH} NAME)

    if(PLATFORM)
        string(TOUPPER ${PLATFORM} PLATFORM)
        list(FIND ARDUINO_PLATFORMS ${PLATFORM} platform_exists)

        if (platform_exists EQUAL -1)
            set(${PLATFORM}_PLATFORM_PATH ${PLATFORM_PATH} CACHE INTERNAL "The path to ${PLATFORM}")
            set(ARDUINO_PLATFORMS ${ARDUINO_PLATFORMS} ${PLATFORM} CACHE INTERNAL "A list of registered platforms")

            find_file(${PLATFORM}_CORES_PATH
                  NAMES cores
                  PATHS ${PLATFORM_PATH}
                  DOC "Path to directory containing the Arduino core sources.")

            find_file(${PLATFORM}_VARIANTS_PATH
                  NAMES variants
                  PATHS ${PLATFORM_PATH}
                  DOC "Path to directory containing the Arduino variant sources.")

            find_file(${PLATFORM}_BOOTLOADERS_PATH
                  NAMES bootloaders
                  PATHS ${PLATFORM_PATH}
                  DOC "Path to directory containing the Arduino bootloader images and sources.")

            find_file(${PLATFORM}_PROGRAMMERS_PATH
                NAMES programmers.txt
                PATHS ${PLATFORM_PATH}
                DOC "Path to Arduino programmers definition file.")

            find_file(${PLATFORM}_BOARDS_PATH
                NAMES boards.txt
                PATHS ${PLATFORM_PATH}
                DOC "Path to Arduino boards definition file.")

            mark_as_advanced(
                ARDUINO_PLATFORMS
                ${PLATFORM}_PLATFORM_PATH
                ${PLATFORM}_CORES_PATH
                ${PLATFORM}_BOARDS_PATH
                ${PLATFORM}_PROGRAMMERS_PATH
                ${PLATFORM}_BOOTLOADERS_PATH
                ${PLATFORM}_VARIANTS_PATH
                )

            if(${PLATFORM}_BOARDS_PATH)
                load_arduino_style_settings(${PLATFORM}_BOARDS "${PLATFORM_PATH}/boards.txt")
            endif()

            if(${PLATFORM}_PROGRAMMERS_PATH)
                load_arduino_style_settings(${PLATFORM}_PROGRAMMERS "${ARDUINO_PROGRAMMERS_PATH}")
            endif()

            if(${PLATFORM}_VARIANTS_PATH)
                file(GLOB sub-dir ${${PLATFORM}_VARIANTS_PATH}/*)
                foreach(dir ${sub-dir})
                    if(IS_DIRECTORY ${dir})
                        get_filename_component(variant ${dir} NAME)
                        set(VARIANTS ${VARIANTS} ${variant} CACHE INTERNAL "A list of registered variant boards")
                        set(${variant}.path ${dir} CACHE INTERNAL "The path to the variant ${variant}")
                    endif()
                endforeach()
            endif()

            if(${PLATFORM}_CORES_PATH)
                file(GLOB sub-dir ${${PLATFORM}_CORES_PATH}/*)
                foreach(dir ${sub-dir})
                    if(IS_DIRECTORY ${dir})
                        get_filename_component(core ${dir} NAME)
                        set(CORES ${CORES} ${core} CACHE INTERNAL "A list of registered cores")
                        set(${core}.path ${dir} CACHE INTERNAL "The path to the core ${core}")
                    endif()
                endforeach()
            endif()
        endif()
    endif()
endfunction()








#=============================================================================#
#                        Internal Functions                                   
#=============================================================================#

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# required_variables(MSG msg VARS var1 var2 .. varN)
#
#        MSG  - Message to be displayed in case of error
#        VARS - List of variables names to check
#
# Ensure the specified variables are not empty, otherwise a fatal error is emmited.
#=============================================================================#
function(REQUIRED_VARIABLES)
    cmake_parse_arguments(INPUT "" "MSG" "VARS" ${ARGN})
    error_for_unparsed(INPUT)
    foreach(VAR ${INPUT_VARS})
        if ("${${VAR}}" STREQUAL "")
            message(FATAL_ERROR "${VAR} not set: ${INPUT_MSG}")
        endif()
    endforeach()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# error_for_unparsed(PREFIX)
#
#        PREFIX - Prefix name
#
# Emit fatal error if there are unparsed argument from cmake_parse_arguments().
#=============================================================================#
function(ERROR_FOR_UNPARSED PREFIX)
    set(ARGS "${${PREFIX}_UNPARSED_ARGUMENTS}")
    if (NOT ( "${ARGS}" STREQUAL "") )
        message(FATAL_ERROR "unparsed argument: ${ARGS}")
    endif()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# detect_arduino_version(VAR_NAME)
#
#       VAR_NAME - Variable name where the detected version will be saved
#
# Detects the Arduino SDK Version based on the revisions.txt file. The
# following variables will be generated:
#
#    ${VAR_NAME}         -> the full version (major.minor.patch)
#    ${VAR_NAME}_MAJOR   -> the major version
#    ${VAR_NAME}_MINOR   -> the minor version
#    ${VAR_NAME}_PATCH   -> the patch version
#
#=============================================================================#
function(detect_arduino_version VAR_NAME)
    if(ARDUINO_VERSION_PATH)
        file(READ ${ARDUINO_VERSION_PATH} RAW_VERSION)
        if("${RAW_VERSION}" MATCHES " *[0]+([0-9]+)")
            set(PARSED_VERSION 0.${CMAKE_MATCH_1}.0)
        elseif("${RAW_VERSION}" MATCHES "[ ]*([0-9]+[.][0-9]+[.][0-9]+)")
            set(PARSED_VERSION ${CMAKE_MATCH_1})
        elseif("${RAW_VERSION}" MATCHES "[ ]*([0-9]+[.][0-9]+)")
            set(PARSED_VERSION ${CMAKE_MATCH_1}.0)
        endif()

        if(NOT PARSED_VERSION STREQUAL "")
            string(REPLACE "." ";" SPLIT_VERSION ${PARSED_VERSION})
            list(GET SPLIT_VERSION 0 SPLIT_VERSION_MAJOR)
            list(GET SPLIT_VERSION 1 SPLIT_VERSION_MINOR)
            list(GET SPLIT_VERSION 2 SPLIT_VERSION_PATCH)

            set(${VAR_NAME}       "${PARSED_VERSION}"      PARENT_SCOPE)
            set(${VAR_NAME}_MAJOR "${SPLIT_VERSION_MAJOR}" PARENT_SCOPE)
            set(${VAR_NAME}_MINOR "${SPLIT_VERSION_MINOR}" PARENT_SCOPE)
            set(${VAR_NAME}_PATCH "${SPLIT_VERSION_PATCH}" PARENT_SCOPE)
        endif()
    endif()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_size_script(OUTPUT_VAR)
#
#        OUTPUT_VAR - Output variable that will contain the script path
#
# Generates script used to display the firmware size.
#=============================================================================#
function(SETUP_ARDUINO_SIZE_SCRIPT OUTPUT_VAR)
    set(ARDUINO_SIZE_SCRIPT_PATH ${CMAKE_BINARY_DIR}/CMakeFiles/FirmwareSize.cmake)

    file(WRITE ${ARDUINO_SIZE_SCRIPT_PATH} "
        set(AVRSIZE_PROGRAM ${AVRSIZE_PROGRAM})
        set(AVRSIZE_FLAGS -C --mcu=\${MCU})

        execute_process(COMMAND \${AVRSIZE_PROGRAM} \${AVRSIZE_FLAGS} \${FIRMWARE_IMAGE} \${EEPROM_IMAGE}
                        OUTPUT_VARIABLE SIZE_OUTPUT)


        string(STRIP \"\${SIZE_OUTPUT}\" RAW_SIZE_OUTPUT)

        # Convert lines into a list
        string(REPLACE \"\\n\" \";\" SIZE_OUTPUT_LIST \"\${SIZE_OUTPUT}\")

        set(SIZE_OUTPUT_LINES)
        foreach(LINE \${SIZE_OUTPUT_LIST})
            if(NOT \"\${LINE}\" STREQUAL \"\")
                list(APPEND SIZE_OUTPUT_LINES \"\${LINE}\")
            endif()
        endforeach()

        function(EXTRACT LIST_NAME INDEX VARIABLE)
            list(GET \"\${LIST_NAME}\" \${INDEX} RAW_VALUE)
            string(STRIP \"\${RAW_VALUE}\" VALUE)

            set(\${VARIABLE} \"\${VALUE}\" PARENT_SCOPE)
        endfunction()
        function(PARSE INPUT VARIABLE_PREFIX)
            if(\${INPUT} MATCHES \"([^:]+):[ \\t]*([0-9]+)[ \\t]*([^ \\t]+)[ \\t]*[(]([0-9.]+)%.*\")
                set(ENTRY_NAME      \${CMAKE_MATCH_1})
                set(ENTRY_SIZE      \${CMAKE_MATCH_2})
                set(ENTRY_SIZE_TYPE \${CMAKE_MATCH_3})
                set(ENTRY_PERCENT   \${CMAKE_MATCH_4})
            endif()

            set(\${VARIABLE_PREFIX}_NAME      \${ENTRY_NAME}      PARENT_SCOPE)
            set(\${VARIABLE_PREFIX}_SIZE      \${ENTRY_SIZE}      PARENT_SCOPE)
            set(\${VARIABLE_PREFIX}_SIZE_TYPE \${ENTRY_SIZE_TYPE} PARENT_SCOPE)
            set(\${VARIABLE_PREFIX}_PERCENT   \${ENTRY_PERCENT}   PARENT_SCOPE)
        endfunction()

        list(LENGTH SIZE_OUTPUT_LINES SIZE_OUTPUT_LENGTH)
        #message(\"\${SIZE_OUTPUT_LINES}\")
        #message(\"\${SIZE_OUTPUT_LENGTH}\")
        if (\${SIZE_OUTPUT_LENGTH} STREQUAL 14)
            EXTRACT(SIZE_OUTPUT_LINES 3 FIRMWARE_PROGRAM_SIZE_ROW)
            EXTRACT(SIZE_OUTPUT_LINES 5 FIRMWARE_DATA_SIZE_ROW)
            PARSE(FIRMWARE_PROGRAM_SIZE_ROW FIRMWARE_PROGRAM)
            PARSE(FIRMWARE_DATA_SIZE_ROW  FIRMWARE_DATA)

            set(FIRMWARE_STATUS \"Firmware Size: \")
            set(FIRMWARE_STATUS \"\${FIRMWARE_STATUS} [\${FIRMWARE_PROGRAM_NAME}: \${FIRMWARE_PROGRAM_SIZE} \${FIRMWARE_PROGRAM_SIZE_TYPE} (\${FIRMWARE_PROGRAM_PERCENT}%)] \")
            set(FIRMWARE_STATUS \"\${FIRMWARE_STATUS} [\${FIRMWARE_DATA_NAME}: \${FIRMWARE_DATA_SIZE} \${FIRMWARE_DATA_SIZE_TYPE} (\${FIRMWARE_DATA_PERCENT}%)]\")
            set(FIRMWARE_STATUS \"\${FIRMWARE_STATUS} on \${MCU}\")

            EXTRACT(SIZE_OUTPUT_LINES 10 EEPROM_PROGRAM_SIZE_ROW)
            EXTRACT(SIZE_OUTPUT_LINES 12 EEPROM_DATA_SIZE_ROW)
            PARSE(EEPROM_PROGRAM_SIZE_ROW EEPROM_PROGRAM)
            PARSE(EEPROM_DATA_SIZE_ROW  EEPROM_DATA)

            set(EEPROM_STATUS \"EEPROM   Size: \")
            set(EEPROM_STATUS \"\${EEPROM_STATUS} [\${EEPROM_PROGRAM_NAME}: \${EEPROM_PROGRAM_SIZE} \${EEPROM_PROGRAM_SIZE_TYPE} (\${EEPROM_PROGRAM_PERCENT}%)] \")
            set(EEPROM_STATUS \"\${EEPROM_STATUS} [\${EEPROM_DATA_NAME}: \${EEPROM_DATA_SIZE} \${EEPROM_DATA_SIZE_TYPE} (\${EEPROM_DATA_PERCENT}%)]\")
            set(EEPROM_STATUS \"\${EEPROM_STATUS} on \${MCU}\")

            message(\"\${FIRMWARE_STATUS}\")
            message(\"\${EEPROM_STATUS}\\n\")

            if(\$ENV{VERBOSE})
                message(\"\${RAW_SIZE_OUTPUT}\\n\")
            elseif(\$ENV{VERBOSE_SIZE})
                message(\"\${RAW_SIZE_OUTPUT}\\n\")
            endif()
        else()
            message(\"\${RAW_SIZE_OUTPUT}\")
        endif()
    ")

    set(${OUTPUT_VAR} ${ARDUINO_SIZE_SCRIPT_PATH} PARENT_SCOPE)
endfunction()


#=============================================================================#
# [PRIVATE/INTERNAL]
#
# load_arduino_style_settings(SETTINGS_LIST SETTINGS_PATH)
#
#      SETTINGS_LIST - Variable name of settings list
#      SETTINGS_PATH - File path of settings file to load.
#
# Load a Arduino style settings file into the cache.
# 
#  Examples of this type of settings file is the boards.txt and
# programmers.txt files located in ${ARDUINO_SDK}/hardware/arduino.
#
# Settings have to following format:
#
#      entry.setting[.subsetting] = value
#
# where [.subsetting] is optional
#
# For example, the following settings:
#
#      uno.name=Arduino Uno
#      uno.upload.protocol=stk500
#      uno.upload.maximum_size=32256
#      uno.build.mcu=atmega328p
#      uno.build.core=arduino
#
# will generate the follwoing equivalent CMake variables:
#
#      set(uno.name "Arduino Uno")
#      set(uno.upload.protocol     "stk500")
#      set(uno.upload.maximum_size "32256")
#      set(uno.build.mcu  "atmega328p")
#      set(uno.build.core "arduino")
#
#      set(uno.SETTINGS  name upload build)              # List of settings for uno
#      set(uno.upload.SUBSETTINGS protocol maximum_size) # List of sub-settings for uno.upload
#      set(uno.build.SUBSETTINGS mcu core)               # List of sub-settings for uno.build
# 
#  The ${ENTRY_NAME}.SETTINGS variable lists all settings for the entry, while
# ${ENTRY_NAME}.SUBSETTINGS variables lists all settings for a sub-setting of
# a entry setting pair.
#
#  These variables are generated in order to be able to  programatically traverse
# all settings (for a example see print_board_settings() function).
#
#=============================================================================#
function(LOAD_ARDUINO_STYLE_SETTINGS SETTINGS_LIST SETTINGS_PATH)

    if(NOT ${SETTINGS_LIST} AND EXISTS ${SETTINGS_PATH})
    file(STRINGS ${SETTINGS_PATH} FILE_ENTRIES)  # Settings file split into lines

    foreach(FILE_ENTRY ${FILE_ENTRIES})
        if("${FILE_ENTRY}" MATCHES "^[^#]+=.*")
            string(REGEX MATCH "^[^=]+" SETTING_NAME  ${FILE_ENTRY})
            string(REGEX MATCH "[^=]+$" SETTING_VALUE ${FILE_ENTRY})
            string(REPLACE "." ";" ENTRY_NAME_TOKENS ${SETTING_NAME})
            string(STRIP "${SETTING_VALUE}" SETTING_VALUE)

            list(LENGTH ENTRY_NAME_TOKENS ENTRY_NAME_TOKENS_LEN)

            # Add entry to settings list if it does not exist
            list(GET ENTRY_NAME_TOKENS 0 ENTRY_NAME)
            list(FIND ${SETTINGS_LIST} ${ENTRY_NAME} ENTRY_NAME_INDEX)
            if(ENTRY_NAME_INDEX LESS 0)
                # Add entry to main list
                list(APPEND ${SETTINGS_LIST} ${ENTRY_NAME})
            endif()

            # Add entry setting to entry settings list if it does not exist
            set(ENTRY_SETTING_LIST ${ENTRY_NAME}.SETTINGS)
            list(GET ENTRY_NAME_TOKENS 1 ENTRY_SETTING)
            list(FIND ${ENTRY_SETTING_LIST} ${ENTRY_SETTING} ENTRY_SETTING_INDEX)
            if(ENTRY_SETTING_INDEX LESS 0)
                # Add setting to entry
                list(APPEND ${ENTRY_SETTING_LIST} ${ENTRY_SETTING})
                set(${ENTRY_SETTING_LIST} ${${ENTRY_SETTING_LIST}}
                    CACHE INTERNAL "Arduino ${ENTRY_NAME} Board settings list")
            endif()

            set(FULL_SETTING_NAME ${ENTRY_NAME}.${ENTRY_SETTING})

            # Add entry sub-setting to entry sub-settings list if it does not exists
            if(ENTRY_NAME_TOKENS_LEN GREATER 2)
                set(ENTRY_SUBSETTING_LIST ${ENTRY_NAME}.${ENTRY_SETTING}.SUBSETTINGS)
                list(GET ENTRY_NAME_TOKENS 2 ENTRY_SUBSETTING)
                list(FIND ${ENTRY_SUBSETTING_LIST} ${ENTRY_SUBSETTING} ENTRY_SUBSETTING_INDEX)
                if(ENTRY_SUBSETTING_INDEX LESS 0)
                    list(APPEND ${ENTRY_SUBSETTING_LIST} ${ENTRY_SUBSETTING})
                    set(${ENTRY_SUBSETTING_LIST}  ${${ENTRY_SUBSETTING_LIST}}
                        CACHE INTERNAL "Arduino ${ENTRY_NAME} Board sub-settings list")
                endif()
                set(FULL_SETTING_NAME ${FULL_SETTING_NAME}.${ENTRY_SUBSETTING})
            endif()

            # Save setting value
            set(${FULL_SETTING_NAME} ${SETTING_VALUE}
                CACHE INTERNAL "Arduino ${ENTRY_NAME} Board setting")
            

        endif()
    endforeach()
    set(${SETTINGS_LIST} ${${SETTINGS_LIST}}
        CACHE STRING "List of detected Arduino Board configurations")
    mark_as_advanced(${SETTINGS_LIST})
    endif()
endfunction()



#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_system_paths()
#
# Setup default Arduino System search paths.
#
#=============================================================================#
macro(setup_arduino_system_paths)
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
endmacro()


#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_search_paths(PATH_SUFFIX_VAR PATH_HINTS_VAR)
#
#      PATH_SUFFIX_VAR  - Variable name of path suffixes
#      PATH_HINTS_VAR   - Variable name of path hints
#
# Setup default search path suffixes and hints used to find the Arduino SDK.
#
#=============================================================================#
function(setup_arduino_search_paths PATH_SUFFIX_VAR PATH_HINTS_VAR)
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

        file(GLOB SDK_PATH_HINTS /usr/share/arduino*
                                 /opt/local/ardiuno*
                                 /usr/local/share/arduino*)
        list(SORT SDK_PATH_HINTS)
        list(REVERSE SDK_PATH_HINTS)

        set(${PATH_SUFFIX_VAR} ${ARDUINO_PATHS} PARENT_SCOPE)
        set(${PATH_HINTS_VAR} ${SDK_PATHS_HINTS} PARENT_SCOPE)
    endif()
endfunction()





#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_sdk()
#
# Initialize the Arduino build system.
#
#=============================================================================#
macro(setup_arduino_sdk)

    if(NOT ARDUINO_SDK_PATH)
        message(FATAL_ERROR "Could not find Arduino SDK (set ARDUINO_SDK_PATH)!")
    endif()

    if(NOT ARDUINO_FOUND AND ARDUINO_SDK_PATH)
    #=============================================================================#
    #                       General Arduino SDK Setup                             #
    #=============================================================================#
    set(ARDUINO_DEFAULT_BOARD uno  CACHE STRING "Default Arduino Board ID when not specified.")
    set(ARDUINO_DEFAULT_PORT       CACHE STRING "Default Arduino port when not specified.")
    set(ARDUINO_DEFAULT_SERIAL     CACHE STRING "Default Arduino Serial command when not specified.")
    set(ARDUINO_DEFAULT_PROGRAMMER CACHE STRING "Default Arduino Programmer ID when not specified.")

    set(ARDUINO_SDK_PACKAGE_PATHS CACHE STRING "Arduino SDK Package paths (semicolon sperated search paths).")

    find_file(ARDUINO_VERSION_PATH
        NAMES lib/version.txt
        PATHS ${ARDUINO_SDK_PATH}
        DOC "Path to Arduino version file.")

    find_file(ARDUINO_LIBRARIES_PATH
              NAMES libraries
              PATHS ${ARDUINO_SDK_PATH}
              DOC "Path to directory containing the Arduino libraries.")


    detect_arduino_version(ARDUINO_SDK_VERSION)
    set(ARDUINO_SDK_VERSION       ${ARDUINO_SDK_VERSION}       CACHE STRING "Arduino SDK Version")
    set(ARDUINO_SDK_VERSION_MAJOR ${ARDUINO_SDK_VERSION_MAJOR} CACHE INTERNAL "Arduino SDK Major Version")
    set(ARDUINO_SDK_VERSION_MINOR ${ARDUINO_SDK_VERSION_MINOR} CACHE INTERNAL "Arduino SDK Minor Version")
    set(ARDUINO_SDK_VERSION_PATCH ${ARDUINO_SDK_VERSION_PATCH} CACHE INTERNAL "Arduino SDK Patch Version")

    if(ARDUINO_SDK_VERSION VERSION_LESS 0.19)
         message(FATAL_ERROR "Unsupported Arduino SDK (require verion 0.19 or higher)")
    endif()



    #=============================================================================#
    #                       Version specific setup                                #
    #=============================================================================#

    list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${ARDUINO_SDK_PATH}/hardware/tools/avr/bin)
    list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${ARDUINO_SDK_PATH}/hardware/tools/avr/utils/bin)

    find_program(ARDUINO_AVRDUDE_PROGRAM
        NAMES avrdude
        PATHS ${ARDUINO_SDK_PATH}
        PATH_SUFFIXES hardware/tools
        NO_DEFAULT_PATH)

    find_program(ARDUINO_AVRDUDE_PROGRAM
        NAMES avrdude
        DOC "Path to avrdude programmer binary.")

    find_program(AVRSIZE_PROGRAM
        NAMES avr-size)

    find_file(ARDUINO_AVRDUDE_CONFIG_PATH
        NAMES avrdude.conf
        PATHS ${ARDUINO_SDK_PATH} /etc/avrdude
        PATH_SUFFIXES hardware/tools
                      hardware/tools/avr/etc
        DOC "Path to avrdude programmer configuration file.")


    #=============================================================================#
    #                         Arduino Settings                                    
    #=============================================================================#
    set(ARDUINO_OBJCOPY_EEP_FLAGS -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load
        --no-change-warnings --change-section-lma .eeprom=0   CACHE STRING "")
    set(ARDUINO_OBJCOPY_HEX_FLAGS -O ihex -R .eeprom          CACHE STRING "")
    set(ARDUINO_AVRDUDE_FLAGS -V                              CACHE STRING "")


    # Ensure that all required paths are found
    required_variables(VARS 
        ARDUINO_LIBRARIES_PATH
        ARDUINO_VERSION_PATH
        ARDUINO_AVRDUDE_FLAGS
        ARDUINO_AVRDUDE_PROGRAM
        ARDUINO_AVRDUDE_CONFIG_PATH
        AVRSIZE_PROGRAM
        MSG "Invalid Arduino SDK path (${ARDUINO_SDK_PATH}).\n")

    setup_arduino_size_script(ARDUINO_SIZE_SCRIPT)
    set(ARDUINO_SIZE_SCRIPT ${ARDUINO_SIZE_SCRIPT} CACHE INTERNAL "Arduino Size Script")

    set(ARDUINO_FOUND True CACHE INTERNAL "Arduino Found")
    mark_as_advanced(
        ARDUINO_LIBRARIES_PATH
        ARDUINO_VERSION_PATH
        ARDUINO_AVRDUDE_FLAGS
        ARDUINO_AVRDUDE_PROGRAM
        ARDUINO_AVRDUDE_CONFIG_PATH
        ARDUINO_OBJCOPY_EEP_FLAGS
        ARDUINO_OBJCOPY_HEX_FLAGS
        AVRSIZE_PROGRAM)

    if (ARDUINO_SDK_VERSION VERSION_LESS 1.5)
        set(ARDUINO_SDK_PACKAGE arduino CACHE STRING "Arduino SDK package.")

        register_hardware_platform(${ARDUINO_SDK_PACKAGE} "${ARDUINO_SDK_PATH}/hardware/arduino/")

        set(CMAKE_C_COMPILER   avr-gcc)
        set(CMAKE_CXX_COMPILER avr-g++)

        #=============================================================================#
        #                              C Flags                                        
        #=============================================================================#
        set(ARDUINO_C_FLAGS "-mcall-prologues -ffunction-sections -fdata-sections")
        set(CMAKE_C_FLAGS                "-g -Os       ${ARDUINO_C_FLAGS}"    CACHE STRING "")
        set(CMAKE_C_FLAGS_DEBUG          "-g           ${ARDUINO_C_FLAGS}"    CACHE STRING "")
        set(CMAKE_C_FLAGS_MINSIZEREL     "-Os -DNDEBUG ${ARDUINO_C_FLAGS}"    CACHE STRING "")
        set(CMAKE_C_FLAGS_RELEASE        "-Os -DNDEBUG -w ${ARDUINO_C_FLAGS}" CACHE STRING "")
        set(CMAKE_C_FLAGS_RELWITHDEBINFO "-Os -g       -w ${ARDUINO_C_FLAGS}" CACHE STRING "")

        #=============================================================================#
        #                             C++ Flags                                       
        #=============================================================================#
        set(ARDUINO_CXX_FLAGS "${ARDUINO_C_FLAGS} -fno-exceptions")
        set(CMAKE_CXX_FLAGS                "-g -Os       ${ARDUINO_CXX_FLAGS}" CACHE STRING "")
        set(CMAKE_CXX_FLAGS_DEBUG          "-g           ${ARDUINO_CXX_FLAGS}" CACHE STRING "")
        set(CMAKE_CXX_FLAGS_MINSIZEREL     "-Os -DNDEBUG ${ARDUINO_CXX_FLAGS}" CACHE STRING "")
        set(CMAKE_CXX_FLAGS_RELEASE        "-Os -DNDEBUG ${ARDUINO_CXX_FLAGS}" CACHE STRING "")
        set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-Os -g       ${ARDUINO_CXX_FLAGS}" CACHE STRING "")

        #=============================================================================#
        #                       Executable Linker Flags                               #
        #=============================================================================#
        set(ARDUINO_LINKER_FLAGS "-Wl,--gc-sections -lm")
        set(CMAKE_EXE_LINKER_FLAGS                "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")
        set(CMAKE_EXE_LINKER_FLAGS_DEBUG          "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")
        set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL     "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")
        set(CMAKE_EXE_LINKER_FLAGS_RELEASE        "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")
        set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")

        #=============================================================================#
        #=============================================================================#
        #                       Shared Lbrary Linker Flags                            #
        #=============================================================================#
        set(CMAKE_SHARED_LINKER_FLAGS                "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")
        set(CMAKE_SHARED_LINKER_FLAGS_DEBUG          "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")
        set(CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL     "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")
        set(CMAKE_SHARED_LINKER_FLAGS_RELEASE        "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")
        set(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")

        set(CMAKE_MODULE_LINKER_FLAGS                "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")
        set(CMAKE_MODULE_LINKER_FLAGS_DEBUG          "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")
        set(CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL     "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")
        set(CMAKE_MODULE_LINKER_FLAGS_RELEASE        "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")
        set(CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO "${ARDUINO_LINKER_FLAGS}" CACHE STRING "")
    else()
        if(NOT DEFINED ARDUONO_SDK_PACKAGE)
            set(ARDUINO_SDK_PACKAGE arduino CACHE STRING "Arduino SDK package.")
            message(STATUS "Using default Arduino Package: ${ARDUINO_SDK_PACKAGE}")
        endif()
        if(NOT DEFINED ARDUONO_SDK_PLATFORM)
            set(ARDUINO_SDK_PLATFORM avr CACHE STRING "Arduino SDK platform.")
            message(STATUS "Using default Arduino Platform: ${ARDUINO_SDK_PLATFORM}")
        endif()

        message(FATAL_ERROR "Arduino SDK 1.5 not yet supported!")
    endif()

    endif(NOT ARDUINO_FOUND AND ARDUINO_SDK_PATH)

    if (NOT DEFINED ARDUINO_CMAKE_INFO_MESSAGE)
        set(ARDUINO_CMAKE_INFO_MESSAGE True)
        message(STATUS "Arduino SDK version ${ARDUINO_SDK_VERSION}: ${ARDUINO_SDK_PATH}")
        if (NOT ARDUINO_SDK_VERSION VERSION_LESS 1.5)
            message(STATUS "Arduino SDK package/platform: ${ARDUINO_SDK_PACKAGE}/${ARDUINO_SDK_PLATFORM}")
        endif()
    endif()
endmacro()

