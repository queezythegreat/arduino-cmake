# Set a variable for commands below
set(PROJECT_NAME example)

# Define your project and language
project(${PROJECT_NAME} C CXX)

set(${PROJECT_NAME}_BOARD pro)

# Define the source code
set(${PROJECT_NAME}_SRCS example.cpp)

# Define the port for uploading code to the Arduino
set(${PROJECT_NAME}_PORT COM6)

# Command to generate code arduino firmware (.hex file)
generate_arduino_firmware(${PROJECT_NAME})
