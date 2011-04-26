
# Arduino CMake

Arduino is a great development platform, which is easy to use. It has everything a beginner should need. The *Arduino IDE* simplifies a lot of things for the standard user, but if you are a professional programmer the IDE can feel simplistic and restrictive.

One major drawback of the *Arduino IDE* is that you cannot do anything without it, which for me is a **complete buzz kill**. Thats why I created an alternative build system for the Arduino using CMake.

CMake is great corss-platform build system that works on practically any operating system. With it you are not constrained to a single build system. CMake lets you generated the build system that fits your needs, using the tools you like. It can generate any type of build system, from simple Makefiles, to complete projects for Eclipse, Visual Studio, XCode, etc.

The **Arduino CMake** build system integrates tightly with the *Arduino SDK*. I'm currently basing on version **0022** of the *Arduino SDK*.

Requirements:

* CMake - http://www.cmake.org/cmake/resources/software.html
* Arduino SDK - http://www.arduino.cc/en/Main/Software


Linux Requirements:

* gcc-avr      - AVR GNU GCC compiler
* binutils-avr - AVR binary tools
* avr-libc     - AVR C library
* avrdude      - Firmware uploader


TODO:

* Sketch conversion (PDE files)
* Setup dependency detection for:
    * Mac OS X
* Test more complex configurations and error handling

## Contents

1. Getting Started
2. Setting up Arduino CMake
3. Creating firmware images
4. Creating libraries
5. Windows Enviroment Setup
    1. CMake Generators
    2. Serial Namming
    3. Serial Terminal
