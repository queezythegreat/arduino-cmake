# This configuration file outlines some of the ways Arduino CMake
# can be used. For a detailed explenation of all the options please
# reade README.rst.

set(ARDUINO_BOARD diecimila)


#====================================================================#
# master_writer example from Wire library
#====================================================================#
generate_arduino_example(Wire master_writer ${ARDUINO_BOARD} /dev/ttyACM0)




#====================================================================#
# Original blink sketch (from Arduino SDK examples)
#====================================================================#
generate_arduino_firmware(blink_original
    SKETCH ${ARDUINO_SDK_PATH}/examples/1.Basics/Blink
    BOARD ${ARDUINO_BOARD}
    PORT /dev/ttyUSB0)

# Alternative: by variables
#set(blink_original_SKETCH ${ARDUINO_SDK_PATH}/examples/1.Basics/Blink)
#set(blink_original_BOARD ${ARDUINO_BOARD})
#set(blink_original_PORT /dev/ttyUSB0)
#
#generate_arduino_firmware(blink_original)




#====================================================================#
# Bundled blink sketch example
#====================================================================#
generate_arduino_firmware(blink_bundled
    SKETCH Blink
    BOARD  ${ARDUINO_BOARD}
    PORT   /dev/ttyUSB0
    PROGRAMMER usbtinyisp
    NO_AUTOLIBS)

# Alternative: by variables
#set(blink_bundled_SKETCH Blink)
#set(blink_bundled_BOARD  ${ARDUINO_BOARD})
#set(blink_bundled_PORT   /dev/ttyUSB0)
#set(blink_bundled_PROGRAMMER usbtinyisp)
#set(blink_bundled_NO_AUTOLIBS true)
#
#generate_arduino_firmware(blink_bundled)




#====================================================================#
# Advanced static library exmaple
#====================================================================#
generate_arduino_library(blink_lib
    SRCS blink_lib.cpp
    HDRS blink_lib.h
    BOARD ${ARDUINO_BOARD})

# Alternative: by variables
#set(blink_lib_SRCS blink_lib.cpp)
#set(blink_lib_HDRS blink_lib.h)
#set(blink_lib_BOARD ${ARDUINO_BOARD})
#
#generate_arduino_library(blink_lib)




#====================================================================#
# Advanced firwmare example
#====================================================================#
generate_arduino_firmware(blink
    SRCS blink.cpp
    LIBS blink_lib
    BOARD ${ARDUINO_BOARD})

# Alternative: by variables
#set(blink_SRCS blink.cpp)
#set(blink_LIBS blink_lib)
#set(blink_BOARD ${ARDUINO_BOARD})
#
#generate_arduino_firmware(blink)
