# - Generate firmware and libraries for Arduino Devices
# generate_arduino_firmware(TARGET_NAME)
#        TARGET_NAME - Name of target
# Creates a Arduino firmware target.
#
# The target options can be configured by setting options of
# the following format:
#      ${TARGET_NAME}${SUFFIX}
# The following suffixes are availabe:
#      _SRCS           # Sources
#      _HDRS           # Headers
#      _SKETCHES       # Arduino sketch files
#      _LIBS           # Libraries to linked in
#      _BOARD          # Board name (such as uno, mega2560, ...)
#      _PORT           # Serial port, for upload and serial targets [OPTIONAL]
#      _AFLAGS         # Override global Avrdude flags for target
#      _SERIAL         # Serial command for serial target           [OPTIONAL]
#      _NO_AUTOLIBS    # Disables Arduino library detection
# Here is a short example for a target named test:
#       set(test_SRCS  test.cpp)
#       set(test_HDRS  test.h)
#       set(test_BOARD uno)
#    
#       generate_arduino_firmware(test)
#
#
# generate_arduino_library(TARGET_NAME)
#        TARGET_NAME - Name of target
# Creates a Arduino firmware target.
#
# The target options can be configured by setting options of
# the following format:
#      ${TARGET_NAME}${SUFFIX}
# The following suffixes are availabe:
#
#      _SRCS           # Sources
#      _HDRS           # Headers
#      _LIBS           # Libraries to linked in
#      _BOARD          # Board name (such as uno, mega2560, ...)
#      _NO_AUTOLIBS    # Disables Arduino library detection
# 
# Here is a short example for a target named test:
#       set(test_SRCS  test.cpp)
#       set(test_HDRS  test.h)
#       set(test_BOARD uno)
#    
#       generate_arduino_library(test)

file(GLOB SDK_PATHS /usr/share/arduino*)

find_path(ARDUINO_SDK_PATH
          NAMES lib/version.txt hardware libraries
		  PATH_SUFFIXES  share/arduino
		  HINTS ${SDK_PATHS}
          DOC "Arduino Development Kit path.")

# load_board_settings()
#
# Load the Arduino SDK board settings from the boards.txt file.
#
function(LOAD_BOARD_SETTINGS)
    load_arduino_style_settings(ARDUINO_BOARDS "${ARDUINO_BOARDS_PATH}")
endfunction()

function(LOAD_PROGRAMMERS_SETTINGS)
    load_arduino_style_settings(ARDUINO_PROGRAMMERS "${ARDUINO_PROGRAMMERS_PATH}")
endfunction()

# print_board_list()
#
# Print list of detected Arduino Boards.
function(PRINT_BOARD_LIST)
    message(STATUS "Supported Arduino Boards:")
    print_list(ARDUINO_BOARDS)
    message(STATUS "")
endfunction()

# print_programmer_list()
#
# Print list of detected Programmers.
function(PRINT_PROGRAMMER_LIST)
    message(STATUS "Supported Programmers:")
    print_list(ARDUINO_PROGRAMMERS)
    message(STATUS "")
endfunction()

# print_programmer_settings(PROGRAMMER)
#
#        PROGRAMMER - programmer id
#
# Print the detected Programmer settings.
#
function(PRINT_PROGRAMMER_SETTINGS PROGRAMMER)
    if(${PROGRAMMER}.SETTINGS)
        message(STATUS "Programmer ${PROGRAMMER} Settings:")
        print_settings(${PROGRAMMER})
    endif()
endfunction()

# print_board_settings(ARDUINO_BOARD)
#
#        ARDUINO_BOARD - Board id
#
# Print the detected Arduino board settings.
#
function(PRINT_BOARD_SETTINGS ARDUINO_BOARD)
    if(${ARDUINO_BOARD}.SETTINGS)
        message(STATUS "Arduino ${ARDUINO_BOARD} Board:")
        print_settings(${ARDUINO_BOARD})
    endif()
endfunction()



