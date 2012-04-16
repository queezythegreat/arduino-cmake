set(CMAKE_SYSTEM_NAME Arduino)

set(CMAKE_C_COMPILER   avr-gcc)
set(CMAKE_CXX_COMPILER avr-g++)

# Add current directory to CMake Module path automatically
if(EXISTS  ${CMAKE_CURRENT_LIST_DIR}/Platform/Arduino.cmake)
    set(CMAKE_MODULE_PATH  ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR})
endif()

#=============================================================================#
#                              C Flags                                        #
#=============================================================================#
set(ARDUINO_C_FLAGS "-ffunction-sections -fdata-sections")
set(CMAKE_C_FLAGS                "-g -Os       ${ARDUINO_C_FLAGS}"    )
set(CMAKE_C_FLAGS_DEBUG          "-g           ${ARDUINO_C_FLAGS}"    )
set(CMAKE_C_FLAGS_MINSIZEREL     "-Os -DNDEBUG ${ARDUINO_C_FLAGS}"    )
set(CMAKE_C_FLAGS_RELEASE        "-Os -DNDEBUG -w ${ARDUINO_C_FLAGS}" )
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-Os -g       -w ${ARDUINO_C_FLAGS}" )

#=============================================================================#
#                             C++ Flags                                       #
#=============================================================================#
set(ARDUINO_CXX_FLAGS "${ARDUINO_C_FLAGS} -fno-exceptions")
set(CMAKE_CXX_FLAGS                "-g -Os       ${ARDUINO_CXX_FLAGS}" )
set(CMAKE_CXX_FLAGS_DEBUG          "-g           ${ARDUINO_CXX_FLAGS}" )
set(CMAKE_CXX_FLAGS_MINSIZEREL     "-Os -DNDEBUG ${ARDUINO_CXX_FLAGS}" )
set(CMAKE_CXX_FLAGS_RELEASE        "-Os -DNDEBUG ${ARDUINO_CXX_FLAGS}" )
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-Os -g       ${ARDUINO_CXX_FLAGS}" )

#=============================================================================#
#                       Executable Linker Flags                               #
#=============================================================================#
set(ARDUINO_LINKER_FLAGS "-lm -Wl,--gc-sections")
set(CMAKE_EXE_LINKER_FLAGS                "${ARDUINO_LINKER_FLAGS}" )
set(CMAKE_EXE_LINKER_FLAGS_DEBUG          "${ARDUINO_LINKER_FLAGS}" )
set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL     "${ARDUINO_LINKER_FLAGS}" )
set(CMAKE_EXE_LINKER_FLAGS_RELEASE        "${ARDUINO_LINKER_FLAGS}" )
set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "${ARDUINO_LINKER_FLAGS}" )

#=============================================================================#
#                       Shared Lbrary Linker Flags                            #
#=============================================================================#
set(CMAKE_SHARED_LINKER_FLAGS                ""                     )
set(CMAKE_SHARED_LINKER_FLAGS_DEBUG          ""                     )
set(CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL     ""                     )
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE        ""                     )
set(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO ""                     )

set(CMAKE_MODULE_LINKER_FLAGS                ""                     )
set(CMAKE_MODULE_LINKER_FLAGS_DEBUG          ""                     )
set(CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL     ""                     )
set(CMAKE_MODULE_LINKER_FLAGS_RELEASE        ""                     )
set(CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO ""                     )

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
#                         Arduino Settings                                    #
#=============================================================================#
set(ARDUINO_OBJCOPY_EEP_FLAGS -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load
    --no-change-warnings --change-section-lma .eeprom=0   )
set(ARDUINO_OBJCOPY_HEX_FLAGS -O ihex -R .eeprom          )
set(ARDUINO_AVRDUDE_FLAGS -V                              )
