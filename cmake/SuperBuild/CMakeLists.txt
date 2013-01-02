###########################################################################
#
#  Copyright (c) Kitware Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0.txt
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################

set(ARDUINO_DEPENDENCIES AVR_BINUTILS AVR_GCC AVR_LIBC)


#-----------------------------------------------------------------------------
# WARNING - No change should be required after this comment
#           when you are adding a new external project dependency.
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Git protocol option
#
option(ARDUINO_USE_GIT_PROTOCOL "If behind a firewall turn this OFF to use http instead." ON)

set(git_protocol "git")
if(NOT ARDUINO_USE_GIT_PROTOCOL)
  set(git_protocol "http")
endif()

include(${ARDUINO_MODULE_PATH}/SuperBuild/Versions.cmake)

#-----------------------------------------------------------------------------
# Enable and setup External project global properties
#
include(ExternalProject)
include(EmptyExternalProject)
include(CheckExternalProjectDependency)

set(ep_install_dir ${ARDUINO_BINARY_DIR}/SuperBuild)
set(ep_suffix      "-cmake")

set(ep_common_c_flags "${CMAKE_C_FLAGS_INIT} ${ADDITIONAL_C_FLAGS}")
set(ep_common_cxx_flags "${CMAKE_CXX_FLAGS_INIT} ${ADDITIONAL_CXX_FLAGS}")

# Compute -G arg for configuring external projects with the same CMake generator:
if(CMAKE_EXTRA_GENERATOR)
  set(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
else()
  set(gen "${CMAKE_GENERATOR}")
endif()

# Use this value where semi-colons are needed in ep_add args:
set(sep "^^")

# This variable will contain the list of CMake variable specific to each external project
# that should passed to ARDUINO.
# The item of this list should have the following form: -D<EP>_DIR:PATH=${<EP>_DIR}
# where '<EP>' is an external project name.
set(ARDUINO_SUPERBUILD_EP_ARGS)

CheckExternalProjectDependency(ARDUINO)

#-----------------------------------------------------------------------------
# Makes sure ${ARDUINO_BINARY_DIR}/bin and ${ARDUINO_BINARY_DIR}/lib exists
#-----------------------------------------------------------------------------
# IF(NOT EXISTS ${ARDUINO_BINARY_DIR}/bin)
#   FILE(MAKE_DIRECTORY ${ARDUINO_BINARY_DIR}/bin)
# ENDIF()
# IF(NOT EXISTS ${ARDUINO_BINARY_DIR}/lib)
#   FILE(MAKE_DIRECTORY ${ARDUINO_BINARY_DIR}/lib)
# ENDIF()
# #-----------------------------------------------------------------------------
# # Set CMake OSX variable to pass down the external project
# #-----------------------------------------------------------------------------
# set(CMAKE_OSX_EXTERNAL_PROJECT_ARGS)
# if(APPLE)
#   list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
#     -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
#     -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
#     -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
# endif()
# 
# #-----------------------------------------------------------------------------
# # ARDUINO Configure
# #-----------------------------------------------------------------------------
# ExternalProject_Add(ARDUINO-Configure
#   DOWNLOAD_COMMAND ""
#   CMAKE_GENERATOR ${gen}
#   CMAKE_ARGS
#     ${CMAKE_OSX_EXTERNAL_PROJECT_ARGS}
#     -DCMAKE_INSTALL_PREFIX:PATH=${ep_install_dir}
#     -DARDUINO_SUPERBUILD:BOOL=OFF
#     ${ARDUINO_SUPERBUILD_EP_ARGS}
#     
#   SOURCE_DIR ${ARDUINO_SOURCE_DIR}
#   BINARY_DIR ${ARDUINO_BINARY_DIR}/ARDUINO-build
#   BUILD_COMMAND ""
#   INSTALL_COMMAND ""
#   DEPENDS
#     ${ARDUINO_DEPENDENCIES}
#   )
# 
# if(CMAKE_GENERATOR MATCHES ".*Makefiles.*")
#   set(ibamr_build_cmd "$(MAKE)")
# else()
#   set(ibamr_build_cmd ${CMAKE_COMMAND} --build ${ARDUINO_BINARY_DIR}/ARDUINO-build --config ${CMAKE_CFG_INTDIR})
# endif()
# 
# #-----------------------------------------------------------------------------
# # ARDUINO
# #
# if(NOT DEFINED SUPERBUILD_EXCLUDE_ARDUINOBUILD_TARGET OR NOT SUPERBUILD_EXCLUDE_ARDUINOBUILD_TARGET)
#   set(ARDUINOBUILD_TARGET_ALL_OPTION "ALL")
# else()
#   set(ARDUINOBUILD_TARGET_ALL_OPTION "")
# endif()
# 
# add_custom_target(ARDUINO-Build ${ARDUINOBUILD_TARGET_ALL_OPTION}
#   COMMAND ${ibamr_build_cmd}
#   WORKING_DIRECTORY ${ARDUINO_BINARY_DIR}/ARDUINO-build
#   )
# add_dependencies(ARDUINO-Build ARDUINO-Configure )
# 
# #-----------------------------------------------------------------------------
# # Custom target allowing to drive the build of ARDUINO project itself
# #
# add_custom_target(ARDUINO
#   COMMAND ${ibamr_build_cmd}
#   WORKING_DIRECTORY ${ARDUINO_BINARY_DIR}/ARDUINO-build
#   )
#   
