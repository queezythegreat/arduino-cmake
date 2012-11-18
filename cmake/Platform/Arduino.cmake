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
#      PORT           # Serial port (enables upload support)
#      SERIAL         # Serial command for serial target
#      PROGRAMMER     # Programmer id (enables programmer support)
#      AFLAGS         # Avrdude flags for target
#      NO_AUTOLIBS    # Disables Arduino library detection
#      MANUAL     # (Advanced) Only use AVR Libc/Includes
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
# generate_arduino_library(name
#      [BOARD board_id]
#      [SRCS  src1 src2 ... srcN]
#      [HDRS  hdr1 hdr2 ... hdrN]
#      [LIBS  lib1 lib2 ... libN]
#      [NO_AUTOLIBS])
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
    message(STATUS "Arduino Boards:")
    print_list(ARDUINO_BOARDS)
    message(STATUS "")
endfunction()

#=============================================================================#
# [PUBLIC/USER]
#
# print_programmer_list()
#
# see documentation at top
#=============================================================================#
function(PRINT_PROGRAMMER_LIST)
    message(STATUS "Arduino Programmers:")
    print_list(ARDUINO_PROGRAMMERS)
    message(STATUS "")
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
    endif()

    find_arduino_libraries(TARGET_LIBS "${ALL_SRCS}")
    set(LIB_DEP_INCLUDES)
    foreach(LIB_DEP ${TARGET_LIBS})
        set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${LIB_DEP}\"")
    endforeach()

    if(NOT ${INPUT_NO_AUTOLIBS})
        setup_arduino_libraries(ALL_LIBS  ${INPUT_BOARD} "${ALL_SRCS}" "${LIB_DEP_INCLUDES}" "")
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
function(GENERATE_ARDUINO_FIRMWARE INPUT_NAME)
    message(STATUS "Generating ${INPUT_NAME}")
    parse_generator_arguments(${INPUT_NAME} INPUT
                              "NO_AUTOLIBS;MANUAL"            # Options
                              "BOARD;PORT;SKETCH;PROGRAMMER"  # One Value Keywords
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
    if(NOT INPUT_MANUAL)
        set(INPUT_MANUAL FALSE)
    endif()
    required_variables(VARS INPUT_BOARD MSG "must define for target ${INPUT_NAME}")

    set(ALL_LIBS)
    set(ALL_SRCS ${INPUT_SRCS} ${INPUT_HDRS})
    set(LIB_DEP_INCLUDES)

    if(NOT INPUT_MANUAL)
      setup_arduino_core(CORE_LIB ${INPUT_BOARD})
    endif()
    
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

    find_arduino_libraries(TARGET_LIBS "${ALL_SRCS}")
    foreach(LIB_DEP ${TARGET_LIBS})
        set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${LIB_DEP}\"")
    endforeach()

    if(NOT INPUT_NO_AUTOLIBS)
        setup_arduino_libraries(ALL_LIBS  ${INPUT_BOARD} "${ALL_SRCS}" "${LIB_DEP_INCLUDES}" "")
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
function(GENERATE_ARDUINO_EXAMPLE INPUT_NAME)
    message(STATUS "Generating example ${LIBRARY_NAME}-${EXAMPLE_NAME}")
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

    set(ALL_LIBS)
    set(ALL_SRCS)

    setup_arduino_core(CORE_LIB ${INPUT_BOARD})

    setup_arduino_example("${INPUT_NAME}" "${INPUT_LIBRARY}" "${INPUT_EXAMPLE}" ALL_SRCS)

    if(NOT ALL_SRCS)
        message(FATAL_ERROR "Missing sources for example, aborting!")
    endif()

    find_arduino_libraries(TARGET_LIBS "${ALL_SRCS}")
    set(LIB_DEP_INCLUDES)
    foreach(LIB_DEP ${TARGET_LIBS})
        set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${LIB_DEP}\"")
    endforeach()

    setup_arduino_libraries(ALL_LIBS ${INPUT_BOARD} "${ALL_SRCS}" "${LIB_DEP_INCLUDES}" "")

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
#                        Internal Functions                                   
#=============================================================================#

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
# get_arduino_flags(COMPILE_FLAGS LINK_FLAGS BOARD_ID MANUAL)
#
#       COMPILE_FLAGS_VAR -Variable holding compiler flags
#       LINK_FLAGS_VAR - Variable holding linker flags
#       BOARD_ID - The board id name
#       MANUAL - (Advanced) Only use AVR Libc/Includes
#
# Configures the the build settings for the specified Arduino Board.
#
#=============================================================================#
function(get_arduino_flags COMPILE_FLAGS_VAR LINK_FLAGS_VAR BOARD_ID MANUAL)
   
    set(BOARD_CORE ${${BOARD_ID}.build.core})
    if(BOARD_CORE)
        if(ARDUINO_SDK_VERSION MATCHES "([0-9]+)[.]([0-9]+)")
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
        else()
            message("Invalid Arduino SDK Version (${ARDUINO_SDK_VERSION})")
        endif()

        # output
        set(COMPILE_FLAGS "-DF_CPU=${${BOARD_ID}.build.f_cpu} -DARDUINO=${ARDUINO_VERSION_DEFINE} -mmcu=${${BOARD_ID}.build.mcu}")
        if(DEFINED ${BOARD_ID}.build.vid)
            set(COMPILE_FLAGS "${COMPILE_FLAGS} -DUSB_VID=${${BOARD_ID}.build.vid}")
        endif()
        if(DEFINED ${BOARD_ID}.build.pid)
            set(COMPILE_FLAGS "${COMPILE_FLAGS} -DUSB_PID=${${BOARD_ID}.build.pid}")
        endif()
        if(NOT MANUAL)
            set(COMPILE_FLAGS "${COMPILE_FLAGS} -I\"${ARDUINO_CORES_PATH}/${BOARD_CORE}\" -I\"${ARDUINO_LIBRARIES_PATH}\"")
        endif()
        set(LINK_FLAGS "-mmcu=${${BOARD_ID}.build.mcu}")
        if(ARDUINO_SDK_VERSION VERSION_GREATER 1.0 OR ARDUINO_SDK_VERSION VERSION_EQUAL 1.0)
            set(PIN_HEADER ${${BOARD_ID}.build.variant})
            if(NOT MANUAL)
              set(COMPILE_FLAGS "${COMPILE_FLAGS} -I\"${ARDUINO_VARIANTS_PATH}/${PIN_HEADER}\"")
            endif()
        endif()

        # output 
        set(${COMPILE_FLAGS_VAR} "${COMPILE_FLAGS}" PARENT_SCOPE)
        set(${LINK_FLAGS_VAR} "${LINK_FLAGS}" PARENT_SCOPE)

    else()
        message(FATAL_ERROR "Invalid Arduino board ID (${BOARD_ID}), aborting.")
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
            set(BOARD_CORE_PATH ${ARDUINO_CORES_PATH}/${BOARD_CORE})
            find_sources(CORE_SRCS ${BOARD_CORE_PATH} True)
            # Debian/Ubuntu fix
            list(REMOVE_ITEM CORE_SRCS "${BOARD_CORE_PATH}/main.cxx")
            add_library(${CORE_LIB_NAME} ${CORE_SRCS})
            get_arduino_flags(ARDUINO_COMPILE_FLAGS ARDUINO_LINK_FLAGS ${BOARD_ID} FALSE)
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
# find_arduino_libraries(VAR_NAME SRCS)
#
#      VAR_NAME - Variable name which will hold the results
#      SRCS     - Sources that will be analized
#
#     returns a list of paths to libraries found.
#
#  Finds all Arduino type libraries included in sources. Available libraries
#  are ${ARDUINO_SDK_PATH}/libraries and ${CMAKE_CURRENT_SOURCE_DIR}.
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
function(find_arduino_libraries VAR_NAME SRCS)
    set(ARDUINO_LIBS )
    foreach(SRC ${SRCS})
        if(NOT (EXISTS ${SRC} OR
                EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${SRC} OR
                EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${SRC}))
            message(FATAL_ERROR "Invalid source file: ${SRC}")
        endif()
        file(STRINGS ${SRC} SRC_CONTENTS)
        foreach(SRC_LINE ${SRC_CONTENTS})
            if("${SRC_LINE}" MATCHES "^ *#include *[<\"](.*)[>\"]")
                get_filename_component(INCLUDE_NAME ${CMAKE_MATCH_1} NAME_WE)
                get_property(LIBRARY_SEARCH_PATH
                             DIRECTORY     # Property Scope
                             PROPERTY LINK_DIRECTORIES)
                foreach(LIB_SEARCH_PATH ${LIBRARY_SEARCH_PATH} ${ARDUINO_LIBRARIES_PATH} ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/libraries ${ARDUINO_EXTRA_LIBRARIES_PATH})
                    if(EXISTS ${LIB_SEARCH_PATH}/${INCLUDE_NAME}/${CMAKE_MATCH_1})
                        list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/${INCLUDE_NAME})
                        break()
                    endif()
                endforeach()
            endif()
        endforeach()
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
function(setup_arduino_library VAR_NAME BOARD_ID LIB_PATH COMPILE_FLAGS LINK_FLAGS)
    set(LIB_TARGETS)

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

            arduino_debug_msg("Generating Arduino ${LIB_NAME} library")
            add_library(${TARGET_LIB_NAME} STATIC ${LIB_SRCS})

            get_arduino_flags(ARDUINO_COMPILE_FLAGS ARDUINO_LINK_FLAGS ${BOARD_ID} FALSE)

            find_arduino_libraries(LIB_DEPS "${LIB_SRCS}")

            foreach(LIB_DEP ${LIB_DEPS})
                setup_arduino_library(DEP_LIB_SRCS ${BOARD_ID} ${LIB_DEP} "${COMPILE_FLAGS}" "${LINK_FLAGS}")
                list(APPEND LIB_TARGETS ${DEP_LIB_SRCS})
            endforeach()

            set_target_properties(${TARGET_LIB_NAME} PROPERTIES
                COMPILE_FLAGS "${ARDUINO_COMPILE_FLAGS} -I\"${LIB_PATH}\" -I\"${LIB_PATH}/utility\" ${COMPILE_FLAGS}"
                LINK_FLAGS "${ARDUINO_LINK_FLAGS} ${LINK_FLAGS}")

            target_link_libraries(${TARGET_LIB_NAME} ${BOARD_ID}_CORE ${LIB_TARGETS})
            list(APPEND LIB_TARGETS ${TARGET_LIB_NAME})

        endif()
    else()
        # Target already exists, skiping creating
        list(APPEND LIB_TARGETS ${TARGET_LIB_NAME})
    endif()
    if(LIB_TARGETS)
        list(REMOVE_DUPLICATES LIB_TARGETS)
    endif()
    set(${VAR_NAME} ${LIB_TARGETS} PARENT_SCOPE)
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
function(setup_arduino_libraries VAR_NAME BOARD_ID SRCS COMPILE_FLAGS LINK_FLAGS)
    set(LIB_TARGETS)
    find_arduino_libraries(TARGET_LIBS "${SRCS}")
    foreach(TARGET_LIB ${TARGET_LIBS})
        # Create static library instead of returning sources
        setup_arduino_library(LIB_DEPS ${BOARD_ID} ${TARGET_LIB} "${COMPILE_FLAGS}" "${LINK_FLAGS}")
        list(APPEND LIB_TARGETS ${LIB_DEPS})
    endforeach()
    set(${VAR_NAME} ${LIB_TARGETS} PARENT_SCOPE)
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

    get_arduino_flags(ARDUINO_COMPILE_FLAGS ARDUINO_LINK_FLAGS  ${BOARD_ID} ${MANUAL})

    set_target_properties(${TARGET_NAME} PROPERTIES
                COMPILE_FLAGS "${ARDUINO_COMPILE_FLAGS} ${COMPILE_FLAGS}"
                LINK_FLAGS "${ARDUINO_LINK_FLAGS} ${LINK_FLAGS}")
    target_link_libraries(${TARGET_NAME} ${ALL_LIBS} "-lc -lm")

    set(TARGET_PATH ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME})
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
                        COMMAND ${CMAKE_OBJCOPY}
                        ARGS     ${ARDUINO_OBJCOPY_EEP_FLAGS}
                                 ${TARGET_PATH}.elf
                                 ${TARGET_PATH}.eep
                        COMMENT "Generating EEP image"
                        VERBATIM)

    # Convert firmware image to ASCII HEX format
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
                        COMMAND ${CMAKE_OBJCOPY}
                        ARGS    ${ARDUINO_OBJCOPY_HEX_FLAGS}
                                ${TARGET_PATH}.elf
                                ${TARGET_PATH}.hex
                        COMMENT "Generating HEX image"
                        VERBATIM)

    # Display target size
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
                        COMMAND ${CMAKE_COMMAND}
                        ARGS    -DFIRMWARE_IMAGE=${TARGET_PATH}.hex
                                -P ${ARDUINO_SIZE_SCRIPT}
                        COMMENT "Calculating image size"
                        VERBATIM)

    # Create ${TARGET_NAME}-size target
    add_custom_target(${TARGET_NAME}-size
                        COMMAND ${CMAKE_COMMAND}
                                -DFIRMWARE_IMAGE=${TARGET_PATH}.hex
                                -P ${ARDUINO_SIZE_SCRIPT}
                        DEPENDS ${TARGET_NAME}
                        COMMENT "Calculating ${TARGET_NAME} image size")
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
    setup_arduino_bootloader_upload(${TARGET_NAME} ${BOARD_ID} ${PORT} "${AVRDUDE_FLAGS}")

    # Add programmer support if defined
    if(PROGRAMMER_ID AND ${PROGRAMMER_ID}.protocol)
        setup_arduino_programmer_burn(${TARGET_NAME} ${BOARD_ID} ${PROGRAMMER_ID} ${PORT} "${AVRDUDE_FLAGS}")
        setup_arduino_bootloader_burn(${TARGET_NAME} ${BOARD_ID} ${PROGRAMMER_ID} ${PORT} "${AVRDUDE_FLAGS}")
    endif()
