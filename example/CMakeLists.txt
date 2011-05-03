#=============================================================================#
# Author: QueezyTheGreat                                                      #
# Date:   26.04.2011                                                          #
#                                                                             #
# Description: wire_master_reader firmware exmaple                            #
#                                                                             #
#=============================================================================#


#====================================================================#
#  Settings                                                          #
#====================================================================#
set(FIRMWARE_NAME wire_reader)

set(${FIRMWARE_NAME}_BOARD mega2560)               # Arduino Target board
set(${FIRMWARE_NAME}_SRCS wire_master_reader.cpp)  # Firmware sources

set(${FIRMWARE_NAME}_PORT /dev/ttyUSB0)            # Serial upload port
set(${FIRMWARE_NAME}_SERIAL picocom @INPUT_PORT@ -b 9600 -l )  # Serial terminal cmd


#====================================================================#
#  Target generation                                                 #
#====================================================================#
generate_arduino_firmware(${FIRMWARE_NAME})