# generate_arduino_library(TARGET_NAME)
#
# see documentation at top
function(GENERATE_ARDUINO_LIBRARY TARGET_NAME)
    load_generator_settings(${TARGET_NAME} INPUT _SRCS       # Sources
                                                 _HDRS       # Headers
                                                 _LIBS       # Libraries to linked in
                                                 _BOARD)     # Board name (such as uno, mega2560, ...)
    set(INPUT_AUTOLIBS True)
    if(DEFINED ${TARGET_NAME}_NO_AUTOLIBS AND ${TARGET_NAME}_NO_AUTOLIBS)
        set(INPUT_AUTOLIBS False)
    endif()

    message(STATUS "Generating ${TARGET_NAME}")
    
    set(ALL_LIBS)
    set(ALL_SRCS ${INPUT_SRCS} ${INPUT_HDRS})

    setup_arduino_compiler(${INPUT_BOARD})
    setup_arduino_core(CORE_LIB ${INPUT_BOARD})

    if(INPUT_AUTOLIBS)
        setup_arduino_libraries(ALL_LIBS  ${INPUT_BOARD} "${ALL_SRCS}")
    endif()

    list(APPEND ALL_LIBS ${CORE_LIB} ${INPUT_LIBS})
        
    add_library(${TARGET_NAME} ${ALL_SRCS})
    target_link_libraries(${TARGET_NAME} ${ALL_LIBS})
endfunction()

# generate_arduino_firmware(TARGET_NAME)
#
# see documentation at top
function(GENERATE_ARDUINO_FIRMWARE TARGET_NAME)
    load_generator_settings(${TARGET_NAME} INPUT _SRCS       # Sources
                                                 _HDRS       # Headers
                                                 _LIBS       # Libraries to linked in
                                                 _BOARD      # Board name (such as uno, mega2560, ...)
                                                 _PORT       # Serial port, for upload and serial targets
                                                 _AFLAGS     # Override global Avrdude flags for target
                                                 _SKETCHES   # Arduino sketch files
                                                 _SERIAL)    # Serial command for serial target
                            
    set(INPUT_AUTOLIBS True)
    if(DEFINED ${TARGET_NAME}_NO_AUTOLIBS AND ${TARGET_NAME}_NO_AUTOLIBS)
        set(INPUT_AUTOLIBS False)
    endif()

    message(STATUS "Generating ${TARGET_NAME}")

    set(ALL_LIBS)
    set(ALL_SRCS ${INPUT_SRCS} ${INPUT_HDRS})

    setup_arduino_compiler(${INPUT_BOARD})
    setup_arduino_core(CORE_LIB ${INPUT_BOARD})

    #setup_arduino_sketch(SKETCH_SRCS ${INPUT_SKETCHES})

    if(INPUT_AUTOLIBS)
        setup_arduino_libraries(ALL_LIBS ${INPUT_BOARD} "${ALL_SRCS}")
    endif()

    
    list(APPEND ALL_LIBS ${CORE_LIB} ${INPUT_LIBS})
    
    setup_arduino_target(${TARGET_NAME} "${ALL_SRCS}" "${ALL_LIBS}")
    
    if(INPUT_PORT)
        setup_arduino_upload(${INPUT_BOARD} ${TARGET_NAME} ${INPUT_PORT})
    endif()
    
    if(INPUT_SERIAL)
        setup_serial_target(${TARGET_NAME} "${INPUT_SERIAL}")
    endif()
endfunction()


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
function(LOAD_GENERATOR_SETTINGS TARGET_NAME PREFIX)
    foreach(GEN_SUFFIX ${ARGN})
        if(${TARGET_NAME}${GEN_SUFFIX})
            set(${PREFIX}${GEN_SUFFIX} ${${TARGET_NAME}${GEN_SUFFIX}} PARENT_SCOPE)
        endif()
    endforeach()
endfunction()