endfunction()


#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_bootloader_upload(TARGET_NAME BOARD_ID PORT)
#
#      TARGET_NAME - target name
#      BOARD_ID    - board id
#      PORT        - serial port
#      AVRDUDE_FLAGS - avrdude flags (override)
#
# Set up target for upload firmware via the bootloader.
#
# The target for uploading the firmware is ${TARGET_NAME}-upload .
#
#=============================================================================#
function(setup_arduino_bootloader_upload TARGET_NAME BOARD_ID PORT AVRDUDE_FLAGS)
    set(UPLOAD_TARGET ${TARGET_NAME}-upload)
    set(AVRDUDE_ARGS)

    setup_arduino_bootloader_args(${BOARD_ID} ${TARGET_NAME} ${PORT} "${AVRDUDE_FLAGS}" AVRDUDE_ARGS)

    if(NOT AVRDUDE_ARGS)
        message("Could not generate default avrdude bootloader args, aborting!")
        return()
    endif()

    list(APPEND AVRDUDE_ARGS "-Uflash:w:${TARGET_NAME}.hex")
    add_custom_target(${UPLOAD_TARGET}
                     ${ARDUINO_AVRDUDE_PROGRAM} 
                     ${AVRDUDE_ARGS}
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
# setup_arduino_programmer_burn(TARGET_NAME BOARD_ID PROGRAMMER PORT AVRDUDE_FLAGS)
#
#      TARGET_NAME - name of target to burn
#      BOARD_ID    - board id
#      PROGRAMMER  - programmer id
#      PORT        - serial port
#      AVRDUDE_FLAGS - avrdude flags (override)
# 
# Sets up target for burning firmware via a programmer.
#
# The target for burning the firmware is ${TARGET_NAME}-burn .
#
#=============================================================================#
function(setup_arduino_programmer_burn TARGET_NAME BOARD_ID PROGRAMMER PORT AVRDUDE_FLAGS)
    set(PROGRAMMER_TARGET ${TARGET_NAME}-burn)

    set(AVRDUDE_ARGS)

    setup_arduino_programmer_args(${BOARD_ID} ${PROGRAMMER} ${TARGET_NAME} ${PORT} "${AVRDUDE_FLAGS}" AVRDUDE_ARGS)

    if(NOT AVRDUDE_ARGS)
        message("Could not generate default avrdude programmer args, aborting!")
        return()
    endif()

    list(APPEND AVRDUDE_ARGS "-Uflash:w:${TARGET_NAME}.hex")

    add_custom_target(${PROGRAMMER_TARGET}
                     ${ARDUINO_AVRDUDE_PROGRAM} 
                     ${AVRDUDE_ARGS}
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
    set(BOOTLOADER_TARGET ${TARGET_NAME}-burn-bootloader)

    set(AVRDUDE_ARGS)

    setup_arduino_programmer_args(${BOARD_ID} ${PROGRAMMER} ${TARGET_NAME} ${PORT} "${AVRDUDE_FLAGS}" AVRDUDE_ARGS)

    if(NOT AVRDUDE_ARGS)
        message("Could not generate default avrdude programmer args, aborting!")
        return()
    endif()

    foreach( ITEM unlock_bits high_fuses low_fuses path file)
        if(NOT ${BOARD_ID}.bootloader.${ITEM})
            message("Missing ${BOARD_ID}.bootloader.${ITEM}, not creating bootloader burn target ${BOOTLOADER_TARGET}.")
            return()
        endif()
    endforeach()

    if(NOT EXISTS "${ARDUINO_BOOTLOADERS_PATH}/${${BOARD_ID}.bootloader.path}/${${BOARD_ID}.bootloader.file}")
        message("${ARDUINO_BOOTLOADERS_PATH}/${${BOARD_ID}.bootloader.path}/${${BOARD_ID}.bootloader.file}")
        message("Missing bootloader image, not creating bootloader burn target ${BOOTLOADER_TARGET}.")
        return()
    endif()

    # Erase the chip
    list(APPEND AVRDUDE_ARGS "-e")

    # Set unlock bits and fuses (because chip is going to be erased)
    list(APPEND AVRDUDE_ARGS "-Ulock:w:${${BOARD_ID}.bootloader.unlock_bits}:m")
    if(${BOARD_ID}.bootloader.extended_fuses)
        list(APPEND AVRDUDE_ARGS "-Uefuse:w:${${BOARD_ID}.bootloader.extended_fuses}:m")
    endif()
    list(APPEND AVRDUDE_ARGS
        "-Uhfuse:w:${${BOARD_ID}.bootloader.high_fuses}:m"
        "-Ulfuse:w:${${BOARD_ID}.bootloader.low_fuses}:m")

    # Set bootloader image
    list(APPEND AVRDUDE_ARGS "-Uflash:w:${${BOARD_ID}.bootloader.file}:i")

    # Set lockbits
    list(APPEND AVRDUDE_ARGS "-Ulock:w:${${BOARD_ID}.bootloader.lock_bits}:m")

    # Create burn bootloader target
    add_custom_target(${BOOTLOADER_TARGET}
                     ${ARDUINO_AVRDUDE_PROGRAM} 
                        ${AVRDUDE_ARGS}
                     WORKING_DIRECTORY ${ARDUINO_BOOTLOADERS_PATH}/${${BOARD_ID}.bootloader.path}
                     DEPENDS ${TARGET_NAME})
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# setup_arduino_programmer_args(BOARD_ID PROGRAMMER TARGET_NAME PORT AVRDUDE_FLAGS OUTPUT_VAR)
#
#      BOARD_ID    - board id
#      PROGRAMMER  - programmer id
#      TARGET_NAME - target name
#      PORT        - serial port
#      AVRDUDE_FLAGS - avrdude flags (override)
#      OUTPUT_VAR  - name of output variable for result
#
# Sets up default avrdude settings for burning firmware via a programmer.
#=============================================================================#
function(setup_arduino_programmer_args BOARD_ID PROGRAMMER TARGET_NAME PORT AVRDUDE_FLAGS OUTPUT_VAR)
    set(AVRDUDE_ARGS ${${OUTPUT_VAR}})

    if(NOT AVRDUDE_FLAGS)
        set(AVRDUDE_FLAGS ${ARDUINO_AVRDUDE_FLAGS})
    endif()

    list(APPEND AVRDUDE_ARGS "-C${ARDUINO_AVRDUDE_CONFIG_PATH}")

    #TODO: Check mandatory settings before continuing
    if(NOT ${PROGRAMMER}.protocol)
        message(FATAL_ERROR "Missing ${PROGRAMMER}.protocol, aborting!")
    endif()

    list(APPEND AVRDUDE_ARGS "-c${${PROGRAMMER}.protocol}") # Set programmer

    if(${PROGRAMMER}.communication STREQUAL "usb")
        list(APPEND AVRDUDE_ARGS "-Pusb") # Set USB as port
    elseif(${PROGRAMMER}.communication STREQUAL "serial")
        list(APPEND AVRDUDE_ARGS "-P${PORT}") # Set port
        if(${PROGRAMMER}.speed)
            list(APPEND AVRDUDE_ARGS "-b${${PROGRAMMER}.speed}") # Set baud rate
        endif()
    endif()

    if(${PROGRAMMER}.force)
        list(APPEND AVRDUDE_ARGS "-F") # Set force
    endif()

    if(${PROGRAMMER}.delay)
        list(APPEND AVRDUDE_ARGS "-i${${PROGRAMMER}.delay}") # Set delay
    endif()

    list(APPEND AVRDUDE_ARGS "-p${${BOARD_ID}.build.mcu}")  # MCU Type

    list(APPEND AVRDUDE_ARGS ${AVRDUDE_FLAGS})

    set(${OUTPUT_VAR} ${AVRDUDE_ARGS} PARENT_SCOPE)
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

    if(NOT AVRDUDE_FLAGS)
        set(AVRDUDE_FLAGS ${ARDUINO_AVRDUDE_FLAGS})
    endif()

    list(APPEND AVRDUDE_ARGS
        "-C${ARDUINO_AVRDUDE_CONFIG_PATH}"  # avrdude config
        "-p${${BOARD_ID}.build.mcu}"        # MCU Type
        )

    # Programmer
    if(${BOARD_ID}.upload.protocol STREQUAL "stk500")
        list(APPEND AVRDUDE_ARGS "-cstk500v1")
    else()
        list(APPEND AVRDUDE_ARGS "-c${${BOARD_ID}.upload.protocol}")
    endif()

    list(APPEND AVRDUDE_ARGS
        "-b${${BOARD_ID}.upload.speed}"     # Baud rate
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
            if(${ENTRY_NAME}.${ENTRY_SETTING})
                message(STATUS "   ${ENTRY_NAME}.${ENTRY_SETTING}=${${ENTRY_NAME}.${ENTRY_SETTING}}")
            endif()
            if(${ENTRY_NAME}.${ENTRY_SETTING}.SUBSETTINGS)
                foreach(ENTRY_SUBSETTING ${${ENTRY_NAME}.${ENTRY_SETTING}.SUBSETTINGS})
                    if(${ENTRY_NAME}.${ENTRY_SETTING}.${ENTRY_SUBSETTING})
                        message(STATUS "   ${ENTRY_NAME}.${ENTRY_SETTING}.${ENTRY_SUBSETTING}=${${ENTRY_NAME}.${ENTRY_SETTING}.${ENTRY_SUBSETTING}}")
                    endif()
                endforeach()
            endif()
            message(STATUS "")
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
    foreach(LIB_SEARCH_PATH ${LIBRARY_SEARCH_PATH} ${ARDUINO_LIBRARIES_PATH} ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/libraries)
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

