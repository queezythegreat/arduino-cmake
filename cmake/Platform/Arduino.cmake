#=============================================================================#
# generate_arduino_firmware(name
#      [BOARD board_id]
#      [SKETCH sketch_path |
#       SRCS  src1 src2 ... srcN]
#      [HDRS  hdr1 hdr2 ... hdrN]
#      [LIBS  lib1 lib2 ... libN]
#      [PORT  port]
#      [SERIAL serial_cmd]
#      [PROGRAMMER programmer_id]
#      [AFLAGS flags]
#      [NO_AUTOLIBS]
#      [MANUAL])
#
#=============================================================================#
#
#   generaters firmware and libraries for Arduino devices
#
# The arguments are as follows:
#
#      name           # The name of the firmware target         [REQUIRED]
#      BOARD          # Board name (such as uno, mega2560, ...) [REQUIRED]
#      SKETCH         # Arduino sketch [must have SRCS or SKETCH]
#      SRCS           # Sources        [must have SRCS or SKETCH]
#      HDRS           # Headers
#      LIBS           # Libraries to link
#      ARDLIBS        # Arduino libraries to link (Wire, Servo, SPI, etc)
#      PORT           # Serial port (enables upload support)
#      SERIAL         # Serial command for serial target
#      PROGRAMMER     # Programmer id (enables programmer support)
#      AFLAGS         # Avrdude flags for target
#      NO_AUTOLIBS    # Disables Arduino library detection
#      MANUAL         # (Advanced) Only use AVR Libc/Includes
#
# Here is a short example for a target named test:
#
#       generate_arduino_firmware(
#           NAME test
#           SRCS test.cpp
#                test2.cpp
#           HDRS test.h test2.h
#           BOARD uno)
#
# Alternatively you can specify the option by variables:
#
#       set(test_SRCS test.cpp test2.cpp)
#       set(test_HDRS test.h test2.h
#       set(test_BOARD uno)
#
#       generate_arduino_firmware(test)
#
# All variables need to be prefixed with the target name (${TARGET_NAME}_${OPTION}).
#
#=============================================================================#
# generate_avr_firmware(name
#      [BOARD board_id]
#       SRCS  src1 src2 ... srcN]
#      [HDRS  hdr1 hdr2 ... hdrN]
#      [LIBS  lib1 lib2 ... libN]
#      [PORT  port]
#      [SERIAL serial_cmd]
#      [PROGRAMMER programmer_id]
#      [AFLAGS flags])
#=============================================================================#
#
#   generaters firmware and libraries for AVR devices
#   it simply calls generate_arduino_firmware() with NO_AUTOLIBS and MANUAL
#
# The arguments are as follows:
#
#      name           # The name of the firmware target         [REQUIRED]
#      BOARD          # Board name (such as uno, mega2560, ...) [REQUIRED]
#      SRCS           # Sources                                 [REQUIRED]
#      HDRS           # Headers
#      LIBS           # Libraries to link
#      PORT           # Serial port (enables upload support)
#      SERIAL         # Serial command for serial target
#      PROGRAMMER     # Programmer id (enables programmer support)
#      AFLAGS         # Avrdude flags for target
#
# Here is a short example for a target named test:
#
#       generate_avr_firmware(
#           NAME test
#           SRCS test.cpp
#                test2.cpp
#           HDRS test.h test2.h
#           BOARD uno)
#
# Alternatively you can specify the option by variables:
#
#       set(test_SRCS test.cpp test2.cpp)
#       set(test_HDRS test.h test2.h
#       set(test_BOARD uno)
#
#       generate_avr_firmware(test)
#
# All variables need to be prefixed with the target name (${TARGET_NAME}_${OPTION}).
#
#=============================================================================#
# generate_arduino_library(name
#      [BOARD board_id]
#      [SRCS  src1 src2 ... srcN]
#      [HDRS  hdr1 hdr2 ... hdrN]
#      [LIBS  lib1 lib2 ... libN]
#      [NO_AUTOLIBS]
#      [MANUAL])
#=============================================================================#
#   generaters firmware and libraries for Arduino devices
#
# The arguments are as follows:
#
#      name           # The name of the firmware target         [REQUIRED]
#      BOARD          # Board name (such as uno, mega2560, ...) [REQUIRED]
#      SRCS           # Sources                                 [REQUIRED]
#      HDRS           # Headers
#      LIBS           # Libraries to link
#      NO_AUTOLIBS    # Disables Arduino library detection
#      MANUAL         # (Advanced) Only use AVR Libc/Includes
#
# Here is a short example for a target named test:
#
#       generate_arduino_library(
#           NAME test
#           SRCS test.cpp
#                test2.cpp
#           HDRS test.h test2.h
#           BOARD uno)
#
# Alternatively you can specify the option by variables:
#
#       set(test_SRCS test.cpp test2.cpp)
#       set(test_HDRS test.h test2.h
#       set(test_BOARD uno)
#
#       generate_arduino_library(test)
#
# All variables need to be prefixed with the target name (${TARGET_NAME}_${OPTION}).
#
#=============================================================================#
# generate_avr_library(name
#      [BOARD board_id]
#      [SRCS  src1 src2 ... srcN]
#      [HDRS  hdr1 hdr2 ... hdrN]
#      [LIBS  lib1 lib2 ... libN])
#=============================================================================#
#   generaters firmware and libraries for AVR devices
#   it simply calls generate_arduino_library() with NO_AUTOLIBS and MANUAL
#
# The arguments are as follows:
#
#      name           # The name of the firmware target         [REQUIRED]
#      BOARD          # Board name (such as uno, mega2560, ...) [REQUIRED]
#      SRCS           # Sources                                 [REQUIRED]
#      HDRS           # Headers
#      LIBS           # Libraries to link
#
# Here is a short example for a target named test:
#
#       generate_avr_library(
#           NAME test
#           SRCS test.cpp
#                test2.cpp
#           HDRS test.h test2.h
#           BOARD uno)
#
# Alternatively you can specify the option by variables:
#
#       set(test_SRCS test.cpp test2.cpp)
#       set(test_HDRS test.h test2.h
#       set(test_BOARD uno)
#
#       generate_avr_library(test)
#
# All variables need to be prefixed with the target name (${TARGET_NAME}_${OPTION}).
#
#=============================================================================#
# generate_arduino_example(name
#                          LIBRARY library_name
#                          EXAMPLE example_name
#                          [BOARD  board_id]
#                          [PORT port]
#                          [SERIAL serial command]
#                          [PORGRAMMER programmer_id]
#                          [AFLAGS avrdude_flags])
#=============================================================================#
#
#        name         - The name of the library example        [REQUIRED]
#        LIBRARY      - Library name                           [REQUIRED]
#        EXAMPLE      - Example name                           [REQUIRED]
#        BOARD        - Board ID
#        PORT         - Serial port [optional]
#        SERIAL       - Serial command [optional]
#        PROGRAMMER   - Programmer id (enables programmer support)
#        AFLAGS       - Avrdude flags for target
#
# Creates a example from the specified library.
#
#
#=============================================================================#
# print_board_list()
#=============================================================================#
#
# Print list of detected Arduino Boards.
#
#=============================================================================#
# print_programmer_list()
#=============================================================================#
#
# Print list of detected Programmers.
#
#=============================================================================#
# print_programmer_settings(PROGRAMMER)
#=============================================================================#
#
#        PROGRAMMER - programmer id
#
# Print the detected Programmer settings.
#
#=============================================================================#
# print_board_settings(ARDUINO_BOARD)
#=============================================================================#
#
#        ARDUINO_BOARD - Board id
#
# Print the detected Arduino board settings.
#
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
# Configuration Options
#=============================================================================#
#
# ARDUINO_SDK_PATH            - Arduino SDK Path
# ARDUINO_AVRDUDE_PROGRAM     - Full path to avrdude programmer
# ARDUINO_AVRDUDE_CONFIG_PATH - Full path to avrdude configuration file
#
# ARDUINO_C_FLAGS             - C compiler flags
# ARDUINO_CXX_FLAGS           - C++ compiler flags
# ARDUINO_LINKER_FLAGS        - Linker flags
#
# ARDUINO_DEFAULT_BOARD      - Default Arduino Board ID when not specified.
# ARDUINO_DEFAULT_PORT       - Default Arduino port when not specified.
# ARDUINO_DEFAULT_SERIAL     - Default Arduino Serial command when not specified.
# ARDUINO_DEFAULT_PROGRAMMER - Default Arduino Programmer ID when not specified.
#
#
# ARDUINO_FOUND       - Set to True when the Arduino SDK is detected and configured.
# ARDUINO_SDK_VERSION - Set to the version of the detected Arduino SDK (ex: 1.0)

#=============================================================================#
# Author: Tomasz Bogdal (QueezyTheGreat)
# Home:   https://github.com/queezythegreat/arduino-cmake
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#=============================================================================#
cmake_minimum_required(VERSION 2.8.5)
include(CMakeParseArguments)






#=============================================================================#
#                           User Functions
#=============================================================================#

#=============================================================================#
# [PUBLIC/USER]
#
# print_board_list()
#
# see documentation at top
#=============================================================================#
function(PRINT_BOARD_LIST)
    foreach(PLATFORM ${ARDUINO_PLATFORMS})
        if(${PLATFORM}_BOARDS)
            message(STATUS "${PLATFORM} Boards:")
            print_list(${PLATFORM}_BOARDS)
            message(STATUS "")
        endif()
    endforeach()
endfunction()

#=============================================================================#
# [PUBLIC/USER]
#
# print_programmer_list()
#
# see documentation at top
#=============================================================================#
function(PRINT_PROGRAMMER_LIST)
    foreach(PLATFORM ${ARDUINO_PLATFORMS})
        if(${PLATFORM}_PROGRAMMERS)
            message(STATUS "${PLATFORM} Programmers:")
            print_list(${PLATFORM}_PROGRAMMERS)
        endif()
        message(STATUS "")
    endforeach()
endfunction()

#=============================================================================#
# [PUBLIC/USER]
#
# print_programmer_settings(PROGRAMMER)
#
# see documentation at top
#=============================================================================#
function(PRINT_PROGRAMMER_SETTINGS PROGRAMMER)
    if(${PROGRAMMER}.SETTINGS)
        message(STATUS "Programmer ${PROGRAMMER} Settings:")
        print_settings(${PROGRAMMER})
    endif()
endfunction()

# [PUBLIC/USER]
#
# print_board_settings(ARDUINO_BOARD)
#
# see documentation at top
function(PRINT_BOARD_SETTINGS ARDUINO_BOARD)
    if(${ARDUINO_BOARD}.SETTINGS)
        message(STATUS "Arduino ${ARDUINO_BOARD} Board:")
        print_settings(${ARDUINO_BOARD})
    endif()
endfunction()

#=============================================================================#
# [PUBLIC/USER]
# see documentation at top
#=============================================================================#
function(GENERATE_ARDUINO_LIBRARY INPUT_NAME)
    message(STATUS "Generating ${INPUT_NAME}")
    parse_generator_arguments(${INPUT_NAME} INPUT
                              "NO_AUTOLIBS;MANUAL"                  # Options
                              "BOARD"                               # One Value Keywords
                              "SRCS;HDRS;LIBS"                      # Multi Value Keywords
                              ${ARGN})

    if(NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif()
    if(NOT INPUT_MANUAL)
        set(INPUT_MANUAL FALSE)
    endif()
    required_variables(VARS INPUT_SRCS INPUT_BOARD MSG "must define for target ${INPUT_NAME}")

    set(ALL_LIBS)
    set(ALL_SRCS ${INPUT_SRCS} ${INPUT_HDRS})

    if(NOT INPUT_MANUAL)
      setup_arduino_core(CORE_LIB ${INPUT_BOARD})
      set(BOARD_CORE ${${BOARD_ID}.build.core})
      set(BOARD_CORE_PATH ${${BOARD_CORE}.path})
      include_directories( ${BOARD_CORE_PATH})
    endif()

    find_arduino_libraries(TARGET_LIBS "${ALL_SRCS}" "")
    set(LIB_DEP_INCLUDES)
    foreach(LIB_DEP ${TARGET_LIBS})
        set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${LIB_DEP}\"")
    endforeach()

    if(NOT ${INPUT_NO_AUTOLIBS})
        setup_arduino_libraries(ALL_LIBS  ${INPUT_BOARD} "${ALL_SRCS}" "" "${LIB_DEP_INCLUDES}" "")
    endif()

    list(APPEND ALL_LIBS ${CORE_LIB} ${INPUT_LIBS})

    add_library(${INPUT_NAME} ${ALL_SRCS})

    get_arduino_flags(ARDUINO_COMPILE_FLAGS ARDUINO_LINK_FLAGS  ${INPUT_BOARD} ${INPUT_MANUAL})

    set_target_properties(${INPUT_NAME} PROPERTIES
                COMPILE_FLAGS "${ARDUINO_COMPILE_FLAGS} ${COMPILE_FLAGS} ${LIB_DEP_INCLUDES}"
                LINK_FLAGS "${ARDUINO_LINK_FLAGS} ${LINK_FLAGS}")

    target_link_libraries(${INPUT_NAME} ${ALL_LIBS} "-lc -lm")
