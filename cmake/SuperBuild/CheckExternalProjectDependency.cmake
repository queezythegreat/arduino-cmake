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

#!
#! Convenient macro allowing to define a "empty" project in case an external one is provided
#! using for example <proj>_DIR.
#! Doing so allows to keep the external project dependency system happy.
#!
#! \ingroup CMakeUtilities
macro(EmptyExternalProject proj dependencies)

  ExternalProject_Add(${proj}
    SOURCE_DIR ${CMAKE_BINARY_DIR}/${proj}
    BINARY_DIR ${proj}-build
    DOWNLOAD_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    DEPENDS
      ${dependencies}
    )
endmacro()

macro(CheckExternalProjectDependency project)
  # Set indent variable if needed
  if(NOT DEFINED __indent)
    set(__indent "")
  else()
    set(__indent "${__indent}  ")
  endif()

  # Sanity checks
  if(NOT DEFINED ${project}_DEPENDENCIES)
    message(FATAL_ERROR "${__indent}${project}_DEPENDENCIES variable is NOT defined !")
  endif()

  # Display dependency of projectect being processed
  if("${${project}_DEPENDENCIES}" STREQUAL "")
    message(STATUS "SuperBuild - ${__indent}${project}[OK]")
  else()
    set(dependency_str " ")
    foreach(dep ${${project}_DEPENDENCIES})
      if(External_${dep}_FILE_INCLUDED)
        set(dependency_str "${dependency_str}${dep}[INCLUDED], ")
      else()
        set(dependency_str "${dependency_str}${dep}, ")
      endif()
    endforeach()
    message(STATUS "SuperBuild - ${__indent}${project} => Requires${dependency_str}")
  endif()
  
  # Include dependencies
  foreach(dep ${${project}_DEPENDENCIES})
    if(NOT External_${dep}_FILE_INCLUDED)
      include(SuperBuild/External_${dep})
    endif()
  endforeach()

  # If projectect being process has dependencies, indicates it has also been added.
  if(NOT "${${project}_DEPENDENCIES}" STREQUAL "")
    message(STATUS "SuperBuild - ${__indent}${project}[OK]")
  endif()
  
  # Update indent variable
  string(LENGTH "${__indent}" __indent_length)
  math(EXPR __indent_length "${__indent_length}-2")
  if(NOT ${__indent_length} LESS 0)
    string(SUBSTRING "${__indent}" 0 ${__indent_length} __indent)
  endif()
endmacro()
