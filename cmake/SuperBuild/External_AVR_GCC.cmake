###########################################################################
#
#  AVR_GCC
#
###########################################################################

# Make sure this file is included only once
get_filename_component(CMAKE_CURRENT_LIST_FILENAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED)
  return()
endif()
set(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED 1)

# Sanity checks
if(DEFINED AVR_GCC_DIR AND NOT EXISTS ${AVR_GCC_DIR})
  message(FATAL_ERROR "AVR_GCC_DIR variable is defined but corresponds to non-existing directory")
endif()

set(AVR_GCC_DEPENDENCIES "AVR_BINUTILS")

# Include dependent projects if any
CheckExternalProjectDependency(AVR_GCC)
set(proj AVR_GCC)

if(NOT DEFINED AVR_GCC_DIR)

  # Set CMake OSX variable to pass down the external project
  set(CMAKE_OSX_EXTERNAL_PROJECT_ARGS)
  if(APPLE)
    list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
      -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
      -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
      -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
  endif()
  
  ExternalProject_Add(${proj}
    SOURCE_DIR ${CMAKE_BINARY_DIR}/SuperBuild/${proj}
    BINARY_DIR ${CMAKE_BINARY_DIR}/SuperBuild/${proj}-build
    PREFIX ${proj}${ep_suffix}
    URL ${GCC_URL}/${GCC_GZ}
    URL_HASH SHA1=${GCC_SHA1}
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${CMAKE_BINARY_DIR}/SuperBuild/${proj}/configure
      --prefix=${ep_install_dir}/avr
      --target=avr
      --enable-languages=c,c++
      --program-prefix='avr-'
    INSTALL_COMMAND make install
    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_INSTALL 1
    DEPENDS
      ${AVR_GCC_DEPENDENCIES}
    )
  set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)

else()
  msvMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
endif()

list(APPEND ARDUINO_SUPERBUILD_EP_ARGS 
#   -DAVR_GCC_DIR:PATH=${ep_install_dir}
  -DCMAKE_C_COMPILER=${ep_install_dir}/avr/bin/avr-gcc
  -DCMAKE_CXX_COMPILER=${ep_install_dir}/avr/bin/avr-g++
  )

list(APPEND CMAKE_FIND_ROOT_PATH ${ep_install_dir}/avr)
list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${ep_install_dir}/avr/bin)
