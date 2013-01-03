###########################################################################
#
#  ARDUINO_SDK
#
###########################################################################

# Make sure this file is included only once
get_filename_component(CMAKE_CURRENT_LIST_FILENAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED)
  return()
endif()
set(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED 1)

# Sanity checks
if(DEFINED ARDUINO_SDK_DIR AND NOT EXISTS ${ARDUINO_SDK_DIR})
  message(FATAL_ERROR "ARDUINO_SDK_DIR variable is defined but corresponds to non-existing directory")
endif()

set(ARDUINO_SDK_DEPENDENCIES "AVR_BINUTILS;AVR_GCC;AVR_LIBC")

# Include dependent projects if any
CheckExternalProjectDependency(ARDUINO_SDK)
set(proj ARDUINO_SDK)

if(NOT DEFINED ARDUINO_SDK_DIR)
  # Set CMake OSX variable to pass down the external project
  set(CMAKE_OSX_EXTERNAL_PROJECT_ARGS)
  if(APPLE)
    list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
      -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
      -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
      -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
  endif()
  
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/SuperBuild/arduino_configure_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/arduino_configure_step.cmake @ONLY)
  
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/SuperBuild/arduino_build_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/arduino_build_step.cmake @ONLY)
  
  set(ARDUINO_CONFIGURE_COMMAND
    ${CMAKE_COMMAND}
    -P ${CMAKE_CURRENT_BINARY_DIR}/arduino_configure_step.cmake
    )

  set(ARDUINO_BUILD_COMMAND
    ${CMAKE_COMMAND}
    -P ${CMAKE_CURRENT_BINARY_DIR}/arduino_build_step.cmake
    )
    
  ExternalProject_Add(${proj}
    SOURCE_DIR ${CMAKE_BINARY_DIR}/SuperBuild/${proj}
    BINARY_DIR ${CMAKE_BINARY_DIR}/SuperBuild/${proj}/build
    PREFIX ${proj}${ep_suffix}
    URL ${ARDUINO_URL}/${ARDUINO_GZ}
    URL_HASH SHA1=${ARDUINO_SHA1}
    UPDATE_COMMAND ""
    INSTALL_COMMAND ""
    CONFIGURE_COMMAND ${ARDUINO_CONFIGURE_COMMAND}
    BUILD_COMMAND ""
    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_INSTALL 1
    DEPENDS
      ${ARDUINO_SDK_DEPENDENCIES}
    )
  set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)

else()
  msvMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
endif()

list(APPEND ARDUINO_SUPERBUILD_EP_ARGS -DARDUINO_SDK_PATH:PATH=${CMAKE_BINARY_DIR}/SuperBuild/${proj}/build/linux/work )
 