endfunction()

#=============================================================================#
# [PUBLIC/USER]
# see documentation at top
#=============================================================================#
function(GENERATE_AVR_LIBRARY INPUT_NAME)
    message(STATUS "Generating ${INPUT_NAME}")
    parse_generator_arguments(${INPUT_NAME} INPUT
                              "NO_AUTOLIBS;MANUAL"                  # Options
                              "BOARD"                               # One Value Keywords
                              "SRCS;HDRS;LIBS"                      # Multi Value Keywords
                              ${ARGN})

    if(NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif()

    required_variables(VARS INPUT_SRCS INPUT_BOARD MSG "must define for target ${INPUT_NAME}")

    if(INPUT_HDRS)
        set( INPUT_HDRS "SRCS ${INPUT_HDRS}" )
    endif()
    if(INPUT_LIBS)
        set( INPUT_LIBS "LIBS ${INPUT_LIBS}" )
    endif()

    if(INPUT_HDRS)
        list(INSERT INPUT_HDRS 0 "HDRS")
    endif()
    if(INPUT_LIBS)
        list(INSERT INPUT_LIBS 0 "LIBS")
    endif()


    generate_arduino_library( ${INPUT_NAME}
        NO_AUTOLIBS
        MANUAL
        BOARD ${INPUT_BOARD}
        SRCS ${INPUT_SRCS}
        ${INPUT_HDRS}
        ${INPUT_LIBS} )

endfunction()

#=============================================================================#
# [PUBLIC/USER]
# see documentation at top
#=============================================================================#
function(GENERATE_ARDUINO_FIRMWARE INPUT_NAME)
    message(STATUS "Generating ${INPUT_NAME}")
    parse_generator_arguments(${INPUT_NAME} INPUT
                              "NO_AUTOLIBS;MANUAL"                  # Options
                              "BOARD;PORT;SKETCH;PROGRAMMER;CPU"        # One Value Keywords
                              "SERIAL;SRCS;HDRS;LIBS;ARDLIBS;AFLAGS"  # Multi Value Keywords
                              ${ARGN})

    if(NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif()
    if(NOT INPUT_PORT)
        set(INPUT_PORT ${ARDUINO_DEFAULT_PORT})
    endif()
    if(NOT INPUT_SERIAL)
        set(INPUT_SERIAL ${ARDUINO_DEFAULT_SERIAL})
    endif()
    if(NOT DEFINED INPUT_PROGRAMMER)
        if(DEFINED ${INPUT_BOARD}.upload.tool)
            set(INPUT_PROGRAMMER ${${INPUT_BOARD}.upload.tool})
        else()
            set(INPUT_PROGRAMMER ${ARDUINO_DEFAULT_PROGRAMMER})
        endif()
    endif()
    if(NOT INPUT_MANUAL)
        set(INPUT_MANUAL FALSE)
    endif()
    required_variables(VARS INPUT_BOARD MSG "must define for target ${INPUT_NAME}")

    if(INPUT_CPU)
        set(ARDUINO_CPUMENU ".menu.cpu.${INPUT_CPU}")
    endif(INPUT_CPU)

    set(PLATFORM ${${INPUT_BOARD}.PLATFORM})


    set(ALL_LIBS)
    set(ALL_SRCS ${INPUT_SRCS} ${INPUT_HDRS})
    set(LIB_DEP_INCLUDES)

    # set predefined variable values

    set(${INPUT_NAME}.build.path ${CMAKE_CURRENT_BINARY_DIR} CACHE INTERNAL "")
    set(${INPUT_NAME}.build.project_name ${INPUT_NAME} CACHE INTERNAL "")

    string(TOUPPER "${PLATFORM}" PLATFORM_UPPER)
    set(${INPUT_BOARD}.build.arch "${PLATFORM_UPPER}" CACHE INTERNAL "")


    if(NOT INPUT_MANUAL)
      setup_arduino_core(CORE_LIB ${INPUT_BOARD})

      set(BOARD_CORE ${${INPUT_BOARD}.build.core})
      set(BOARD_CORE_PATH ${${BOARD_CORE}.path})
      include_directories( ${BOARD_CORE_PATH})
    endif()

    # Set include dir for variant
    set(BOARD_VARIANT ${${INPUT_BOARD}.build.variant})
    include_directories( ${${BOARD_VARIANT}.path})

    if(NOT "${INPUT_SKETCH}" STREQUAL "")
        get_filename_component(INPUT_SKETCH "${INPUT_SKETCH}" ABSOLUTE)
        setup_arduino_sketch(${INPUT_NAME} ${INPUT_SKETCH} ALL_SRCS)
        if (IS_DIRECTORY "${INPUT_SKETCH}")
            set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${INPUT_SKETCH}\"")
        else()
            get_filename_component(INPUT_SKETCH_PATH "${INPUT_SKETCH}" PATH)
            set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${INPUT_SKETCH_PATH}\"")
        endif()
    endif()

    required_variables(VARS ALL_SRCS MSG "must define SRCS or SKETCH for target ${INPUT_NAME}")

    find_arduino_libraries(TARGET_LIBS "${ALL_SRCS}" "${INPUT_ARDLIBS}")
    foreach(LIB_DEP ${TARGET_LIBS})
        arduino_debug_msg("Arduino Library: ${LIB_DEP}")
        set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${LIB_DEP}\" -I\"${LIB_DEP}/src\"")
    endforeach()

    if(NOT INPUT_NO_AUTOLIBS)
        setup_arduino_libraries(ALL_LIBS  ${INPUT_BOARD} "${ALL_SRCS}" "${INPUT_ARDLIBS}" "${LIB_DEP_INCLUDES}" "")
        foreach(LIB_INCLUDES ${ALL_LIBS_INCLUDES})
            arduino_debug_msg("Arduino Library Includes: ${LIB_INCLUDES}")
            set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} ${LIB_INCLUDES}")
        endforeach()
    endif()

    list(APPEND ALL_LIBS ${CORE_LIB} ${INPUT_LIBS})

    setup_arduino_target(${INPUT_NAME} ${INPUT_BOARD} "${ALL_SRCS}" "${ALL_LIBS}" "${LIB_DEP_INCLUDES}" "" "${INPUT_MANUAL}")

    if(INPUT_PORT)
        setup_arduino_upload(${INPUT_BOARD} ${INPUT_NAME} ${INPUT_PORT} "${INPUT_PROGRAMMER}" "${INPUT_AFLAGS}")
    endif()

    if(INPUT_SERIAL)
        setup_serial_target(${INPUT_NAME} "${INPUT_SERIAL}" "${INPUT_PORT}")
    endif()

endfunction()

