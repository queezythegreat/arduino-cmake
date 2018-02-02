# Set a variable for commands below
set(PROJECT_NAME example_ap)

# Define your project and language
project(${PROJECT_NAME})

set(${PROJECT_NAME}_BOARD featheresp32)

# Define the source code
set(${PROJECT_NAME}_SRCS wifi_ap.cpp aes.c)

# Define the port for uploading code to the Arduino
set(${PROJECT_NAME}_PORT /dev/ttyUSB0)

# Select a specific upload speed for the board
set(${${PROJECT_NAME}_BOARD}.upload.speed 921600)

# Select a specific flash frequence for the board
set(${${PROJECT_NAME}_BOARD}.build.flash_freq 80m)

set(${PROJECT_NAME}_LIBS   esp32  mbedtls wpa_supplicant)
#set(${PROJECT_NAME}_ARDLIBS WiFi)
#set(${PROJECT_NAME}_ARDLIBS_PATH ${ESP32_LIBRARIES_PATH})

# Command to generate code arduino firmware (.hex file)
generate_arduino_firmware(${PROJECT_NAME})
