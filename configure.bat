::===========================================================================::
:: Author: QueezyTheGreat                                                    ::
:: Description: Small wrapper around cmake and cmake-gui for                 ::
::              easy build system configuration and generation.              ::
::===========================================================================::
@echo off

set CURRENT_PATH=%CD%

set CONFIGURE_PATH=%~dp0%
set CONFIGURE_MODE=%1
set CONFIGURE_ARGS=%*

set BUILD_PATh=build

set CMAKE_NAME=cmake.exe
set CMAKEGUI_NAME=cmake-gui.exe


:: Parse arguments
if /i [%CONFIGURE_MODE%] EQU [-h]      goto :print_help
if /i [%CONFIGURE_MODE%] EQU [--help]  goto :print_help
if /i [%CONFIGURE_MODE%] EQU [/?]      goto :print_help


:: Check dependencies
for %%X in (%CMAKE_NAME% %CMAKEGUI_NAME%) do (
    set FOUND=%%~$PATH:X
    if not defined FOUND (
        echo %%X missing on the path, aborting!
        echo.
        echo Please ensure that CMake is available on the system path.
        echo.
        pause
        goto :EXIT
    )
)

:: Generate/Configure build
call :init_build
call :setup_build


::===========================================================================::
::                                                                           ::
::===========================================================================::
goto :EXIT


:: Initialize build path
:init_build
    if "%CURRENT_PATH%\" EQU "%CONFIGURE_PATH%" (
        :: In sources, create build directory
        set "BUILD_PATH=%CONFIGURE_PATH%%BUILD_PATH%"

        :: Create build directory
        if not exist "%BUILD_PATH%" (
            mkdir "%BUILD_PATH%"
        )
    ) else (
        :: Out of sources, do nothing
        set BUILD_PATH=%CD%
    )
    goto :RETURN

:: Configure/Generate build system
:setup_build
    cd "%BUILD_PATH%"
    if /i [%CONFIGURE_MODE%] EQU [-c] (
        :: Command Line version (cmake)
        echo cmake %CONFIGURE_ARGS:~3% "%CONFIGURE_PATH%"
        %CMAKE_NAME% %CONFIGURE_ARGS:~3% "%CONFIGURE_PATH%"
    ) else (
        :: GUI version (cmake-gui)
        start %CMAKEGUI_NAME% "%CONFIGURE_PATH%"
    )
    cd "%CURRENT_PATH%"
    goto :RETURN

:: Display help message
:print_help
    echo configure [-h ^| -c OPTS]
    echo     -h    Display this message
    echo     -c    Command line version of CMake
    echo.
    echo   OPTS    Options to pass to CMake command line
    echo.
    echo  Small wrapper around cmake and cmake-gui for
    echo  easy build system configuration and generation.
    echo.
    echo  For GUI and command line use.
    goto :EXIT

:RETURN
:EXIT
