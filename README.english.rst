Arduino Cmake Example Project
===============================

This is the Cmake project settings for the Arduino platform. 
You can use this project as an example to develop C++ programs 
in JetBrains CLion IDE for Arduino and using toolchain from 
Arduino IDE 1.6+.

This project correctly works and tested in Windows with MinGW, 
but it should work in linux and mac with standard cmake/make pakages.

Original cmake project is licensed with 
Mozilla Public License, v. 2.0 http://mozilla.org/MPL/2.0/

Readme from the original project is moved to /README.original.rst. 
You can find all the authors and contributors there.

Usefull links
-------------------------------
Original project URI: https://github.com/queezythegreat/arduino-cmake

Current project is it's fork with patches from pull requests 
https://github.com/queezythegreat/arduino-cmake/pulls 
and with my patches that fixes some major and minor bugs 
as long as adds other new features.

Some examples are taken from this article http://habrahabr.ru/post/247017/

Differencies between this project and original one
-------------------------------
1. Added patch "Adding support for SDK 1.5" 
    https://github.com/queezythegreat/arduino-cmake/pull/104 
    Added support for Arduino IDE 1.5-1.6+.

2. Added patch "fixed bug in find_file method" 
    https://github.com/queezythegreat/arduino-cmake/pull/109 
    Now cmake project does not search for arduino toolchain 
    files in standard windows paths.

3. Added patch "Fix CMP0038 warnings on CMake >= 3.0" 
    https://github.com/queezythegreat/arduino-cmake/pull/143 
    Removed warnings.

4. Fixed windows paths to avr-size command. Now we can see the size of the compiled arduino program.

5. Fixed parsing of the boards.txt settings that are used for compilation of the boards (that differs from arduino mega).

6. All compilation settings are taken from original Arduino IDE. 
    But i dont think i've done it the best way so you can try do better if you want.

7. Removed any differences between all build flavors (debug, release, etc). This is descructive difference between this fork 
    and original project, that is why you should not try to merge this fork into original project. 
    I make it because i dont have enough experience in finding the best compile options for these different build types. 
    So now it uses original Arduino IDE options.

8. Original Readme is saved in README.original.rst

Installing CLion + Arduino IDE + MinGW
-----------------------------------
1. Install MinGW (needed for CLion, includes make, g++, cpp)

This is needed only for windows. In different OS'es you should skip this and continue to 
the next - "2. Install Arduino IDE".

1.1. Installing MinGW 
    http://sourceforge.net/projects/mingw/files/Installer/ 
    Tested on version mingw-get-0.6.2-mingw32-beta-20131004-1

1.2. Run MinGW Installation Manager

1.3. Choose packages from "Basic Setup" 
    - mingw-developer-toolkit
    - mingw32-base
    - mingw32-gcc-g++
    - msys-base
and push "Apply Changes"

2. Install Arduino IDE 1.6 (needed for building the project, includes avr toolchain) 
    http://www.arduino.cc/en/Main/OldSoftwareReleases 
    Tested on version 1.6.3

3. Install and setup JetBrains CLion 1.0

3.1. Install JetBrains CLion 1.0 
    https://www.jetbrains.com/clion/ 
    Test on version 1.0

3.2. Run CLion

3.3. Setup toolchain 
    Menu settings "File" -> "Settings" 
    Choose "Build, Execudion, Deployment" -> "Toolchain" 
    Setup 
        - Env: MinGW "c:\mingw"
        - cmake: "bundled cmake"

MinGW option only exists in windows.

All is done, you can open project in CLion.

How to move you existing project from Arduino IDE
-----------------------------------

For example, you have your own project named Robot with the following files
- /Robot.ino 
- /Chassis.cpp
- /Chassis.h
that already works in Arduino IDE, and you want to move it to CLion IDE.

1. Make new project with name arduino-cmake-robot 
Clone this repository: 
    git clone {THIS_REPO_URI} arduino-cmake-robot

We do not need origin any more, we will use our own project repository. 
Remove origin: 
    git remote rm origin

2. Copy our existing project files Robot 
Make folder /robot in the root of new project. 
Copy files into this folder. Now we have 3 new files in new project
    - /robot/Robot.ino
    - /robot/Chassis.cpp
    - /robot/Chassis.h

3. Rename Robot.ino into robot.cpp 
Now our new files and folders structure is like the following:
    - /robot/robot.cpp
    - /robot/Chassis.cpp
    - /robot/Chassis.h

4. Add standard Arduino library 
Add the following line before the very first line of the /robot/robot.cpp file
    #include "Arduino.h"

5. Make file with cmake build settings 
Copy /example/CMakeLists.txt into /robot/CMakeLists.txt

6. Setup CMakeLists.txt for "robot" project (/robot/CMakeLists.txt) 
Set up the name of the project 
    set(PROJECT_NAME robot)

Set up the target platform. 
Example 1. For Arduino Pro (Arduino Pro Mini) it should look like this 
    set(${PROJECT_NAME}_BOARD pro) 
Example 2. For Arduino UNO 
    set(${PROJECT_NAME}_BOARD uno)

Set up the name of the file, that was previously with INO extension 
    set(${PROJECT_NAME}_SRCS robot.cpp) 
Set up target COM port, which is connect to the board 
    set(${PROJECT_NAME}_PORT COM3)

7. Set up root folder CMakeLists.txt (/CMakeLists.txt) 
Choose correct CPU option for the board. 
This name is located in the file 
    C:\Program Files (x86)\Arduino\hardware\arduino\avr\boards.txt 
This is windows path. For other OS'es it will look similar to 
"hardware\arduino\avr\boards.txt".

Example 1. For Arduino Pro 16Mhz 5V ATmega 328 
we can file the line "pro.menu.cpu.16MHzatmega328=ATmega328 (5V, 16 MHz)" 
and than take correct CPU ID "16MHzatmega328", but not the value "ATmega328 (5V, 16 MHz)" 
     set(ARDUINO_CPU 16MHzatmega328) 
Example 2. For Arduino UNO where is no need to define anything, just comment out the CPU ID line, 
because Arduino UNO does not have different CPU options 
    # (commented) set(ARDUINO_CPU 16MHzatmega328)

Add project folder, change "example" to "robot" 
    # (commented) add_subdirectory(example) 
    add_subdirectory(robot)

8. Open project in CLion IDE and choose build option "robot" (for compilation only)  
or "robot_upload" (for compilation and upload).  
Build project (CTRL+F9). After that project starts to build and upload to the Arduino board.