# setup_arduino_compiler(BOARD_ID)
#
#       BOARD_ID - The board id name
#
# Configures the the build settings for the specified Arduino Board.
#
macro(setup_arduino_compiler BOARD_ID)
    set(BOARD_CORE ${${BOARD_ID}.build.core})
    set(PIN_HEADER ${${BOARD_ID}.build.variant})
    if(BOARD_CORE)
        if(ARDUINO_SDK_VERSION MATCHES "([0-9]+)[.]([0-9]+)")
            string(REPLACE "." "" ARDUINO_VERSION_DEFINE "${ARDUINO_SDK_VERSION}") # Normalize version (remove all periods)
            set(ARDUINO_VERSION_DEFINE "${CMAKE_MATCH_1}")
            if(CMAKE_MATCH_2 GREATER 10)
                set(ARDUINO_VERSION_DEFINE "${ARDUINO_VERSION_DEFINE}${CMAKE_MATCH_2}")
            else()
                set(ARDUINO_VERSION_DEFINE "${ARDUINO_VERSION_DEFINE}0${CMAKE_MATCH_2}")
            endif()
        else()
            set(ARDUINO_VERSION_DEFINE "00${ARDUINO_SDK_VERSION}")
        endif()
        set(BOARD_CORE_PATH ${ARDUINO_CORES_PATH}/${BOARD_CORE})
        include_directories(${ARDUINO_VARIANTS_PATH}/${PIN_HEADER})
        include_directories(${BOARD_CORE_PATH})
        include_directories(${ARDUINO_LIBRARIES_PATH})
        add_definitions(-DF_CPU=${${BOARD_ID}.build.f_cpu}
                        -DARDUINO=${ARDUINO_VERSION_DEFINE}
                        -mmcu=${${BOARD_ID}.build.mcu}
                        )
        set(CMAKE_EXE_LINKER_FLAGS    "${CMAKE_EXE_LINKER_FLAGS}    -mmcu=${${BOARD_ID}.build.mcu}" PARENT_SCOPE)
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -mmcu=${${BOARD_ID}.build.mcu}" PARENT_SCOPE)
        set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -mmcu=${${BOARD_ID}.build.mcu}" PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Invalid Arduino board ID (${BOARD_ID}), aborting.")
    endif()
endmacro()

# setup_arduino_core(VAR_NAME BOARD_ID)
#
#        VAR_NAME    - Variable name that will hold the generated library name
#        BOARD_ID    - Arduino board id
#
# Creates the Arduino Core library for the specified board,
# each board gets it's own version of the library.
#
function(setup_arduino_core VAR_NAME BOARD_ID)
    set(CORE_LIB_NAME ${BOARD_ID}_CORE)
    set(BOARD_CORE ${${BOARD_ID}.build.core})
    if(BOARD_CORE AND NOT TARGET ${CORE_LIB_NAME})
        set(BOARD_CORE_PATH ${ARDUINO_CORES_PATH}/${BOARD_CORE})
        find_sources(CORE_SRCS ${BOARD_CORE_PATH} True)
        # Debian/Ubuntu fix
        list(REMOVE_ITEM CORE_SRCS "${BOARD_CORE_PATH}/main.cxx")
        add_library(${CORE_LIB_NAME} ${CORE_SRCS})
        set(${VAR_NAME} ${CORE_LIB_NAME} PARENT_SCOPE)
    endif()
endfunction()

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
function(find_arduino_libraries VAR_NAME SRCS)
    set(ARDUINO_LIBS )
    foreach(SRC ${SRCS})
        file(STRINGS ${SRC} SRC_CONTENTS)
        foreach(SRC_LINE ${SRC_CONTENTS})
            if("${SRC_LINE}" MATCHES "^ *#include *[<\"](.*)[>\"]")
                get_filename_component(INCLUDE_NAME ${CMAKE_MATCH_1} NAME_WE)
                get_property(LIBRARY_SEARCH_PATH
                             DIRECTORY     # Property Scope
                             PROPERTY LINK_DIRECTORIES)
                foreach(LIB_SEARCH_PATH ${LIBRARY_SEARCH_PATH} ${ARDUINO_LIBRARIES_PATH} ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/libraries)
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

# setup_arduino_library(VAR_NAME BOARD_ID LIB_PATH)
#
#        VAR_NAME    - Vairable wich will hold the generated library names
#        BOARD_ID    - Board name
#        LIB_PATH    - path of the library
#
# Creates an Arduino library, with all it's library dependencies.
#
#      ${LIB_NAME}_RECURSE controls if the library will recurse
#      when looking for source files.
#

