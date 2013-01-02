###########################################################################
#
#  Library: ARDUINO
#
###########################################################################

#
# AVR_LIBC
#

# Make sure this file is included only once
get_filename_component(CMAKE_CURRENT_LIST_FILENAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED)
  return()
endif()
set(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED 1)

# Sanity checks
if(DEFINED AVR_LIBC_DIR AND NOT EXISTS ${AVR_LIBC_DIR})
  message(FATAL_ERROR "AVR_LIBC_DIR variable is defined but corresponds to non-existing directory")
endif()

#set(AVR_LIBC_enabling_variable AVR_LIBC_LIBRARIES)

set(AVR_LIBC_DEPENDENCIES "AVR_GCC;AVR_BINUTILS")

# Include dependent projects if any
CheckExternalProjectDependency(AVR_LIBC)
set(proj AVR_LIBC)

if(NOT DEFINED AVR_LIBC_DIR)

  # Set CMake OSX variable to pass down the external project
  set(CMAKE_OSX_EXTERNAL_PROJECT_ARGS)
  if(APPLE)
    list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
      -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
      -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
      -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
  endif()
  
  set(ARDUINOSuperBuild_CMAKE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

  set(Samrai_PATCH_COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/samrai_patch_step.cmake)

  ExternalProject_Add(${proj}
    SOURCE_DIR ${ARDUINO_BINARY_DIR}/SuperBuild/${proj}
    BINARY_DIR ${ARDUINO_BINARY_DIR}/SuperBuild/${proj}-build
    PREFIX ${proj}${ep_suffix}
    URL ${AVR_LIBC_URL}/${AVR_LIBC_GZ}
    URL_HASH SHA1=${AVR_LIBC_SHA1}
    UPDATE_COMMAND ""
    INSTALL_COMMAND make install
    CONFIGURE_COMMAND ./configure 
      --prefix=${ep_install_dir}
      --build=`./config.guess` --host=avr
    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    LOG_INSTALL 1
    LOG_PATCH 1
    DEPENDS
      ${AVR_LIBC_DEPENDENCIES}
    )
  set(${proj}_DIR ${ARDUINO_BINARY_DIR}/${proj}-build)

else()
  msvMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
endif()

list(APPEND ARDUINO_SUPERBUILD_EP_ARGS -DAVR_LIBC_DIR:PATH=${ep_install_dir} )
 
