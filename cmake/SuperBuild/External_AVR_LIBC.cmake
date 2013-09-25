###########################################################################
#
#  AVR_LIBC
#
###########################################################################

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

  set(AVR_GCC_DIR ${ep_install_dir}/avr)
  
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/SuperBuild/avr_libc_configure_step.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/avr_libc_configure_step.cmake @ONLY)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/SuperBuild/avr_libc_build_step.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/avr_libc_build_step.cmake @ONLY)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/SuperBuild/avr_libc_install_step.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/avr_libc_install_step.cmake @ONLY)
    
  set(AVR_LIBC_CONFIGURE_COMMAND
    ${CMAKE_COMMAND}
    -P ${CMAKE_CURRENT_BINARY_DIR}/avr_libc_configure_step.cmake
    )
  set(AVR_LIBC_BUILD_COMMAND
    ${CMAKE_COMMAND}
    -P ${CMAKE_CURRENT_BINARY_DIR}/avr_libc_build_step.cmake
    )
  set(AVR_LIBC_INSTALL_COMMAND
    ${CMAKE_COMMAND}
    -P ${CMAKE_CURRENT_BINARY_DIR}/avr_libc_install_step.cmake
    )
    
  ExternalProject_Add(${proj}
    SOURCE_DIR ${CMAKE_BINARY_DIR}/SuperBuild/${proj}
    BINARY_DIR ${CMAKE_BINARY_DIR}/SuperBuild/${proj}-build
    PREFIX ${proj}${ep_suffix}
    URL ${AVR_LIBC_URL}/${AVR_LIBC_GZ}
    URL_HASH SHA1=${AVR_LIBC_SHA1}
    UPDATE_COMMAND ""
    INSTALL_COMMAND ${AVR_LIBC_INSTALL_COMMAND}
    CONFIGURE_COMMAND ${AVR_LIBC_CONFIGURE_COMMAND}
    BUILD_COMMAND ${AVR_LIBC_BUILD_COMMAND}
    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_INSTALL 1
    DEPENDS
      ${AVR_LIBC_DEPENDENCIES}
    )
  set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)

else()
  EmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
endif()

list(APPEND CMAKE_FIND_ROOT_PATH ${ep_install_dir}/avr/avr)