#=============================================================================#
# [PUBLIC/USER]
# see documentation at top
#=============================================================================#
function(GENERATE_AVR_FIRMWARE INPUT_NAME)
    # TODO: This is not optimal!!!!
    message(STATUS "Generating ${INPUT_NAME}")
    parse_generator_arguments(${INPUT_NAME} INPUT
                              "NO_AUTOLIBS;MANUAL"            # Options
                              "BOARD;PORT;PROGRAMMER"  # One Value Keywords
                              "SERIAL;SRCS;HDRS;LIBS;AFLAGS"  # Multi Value Keywords
                              ${ARGN})

    if(NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif()
    if(NOT INPUT_PORT)
        set(INPUT_PORT ${ARDUINO_DEFAULT_PORT})
    endif()
    if(NOT INPUT_SERIAL)
        set(INPUT_SERIAL ${ARDUINO_DEFAULT_SERIAL})
    endif()
    if(NOT INPUT_PROGRAMMER)
        set(INPUT_PROGRAMMER ${ARDUINO_DEFAULT_PROGRAMMER})
    endif()

    required_variables(VARS INPUT_BOARD INPUT_SRCS MSG "must define for target ${INPUT_NAME}")

    if(INPUT_HDRS)
        list(INSERT INPUT_HDRS 0 "HDRS")
    endif()
    if(INPUT_LIBS)
        list(INSERT INPUT_LIBS 0 "LIBS")
    endif()
    if(INPUT_AFLAGS)
        list(INSERT INPUT_AFLAGS 0 "AFLAGS")
    endif()

    generate_arduino_firmware( ${INPUT_NAME}
        NO_AUTOLIBS
        MANUAL
        BOARD ${INPUT_BOARD}
        PORT ${INPUT_PORT}
        PROGRAMMER ${INPUT_PROGRAMMER}
        SERIAL ${INPUT_SERIAL}
        SRCS ${INPUT_SRCS}
        ${INPUT_HDRS}
        ${INPUT_LIBS}
        ${INPUT_AFLAGS} )

endfunction()

#=============================================================================#
# [PUBLIC/USER]
# see documentation at top
#=============================================================================#
function(GENERATE_ARDUINO_EXAMPLE INPUT_NAME)
    parse_generator_arguments(${INPUT_NAME} INPUT
                              ""                                       # Options
                              "LIBRARY;EXAMPLE;BOARD;PORT;PROGRAMMER"  # One Value Keywords
                              "SERIAL;AFLAGS"                          # Multi Value Keywords
                              ${ARGN})


    if(NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif()
    if(NOT INPUT_PORT)
        set(INPUT_PORT ${ARDUINO_DEFAULT_PORT})
    endif()
    if(NOT INPUT_SERIAL)
        set(INPUT_SERIAL ${ARDUINO_DEFAULT_SERIAL})
    endif()
    if(NOT INPUT_PROGRAMMER)
        set(INPUT_PROGRAMMER ${ARDUINO_DEFAULT_PROGRAMMER})
    endif()
    required_variables(VARS INPUT_LIBRARY INPUT_EXAMPLE INPUT_BOARD
                       MSG "must define for target ${INPUT_NAME}")

    message(STATUS "Generating ${INPUT_NAME}")

    set(ALL_LIBS)
    set(ALL_SRCS)

    setup_arduino_core(CORE_LIB ${INPUT_BOARD})

    setup_arduino_example("${INPUT_NAME}" "${INPUT_LIBRARY}" "${INPUT_EXAMPLE}" ALL_SRCS)

    if(NOT ALL_SRCS)
        message(FATAL_ERROR "Missing sources for example, aborting!")
    endif()

    find_arduino_libraries(TARGET_LIBS "${ALL_SRCS}" "")
    set(LIB_DEP_INCLUDES)
    foreach(LIB_DEP ${TARGET_LIBS})
        set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${LIB_DEP}\"")
    endforeach()

    setup_arduino_libraries(ALL_LIBS ${INPUT_BOARD} "${ALL_SRCS}" "" "${LIB_DEP_INCLUDES}" "")

    list(APPEND ALL_LIBS ${CORE_LIB} ${INPUT_LIBS})

    setup_arduino_target(${INPUT_NAME} ${INPUT_BOARD}  "${ALL_SRCS}" "${ALL_LIBS}" "${LIB_DEP_INCLUDES}" "" FALSE)

    if(INPUT_PORT)
        setup_arduino_upload(${INPUT_BOARD} ${INPUT_NAME} ${INPUT_PORT} "${INPUT_PROGRAMMER}" "${INPUT_AFLAGS}")
    endif()

    if(INPUT_SERIAL)
        setup_serial_target(${INPUT_NAME} "${INPUT_SERIAL}" "${INPUT_PORT}")
    endif()
endfunction()

#=============================================================================#
# [PUBLIC/USER]
# see documentation at top
#=============================================================================#
function(REGISTER_HARDWARE_PLATFORM PLATFORM_PATH)
    string(REGEX REPLACE "/$" "" PLATFORM_PATH ${PLATFORM_PATH})
    if(ARDUINO_SDK_VERSION VERSION_LESS 1.5)
        SET(PLATFORM "AVR")
    else()
        GET_FILENAME_COMPONENT(PLATFORM ${PLATFORM_PATH} NAME)
        string(TOUPPER ${PLATFORM} PLATFORM)
    endif()

    if(PLATFORM)
        list(FIND ARDUINO_PLATFORMS ${PLATFORM} platform_exists)

        if (platform_exists EQUAL -1)
            set(${PLATFORM}_PLATFORM_PATH ${PLATFORM_PATH} CACHE INTERNAL "The path to ${PLATFORM}")
            set(ARDUINO_PLATFORMS ${ARDUINO_PLATFORMS} ${PLATFORM} CACHE INTERNAL "A list of registered platforms")


            # Set some predefined variable values as defined in
            # https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.5-3rd-party-Hardware-specification

            set(${PLATFORM}.runtime.platform.path ${PLATFORM_PATH}
                CACHE INTERNAL "${PLATFORM} platform path")

            if(ARDUINO_SDK_VERSION VERSION_LESS 1.5)
                set(${PLATFORM}.runtime.hardware.path ${PLATFORM_PATH}
                    CACHE INTERNAL "${PLATFORM} hardware path")
            else()
                GET_FILENAME_COMPONENT(HARDWARE_PATH ${PLATFORM_PATH} DIRECTORY)
                set(${PLATFORM}.runtime.hardware.path ${HARDWARE_PATH}
                    CACHE INTERNAL "${PLATFORM} hardware path")
            endif()



            find_file(${PLATFORM}_CORES_PATH
                  NAMES cores
                  PATHS ${PLATFORM_PATH}
                  DOC "Path to directory containing the Arduino core sources."
                  NO_SYSTEM_ENVIRONMENT_PATH)

            find_file(${PLATFORM}_VARIANTS_PATH
                  NAMES variants
                  PATHS ${PLATFORM_PATH}
                  DOC "Path to directory containing the Arduino variant sources."
                  NO_SYSTEM_ENVIRONMENT_PATH)

            find_file(${PLATFORM}_BOOTLOADERS_PATH
                  NAMES bootloaders
                  PATHS ${PLATFORM_PATH}
                  DOC "Path to directory containing the Arduino bootloader images and sources."
                  NO_SYSTEM_ENVIRONMENT_PATH)

            find_file(${PLATFORM}_LIBRARIES_PATH
                  NAMES libraries
                  PATHS ${PLATFORM_PATH}
                  DOC "Path to directory containing the Arduino hardware libraries sources."
                  NO_SYSTEM_ENVIRONMENT_PATH)

            find_file(${PLATFORM}_PROGRAMMERS_PATH
                NAMES programmers.txt
                PATHS ${PLATFORM_PATH}
                DOC "Path to Arduino programmers definition file."
                NO_SYSTEM_ENVIRONMENT_PATH)

            find_file(${PLATFORM}_BOARDS_PATH
                NAMES boards.txt
                PATHS ${PLATFORM_PATH}
                DOC "Path to Arduino boards definition file."
                NO_SYSTEM_ENVIRONMENT_PATH)

            find_file(${PLATFORM}_PLATFORM_PATH
                NAMES platform.txt
                PATHS ${PLATFORM_PATH}
                DOC "Path to Arduino platform definition file."
                NO_SYSTEM_ENVIRONMENT_PATH)

            if(${PLATFORM}_BOARDS_PATH)
                load_arduino_style_settings(${PLATFORM}_BOARDS "${PLATFORM_PATH}/boards.txt" "")

                # store the platform to which the board belongs
                foreach(board IN LISTS ${PLATFORM}_BOARDS)
                    set(${board}.PLATFORM ${PLATFORM} CACHE INTERNAL "")
                endforeach()

            endif()

            if(${PLATFORM}_PROGRAMMERS_PATH)
                load_arduino_style_settings(${PLATFORM}_PROGRAMMERS "${PLATFORM_PATH}/programmers.txt" "")
            endif()

            if(${PLATFORM}_PLATFORM_PATH)
                load_arduino_style_settings(${PLATFORM}_PLATFORM "${PLATFORM_PATH}/platform.txt" ${PLATFORM})
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
# subdirlist(RESULT DIR)
#
#         RESULT - Variable name of list containing all the sub directories
#         DIR    - Parent directory where to iterate over
#
# Gets a list of all the direct subdirectories of the given directory
# see https://stackoverflow.com/a/7788165/869402
#
#=============================================================================#
MACRO(SUBDIRLIST result curdir)
    FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
    SET(dirlist "")
    FOREACH(child ${children})
        IF(IS_DIRECTORY ${curdir}/${child})
            LIST(APPEND dirlist ${child})
        ENDIF()
    ENDFOREACH()
    SET(${result} ${dirlist})
ENDMACRO()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# parse_generator_arguments(TARGET_NAME PREFIX OPTIONS ARGS MULTI_ARGS [ARG1 ARG2 .. ARGN])
#
#         PREFIX     - Parsed options prefix
#         OPTIONS    - List of options
#         ARGS       - List of one value keyword arguments
#         MULTI_ARGS - List of multi value keyword arguments
#         [ARG1 ARG2 .. ARGN] - command arguments [optional]
#
# Parses generator options from either variables or command arguments
#
#=============================================================================#
macro(PARSE_GENERATOR_ARGUMENTS TARGET_NAME PREFIX OPTIONS ARGS MULTI_ARGS)
    cmake_parse_arguments(${PREFIX} "${OPTIONS}" "${ARGS}" "${MULTI_ARGS}" ${ARGN})
    error_for_unparsed(${PREFIX})
    load_generator_settings(${TARGET_NAME} ${PREFIX} ${OPTIONS} ${ARGS} ${MULTI_ARGS})
endmacro()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# load_generator_settings(TARGET_NAME PREFIX [SUFFIX_1 SUFFIX_2 .. SUFFIX_N])
#
#         TARGET_NAME - The base name of the user settings
#         PREFIX      - The prefix name used for generator settings
#         SUFFIX_XX   - List of suffixes to load
#
#  Loads a list of user settings into the generators scope. User settings have
#  the following syntax:
#
#      ${BASE_NAME}${SUFFIX}
#
#  The BASE_NAME is the target name and the suffix is a specific generator settings.
#
#  For every user setting found a generator setting is created of the follwoing fromat:
#
#      ${PREFIX}${SUFFIX}
#
#  The purpose of loading the settings into the generator is to not modify user settings
#  and to have a generic naming of the settings within the generator.
#
#=============================================================================#
function(LOAD_GENERATOR_SETTINGS TARGET_NAME PREFIX)
    foreach(GEN_SUFFIX ${ARGN})
        if(${TARGET_NAME}_${GEN_SUFFIX} AND NOT ${PREFIX}_${GEN_SUFFIX})
            set(${PREFIX}_${GEN_SUFFIX} ${${TARGET_NAME}_${GEN_SUFFIX}} PARENT_SCOPE)
        endif()
    endforeach()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# get_recipe_flags(COMPILE_CMD_VAR COMPILE_FLAGS_VAR BOARD_ID RECIPE_TYPE)
#
#       COMPILE_CMD_VAR - Command for the given recipe (i.e. the first part of the string)
#       COMPILE_FLAGS_VAR - compile flags for the recipe
#       BOARD_ID - The board id name
#       RECIPE_TYPE - name of the recipe, e.g. [recipe.c.o, recipe.cpp.o, recipe.ar, recipe.objcopy.eep, ...]
#
# Gets the recipe configuration for the given recipe type
#
#=============================================================================#
function(get_recipe_flags COMPILE_CMD_VAR COMPILE_FLAGS_VAR BOARD_ID RECIPE_TYPE)

    set(PLATFORM ${${BOARD_ID}.PLATFORM})

    set(RECIPE_VAR_NAME "${PLATFORM}.${RECIPE_TYPE}.pattern")

    if(NOT DEFINED ${RECIPE_VAR_NAME})
        MESSAGE(FATAL_ERROR "Value for ${RECIPE_VAR_NAME} not defined")
    endif()

    set(RECIPE_PATTERN ${${RECIPE_VAR_NAME}})

    # Split recipe into command part (first part in quotes or up to first space) and flags part
    if("${RECIPE_PATTERN}" MATCHES "^[\"]*([^\"]+)[\"]*(.*)")
        SET(RECPIE_CMD ${CMAKE_MATCH_1})
        SET(RECPIE_FLAGS ${CMAKE_MATCH_2})

        # remove the files variables (this is a list of commonly used endings. It may be necessary to extend them
        string(REPLACE "{includes} \"{source_file}\" -o \"{object_file}\"" "" RECPIE_FLAGS ${RECPIE_FLAGS})
        string(REPLACE "-o \"{build.path}/{build.project_name}.elf\" {object_files} \"{build.path}/{archive_file}\"" "" RECPIE_FLAGS ${RECPIE_FLAGS})
        string(REPLACE "\"{build.path}/arduino.ar\" \"{object_file}\"" "" RECPIE_FLAGS ${RECPIE_FLAGS})


        if("${RECPIE_FLAGS}" MATCHES ".*{build.path}/{build.project_name}.*")
            if(NOT DEFINED TARGET_PATH)
                MESSAGE(FATAL_ERROR "TARGET_PATH must be defined to replace '{build.path}/{build.project_name}'")
            endif()
            string(REPLACE "{build.path}/{build.project_name}" "${TARGET_PATH}" RECPIE_FLAGS ${RECPIE_FLAGS})
        endif()

        string(STRIP "${RECPIE_FLAGS}" RECPIE_FLAGS)

        get_variable_value_filled(RECIPE_CMD_FULL "${RECPIE_CMD}" ${BOARD_ID} ${RECIPE_VAR_NAME})
        SET(${COMPILE_CMD_VAR} ${RECIPE_CMD_FULL} PARENT_SCOPE)

        get_variable_value_filled(RECIPE_FLAGS_FULL "${RECPIE_FLAGS}" ${BOARD_ID} ${RECIPE_VAR_NAME})
        SET(${COMPILE_FLAGS_VAR} ${RECIPE_FLAGS_FULL} PARENT_SCOPE)

    else()
        MESSAGE(FATAL_ERROR "Recipe pattern for '${RECIPE_VAR_NAME}' in unexpected format ")
    endif()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_core(VAR_NAME BOARD_ID)
#
#        VAR_NAME    - Variable name that will hold the generated library name
#        BOARD_ID    - Arduino board id
#
# Creates the Arduino Core library for the specified board,
# each board gets it's own version of the library.
#
#=============================================================================#
function(setup_arduino_core VAR_NAME BOARD_ID)
    set(CORE_LIB_NAME ${BOARD_ID}_CORE)
    set(BOARD_CORE ${${BOARD_ID}.build.core})
    if(BOARD_CORE)
        if(NOT TARGET ${CORE_LIB_NAME})
            set(BOARD_CORE_PATH ${${BOARD_CORE}.path})
            find_sources(CORE_SRCS ${BOARD_CORE_PATH} True)
            # Debian/Ubuntu fix
            list(REMOVE_ITEM CORE_SRCS "${BOARD_CORE_PATH}/main.cxx")
            add_library(${CORE_LIB_NAME} ${CORE_SRCS})

            get_recipe_flags(ARDUINO_COMPILE_CMD ARDUINO_COMPILE_FLAGS ${BOARD_ID} "recipe.c.o")

            if(NOT "${CMAKE_C_COMPILER}" STREQUAL "${ARDUINO_COMPILE_CMD}")
                MESSAGE(FATAL_ERROR "Your compiler needs to be manually set to\nCMAKE_C_COMPILER=\"${ARDUINO_COMPILE_CMD}\"")
            endif()

            get_recipe_flags(ARDUINO_LINK_CMD ARDUINO_LINK_FLAGS ${BOARD_ID} "recipe.ar")

            if(NOT "${CMAKE_AR}" STREQUAL "${ARDUINO_LINK_CMD}")
                MESSAGE(FATAL_ERROR "Your archiver needs to be manually set. You then also need to update the CMAKE_RANLIB to point to the correct one.\nCMAKE_AR=\"${ARDUINO_LINK_CMD}\"")
            endif()

            set_target_properties(${CORE_LIB_NAME} PROPERTIES
                COMPILE_FLAGS "${ARDUINO_COMPILE_FLAGS}"
                LINK_FLAGS "${ARDUINO_LINK_FLAGS}")
        endif()
        set(${VAR_NAME} ${CORE_LIB_NAME} PARENT_SCOPE)
    endif()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# find_arduino_libraries(VAR_NAME SRCS ARDLIBS)
#
#      VAR_NAME - Variable name which will hold the results
#      SRCS     - Sources that will be analized
#      ARDLIBS  - Arduino libraries identified by name (e.g., Wire, SPI, Servo)
#
#     returns a list of paths to libraries found.
#
#  Finds all Arduino type libraries included in sources. Available libraries
#  are ${ARDUINO_SDK_PATH}/libraries and ${CMAKE_CURRENT_SOURCE_DIR}.
#
#  Also adds Arduino libraries specifically names in ALIBS.  We add ".h" to the
#  names and then process them just like the Arduino libraries found in the sources.
#
#  A Arduino library is a folder that has the same name as the include header.
#  For example, if we have a include "#include <LibraryName.h>" then the following
#  directory structure is considered a Arduino library:
#
#     LibraryName/
#          |- LibraryName.h
#          `- LibraryName.c
#
#  If such a directory is found then all sources within that directory are considred
#  to be part of that Arduino library.
#
#=============================================================================#
function(find_arduino_libraries VAR_NAME SRCS ARDLIBS)
    get_property(include_dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
    
    set(ARDUINO_LIBS )
    foreach(SRC ${SRCS})

        # Skipping generated files. They are, probably, not exist yet.
        # TODO: Maybe it's possible to skip only really nonexisting files,
        # but then it wiil be less deterministic.
        get_source_file_property(_srcfile_generated ${SRC} GENERATED)
        # Workaround for sketches, which are marked as generated
        get_source_file_property(_sketch_generated ${SRC} GENERATED_SKETCH)

        if(NOT ${_srcfile_generated} OR ${_sketch_generated})
            if(NOT (EXISTS ${SRC} OR
                    EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${SRC} OR
                    EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${SRC}))
                message(FATAL_ERROR "Invalid source file: ${SRC}")
            endif()
            file(STRINGS ${SRC} SRC_CONTENTS)

            foreach(LIBNAME ${ARDLIBS})
                list(APPEND SRC_CONTENTS "#include <${LIBNAME}.h>")
            endforeach()

            foreach(SRC_LINE ${SRC_CONTENTS})
                if("#${SRC_LINE}#" MATCHES "^#[ \t]*#[ \t]*include[ \t]*[<\"]([^>\"]*)[>\"]#")
                    get_filename_component(INCLUDE_NAME ${CMAKE_MATCH_1} NAME_WE)
                    get_property(LIBRARY_SEARCH_PATH
                                 DIRECTORY     # Property Scope
                                 PROPERTY LINK_DIRECTORIES)
                    foreach(LIB_SEARCH_PATH ${include_dirs} ${LIBRARY_SEARCH_PATH} ${ARDUINO_LIBRARIES_PATH} ${${ARDUINO_PLATFORM}_LIBRARIES_PATH} ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/libraries ${ARDUINO_EXTRA_LIBRARIES_PATH})
                        if(EXISTS ${LIB_SEARCH_PATH}/${INCLUDE_NAME}/${CMAKE_MATCH_1})
                            list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/${INCLUDE_NAME})
                            break()
                        endif()
                        if(EXISTS ${LIB_SEARCH_PATH}/${INCLUDE_NAME}/src/${CMAKE_MATCH_1})
                            list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/${INCLUDE_NAME})
                            break()
                        endif()
                        get_source_file_property(_header_generated ${LIB_SEARCH_PATH}/${CMAKE_MATCH_1} GENERATED)
                        if((EXISTS ${LIB_SEARCH_PATH}/${CMAKE_MATCH_1}) OR ${_header_generated})
                            list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/${INCLUDE_NAME})
                            break()
                        endif()
                    endforeach()
                endif()
            endforeach()
        endif()
    endforeach()
    if(ARDUINO_LIBS)
        list(REMOVE_DUPLICATES ARDUINO_LIBS)
    endif()
    set(${VAR_NAME} ${ARDUINO_LIBS} PARENT_SCOPE)
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_library(VAR_NAME BOARD_ID LIB_PATH COMPILE_FLAGS LINK_FLAGS)
#
#        VAR_NAME    - Vairable wich will hold the generated library names
#        BOARD_ID    - Board ID
#        LIB_PATH    - Path of the library
#        COMPILE_FLAGS - Compile flags
#        LINK_FLAGS    - Link flags
#
# Creates an Arduino library, with all it's library dependencies.
#
#      ${LIB_NAME}_RECURSE controls if the library will recurse
#      when looking for source files.
#
#=============================================================================#