# For known libraries can list recurse here
set(Wire_RECURSE True)
set(Ethernet_RECURSE True)
function(setup_arduino_library VAR_NAME BOARD_ID LIB_PATH)
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

            message(STATUS "Generating Arduino ${LIB_NAME} library")
            include_directories(${LIB_PATH} ${LIB_PATH}/utility)
            add_library(${TARGET_LIB_NAME} STATIC ${LIB_SRCS})

            find_arduino_libraries(LIB_DEPS "${LIB_SRCS}")
            foreach(LIB_DEP ${LIB_DEPS})
                setup_arduino_library(DEP_LIB_SRCS ${BOARD_ID} ${LIB_DEP})
                list(APPEND LIB_TARGETS ${DEP_LIB_SRCS})
            endforeach()

            target_link_libraries(${TARGET_LIB_NAME} ${BOARD_ID}_CORE ${LIB_TARGETS})
            list(APPEND LIB_TARGETS ${TARGET_LIB_NAME})
        endif()
    else()
        # Target already exists, skiping creating
        include_directories(${LIB_PATH} ${LIB_PATH}/utility)
        list(APPEND LIB_TARGETS ${TARGET_LIB_NAME})
    endif()
    if(LIB_TARGETS)
        list(REMOVE_DUPLICATES LIB_TARGETS)
    endif()
    set(${VAR_NAME} ${LIB_TARGETS} PARENT_SCOPE)
endfunction()

# setup_arduino_libraries(VAR_NAME BOARD_ID SRCS)
#
#        VAR_NAME    - Vairable wich will hold the generated library names
#        BOARD_ID    - Board ID
#        SRCS        - source files
#
# Finds and creates all dependency libraries based on sources.
#
function(setup_arduino_libraries VAR_NAME BOARD_ID SRCS)
    set(LIB_TARGETS)
    find_arduino_libraries(TARGET_LIBS "${SRCS}")
    foreach(TARGET_LIB ${TARGET_LIBS})
        setup_arduino_library(LIB_DEPS ${BOARD_ID} ${TARGET_LIB}) # Create static library instead of returning sources
        list(APPEND LIB_TARGETS ${LIB_DEPS})
    endforeach()
    set(${VAR_NAME} ${LIB_TARGETS} PARENT_SCOPE)
endfunction()


# setup_arduino_target(TARGET_NAME ALL_SRCS ALL_LIBS)
#
#        TARGET_NAME - Target name
#        ALL_SRCS    - All sources
#        ALL_LIBS    - All libraries
#
# Creates an Arduino firmware target.
#
function(setup_arduino_target TARGET_NAME ALL_SRCS ALL_LIBS)
    add_executable(${TARGET_NAME} ${ALL_SRCS})
    target_link_libraries(${TARGET_NAME} ${ALL_LIBS})
    set_target_properties(${TARGET_NAME} PROPERTIES SUFFIX ".elf")

    set(TARGET_PATH ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME})
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
                        COMMAND ${CMAKE_OBJCOPY}
                        ARGS     ${ARDUINO_OBJCOPY_EEP_FLAGS}
                                 ${TARGET_PATH}.elf
                                 ${TARGET_PATH}.eep
                        VERBATIM)
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
                        COMMAND ${CMAKE_OBJCOPY}
                        ARGS    ${ARDUINO_OBJCOPY_HEX_FLAGS}
                                ${TARGET_PATH}.elf
                                ${TARGET_PATH}.hex
                        VERBATIM)
endfunction()

# setup_arduino_upload(BOARD_ID TARGET_NAME PORT)
#
#        BOARD_ID    - Arduino board id
#        TARGET_NAME - Target name
#        PORT        - Serial port for upload
#
# Create an upload target (${TARGET_NAME}-upload) for the specified Arduino target.
#
function(setup_arduino_upload BOARD_ID TARGET_NAME PORT)
# setup_arduino_bootloader_upload()
    setup_arduino_bootloader_upload(${TARGET_NAME} ${BOARD_ID} ${PORT})

    # Add programmer support if defined
    if(${TARGET_NAME}_PROGRAMMER AND ${${TARGET_NAME}_PROGRAMMER}.protocol)
        setup_arduino_programmer_burn(${TARGET_NAME} ${BOARD_ID} ${${TARGET_NAME}_PROGRAMMER} ${PORT})
        setup_arduino_bootloader_burn(${TARGET_NAME} ${BOARD_ID} ${${TARGET_NAME}_PROGRAMMER} ${PORT})
    endif()
endfunction()


