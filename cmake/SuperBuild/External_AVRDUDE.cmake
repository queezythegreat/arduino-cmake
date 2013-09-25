###########################################################################
#
#  AVRDUDE
#
###########################################################################

# Make sure this file is included only once
get_filename_component(CMAKE_CURRENT_LIST_FILENAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED)
  return()
endif()
set(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED 1)

# Sanity checks
if(DEFINED AVRDUDE_DIR AND NOT EXISTS ${AVRDUDE_DIR})
  message(FATAL_ERROR "AVRDUDE_DIR variable is defined but corresponds to non-existing directory")
endif()

set(AVRDUDE_DEPENDENCIES "")

# Include dependent projects if any
CheckExternalProjectDependency(AVRDUDE)
set(proj AVRDUDE)

if(NOT DEFINED AVRDUDE_DIR)
  # Set CMake OSX variable to pass down the external project
  set(CMAKE_OSX_EXTERNAL_PROJECT_ARGS)
  if(APPLE)
    list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
      -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
      -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
      -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
  endif()

  set(AVR_GCC_DIR ${ep_install_dir}/avr)
     
  ExternalProject_Add(${proj}
    SOURCE_DIR ${CMAKE_BINARY_DIR}/SuperBuild/${proj}
    BINARY_DIR ${CMAKE_BINARY_DIR}/SuperBuild/${proj}-build
    PREFIX ${proj}${ep_suffix}
    URL ${AVRDUDE_URL}/${AVRDUDE_GZ}
    URL_HASH SHA1=${AVRDUDE_SHA1}
    UPDATE_COMMAND ""
    INSTALL_COMMAND make install
    CONFIGURE_COMMAND ${CMAKE_BINARY_DIR}/SuperBuild/${proj}/configure --prefix=${ep_install_dir}/avr
    BUILD_COMMAND make
    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_INSTALL 1
    DEPENDS
      ${AVRDUDE_DEPENDENCIES}
    )
  set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)

else()
  EmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
endif()