# For known libraries can list recurse here
set(Wire_RECURSE True)
set(Ethernet_RECURSE True)
set(SD_RECURSE True)
set(Servo_RECURSE True)
set(SPI_RECURSE True)
set(SoftwareSerial_RECURSE True)
set(EEPROM_RECURSE True)
set(LiquidCrystal_RECURSE True)
set(TFT_RECURSE True)
set(WiFi_RECURSE True)
set(Robot_Control_RECURSE True)
function(setup_arduino_library VAR_NAME BOARD_ID LIB_PATH COMPILE_FLAGS LINK_FLAGS)
    set(LIB_TARGETS)
    set(LIB_INCLUDES)

    get_filename_component(LIB_NAME ${LIB_PATH} NAME)
    set(TARGET_LIB_NAME ${BOARD_ID}_${LIB_NAME})
    if(NOT TARGET ${TARGET_LIB_NAME})
        string(REGEX REPLACE ".*/" "" LIB_SHORT_NAME ${LIB_NAME})

        # Detect if recursion is needed
        if (NOT DEFINED ${LIB_SHORT_NAME}_RECURSE)
            set(${LIB_SHORT_NAME}_RECURSE False)
        endif()

        find_sources(LIB_SRCS ${LIB_PATH} ${${LIB_SHORT_NAME}_RECURSE})
        if(LIB_SRCS)
            message(STATUS "Generating ${TARGET_LIB_NAME} for library ${LIB_NAME}")
            arduino_debug_msg("Generating Arduino ${LIB_NAME} library")
            add_library(${TARGET_LIB_NAME} STATIC ${LIB_SRCS})
            include_directories(${LIB_PATH})
            include_directories(${LIB_PATH}/src)
            include_directories(${LIB_PATH}/utility)

            get_arduino_flags(ARDUINO_COMPILE_FLAGS ARDUINO_LINK_FLAGS ${BOARD_ID} FALSE)

            find_arduino_libraries(LIB_DEPS "${LIB_SRCS}" "")

            foreach(LIB_DEP ${LIB_DEPS})
                if(NOT DEP_LIB_SRCS STREQUAL TARGET_LIB_NAME AND DEP_LIB_SRCS)
                      message(STATUS "Found library ${LIB_NAME} needs ${DEP_LIB_SRCS}")
                endif()

                setup_arduino_library(DEP_LIB_SRCS ${BOARD_ID} ${LIB_DEP} "${COMPILE_FLAGS}" "${LINK_FLAGS}")
                # Do not link to this library. DEP_LIB_SRCS will always be only one entry
                # if we are looking at the same library.
                if(NOT DEP_LIB_SRCS STREQUAL TARGET_LIB_NAME)
                    list(APPEND LIB_TARGETS ${DEP_LIB_SRCS})
                    list(APPEND LIB_INCLUDES ${DEP_LIB_SRCS_INCLUDES})
                endif()
            endforeach()

            if (LIB_INCLUDES)
                string(REPLACE ";" " " LIB_INCLUDES "${LIB_INCLUDES}")
            endif()

            set_target_properties(${TARGET_LIB_NAME} PROPERTIES
                COMPILE_FLAGS "${ARDUINO_COMPILE_FLAGS} ${LIB_INCLUDES} -I\"${LIB_PATH}\" -I\"${LIB_PATH}/src\" -I\"${LIB_PATH}/utility\" ${COMPILE_FLAGS}"
                LINK_FLAGS "${ARDUINO_LINK_FLAGS} ${LINK_FLAGS}")
            list(APPEND LIB_INCLUDES "-I\"${LIB_PATH}\" -I\"${LIB_PATH}/src\" -I\"${LIB_PATH}/utility\"")

            target_link_libraries(${TARGET_LIB_NAME} ${BOARD_ID}_CORE)
            list(APPEND LIB_TARGETS ${TARGET_LIB_NAME})

        endif()
    else()
        # Target already exists, skiping creating
        list(APPEND LIB_TARGETS ${TARGET_LIB_NAME})
    endif()
    if(LIB_TARGETS)
        list(REMOVE_DUPLICATES LIB_TARGETS)
    endif()
    set(${VAR_NAME}          ${LIB_TARGETS}  PARENT_SCOPE)
    set(${VAR_NAME}_INCLUDES ${LIB_INCLUDES} PARENT_SCOPE)
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_libraries(VAR_NAME BOARD_ID SRCS COMPILE_FLAGS LINK_FLAGS)
#
#        VAR_NAME    - Vairable wich will hold the generated library names
#        BOARD_ID    - Board ID
#        SRCS        - source files
#        COMPILE_FLAGS - Compile flags
#        LINK_FLAGS    - Linker flags
#
# Finds and creates all dependency libraries based on sources.
#
#=============================================================================#
function(setup_arduino_libraries VAR_NAME BOARD_ID SRCS ARDLIBS COMPILE_FLAGS LINK_FLAGS)
    set(LIB_TARGETS)
    set(LIB_INCLUDES)

    find_arduino_libraries(TARGET_LIBS "${SRCS}" ARDLIBS)
    foreach(TARGET_LIB ${TARGET_LIBS})
        # Create static library instead of returning sources
        setup_arduino_library(LIB_DEPS ${BOARD_ID} ${TARGET_LIB} "${COMPILE_FLAGS}" "${LINK_FLAGS}")
        list(APPEND LIB_TARGETS ${LIB_DEPS})
        list(APPEND LIB_INCLUDES ${LIB_DEPS_INCLUDES})
    endforeach()

    set(${VAR_NAME}          ${LIB_TARGETS}  PARENT_SCOPE)
    set(${VAR_NAME}_INCLUDES ${LIB_INCLUDES} PARENT_SCOPE)
endfunction()


#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_target(TARGET_NAME ALL_SRCS ALL_LIBS COMPILE_FLAGS LINK_FLAGS MANUAL)
#
#        TARGET_NAME - Target name
#        BOARD_ID    - Arduino board ID
#        ALL_SRCS    - All sources
#        ALL_LIBS    - All libraries
#        COMPILE_FLAGS - Compile flags
#        LINK_FLAGS    - Linker flags
#        MANUAL - (Advanced) Only use AVR Libc/Includes
#
# Creates an Arduino firmware target.
#
#=============================================================================#
function(setup_arduino_target TARGET_NAME BOARD_ID ALL_SRCS ALL_LIBS COMPILE_FLAGS LINK_FLAGS MANUAL)

    add_executable(${TARGET_NAME} ${ALL_SRCS})
    set_target_properties(${TARGET_NAME} PROPERTIES SUFFIX ".elf")

    if(NOT EXECUTABLE_OUTPUT_PATH)
        set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})
    endif()
    set(TARGET_PATH ${EXECUTABLE_OUTPUT_PATH}/${TARGET_NAME})

    get_recipe_flags(ARDUINO_COMPILE_CMD ARDUINO_COMPILE_FLAGS ${BOARD_ID} "recipe.cpp.o")
    if(NOT DEFINED ARDUINO_COMPILE_FLAGS)
        MESSAGE(FATAL_ERROR "Could not get 'recipe.cpp.o'")
    endif()

    if(NOT "${CMAKE_CXX_COMPILER}" STREQUAL "${ARDUINO_COMPILE_CMD}")
        MESSAGE(FATAL_ERROR "Your compiler needs to be manually set to\nCMAKE_CXX_COMPILER=\"${ARDUINO_COMPILE_CMD}\"")
    endif()

    get_recipe_flags(ARDUINO_LINK_CMD ARDUINO_LINK_FLAGS ${BOARD_ID} "recipe.c.combine")
    if(NOT DEFINED ARDUINO_LINK_FLAGS)
        MESSAGE(FATAL_ERROR "Could not get 'recipe.c.combine'")
    endif()


    string(REPLACE "\"{build.path}/{archive_file}\"" "" ARDUINO_LINK_FLAGS ${ARDUINO_LINK_FLAGS})
    string(REPLACE "{object_files}" "" ARDUINO_LINK_FLAGS ${ARDUINO_LINK_FLAGS})
    string(REPLACE "{build.path}" "${EXECUTABLE_OUTPUT_PATH}" ARDUINO_LINK_FLAGS ${ARDUINO_LINK_FLAGS})

        message("Link flags = ${ARDUINO_LINK_FLAGS} ${LINK_FLAGS}")

    set_target_properties(${TARGET_NAME} PROPERTIES
                COMPILE_FLAGS "${ARDUINO_COMPILE_FLAGS} ${COMPILE_FLAGS}"
                LINK_FLAGS "${ARDUINO_LINK_FLAGS}"
              ARCHIVE_OUTPUT_DIRECTORY "${EXECUTABLE_OUTPUT_PATH}"
              LIBRARY_OUTPUT_DIRECTORY "${EXECUTABLE_OUTPUT_PATH}"
              RUNTIME_OUTPUT_DIRECTORY "${EXECUTABLE_OUTPUT_PATH}"
                          )
    target_link_libraries(${TARGET_NAME} ${ALL_LIBS})


    # Convert firmware image to EEP format
    get_recipe_flags(ARDUINO_OBJCOPY_EEP_CMD ARDUINO_OBJCOPY_EEP_FLAGS ${BOARD_ID} "recipe.objcopy.eep")
    if(NOT DEFINED ARDUINO_OBJCOPY_EEP_FLAGS)
        MESSAGE(FATAL_ERROR "Could not get 'recipe.objcopy.eep'")
    endif()
    string(REPLACE "\"" "" ARDUINO_OBJCOPY_EEP_FLAGS ${ARDUINO_OBJCOPY_EEP_FLAGS})
    string(REPLACE " " ";" ARDUINO_OBJCOPY_EEP_FLAGS ${ARDUINO_OBJCOPY_EEP_FLAGS})
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
                        COMMAND ${ARDUINO_OBJCOPY_EEP_CMD}
                        ARGS     ${ARDUINO_OBJCOPY_EEP_FLAGS}
                        COMMENT "Generating EEP image"
                        VERBATIM)

    # Convert firmware image to ASCII HEX format
    get_recipe_flags(ARDUINO_OBJCOPY_HEX_CMD ARDUINO_OBJCOPY_HEX_FLAGS ${BOARD_ID} "recipe.objcopy.hex")
    if(NOT DEFINED ARDUINO_OBJCOPY_HEX_FLAGS)
        MESSAGE(FATAL_ERROR "Could not get 'recipe.objcopy.hex'")
    endif()
    string(REPLACE "\"" "" ARDUINO_OBJCOPY_HEX_FLAGS ${ARDUINO_OBJCOPY_HEX_FLAGS})
    string(REPLACE " " ";" ARDUINO_OBJCOPY_HEX_FLAGS ${ARDUINO_OBJCOPY_HEX_FLAGS})
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
                        COMMAND ${ARDUINO_OBJCOPY_HEX_CMD}
                        ARGS    ${ARDUINO_OBJCOPY_HEX_FLAGS}
                        COMMENT "Generating HEX image"
                        VERBATIM)

    # Display target size
    get_recipe_flags(ARDUINO_SIZE_CMD ARDUINO_SIZE_FLAGS ${BOARD_ID} "recipe.size")
    if(NOT DEFINED ARDUINO_SIZE_FLAGS)
        MESSAGE(FATAL_ERROR "Could not get 'recipe.size'")
    endif()
    string(REPLACE "\"" "" ARDUINO_SIZE_FLAGS ${ARDUINO_SIZE_FLAGS})
    string(REPLACE " " ";" ARDUINO_SIZE_FLAGS ${ARDUINO_SIZE_FLAGS})
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
                        COMMAND ${ARDUINO_SIZE_CMD}
                        ARGS    ${ARDUINO_SIZE_FLAGS}
                        COMMENT "Calculating image size"
                        VERBATIM)

    # Create ${TARGET_NAME}-size target
    add_custom_target(${TARGET_NAME}-size
                        COMMAND ${ARDUINO_SIZE_CMD}
                        ARGS    ${ARDUINO_SIZE_FLAGS}
                        DEPENDS ${TARGET_NAME}
                        COMMENT "Calculating ${TARGET_NAME} image size")