6. Troubleshooting
    1. undefined reference to `__cxa_pure_virtual'

## Getting Started

The following instructions are for **\*nix** type systems, specifically this is a Linux example.

In short you can get up and running using the follwoing commands:

    mkdir build
    cd build
    cmake ..
    make
    make upload                      # to upload the firmware   [optional]
    make wire_master_reader-serial  # to get a serial terminal [optional]

For a more detailed explanation, please read on...

1. Toolchain file

    In order to build firmware for the Arduino you have to specify a toolchain file to enable cross-compilation. There are two ways of specifying the file, either at the command line or from within the *CMakeLists.txt* configuration files. The bundled example uses the second approche like so:

        set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/cmake/toolchains/Arduino.cmake)

    Please note that this must be before the `project(...)` command.

    If you would like to specify it from the command line, heres how:

        cmake -DCMAKE_TOOLCHAIN_FILE=../path/to/toolchain/file.cmake PATH_TO_SOURCE_DIR

2. Creating a build directory

    The second order of business is creating a build directory. CMake has a great feature called out-of-source builds, what this means is the building is done in a completely separate directory, than where the sources are. The benefits of this is you don't have any clutter in you source directory and you won't accidentally commit something in, that is auto-generated.

    So lets create that build directory:

        mkdir build
        cd build

3. Creating the build system

    Now lets create the build system that will create our firmware:

        cmake ..

4. Building

    Next we will build everything:

        make

5. Uploading

    Once everything built correctly we can upload. Depending on your Arduino you will have to update the serial port used for uploading the firmware. To change the port please edit the following variable in *CMakeLists.txt*:

        set(${FIRMWARE_NAME}_PORT /path/to/device)

    Ok lets do a upload:

        make upload

6. Serial output

    If you have some serial output, you can launch a serial terminal from the build system. The command used for executing the serial terminal is user configurable by the following setting:

        set(${FIRMWARE_NAME}_SERIAL serial command goes here)

    In order to get access to the serial port use the following in your command:

        @INPUT_PORT@

    That constant will get replaced with the actual serial port used (see uploading). In the case of our example configuration we can get the serial terminal by executing the following:

        make wire_master_reader-serial






## Setting up Arduino CMake

The first step in generating Arduino firmware is including the **Arduino CMake** module package. This easily done with:

    find_package(Arduino)

To have a specific minimal version of the *Arduino SDK*, you can specify the version like so:

    find_package(Arduino 22)

That will require an *Arduino SDK* version **0022** or newer. To ensure that the SDK is detected you can add the **REQUIRED** keyword:


    find_package(Arduino 22 REQUIRED)


## Creating firmware images

Once you have the **Arduino CMake** package loaded you can start defining firmware images.

To create Arduino firmware in CMake you use the `generate_arduino_firmware` command. This function only accepts a single argument, the target name. To configure the target you need to specify a list of variables of the following format before the command:

    ${TARGET_NAME}${OPTION_SUFFIX}

Where `${TARGET_NAME}` is the name of you target and `${OPTIONS_SUFFIX}` is one of the following option suffixes:

     _SRCS           # Target source files
     _HDRS           # Target Headers files (for project based build systems)
     _SKETCHES       # Target sketch files
     _LIBS           # Libraries to linked against target
     _BOARD          # Board name (such as uno, mega2560, ...)
     _PORT           # Serial port, for upload and serial targets [OPTIONAL]
     _SERIAL         # Serial command for serial target           [OPTIONAL]
     _NO_AUTOLIBS    # Disables Arduino library detection (default On)


So to create a target (firmware image) called `blink`, composed of `blink.h` and `blink.cpp` source files for the *Arduino Uno*, you write the following:

    set(blink_SRCS  blink.cpp)
    set(blink_HDRS  blink.h)
    set(blink_BOARD uno)

    generate_arduino_firmware(blink)

To enable firmware upload functionality, you need to add the `_PORT` settings:

    set(blink_PORT /dev/ttyUSB0)

To enable serial terminal, add the `_SERIAL` setting (`@INPUT_PORT@` will be replaced with the `blink_PORT` setting):

    set(blink_PORT picocom @INPUT_PORT@ -b 9600 -l)






## Creating libraries

Creating libraries is very similar to defining a firmware image, except we use the `generate_arduino_library` command. The syntax of the settings is the same except we have a different list of settings:

     _SRCS           # Library Sources
     _HDRS           # Library Headers
     _LIBS           # Libraries to linked in
     _BOARD          # Board name (such as uno, mega2560, ...)
     _NO_AUTOLIBS    # Disables Arduino library detection

Lets define a simple library called `blink_lib`, with two sources files for the *Arduino Uno*:


    set(blink_lib_SRCS  blink_lib.cpp)
    set(blink_lib_HDRS  blink_lib.h)
    set(blink_lib_BOARD uno)

    generate_arduino_firmware(blink_lib)

Once that library is defined we can use it in our other firmware images... Lets add `blink_lib` to the `blink` firmware:

    set(blink_SRCS  blink.cpp)
    set(blink_HDRS  blink.h)
    set(blink_LIBS  blink_lib)
    set(blink_BOARD uno)

    generate_arduino_firmware(blink)


## Windows Enviroment Setup

On Windows the *Arduino SDK* is self contained and has everything needed for building. To setup the environment do the following:

1. Place the *Arduino SDK* either
    * into  **Program Files**, or
    * onto the **System Path**
    
    NOTE: Don't change the default *Arduino SDK* directory name, otherwise auto detection will no work properly!
2. Add to the **System Path**: `${ARDUINO_SDK_PATH}/hardware/tools/avr/utils/bin`
3. Install [CMake 2.8](http://www.cmake.org/cmake/resources/software.html "CMake Downloads")
   
    NOTE: Make sure you check the option to add CMake to the **System Path**.


### CMake Generators

Once installed, you can start using CMake the usual way, just make sure to chose either a **MSYS Makefiles** or **Unix Makefiles** type generator:

    MSYS Makefiles              = Generates MSYS makefiles.
    Unix Makefiles              = Generates standard UNIX makefiles.
    CodeBlocks - Unix Makefiles = Generates CodeBlocks project files.
    Eclipse CDT4 - Unix Makefiles
                                = Generates Eclipse CDT 4.0 project files.

If you want to use a **MinGW Makefiles** type generator, you must generate the build system the following way:

1. Remove `${ARDUINO_SDK_PATH}/hardware/tools/avr/utils/bin` from the **System Path**
2. Generate the build system using CMake with the following option set (either throug the GUI or from the command line):

    CMAKE_MAKE_PROGRAM=${ARDIUNO_SDK_PATH}/hardware/tools/avr/utils/bin/make.exe

3. Then build the normal way

The reason for doing this is the MinGW generator cannot have the `sh.exe` binary on the **System Path** during generation, otherwise you get an error.

### Serial Namming

When specifying the serial port name on Windows, use the following names:

    com1 com2 ... comN

CMake configuration example:

    set(${FIRMWARE_NAME}_PORT com3)

### Serial Terminal

Putty is a great multi-protocol terminal, which supports SSH, Telnet, Serial, and many more... The latest development snapshot supports command line options for launching a serial terminal, for example:

    putty -serial COM3 -sercfg 9600,8,n,1,X

CMake configuration example (assuming putty is on the **System Path**):

    set(${FIRMWARE_NAME}_SERIAL putty -serial @INPUT_PORT@)

Putty - http://tartarus.org/~simon/putty-snapshots/x86/putty-installer.exe


## Troubleshooting

The following section will outline some solutions to common problems that you may encounter.

###  undefined reference to `__cxa_pure_virtual'

When linking you'r firmware image you may encounter this error on some systems. An easy fix is to add the following to your firmware source code:

    extern "C" void __cxa_pure_virtual(void);
    void __cxa_pure_virtual(void) { while(1); } 


The contents of the `__cxa_pure_virtual` function can be any error handling code; this function will be called whenever a pure virtual function is called. 

* [What is the purpose of `cxa_pure_virtual`](http://stackoverflow.com/questions/920500/what-is-the-purpose-of-cxa-pure-virtual "")
