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

set(${FIRMWARE_NAME}_BOARD uno)               # Arduino Target board
set(${FIRMWARE_NAME}_SRCS wire_master_reader.cpp)  # Firmware sources

set(${FIRMWARE_NAME}_PORT /dev/ttyACM0)            # Serial upload port


#====================================================================#
#  Target generation                                                 #
#====================================================================#
generate_arduino_firmware(${FIRMWARE_NAME})
