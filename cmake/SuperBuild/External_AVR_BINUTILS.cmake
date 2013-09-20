###########################################################################
#
#  AVR_BINUTILS
#
###########################################################################

# Make sure this file is included only once
get_filename_component(CMAKE_CURRENT_LIST_FILENAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED)
  return()
endif()
set(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED 1)

# Sanity checks
if(DEFINED AVR_BINUTILS_DIR AND NOT EXISTS ${AVR_BINUTILS_DIR})
  message(FATAL_ERROR "AVR_BINUTILS_DIR variable is defined but corresponds to non-existing directory")
endif()

set(AVR_BINUTILS_DEPENDENCIES "")

# Include dependent projects if any
CheckExternalProjectDependency(AVR_BINUTILS)
set(proj AVR_BINUTILS)

if(NOT DEFINED AVR_BINUTILS_DIR)

  # Set CMake OSX variable to pass down the external project
  set(CMAKE_OSX_EXTERNAL_PROJECT_ARGS)
  if(APPLE)
    list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
      -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
      -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
      -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
  endif()
  
  set(BINUTILS_PATCH_FILE ${CMAKE_CURRENT_SOURCE_DIR}/cmake/SuperBuild/30-binutils-2.20.1-avr-size.patch)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/SuperBuild/binutils_patch_step.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/binutils_patch_step.cmake @ONLY)
  
  set(BINUTILS_PATCH_COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/binutils_patch_step.cmake)
  ExternalProject_Add(${proj}
    SOURCE_DIR ${CMAKE_BINARY_DIR}/SuperBuild/${proj}
    BINARY_DIR ${CMAKE_BINARY_DIR}/SuperBuild/${proj}-build
    PREFIX ${proj}${ep_suffix}
    URL ${BINUTILS_URL}/${BINUTILS_GZ}
    URL_HASH SHA1=${BINUTILS_SHA1}
    UPDATE_COMMAND ""
    PATCH_COMMAND ${BINUTILS_PATCH_COMMAND}
    INSTALL_COMMAND make install
    CONFIGURE_COMMAND ${CMAKE_BINARY_DIR}/SuperBuild/${proj}/configure 
      --prefix=${ep_install_dir}/avr
      --target=avr
      --program-prefix='avr-'
    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_INSTALL 1
    DEPENDS
      ${AVR_BINUTILS_DEPENDENCIES}
    )
  set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)

else()
  msvMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
endif()

list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${ep_install_dir}/avr/avr/bin ${ep_install_dir}/avr/bin)
# list(APPEND ARDUINO_SUPERBUILD_EP_ARGS -DAVR_BINUTILS_DIR:PATH=${ep_install_dir} )