# setup_arduino_bootloader_upload(TARGET_NAME BOARD_ID PORT)
#
#      TARGET_NAME - target name
#      BOARD_ID    - board id
#      PORT        - serial port
#
# Set up target for upload firmware via the bootloader.
#
# The target for uploading the firmware is ${TARGET_NAME}-upload .
#
function(setup_arduino_bootloader_upload TARGET_NAME BOARD_ID PORT)
    set(UPLOAD_TARGET ${TARGET_NAME}-upload)
    set(AVRDUDE_ARGS)

    setup_arduino_bootloader_args(${BOARD_ID} ${TARGET_NAME} ${PORT} AVRDUDE_ARGS)

    if(NOT AVRDUDE_ARGS)
        message("Could not generate default avrdude bootloader args, aborting!")
        return()
    endif()

    list(APPEND AVRDUDE_ARGS "-Uflash:w:${TARGET_NAME}.hex")
    add_custom_target(${UPLOAD_TARGET}
                     ${ARDUINO_AVRDUDE_PROGRAM} 
                        ${AVRDUDE_ARGS}
                     DEPENDS ${TARGET_NAME})
endfunction()

# setup_arduino_programmer_burn(TARGET_NAME BOARD_ID PROGRAMMER)
#
#      TARGET_NAME - name of target to burn
#      BOARD_ID    - board id
#      PROGRAMMER  - programmer id
# 
# Sets up target for burning firmware via a programmer.
#
# The target for burning the firmware is ${TARGET_NAME}-burn .
#
function(setup_arduino_programmer_burn TARGET_NAME BOARD_ID PROGRAMMER)
    set(PROGRAMMER_TARGET ${TARGET_NAME}-burn)

    set(AVRDUDE_ARGS)

    setup_arduino_programmer_args(${BOARD_ID} ${PROGRAMMER} ${TARGET_NAME} ${PORT} AVRDUDE_ARGS)

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

# setup_arduino_bootloader_burn(TARGET_NAME BOARD_ID PROGRAMMER)
# 
#      TARGET_NAME - name of target to burn
#      BOARD_ID    - board id
#      PROGRAMMER  - programmer id
#
# Create a target for burning a bootloader via a programmer.
#
# The target for burning the bootloader is ${TARGET_NAME}-burn-bootloader
#
function(setup_arduino_bootloader_burn TARGET_NAME BOARD_ID PROGRAMMER PORT)
    set(BOOTLOADER_TARGET ${TARGET_NAME}-burn-bootloader)

    set(AVRDUDE_ARGS)

    setup_arduino_programmer_args(${BOARD_ID} ${PROGRAMMER} ${TARGET_NAME} ${PORT} AVRDUDE_ARGS)

    if(NOT AVRDUDE_ARGS)
        message("Could not generate default avrdude programmer args, aborting!")
        return()
    endif()

    if(NOT ${BOARD_ID}.bootloader.unlock_bits)
        message("Missing ${BOARD_ID}.bootloader.unlock_bits, not creating bootloader burn target ${BOOTLOADER_TARGET}.")
        return()
    endif()
    if(NOT ${BOARD_ID}.bootloader.high_fuses)
        message("Missing ${BOARD_ID}.bootloader.high_fuses, not creating bootloader burn target ${BOOTLOADER_TARGET}.")
        return()
    endif()
    if(NOT ${BOARD_ID}.bootloader.low_fuses)
        message("Missing ${BOARD_ID}.bootloader.low_fuses, not creating bootloader burn target ${BOOTLOADER_TARGET}.")
        return()
    endif()
    if(NOT ${BOARD_ID}.bootloader.path)
        message("Missing ${BOARD_ID}.bootloader.path, not creating bootloader burn target ${BOOTLOADER_TARGET}.")
        return()
    endif()
    if(NOT ${BOARD_ID}.bootloader.file)
        message("Missing ${BOARD_ID}.bootloader.file, not creating bootloader burn target ${BOOTLOADER_TARGET}.")
        return()
    endif()

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
    list(APPEND AVRDUDE_ARGS "-Uhfuse:w:${${BOARD_ID}.bootloader.high_fuses}:m")
    list(APPEND AVRDUDE_ARGS "-Ulfuse:w:${${BOARD_ID}.bootloader.low_fuses}:m")

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

