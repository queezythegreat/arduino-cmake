set(CMAKE_SYSTEM_NAME Arduino)

set(CMAKE_C_COMPILER   avr-gcc)
set(CMAKE_CXX_COMPILER avr-g++)

set(CMAKE_C_FLAGS   "-g -Os -w -ffunction-sections -fdata-sections")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}  -fno-exceptions")

set(CMAKE_EXE_LINKER_FLAGS "-Os -Wl,--gc-sections")
set(CMAKE_SHARED_LINKER_FLAGS)
set(CMAKE_MODULE_LINKER_FLAGS)