endfunction()


#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_bootloader_upload(TARGET_NAME BOARD_ID PORT)
#
#      TARGET_NAME - target name
#      BOARD_ID    - board id
#      PROGRAMMER_ID - the programmer
#      PORT        - serial port
#
# Set up target for upload firmware via the bootloader.
#
# The target for uploading the firmware is ${TARGET_NAME}-upload .
#
#=============================================================================#
function(setup_arduino_bootloader_upload TARGET_NAME BOARD_ID PROGRAMMER_ID PORT)
    set(UPLOAD_TARGET ${TARGET_NAME}-upload)

    if(NOT EXECUTABLE_OUTPUT_PATH)
        set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})
    endif()
    set(TARGET_PATH ${EXECUTABLE_OUTPUT_PATH}/${TARGET_NAME})

    get_recipe_flags(ARDUINO_UPLOAD_CMD ARDUINO_UPLOAD_FLAGS ${BOARD_ID} "tools.${PROGRAMMER_ID}.upload")

    string(REPLACE "{build.path}/{build.project_name}" "${TARGET_NAME}" ARDUINO_UPLOAD_FLAGS ${ARDUINO_UPLOAD_FLAGS})
    string(REPLACE "{serial.port}" "${PORT}" ARDUINO_UPLOAD_FLAGS ${ARDUINO_UPLOAD_FLAGS})

    if(NOT ARDUINO_UPLOAD_FLAGS)
        message(FATAL_ERROR "Could not generate bootloader args, aborting!")
    endif()

    string(REPLACE " " ";" ARDUINO_UPLOAD_FLAGS ${ARDUINO_UPLOAD_FLAGS})
    add_custom_target(${UPLOAD_TARGET}
                      ${ARDUINO_UPLOAD_CMD}
                      ${ARDUINO_UPLOAD_FLAGS}
                      DEPENDS ${TARGET_NAME})

    # Global upload target
    if(NOT TARGET upload)
        add_custom_target(upload)
    endif()

    add_dependencies(upload ${UPLOAD_TARGET})
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_upload(BOARD_ID TARGET_NAME PORT)
#
#        BOARD_ID    - Arduino board id
#        TARGET_NAME - Target name
#        PORT        - Serial port for upload
#        PROGRAMMER_ID - Programmer ID
#        AVRDUDE_FLAGS - avrdude flags
#
# Create an upload target (${TARGET_NAME}-upload) for the specified Arduino target.
#
#=============================================================================#
function(setup_arduino_upload BOARD_ID TARGET_NAME PORT PROGRAMMER_ID AVRDUDE_FLAGS)

    setup_arduino_bootloader_upload(${TARGET_NAME} ${BOARD_ID} ${PROGRAMMER_ID} ${PORT})

    # Add programmer support if defined
    if(PROGRAMMER_ID AND ${BOARD_ID}.upload.protocol)
        setup_arduino_programmer_burn(${TARGET_NAME} ${BOARD_ID} ${PROGRAMMER_ID} ${PORT} "${AVRDUDE_FLAGS}")
        setup_arduino_bootloader_burn(${TARGET_NAME} ${BOARD_ID} ${PROGRAMMER_ID} ${PORT} "${AVRDUDE_FLAGS}")
    endif()
endfunction()


#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_programmer_burn(TARGET_NAME BOARD_ID PROGRAMMER PORT AVRDUDE_FLAGS)
#
#      TARGET_NAME - name of target to burn
#      BOARD_ID    - board id
#      PROGRAMMER  - programmer id
#      PORT        - serial port
#
# Sets up target for burning firmware via a programmer.
#
# The target for burning the firmware is ${TARGET_NAME}-burn .
#
#=============================================================================#
function(setup_arduino_programmer_burn TARGET_NAME BOARD_ID PROGRAMMER PORT)
    set(PROGRAMMER_TARGET ${TARGET_NAME}-burn)

    if(NOT EXECUTABLE_OUTPUT_PATH)
        set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})
    endif()
    set(TARGET_PATH ${EXECUTABLE_OUTPUT_PATH}/${TARGET_NAME})

    get_recipe_flags(ARDUINO_PROGRAM_CMD ARDUINO_PROGRAM_FLAGS ${BOARD_ID} "tools.${PROGRAMMER_ID}.program")
    if(NOT ARDUINO_PROGRAM_FLAGS)
        message(FATAL_ERROR "Could not generate programmer args, aborting!")
    endif()

    string(REPLACE "{build.path}/{build.project_name}" "${TARGET_NAME}" ARDUINO_PROGRAM_FLAGS ${ARDUINO_PROGRAM_FLAGS})
    string(REPLACE "{program.extra_params}" "" ARDUINO_PROGRAM_FLAGS ${ARDUINO_PROGRAM_FLAGS})
    string(REPLACE "{protocol}" "${${BOARD_ID}.upload.protocol}" ARDUINO_PROGRAM_FLAGS ${ARDUINO_PROGRAM_FLAGS})
    string(REPLACE " " ";" ARDUINO_PROGRAM_FLAGS ${ARDUINO_PROGRAM_FLAGS})

    add_custom_target(${PROGRAMMER_TARGET}
                      ${ARDUINO_PROGRAM_CMD}
                      ${ARDUINO_PROGRAM_FLAGS}
                      DEPENDS ${TARGET_NAME})

endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_bootloader_burn(TARGET_NAME BOARD_ID PROGRAMMER PORT AVRDUDE_FLAGS)
#
#      TARGET_NAME - name of target to burn
#      BOARD_ID    - board id
#      PROGRAMMER  - programmer id
#      PORT        - serial port
#      AVRDUDE_FLAGS - avrdude flags (override)
#
# Create a target for burning a bootloader via a programmer.
#
# The target for burning the bootloader is ${TARGET_NAME}-burn-bootloader
#
#=============================================================================#
function(setup_arduino_bootloader_burn TARGET_NAME BOARD_ID PROGRAMMER PORT AVRDUDE_FLAGS)

    set(PLATFORM ${${BOARD_ID}.PLATFORM})

    setup_arduino_bootloader_erase("${TARGET_NAME}" "${BOARD_ID}" "${PROGRAMMER}" "${PORT}" "${AVRDUDE_FLAGS}")

    set(BOOTLOADER_TARGET ${TARGET_NAME}-burn-bootloader)

    if(NOT EXECUTABLE_OUTPUT_PATH)
        set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})
    endif()
    set(TARGET_PATH ${EXECUTABLE_OUTPUT_PATH}/${TARGET_NAME})

    get_recipe_flags(ARDUINO_BOOTLOADER_CMD ARDUINO_BOOTLOADER_FLAGS ${BOARD_ID} "tools.${PROGRAMMER_ID}.bootloader")
    if(NOT ARDUINO_BOOTLOADER_FLAGS)
        message(FATAL_ERROR "Could not generate bootloader args, aborting!")
    endif()

    string(REPLACE "{build.path}/{build.project_name}" "${TARGET_NAME}" ARDUINO_BOOTLOADER_FLAGS ${ARDUINO_BOOTLOADER_FLAGS})
    string(REPLACE "{program.extra_params}" "" ARDUINO_BOOTLOADER_FLAGS ${ARDUINO_BOOTLOADER_FLAGS})
    string(REPLACE "{protocol}" "${${BOARD_ID}.upload.protocol}" ARDUINO_BOOTLOADER_FLAGS ${ARDUINO_BOOTLOADER_FLAGS})
    string(REPLACE " " ";" ARDUINO_BOOTLOADER_FLAGS ${ARDUINO_BOOTLOADER_FLAGS})

    if(NOT EXISTS "${${PLATFORM}_BOOTLOADERS_PATH}/${${BOARD_ID}.bootloader.path}/${${BOARD_ID}${ARDUINO_CPUMENU}.bootloader.file}")
        message("${${PLATFORM}_BOOTLOADERS_PATH}/${${BOARD_ID}.bootloader.path}/${${BOARD_ID}${ARDUINO_CPUMENU}.bootloader.file}")
        message(FATAL_ERROR "Missing bootloader image, not creating bootloader burn target ${BOOTLOADER_TARGET}.")
    endif()

    # Create burn bootloader target
    add_custom_target(${BOOTLOADER_TARGET}
                     ${ARDUINO_BOOTLOADER_CMD}
                     ${ARDUINO_BOOTLOADER_FLAGS}
                     WORKING_DIRECTORY ${${PLATFORM}_BOOTLOADERS_PATH}/${${BOARD_ID}.bootloader.path}
                     DEPENDS ${TARGET_NAME}-erase-bootloader)
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_bootloader_erase(TARGET_NAME BOARD_ID PROGRAMMER PORT AVRDUDE_FLAGS)
#
#      TARGET_NAME - name of target to erase
#      BOARD_ID    - board id
#      PROGRAMMER  - programmer id
#      PORT        - serial port
#      AVRDUDE_FLAGS - avrdude flags (override)
#
# Create a target for erasing the bootloader via a programmer.
#
# The target for erasing the bootloader is ${TARGET_NAME}-erase-bootloader
#
#=============================================================================#
function(setup_arduino_bootloader_erase TARGET_NAME BOARD_ID PROGRAMMER PORT AVRDUDE_FLAGS)
    set(ERASE_TARGET ${TARGET_NAME}-erase-bootloader)

    if(NOT EXECUTABLE_OUTPUT_PATH)
        set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})
    endif()
    set(TARGET_PATH ${EXECUTABLE_OUTPUT_PATH}/${TARGET_NAME})

    get_recipe_flags(ARDUINO_ERASE_CMD ARDUINO_ERASE_FLAGS ${BOARD_ID} "tools.${PROGRAMMER_ID}.erase")
    if(NOT ARDUINO_ERASE_FLAGS)
        message(FATAL_ERROR "Could not generate ERASE args, aborting!")
    endif()

    string(REPLACE "{build.path}/{build.project_name}" "${TARGET_NAME}" ARDUINO_ERASE_FLAGS ${ARDUINO_ERASE_FLAGS})
    string(REPLACE "{program.extra_params}" "" ARDUINO_ERASE_FLAGS ${ARDUINO_ERASE_FLAGS})
    string(REPLACE "{protocol}" "${${BOARD_ID}.upload.protocol}" ARDUINO_ERASE_FLAGS ${ARDUINO_ERASE_FLAGS})
    string(REPLACE " " ";" ARDUINO_ERASE_FLAGS ${ARDUINO_ERASE_FLAGS})

    # Create burn ERASE target
    add_custom_target(${ERASE_TARGET}
                     ${ARDUINO_ERASE_CMD}
                     ${ARDUINO_ERASE_FLAGS}
                     DEPENDS ${TARGET_NAME})
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_bootloader_args(BOARD_ID TARGET_NAME PORT AVRDUDE_FLAGS OUTPUT_VAR)
#
#      BOARD_ID    - board id
#      TARGET_NAME - target name
#      PORT        - serial port
#      AVRDUDE_FLAGS - avrdude flags (override)
#      OUTPUT_VAR  - name of output variable for result
#
# Sets up default avrdude settings for uploading firmware via the bootloader.
#=============================================================================#
function(setup_arduino_bootloader_args BOARD_ID TARGET_NAME PORT AVRDUDE_FLAGS OUTPUT_VAR)
    set(AVRDUDE_ARGS ${${OUTPUT_VAR}})

    list(APPEND AVRDUDE_ARGS
        "-C${ARDUINO_AVRDUDE_CONFIG_PATH}"  # avrdude config
        "-p${${BOARD_ID}${ARDUINO_CPUMENU}.build.mcu}"        # MCU Type
        )

    # Programmer
    if(NOT ${BOARD_ID}${ARDUINO_CPUMENU}.upload.protocol OR ${BOARD_ID}${ARDUINO_CPUMENU}.upload.protocol STREQUAL "stk500")
        if(NOT ${BOARD_ID}.upload.protocol OR ${BOARD_ID}.upload.protocol STREQUAL "stk500")
            list(APPEND AVRDUDE_ARGS "-cstk500v1")
        else()
            list(APPEND AVRDUDE_ARGS "-c${${BOARD_ID}.upload.protocol}")
        endif()
    else()
        list(APPEND AVRDUDE_ARGS "-c${${BOARD_ID}${ARDUINO_CPUMENU}.upload.protocol}")
    endif()

    set(UPLOAD_SPEED "19200")
    if(${BOARD_ID}${ARDUINO_CPUMENU}.upload.speed)
        set(UPLOAD_SPEED ${${BOARD_ID}${ARDUINO_CPUMENU}.upload.speed})
    endif()

    list(APPEND AVRDUDE_ARGS
        "-b${UPLOAD_SPEED}"     # Baud rate
        "-P${PORT}"                         # Serial port
        "-D"                                # Dont erase
        )

    list(APPEND AVRDUDE_ARGS ${AVRDUDE_FLAGS})

    set(${OUTPUT_VAR} ${AVRDUDE_ARGS} PARENT_SCOPE)
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# find_sources(VAR_NAME LIB_PATH RECURSE)
#
#        VAR_NAME - Variable name that will hold the detected sources
#        LIB_PATH - The base path
#        RECURSE  - Whether or not to recurse
#
# Finds all C/C++ sources located at the specified path.
#
#=============================================================================#
function(find_sources VAR_NAME LIB_PATH RECURSE)
    set(FILE_SEARCH_LIST
        ${LIB_PATH}/*.cpp
        ${LIB_PATH}/*.c
        ${LIB_PATH}/*.cc
        ${LIB_PATH}/*.cxx
        ${LIB_PATH}/*.h
        ${LIB_PATH}/*.hh
        ${LIB_PATH}/*.hxx)

    if(RECURSE)
        file(GLOB_RECURSE LIB_FILES ${FILE_SEARCH_LIST})
    else()
        file(GLOB LIB_FILES ${FILE_SEARCH_LIST})
    endif()

    if(LIB_FILES)
        set(${VAR_NAME} ${LIB_FILES} PARENT_SCOPE)
    endif()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_serial_target(TARGET_NAME CMD)
#
#         TARGET_NAME - Target name
#         CMD         - Serial terminal command
#
# Creates a target (${TARGET_NAME}-serial) for launching the serial termnial.
#
#=============================================================================#
function(setup_serial_target TARGET_NAME CMD SERIAL_PORT)
    string(CONFIGURE "${CMD}" FULL_CMD @ONLY)
    add_custom_target(${TARGET_NAME}-serial
                      COMMAND ${FULL_CMD})
endfunction()


#=============================================================================#
# [PRIVATE/INTERNAL]
#
# detect_arduino_version(VAR_NAME)
#
#       VAR_NAME - Variable name where the detected version will be saved
#
# Detects the Arduino SDK Version based on the lib/versions.txt file. The
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
#      entry[.setting][.subsetting] = value
#
# where [.setting] and [.subsetting] is optional
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
#      set(uno.upload.SETTINGS protocol maximum_size) # List of sub-settings for uno.upload
#      set(uno.build.SETTINGS mcu core)               # List of sub-settings for uno.build
#
#  The ${ENTRY_NAME}.SETTINGS variable lists all settings for the entry
#
#  These variables are generated in order to be able to  programatically traverse
# all settings (for a example see print_board_settings() function).
#
#=============================================================================#
function(LOAD_ARDUINO_STYLE_SETTINGS SETTINGS_LIST SETTINGS_PATH SETTINGS_PREFIX)

    if(NOT ${SETTINGS_LIST} AND EXISTS ${SETTINGS_PATH})
        file(STRINGS ${SETTINGS_PATH} FILE_ENTRIES)  # Settings file split into lines

        foreach(FILE_ENTRY ${FILE_ENTRIES})
            if("${FILE_ENTRY}" MATCHES "^[^#]+=.*")

                string(REGEX MATCH "^([^=]*)=(.*)$" SETTING_SPLIT ${FILE_ENTRY})
                if(NOT DEFINED CMAKE_MATCH_1 OR NOT DEFINED CMAKE_MATCH_2)
                    MESSAGE(WARNING "Invalid setting: ${FILE_ENTRY}")
                    continue()
                endif()

                set(SETTING_NAME ${CMAKE_MATCH_1})
                set(SETTING_VALUE ${CMAKE_MATCH_2})
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

                set(FULL_SETTING_NAME "${SETTINGS_PREFIX}")

                set(ENTRY_SETTING_LIST)

                foreach(subsetting ${ENTRY_NAME_TOKENS})

                    if (FULL_SETTING_NAME STREQUAL "")
                        set(FULL_SETTING_NAME "${subsetting}")
                    else()
                        set(FULL_SETTING_NAME ${FULL_SETTING_NAME}.${subsetting})
                    endif()

                    if(ENTRY_SETTING_LIST)
                        list(FIND ${ENTRY_SETTING_LIST} ${subsetting} ENTRY_SETTING_INDEX)
                        if(ENTRY_SETTING_INDEX LESS 0)
                            # Add setting to entry
                            list(APPEND ${ENTRY_SETTING_LIST} ${subsetting})
                            set(${ENTRY_SETTING_LIST} ${${ENTRY_SETTING_LIST}}
                                CACHE INTERNAL "${PLATFORM} ${FULL_SETTING_NAME} Board settings list")
                        endif()
                    endif()

                    set(ENTRY_SETTING_LIST ${FULL_SETTING_NAME}.SETTINGS)

                endforeach()

                # Save setting value
                set(${FULL_SETTING_NAME} ${SETTING_VALUE}
                    CACHE INTERNAL "${PLATFORM} ${ENTRY_NAME} Board setting")

            endif()
        endforeach()
        set(${SETTINGS_LIST} ${${SETTINGS_LIST}}
            CACHE STRING "List of detected ${PLATFORM} Board configurations")
        mark_as_advanced(${SETTINGS_LIST})
    endif()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# GET_VARIABLE_VALUE_FILLED(SETTING_VALUE BOARD_ID)
#
#      VARIABLE_RETURN - The name of the return variable
#      SETTING_VALUE - the value of the variable with placeholders
#      BOARD_ID - the id of the board to identify the correct placeholder replacements
#      SETTING_NAME - optional setting name
#
# Replace placeholders in the variable value with the defined values from
# the cache.
# E.g.
# {runtime.tools.avrdude.path}
# will be replaced accordingly
#=============================================================================#
function(GET_VARIABLE_VALUE_FILLED VARIABLE_RETURN SETTING_VALUE BOARD_ID SETTING_NAME)
    set(PLATFORM ${${BOARD_ID}.PLATFORM})
    set(${VARIABLE_RETURN} ${SETTING_VALUE} PARENT_SCOPE)

    if (NOT SETTING_VALUE STREQUAL "")
        string(REGEX MATCHALL "{([^}]+)}" VARS_REPLACE ${SETTING_VALUE})
        LIST(LENGTH VARS_REPLACE MATCH_COUNT)
        if(MATCH_COUNT GREATER 0)
            FOREACH(i IN LISTS VARS_REPLACE)
                string(REPLACE "}" "" i ${i})
                string(REPLACE "{" "" i ${i})

                unset(VAR_VALUE)
                unset(VAR_NAME)

                set(PREFIXED_NAME_PLATFORM "${PLATFORM}.${i}")
                set(PREFIXED_NAME_BOARD "${BOARD_ID}.${i}")
                set(PREFIXED_CPU "${BOARD_ID}${ARDUINO_CPUMENU}.${i}")
                if (DEFINED ${PREFIXED_NAME_BOARD})
                    set(VAR_VALUE "${${PREFIXED_NAME_BOARD}}")
                    set(VAR_NAME "${PREFIXED_NAME_BOARD}")
                elseif(DEFINED ${PREFIXED_NAME_PLATFORM})
                    set(VAR_VALUE "${${PREFIXED_NAME_PLATFORM}}")
                    set(VAR_NAME "${PREFIXED_NAME_PLATFORM}")
                elseif(DEFINED ${PREFIXED_CPU} )
                    set(VAR_VALUE "${${PREFIXED_CPU}}")
                    set(VAR_NAME "${PREFIXED_CPU}")
                elseif(DEFINED ${i})
                    set(VAR_VALUE "${${i}}")
                    set(VAR_NAME "${i}")
                else()
                    #MESSAGE(FATAL_ERROR "${i} not found in settings")
                endif()

                if(NOT DEFINED VAR_VALUE AND SETTING_NAME)
                    # check if the value is somewhere available along the path leading to this setting
                    # i.e. if the searched value is 'path' and the variable is called 'some.compiler.tool' check
                    # - some.compiler.path
                    # - some.path
                    if(SETTING_NAME MATCHES "^(.+)\\.[^\\.]+\$")
                        set(SETTING_NAME_BASE "${CMAKE_MATCH_1}")
                        while (SETTING_NAME_BASE MATCHES "^(.+)\\.[^\\.]+\$")
                            set(SETTING_NAME_BASE "${CMAKE_MATCH_1}")
                            set(CUR_VAR_NAME "${SETTING_NAME_BASE}.${i}")
                            if(DEFINED ${CUR_VAR_NAME})
                                set(VAR_VALUE "${${CUR_VAR_NAME}}")
                                set(VAR_NAME "${CUR_VAR_NAME}")
                                break()
                            endif()
                        endwhile ()
                    endif()
                endif()

                if(DEFINED VAR_VALUE)
                    #recursively replace
                    set(TMP_FILLED "${VAR_VALUE}")
                    get_variable_value_filled(TMP_FILLED "${VAR_VALUE}" ${BOARD_ID} ${VAR_NAME})
                    string(REPLACE "{${i}}" "${TMP_FILLED}" SETTING_VALUE ${SETTING_VALUE})
                endif()
            ENDFOREACH()
            set(${VARIABLE_RETURN} ${SETTING_VALUE} PARENT_SCOPE)
        endif()
    endif()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# GET_VARIABLE_FILLED(VARIABLE_NAME BOARD_ID)
#
#      VARIABLE_RETURN - The name of the return variable
#      VARIABLE_NAME - the variable from which the value should be returned
#      BOARD_ID - the id of the board to identify the correct placeholder replacements
#
# Replace placeholders in the variable value with the defined values from
# the cache.
# E.g.
# GET_VARIABLE_FILLED(SOME_VAR "recipe.c.o.pattern" "${${PROJECT_NAME}_BOARD}")
# MESSAGE(STATUS "Var = ${SOME_VAR}")
#=============================================================================#
function(GET_VARIABLE_FILLED VARIABLE_RETURN VARIABLE_NAME BOARD_ID)

    set(PLATFORM ${${BOARD_ID}.PLATFORM})

    set(PREFIXED_NAME_PLATFORM "${PLATFORM}.${VARIABLE_NAME}")
    set(PREFIXED_NAME_BOARD "${BOARD_ID}.${VARIABLE_NAME}")
    if (DEFINED ${PREFIXED_NAME_BOARD})
        set(SETTING_VALUE "${${PREFIXED_NAME_BOARD}}")
    elseif(DEFINED ${PREFIXED_NAME_PLATFORM})
        set(SETTING_VALUE "${${PREFIXED_NAME_PLATFORM}}")
    elseif(DEFINED ${VARIABLE_NAME})
        set(SETTING_VALUE "${${VARIABLE_NAME}}")
    endif()

    if (NOT DEFINED SETTING_VALUE)
        MESSAGE(WARNING "Variable ${VARIABLE_NAME} is not set")
    endif()


    if (NOT SETTING_VALUE STREQUAL "")
        set(VARIABLE_FILLED "")
        get_variable_value_filled("VARIABLE_FILLED" "${SETTING_VALUE}" "${BOARD_ID}")
        set(${VARIABLE_RETURN} ${VARIABLE_FILLED} PARENT_SCOPE)
    else()
        set(${VARIABLE_RETURN} ${SETTING_VALUE} PARENT_SCOPE)
    endif()
endfunction()

#=============================================================================#
# print_settings(ENTRY_NAME)
#
#      ENTRY_NAME - name of entry
#
# Print the entry settings (see load_arduino_syle_settings()).
#
#=============================================================================#
function(PRINT_SETTINGS ENTRY_NAME)
    if(${ENTRY_NAME}.SETTINGS)

        foreach(ENTRY_SETTING ${${ENTRY_NAME}.SETTINGS})
            if(DEFINED ${ENTRY_NAME}.${ENTRY_SETTING})
                message(STATUS "   ${ENTRY_NAME}.${ENTRY_SETTING}=${${ENTRY_NAME}.${ENTRY_SETTING}}")
            endif()
            print_settings("${ENTRY_NAME}.${ENTRY_SETTING}")
        endforeach()
    endif()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# print_list(SETTINGS_LIST)
#
#      SETTINGS_LIST - Variables name of settings list
#
# Print list settings and names (see load_arduino_syle_settings()).
#=============================================================================#
function(PRINT_LIST SETTINGS_LIST)
    if(${SETTINGS_LIST})
        set(MAX_LENGTH 0)
        foreach(ENTRY_NAME ${${SETTINGS_LIST}})
            string(LENGTH "${ENTRY_NAME}" CURRENT_LENGTH)
            if(CURRENT_LENGTH GREATER MAX_LENGTH)
                set(MAX_LENGTH ${CURRENT_LENGTH})
            endif()
        endforeach()
        foreach(ENTRY_NAME ${${SETTINGS_LIST}})
            string(LENGTH "${ENTRY_NAME}" CURRENT_LENGTH)
            math(EXPR PADDING_LENGTH "${MAX_LENGTH}-${CURRENT_LENGTH}")
            set(PADDING "")
            foreach(X RANGE ${PADDING_LENGTH})
                set(PADDING "${PADDING} ")
            endforeach()
            message(STATUS "   ${PADDING}${ENTRY_NAME}: ${${ENTRY_NAME}.name}")
        endforeach()
    endif()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_example(TARGET_NAME LIBRARY_NAME EXAMPLE_NAME OUTPUT_VAR)
#
#      TARGET_NAME  - Target name
#      LIBRARY_NAME - Library name
#      EXAMPLE_NAME - Example name
#      OUTPUT_VAR   - Variable name to save sketch path.
#
# Creates a Arduino example from a the specified library.
#=============================================================================#
function(SETUP_ARDUINO_EXAMPLE TARGET_NAME LIBRARY_NAME EXAMPLE_NAME OUTPUT_VAR)
    set(EXAMPLE_SKETCH_PATH )

    get_property(LIBRARY_SEARCH_PATH
                 DIRECTORY     # Property Scope
                 PROPERTY LINK_DIRECTORIES)
    foreach(LIB_SEARCH_PATH ${LIBRARY_SEARCH_PATH} ${ARDUINO_LIBRARIES_PATH} ${${ARDUINO_PLATFORM}_LIBRARIES_PATH} ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/libraries)
        message(STATUS "Search ${LIBRARY_NAME} example directory in ${LIB_SEARCH_PATH}")
        if(EXISTS "${LIB_SEARCH_PATH}/${LIBRARY_NAME}/examples/${EXAMPLE_NAME}")
            set(EXAMPLE_SKETCH_PATH "${LIB_SEARCH_PATH}/${LIBRARY_NAME}/examples/${EXAMPLE_NAME}")
            break()
        endif()
    endforeach()

    if(EXAMPLE_SKETCH_PATH)
        setup_arduino_sketch(${TARGET_NAME} ${EXAMPLE_SKETCH_PATH} SKETCH_CPP)
        set("${OUTPUT_VAR}" ${${OUTPUT_VAR}} ${SKETCH_CPP} PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Could not find example ${EXAMPLE_NAME} from library ${LIBRARY_NAME}")
    endif()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_sketch(TARGET_NAME SKETCH_PATH OUTPUT_VAR)
#
#      TARGET_NAME - Target name
#      SKETCH_PATH - Path to sketch directory
#      OUTPUT_VAR  - Variable name where to save generated sketch source
#
# Generates C++ sources from Arduino Sketch.
#=============================================================================#
function(SETUP_ARDUINO_SKETCH TARGET_NAME SKETCH_PATH OUTPUT_VAR)
    get_filename_component(SKETCH_NAME "${SKETCH_PATH}" NAME)
    get_filename_component(SKETCH_PATH "${SKETCH_PATH}" ABSOLUTE)

    if(EXISTS "${SKETCH_PATH}")
        set(SKETCH_CPP  ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}_${SKETCH_NAME}.cpp)

        if (IS_DIRECTORY "${SKETCH_PATH}")
            # Sketch directory specified, try to find main sketch...
            set(MAIN_SKETCH ${SKETCH_PATH}/${SKETCH_NAME})

            if(EXISTS "${MAIN_SKETCH}.pde")
                set(MAIN_SKETCH "${MAIN_SKETCH}.pde")
            elseif(EXISTS "${MAIN_SKETCH}.ino")
                set(MAIN_SKETCH "${MAIN_SKETCH}.ino")
            else()
                message(FATAL_ERROR "Could not find main sketch (${SKETCH_NAME}.pde or ${SKETCH_NAME}.ino) at ${SKETCH_PATH}! Please specify the main sketch file path instead of directory.")
            endif()
        else()
            # Sektch file specified, assuming parent directory as sketch directory
            set(MAIN_SKETCH ${SKETCH_PATH})
            get_filename_component(SKETCH_PATH "${SKETCH_PATH}" PATH)
        endif()
        arduino_debug_msg("sketch: ${MAIN_SKETCH}")

        # Find all sketch files
        file(GLOB SKETCH_SOURCES ${SKETCH_PATH}/*.pde ${SKETCH_PATH}/*.ino)
        set(ALL_SRCS ${SKETCH_SOURCES})

        list(REMOVE_ITEM SKETCH_SOURCES ${MAIN_SKETCH})
        list(SORT SKETCH_SOURCES)



        generate_cpp_from_sketch("${MAIN_SKETCH}" "${SKETCH_SOURCES}" "${SKETCH_CPP}")

        # Regenerate build system if sketch changes
        add_custom_command(OUTPUT ${SKETCH_CPP}
                           COMMAND ${CMAKE_COMMAND} ${CMAKE_SOURCE_DIR}
                           WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                           DEPENDS ${MAIN_SKETCH} ${SKETCH_SOURCES}
                           COMMENT "Regnerating ${SKETCH_NAME} Sketch")
        set_source_files_properties(${SKETCH_CPP} PROPERTIES GENERATED TRUE)
        # Mark file that it exists for find_file
        set_source_files_properties(${SKETCH_CPP} PROPERTIES GENERATED_SKETCH TRUE)

        set("${OUTPUT_VAR}" ${${OUTPUT_VAR}} ${SKETCH_CPP} PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Sketch does not exist: ${SKETCH_PATH}")
    endif()
endfunction()


#=============================================================================#
# [PRIVATE/INTERNAL]
#
# generate_cpp_from_sketch(MAIN_SKETCH_PATH SKETCH_SOURCES SKETCH_CPP)
#
#         MAIN_SKETCH_PATH - Main sketch file path
#         SKETCH_SOURCES   - Setch source paths
#         SKETCH_CPP       - Name of file to generate
#
# Generate C++ source file from Arduino sketch files.
#=============================================================================#
function(GENERATE_CPP_FROM_SKETCH MAIN_SKETCH_PATH SKETCH_SOURCES SKETCH_CPP)
    file(WRITE ${SKETCH_CPP} "// automatically generated by arduino-cmake\n")
    file(READ  ${MAIN_SKETCH_PATH} MAIN_SKETCH)

    # remove comments
    remove_comments(MAIN_SKETCH MAIN_SKETCH_NO_COMMENTS)

    # find first statement
    string(REGEX MATCH "[\n][_a-zA-Z0-9]+[^\n]*" FIRST_STATEMENT "${MAIN_SKETCH_NO_COMMENTS}")
    string(FIND "${MAIN_SKETCH}" "${FIRST_STATEMENT}" HEAD_LENGTH)
    if ("${HEAD_LENGTH}" STREQUAL "-1")
        set(HEAD_LENGTH 0)
    endif()
    #message(STATUS "FIRST STATEMENT: ${FIRST_STATEMENT}")
    #message(STATUS "FIRST STATEMENT POSITION: ${HEAD_LENGTH}")
    string(LENGTH "${MAIN_SKETCH}" MAIN_SKETCH_LENGTH)

    string(SUBSTRING "${MAIN_SKETCH}" 0 ${HEAD_LENGTH} SKETCH_HEAD)
    #arduino_debug_msg("SKETCH_HEAD:\n${SKETCH_HEAD}")

    # find the body of the main pde
    math(EXPR BODY_LENGTH "${MAIN_SKETCH_LENGTH}-${HEAD_LENGTH}")
    string(SUBSTRING "${MAIN_SKETCH}" "${HEAD_LENGTH}+1" "${BODY_LENGTH}-1" SKETCH_BODY)
    #arduino_debug_msg("BODY:\n${SKETCH_BODY}")

    # write the file head
    file(APPEND ${SKETCH_CPP} "#line 1 \"${MAIN_SKETCH_PATH}\"\n${SKETCH_HEAD}")

    # Count head line offset (for GCC error reporting)
    file(STRINGS ${SKETCH_CPP} SKETCH_HEAD_LINES)
    list(LENGTH SKETCH_HEAD_LINES SKETCH_HEAD_LINES_COUNT)
    math(EXPR SKETCH_HEAD_OFFSET "${SKETCH_HEAD_LINES_COUNT}+2")

    # add arduino include header
    #file(APPEND ${SKETCH_CPP} "\n#line 1 \"autogenerated\"\n")
    file(APPEND ${SKETCH_CPP} "\n#line ${SKETCH_HEAD_OFFSET} \"${SKETCH_CPP}\"\n")
    if(ARDUINO_SDK_VERSION VERSION_LESS 1.0)
        file(APPEND ${SKETCH_CPP} "#include \"WProgram.h\"\n")
    else()
        file(APPEND ${SKETCH_CPP} "#include \"Arduino.h\"\n")
    endif()

    # add function prototypes
    foreach(SKETCH_SOURCE_PATH ${SKETCH_SOURCES} ${MAIN_SKETCH_PATH})
        arduino_debug_msg("Sketch: ${SKETCH_SOURCE_PATH}")
        file(READ ${SKETCH_SOURCE_PATH} SKETCH_SOURCE)
        remove_comments(SKETCH_SOURCE SKETCH_SOURCE)

        set(ALPHA "a-zA-Z")
        set(NUM "0-9")
        set(ALPHANUM "${ALPHA}${NUM}")
        set(WORD "_${ALPHANUM}")
        set(LINE_START "(^|[\n])")
        set(QUALIFIERS "[ \t]*([${ALPHA}]+[ ])*")
        set(TYPE "[${WORD}]+([ ]*[\n][\t]*|[ ])+")
        set(FNAME "[${WORD}]+[ ]?[\n]?[\t]*[ ]*")
        set(FARGS "[(]([\t]*[ ]*[*&]?[ ]?[${WORD}](\\[([${NUM}]+)?\\])*[,]?[ ]*[\n]?)*([,]?[ ]*[\n]?)?[)]")
        set(BODY_START "([ ]*[\n][\t]*|[ ]|[\n])*{")
        set(PROTOTYPE_PATTERN "${LINE_START}${QUALIFIERS}${TYPE}${FNAME}${FARGS}${BODY_START}")

        string(REGEX MATCHALL "${PROTOTYPE_PATTERN}" SKETCH_PROTOTYPES "${SKETCH_SOURCE}")

        # Write function prototypes
        file(APPEND ${SKETCH_CPP} "\n//=== START Forward: ${SKETCH_SOURCE_PATH}\n")
        foreach(SKETCH_PROTOTYPE ${SKETCH_PROTOTYPES})
            string(REPLACE "\n" " " SKETCH_PROTOTYPE "${SKETCH_PROTOTYPE}")
            string(REPLACE "{" "" SKETCH_PROTOTYPE "${SKETCH_PROTOTYPE}")
            arduino_debug_msg("\tprototype: ${SKETCH_PROTOTYPE};")
            # " else if(var == other) {" shoudn't be listed as prototype
            if(NOT SKETCH_PROTOTYPE MATCHES "(if[ ]?[\n]?[\t]*[ ]*[)])")
                file(APPEND ${SKETCH_CPP} "${SKETCH_PROTOTYPE};\n")
            else()
                arduino_debug_msg("\trejected prototype: ${SKETCH_PROTOTYPE};")
            endif()
            file(APPEND ${SKETCH_CPP} "${SKETCH_PROTOTYPE};\n")
        endforeach()
        file(APPEND ${SKETCH_CPP} "//=== END Forward: ${SKETCH_SOURCE_PATH}\n")
    endforeach()

    # Write Sketch CPP source
    get_num_lines("${SKETCH_HEAD}" HEAD_NUM_LINES)
    file(APPEND ${SKETCH_CPP} "#line ${HEAD_NUM_LINES} \"${MAIN_SKETCH_PATH}\"\n")
    file(APPEND ${SKETCH_CPP} "\n${SKETCH_BODY}")
    foreach (SKETCH_SOURCE_PATH ${SKETCH_SOURCES})
        file(READ ${SKETCH_SOURCE_PATH} SKETCH_SOURCE)
        file(APPEND ${SKETCH_CPP} "\n//=== START : ${SKETCH_SOURCE_PATH}\n")
        file(APPEND ${SKETCH_CPP} "#line 1 \"${SKETCH_SOURCE_PATH}\"\n")
        file(APPEND ${SKETCH_CPP} "${SKETCH_SOURCE}")
        file(APPEND ${SKETCH_CPP} "\n//=== END : ${SKETCH_SOURCE_PATH}\n")
    endforeach()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
#  arduino_debug_on()
#
# Enables Arduino module debugging.
#=============================================================================#
function(ARDUINO_DEBUG_ON)
    set(ARDUINO_DEBUG True PARENT_SCOPE)
endfunction()


#=============================================================================#
# [PRIVATE/INTERNAL]
#
#  arduino_debug_off()
#
# Disables Arduino module debugging.
#=============================================================================#
function(ARDUINO_DEBUG_OFF)
    set(ARDUINO_DEBUG False PARENT_SCOPE)
endfunction()


#=============================================================================#
# [PRIVATE/INTERNAL]
#
# arduino_debug_msg(MSG)
#
#        MSG - Message to print
#
# Print Arduino debugging information. In order to enable printing
# use arduino_debug_on() and to disable use arduino_debug_off().
#=============================================================================#
function(ARDUINO_DEBUG_MSG MSG)
    if(ARDUINO_DEBUG)
        message("## ${MSG}")
    endif()
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# remove_comments(SRC_VAR OUT_VAR)
#
#        SRC_VAR - variable holding sources
#        OUT_VAR - variable holding sources with no comments
#
# Removes all comments from the source code.
#=============================================================================#
function(REMOVE_COMMENTS SRC_VAR OUT_VAR)
    string(REGEX REPLACE "[\\./\\\\]" "_" FILE "${NAME}")

    set(SRC ${${SRC_VAR}})

    #message(STATUS "removing comments from: ${FILE}")
    #file(WRITE "${CMAKE_BINARY_DIR}/${FILE}_pre_remove_comments.txt" ${SRC})
    #message(STATUS "\n${SRC}")

    # remove all comments
    string(REGEX REPLACE "([/][/][^\n]*)|([/][\\*]([^\\*]|([\\*]+[^/\\*]))*[\\*]+[/])" "" OUT "${SRC}")

    #file(WRITE "${CMAKE_BINARY_DIR}/${FILE}_post_remove_comments.txt" ${SRC})
    #message(STATUS "\n${SRC}")

    set(${OUT_VAR} ${OUT} PARENT_SCOPE)

endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# get_num_lines(DOCUMENT OUTPUT_VAR)
#
#        DOCUMENT   - Document contents
#        OUTPUT_VAR - Variable which will hold the line number count
#
# Counts the line number of the document.
#=============================================================================#
function(GET_NUM_LINES DOCUMENT OUTPUT_VAR)
    string(REGEX MATCHALL "[\n]" MATCH_LIST "${DOCUMENT}")
    list(LENGTH MATCH_LIST NUM)
    set(${OUTPUT_VAR} ${NUM} PARENT_SCOPE)
endfunction()

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
#                              C Flags
#=============================================================================#
if (NOT DEFINED ARDUINO_C_FLAGS)
    set(ARDUINO_C_FLAGS "-g -Os -w -ffunction-sections -fdata-sections -MMD")
endif (NOT DEFINED ARDUINO_C_FLAGS)
set(CMAKE_C_FLAGS                "${ARDUINO_C_FLAGS}" CACHE STRING "")
set(CMAKE_C_FLAGS_DEBUG          "${ARDUINO_C_FLAGS}" CACHE STRING "")
set(CMAKE_C_FLAGS_MINSIZEREL     "${ARDUINO_C_FLAGS}" CACHE STRING "")
set(CMAKE_C_FLAGS_RELEASE        "${ARDUINO_C_FLAGS}" CACHE STRING "")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "${ARDUINO_C_FLAGS}" CACHE STRING "")

#=============================================================================#
#                             C++ Flags
#=============================================================================#
if (NOT DEFINED ARDUINO_CXX_FLAGS)
    set(ARDUINO_CXX_FLAGS "-g -Os -w -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD")
endif (NOT DEFINED ARDUINO_CXX_FLAGS)
set(CMAKE_CXX_FLAGS                "${ARDUINO_CXX_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_DEBUG          "${ARDUINO_CXX_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_MINSIZEREL     "${ARDUINO_CXX_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE        "${ARDUINO_CXX_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${ARDUINO_CXX_FLAGS}" CACHE STRING "")

#=============================================================================#
#                       Executable Linker Flags                               #
#=============================================================================#
set(ARDUINO_LINKER_FLAGS "-w -Os -Wl,--gc-sections")
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


#=============================================================================#
#                          Initialization
#=============================================================================#
if(NOT ARDUINO_FOUND AND ARDUINO_SDK_PATH)

    find_file(ARDUINO_VERSION_PATH
        NAMES lib/version.txt
        PATHS ${ARDUINO_SDK_PATH}
        DOC "Path to Arduino version file."
        NO_SYSTEM_ENVIRONMENT_PATH)


    detect_arduino_version(ARDUINO_SDK_VERSION)
    set(ARDUINO_SDK_VERSION       ${ARDUINO_SDK_VERSION}       CACHE STRING "Arduino SDK Version")
    set(ARDUINO_SDK_VERSION_MAJOR ${ARDUINO_SDK_VERSION_MAJOR} CACHE STRING "Arduino SDK Major Version")
    set(ARDUINO_SDK_VERSION_MINOR ${ARDUINO_SDK_VERSION_MINOR} CACHE STRING "Arduino SDK Minor Version")
    set(ARDUINO_SDK_VERSION_PATCH ${ARDUINO_SDK_VERSION_PATCH} CACHE STRING "Arduino SDK Patch Version")

    if(ARDUINO_SDK_VERSION VERSION_LESS 0.19)
        message(FATAL_ERROR "Unsupported Arduino SDK (require version 0.19 or higher)")
    endif()

    message(STATUS "Arduino SDK version ${ARDUINO_SDK_VERSION}: ${ARDUINO_SDK_PATH}")

    SUBDIRLIST(HARDWARES ${ARDUINO_SDK_PATH}/hardware/)
    FOREACH(hardware ${HARDWARES})
        if("${hardware}" STREQUAL "tools")
            continue()
        endif()

        if(ARDUINO_SDK_VERSION VERSION_LESS 1.5)
            # SDK less than 1.5 does not have architecture subfolders
            register_hardware_platform(${ARDUINO_SDK_PATH}/hardware/${hardware})
        else()
            SUBDIRLIST(ARCHITECTURES ${ARDUINO_SDK_PATH}/hardware/${hardware})
            FOREACH(architecture ${ARCHITECTURES})
                register_hardware_platform(${ARDUINO_SDK_PATH}/hardware/${hardware}/${architecture})
            ENDFOREACH()
        endif()

    ENDFOREACH()

    find_file(ARDUINO_LIBRARIES_PATH
              NAMES libraries
              PATHS ${ARDUINO_SDK_PATH}
              DOC "Path to directory containing the Arduino libraries."
              NO_SYSTEM_ENVIRONMENT_PATH)

    find_program(ARDUINO_AVRDUDE_PROGRAM
        NAMES avrdude
        PATHS ${ARDUINO_SDK_PATH}
        PATH_SUFFIXES hardware/tools hardware/tools/avr/bin
        NO_DEFAULT_PATH)

    find_program(ARDUINO_AVRDUDE_PROGRAM
        NAMES avrdude
        DOC "Path to avrdude programmer binary.")

    find_program(AVRSIZE_PROGRAM
        NAMES avr-size)

    find_file(ARDUINO_AVRDUDE_CONFIG_PATH
        NAMES avrdude.conf
        PATHS ${ARDUINO_SDK_PATH} /etc/avrdude /etc
        PATH_SUFFIXES hardware/tools
                      hardware/tools/avr/etc
        DOC "Path to avrdude programmer configuration file."
        NO_SYSTEM_ENVIRONMENT_PATH)

    set(ARDUINO_DEFAULT_BOARD uno  CACHE STRING "Default Arduino Board ID when not specified.")
    set(ARDUINO_DEFAULT_PORT       CACHE STRING "Default Arduino port when not specified.")
    set(ARDUINO_DEFAULT_SERIAL     CACHE STRING "Default Arduino Serial command when not specified.")
    set(ARDUINO_DEFAULT_PROGRAMMER CACHE STRING "Default Arduino Programmer ID when not specified.")

    # Ensure that all required paths are found
    required_variables(VARS
                       ARDUINO_PLATFORMS
                       AVR_CORES_PATH
                       AVR_BOOTLOADERS_PATH
                       ARDUINO_LIBRARIES_PATH
                       AVR_BOARDS_PATH
                       AVR_PROGRAMMERS_PATH
                       ARDUINO_VERSION_PATH
                       ARDUINO_AVRDUDE_PROGRAM
                       ARDUINO_AVRDUDE_CONFIG_PATH
                       AVRSIZE_PROGRAM
                       ${ADDITIONAL_REQUIRED_VARS}
                       MSG "Invalid Arduino SDK path (${ARDUINO_SDK_PATH}).\n")

    #print_board_list()
    #print_programmer_list()

    set(ARDUINO_FOUND True CACHE INTERNAL "Arduino Found")
    mark_as_advanced(
        AVR_CORES_PATH
        AVR_VARIANTS_PATH
        AVR_BOOTLOADERS_PATH
        ARDUINO_LIBRARIES_PATH
        AVR_BOARDS_PATH
        AVR_PROGRAMMERS_PATH
        ARDUINO_VERSION_PATH
        ARDUINO_AVRDUDE_PROGRAM
        ARDUINO_AVRDUDE_CONFIG_PATH
        AVRSIZE_PROGRAM)
endif()

# Set some predefined variable values as defined in
# https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.5-3rd-party-Hardware-specification

set(runtime.ide.path ${ARDUINO_SDK_PATH} CACHE INTERNAL "")
set(runtime.tools.avr-gcc.path "${ARDUINO_SDK_PATH}/hardware/tools/avr" CACHE INTERNAL "")
set(runtime.tools.avrdude.path "${ARDUINO_SDK_PATH}/hardware/tools/avr" CACHE INTERNAL "")
set(runtime.tools.arduinoOTA.path "${ARDUINO_SDK_PATH}/hardware/tools/avr" CACHE INTERNAL "")



if(ARDUINO_SDK_VERSION MATCHES "([0-9]+)[.]([0-9]+)[.]([0-9]+)")
    string(REPLACE "." "" ARDUINO_VERSION_DEFINE "${ARDUINO_SDK_VERSION}") # Normalize version (remove all periods)
    set(ARDUINO_VERSION_DEFINE "")
    if(CMAKE_MATCH_1 GREATER 0)
        set(ARDUINO_VERSION_DEFINE "${CMAKE_MATCH_1}")
    endif()
    if(CMAKE_MATCH_2 GREATER 10)
        set(ARDUINO_VERSION_DEFINE "${ARDUINO_VERSION_DEFINE}${CMAKE_MATCH_2}")
    else()
        set(ARDUINO_VERSION_DEFINE "${ARDUINO_VERSION_DEFINE}0${CMAKE_MATCH_2}")
    endif()
    if(CMAKE_MATCH_3 GREATER 10)
        set(ARDUINO_VERSION_DEFINE "${ARDUINO_VERSION_DEFINE}${CMAKE_MATCH_3}")
    else()
        set(ARDUINO_VERSION_DEFINE "${ARDUINO_VERSION_DEFINE}0${CMAKE_MATCH_3}")
    endif()
else()
    message("Invalid Arduino SDK Version (${ARDUINO_SDK_VERSION})")
endif()

set(runtime.ide.version ${ARDUINO_VERSION_DEFINE} CACHE INTERNAL "")
set(upload.verbose "-V" CACHE INTERNAL "")
set(program.verbose "-V" CACHE INTERNAL "")
set(bootloader.verbose "-V" CACHE INTERNAL "")
set(erase.verbose "-V" CACHE INTERNAL "")

if (WIN32)
    set(runtime.os "windows" CACHE INTERNAL "")
elseif(UNIX)
    set(runtime.os "linux" CACHE INTERNAL "")
elseif(APPLE)
    set(runtime.os "macosx" CACHE INTERNAL "")
endif()


if(ARDUINO_SDK_VERSION VERSION_LESS 1.5)
	set(ARDUINO_PLATFORM "AVR")
else()
	if(NOT ARDUINO_PLATFORM)
	    set(ARDUINO_PLATFORM "AVR")
	endif()
endif()