# setup_arduino_programmer_args(PROGRAMMER OUTPUT_VAR)
#
#      PROGRAMMER  - programmer id
#      TARGET_NAME - target name
#      OUTPUT_VAR  - name of output variable for result
#
# Sets up default avrdude settings for burning firmware via a programmer.
function(setup_arduino_programmer_args BOARD_ID PROGRAMMER TARGET_NAME PORT OUTPUT_VAR)
    set(AVRDUDE_ARGS ${${OUTPUT_VAR}})

    set(AVRDUDE_FLAGS ${ARDUINO_AVRDUDE_FLAGS})
    if(DEFINED ${TARGET_NAME}_AFLAGS)
        set(AVRDUDE_FLAGS ${${TARGET_NAME}_AFLAGS})
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

# setup_arduino_bootloader_args(BOARD_ID TARGET_NAME PORT OUTPUT_VAR)
#
#      BOARD_ID    - board id
#      TARGET_NAME - target name
#      PORT        - serial port
#      OUTPUT_VAR  - name of output variable for result
#
# Sets up default avrdude settings for uploading firmware via the bootloader.
function(setup_arduino_bootloader_args BOARD_ID TARGET_NAME PORT OUTPUT_VAR)
    set(AVRDUDE_ARGS ${${OUTPUT_VAR}})

    set(AVRDUDE_FLAGS ${ARDUINO_AVRDUDE_FLAGS})
    if(DEFINED ${TARGET_NAME}_AFLAGS)
        set(AVRDUDE_FLAGS ${${TARGET_NAME}_AFLAGS})
    endif()

    list(APPEND AVRDUDE_ARGS "-C${ARDUINO_AVRDUDE_CONFIG_PATH}") # avrdude config

    list(APPEND AVRDUDE_ARGS "-p${${BOARD_ID}.build.mcu}")  # MCU Type

    # Programmer
    if(${BOARD_ID}.upload.protocol STREQUAL "stk500")
        list(APPEND AVRDUDE_ARGS "-cstk500v1")
    else()
        list(APPEND AVRDUDE_ARGS "-c${${BOARD_ID}.upload.protocol}")
    endif()

    list(APPEND AVRDUDE_ARGS "-b${${BOARD_ID}.upload.speed}") # Baud rate

    list(APPEND AVRDUDE_ARGS "-P${PORT}")  # Serial port

    list(APPEND AVRDUDE_ARGS "-D")  # Dont erase

    list(APPEND AVRDUDE_ARGS ${AVRDUDE_FLAGS})

    set(${OUTPUT_VAR} ${AVRDUDE_ARGS} PARENT_SCOPE)
endfunction()

# find_sources(VAR_NAME LIB_PATH RECURSE)
#
#        VAR_NAME - Variable name that will hold the detected sources
#        LIB_PATH - The base path
#        RECURSE  - Whether or not to recurse
#
# Finds all C/C++ sources located at the specified path.
#
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

# setup_serial_target(TARGET_NAME CMD)
#
#         TARGET_NAME - Target name
#         CMD         - Serial terminal command
#
# Creates a target (${TARGET_NAME}-serial) for launching the serial termnial.
#
function(setup_serial_target TARGET_NAME CMD)
    string(CONFIGURE "${CMD}" FULL_CMD @ONLY)
    add_custom_target(${TARGET_NAME}-serial
                      ${FULL_CMD})
endfunction()


# detect_arduino_version(VAR_NAME)
#
#       VAR_NAME - Variable name where the detected version will be saved
#
# Detects the Arduino SDK Version based on the revisions.txt file.
#
function(detect_arduino_version VAR_NAME)
    if(ARDUINO_VERSION_PATH)
        file(READ ${ARDUINO_VERSION_PATH} ARD_VERSION)
        if("${ARD_VERSION}" MATCHES " *[0]+([0-9]+)")
            set(${VAR_NAME} ${CMAKE_MATCH_1} PARENT_SCOPE)
        elseif("${ARD_VERSION}" MATCHES "[ ]*([0-9]+[.][0-9]+)")
            set(${VAR_NAME} ${CMAKE_MATCH_1} PARENT_SCOPE)
        endif()
    endif()
endfunction()


