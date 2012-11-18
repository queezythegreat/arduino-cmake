include(CMakeParseArguments)


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
    set(AVRSIZE_FLAGS --target=ihex -d)

    execute_process(COMMAND \${AVRSIZE_PROGRAM} \${AVRSIZE_FLAGS} \${FIRMWARE_IMAGE}
                    OUTPUT_VARIABLE SIZE_OUTPUT)

    string(STRIP \"\${SIZE_OUTPUT}\" SIZE_OUTPUT)

    # Convert lines into a list
    string(REPLACE \"\\n\" \";\" SIZE_OUTPUT \"\${SIZE_OUTPUT}\")

    list(GET SIZE_OUTPUT 1 SIZE_ROW)

    if(SIZE_ROW MATCHES \"[ \\t]*[0-9]+[ \\t]*[0-9]+[ \\t]*[0-9]+[ \\t]*([0-9]+)[ \\t]*([0-9a-fA-F]+).*\")
        message(\"Total size \${CMAKE_MATCH_1} bytes\")
    endif()")

    set(${OUTPUT_VAR} ${ARDUINO_SIZE_SCRIPT_PATH} PARENT_SCOPE)
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
# load_board_settings()
#
# Load the Arduino SDK board settings from the boards.txt file.
#
#=============================================================================#
function(LOAD_BOARD_SETTINGS)
    load_arduino_style_settings(ARDUINO_BOARDS "${ARDUINO_BOARDS_PATH}")
endfunction()

#=============================================================================#
# [PRIVATE/INTERNAL]
#
#=============================================================================#
function(LOAD_PROGRAMMERS_SETTINGS)
    load_arduino_style_settings(ARDUINO_PROGRAMMERS "${ARDUINO_PROGRAMMERS_PATH}")
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
#                         Arduino Settings                                    
#=============================================================================#
set(ARDUINO_OBJCOPY_EEP_FLAGS -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load
    --no-change-warnings --change-section-lma .eeprom=0   CACHE STRING "")
set(ARDUINO_OBJCOPY_HEX_FLAGS -O ihex -R .eeprom          CACHE STRING "")
set(ARDUINO_AVRDUDE_FLAGS -V                              CACHE STRING "")






#=============================================================================#
#                          Initialization                                     
#=============================================================================#
macro(setup_arduino_sdk)

if(ARDUINO_SDK_PATH)
    list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${ARDUINO_SDK_PATH}/hardware/tools/avr/bin)
    list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${ARDUINO_SDK_PATH}/hardware/tools/avr/utils/bin)
else()
    message(FATAL_ERROR "Could not find Arduino SDK (set ARDUINO_SDK_PATH)!")
endif()

if(NOT ARDUINO_FOUND AND ARDUINO_SDK_PATH)
    find_file(ARDUINO_CORES_PATH
              NAMES cores
              PATHS ${ARDUINO_SDK_PATH}
              PATH_SUFFIXES hardware/arduino
              DOC "Path to directory containing the Arduino core sources.")

    find_file(ARDUINO_VARIANTS_PATH
              NAMES variants 
              PATHS ${ARDUINO_SDK_PATH}
              PATH_SUFFIXES hardware/arduino
              DOC "Path to directory containing the Arduino variant sources.")

    find_file(ARDUINO_BOOTLOADERS_PATH
              NAMES bootloaders
              PATHS ${ARDUINO_SDK_PATH}
              PATH_SUFFIXES hardware/arduino
              DOC "Path to directory containing the Arduino bootloader images and sources.")

    find_file(ARDUINO_LIBRARIES_PATH
              NAMES libraries
              PATHS ${ARDUINO_SDK_PATH}
              DOC "Path to directory containing the Arduino libraries.")

    find_file(ARDUINO_BOARDS_PATH
              NAMES boards.txt
              PATHS ${ARDUINO_SDK_PATH}
              PATH_SUFFIXES hardware/arduino
              DOC "Path to Arduino boards definition file.")

    find_file(ARDUINO_PROGRAMMERS_PATH
        NAMES programmers.txt
        PATHS ${ARDUINO_SDK_PATH}
        PATH_SUFFIXES hardware/arduino
        DOC "Path to Arduino programmers definition file.")

    find_file(ARDUINO_VERSION_PATH
        NAMES lib/version.txt
        PATHS ${ARDUINO_SDK_PATH}
        DOC "Path to Arduino version file.")

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

    set(ARDUINO_DEFAULT_BOARD uno  CACHE STRING "Default Arduino Board ID when not specified.")
    set(ARDUINO_DEFAULT_PORT       CACHE STRING "Default Arduino port when not specified.")
    set(ARDUINO_DEFAULT_SERIAL     CACHE STRING "Default Arduino Serial command when not specified.")
    set(ARDUINO_DEFAULT_PROGRAMMER CACHE STRING "Default Arduino Programmer ID when not specified.")

    # Ensure that all required paths are found
    required_variables(VARS 
        ARDUINO_CORES_PATH
        ARDUINO_BOOTLOADERS_PATH
        ARDUINO_LIBRARIES_PATH
        ARDUINO_BOARDS_PATH
        ARDUINO_PROGRAMMERS_PATH
        ARDUINO_VERSION_PATH
        ARDUINO_AVRDUDE_FLAGS
        ARDUINO_AVRDUDE_PROGRAM
        ARDUINO_AVRDUDE_CONFIG_PATH
        AVRSIZE_PROGRAM
        MSG "Invalid Arduino SDK path (${ARDUINO_SDK_PATH}).\n")

    detect_arduino_version(ARDUINO_SDK_VERSION)
    set(ARDUINO_SDK_VERSION       ${ARDUINO_SDK_VERSION}       CACHE STRING "Arduino SDK Version")
    set(ARDUINO_SDK_VERSION_MAJOR ${ARDUINO_SDK_VERSION_MAJOR} CACHE STRING "Arduino SDK Major Version")
    set(ARDUINO_SDK_VERSION_MINOR ${ARDUINO_SDK_VERSION_MINOR} CACHE STRING "Arduino SDK Minor Version")
    set(ARDUINO_SDK_VERSION_PATCH ${ARDUINO_SDK_VERSION_PATCH} CACHE STRING "Arduino SDK Patch Version")

    if(ARDUINO_SDK_VERSION VERSION_LESS 0.19)
         message(FATAL_ERROR "Unsupported Arduino SDK (require verion 0.19 or higher)")
    endif()

    message(STATUS "Arduino SDK version ${ARDUINO_SDK_VERSION}: ${ARDUINO_SDK_PATH}")

    setup_arduino_size_script(ARDUINO_SIZE_SCRIPT)
    set(ARDUINO_SIZE_SCRIPT ${ARDUINO_SIZE_SCRIPT} CACHE INTERNAL "Arduino Size Script")

    load_board_settings()
    load_programmers_settings()

    #print_board_list()
    #print_programmer_list()

    set(ARDUINO_FOUND True CACHE INTERNAL "Arduino Found")
    mark_as_advanced(
        ARDUINO_CORES_PATH
        ARDUINO_VARIANTS_PATH
        ARDUINO_BOOTLOADERS_PATH
        ARDUINO_LIBRARIES_PATH
        ARDUINO_BOARDS_PATH
        ARDUINO_PROGRAMMERS_PATH
        ARDUINO_VERSION_PATH
        ARDUINO_AVRDUDE_FLAGS
        ARDUINO_AVRDUDE_PROGRAM
        ARDUINO_AVRDUDE_CONFIG_PATH
        ARDUINO_OBJCOPY_EEP_FLAGS
        ARDUINO_OBJCOPY_HEX_FLAGS
        ARDUINO_SDK_VERSION_MAJOR
        ARDUINO_SDK_VERSION_MINOR
        ARDUINO_SDK_VERSION_PATCH
        AVRSIZE_PROGRAM)

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
endif()
endmacro()