function(convert_arduino_sketch VAR_NAME SRCS)
endfunction()

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

# print_settings(ENTRY_NAME)
#
#      ENTRY_NAME - name of entry
#
# Print the entry settings (see load_arduino_syle_settings()).
#
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

# print_list(SETTINGS_LIST)
#
#      SETTINGS_LIST - Variables name of settings list
#
# Print list settings and names (see load_arduino_syle_settings()).
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


# Setting up Arduino enviroment settings
if(NOT ARDUINO_FOUND)
    find_file(ARDUINO_CORES_PATH
              NAMES cores
              PATHS ${ARDUINO_SDK_PATH}
              PATH_SUFFIXES hardware/arduino)

    find_file(ARDUINO_VARIANTS_PATH
              NAMES variants 
              PATHS ${ARDUINO_SDK_PATH}
              PATH_SUFFIXES hardware/arduino)

    find_file(ARDUINO_BOOTLOADERS_PATH
              NAMES bootloaders
              PATHS ${ARDUINO_SDK_PATH}
              PATH_SUFFIXES hardware/arduino)

    find_file(ARDUINO_LIBRARIES_PATH
              NAMES libraries
              PATHS ${ARDUINO_SDK_PATH})

    find_file(ARDUINO_BOARDS_PATH
              NAMES boards.txt
              PATHS ${ARDUINO_SDK_PATH}
              PATH_SUFFIXES hardware/arduino)

    find_file(ARDUINO_PROGRAMMERS_PATH
              NAMES programmers.txt
              PATHS ${ARDUINO_SDK_PATH}
              PATH_SUFFIXES hardware/arduino)

    find_file(ARDUINO_REVISIONS_PATH
              NAMES revisions.txt
              PATHS ${ARDUINO_SDK_PATH})

    find_file(ARDUINO_VERSION_PATH
              NAMES lib/version.txt
              PATHS ${ARDUINO_SDK_PATH})

    find_program(ARDUINO_AVRDUDE_PROGRAM
                 NAMES avrdude
                 PATHS ${ARDUINO_SDK_PATH}
                 PATH_SUFFIXES hardware/tools)

    find_program(ARDUINO_AVRDUDE_CONFIG_PATH
                 NAMES avrdude.conf
                 PATHS ${ARDUINO_SDK_PATH} /etc/avrdude
                 PATH_SUFFIXES hardware/tools
                               hardware/tools/avr/etc)

     set(ARDUINO_OBJCOPY_EEP_FLAGS -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0
         CACHE STRING "")
     set(ARDUINO_OBJCOPY_HEX_FLAGS -O ihex -R .eeprom
         CACHE STRING "")
     set(ARDUINO_AVRDUDE_FLAGS -V
         CACHE STRING "Arvdude global flag list.")

     if(ARDUINO_SDK_PATH)
         detect_arduino_version(ARDUINO_SDK_VERSION)
         set(ARDUINO_SDK_VERSION ${ARDUINO_SDK_VERSION} CACHE STRING "Arduino SDK Version")
     endif(ARDUINO_SDK_PATH)

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(Arduino
                                      REQUIRED_VARS ARDUINO_SDK_PATH
                                                    ARDUINO_SDK_VERSION
                                      VERSION_VAR ARDUINO_SDK_VERSION)


     mark_as_advanced(ARDUINO_CORES_PATH
		      ARDUINO_VARIANTS_PATH
                      ARDUINO_BOOTLOADERS_PATH
                      ARDUINO_SDK_VERSION
                      ARDUINO_LIBRARIES_PATH
                      ARDUINO_BOARDS_PATH
                      ARDUINO_PROGRAMMERS_PATH
                      ARDUINO_REVISIONS_PATH
                      ARDUINO_VERSION_PATH
                      ARDUINO_AVRDUDE_FLAGS
                      ARDUINO_AVRDUDE_PROGRAM
                      ARDUINO_AVRDUDE_CONFIG_PATH
                      ARDUINO_OBJCOPY_EEP_FLAGS
                      ARDUINO_OBJCOPY_HEX_FLAGS)

    load_board_settings()
    load_programmers_settings()

    print_board_list()
    print_programmer_list()

    set(ARDUINO_FOUND True CACHE INTERNAL "Arduino Found")
endif()

