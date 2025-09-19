# SPDX-License-Identifier: BSD-3-Clause
# Copyright Contributors to the OpenColorIO Project.
#
# Build a Python_EXECUTABLE pre-command which temporarily modifies PATH and 
# PYTHONPATH with the OCIO Python environment and any additionally provided 
# paths containing Python packages.
#
# Variables defined by this module:
#   Python_PRE_CMD
#
# Usage:
#   get_python_pre_command([path [...]])
#
# Use the PYT_PRE_COMMAND when running a command with Python_EXECUTABLE:
#   ${Python_PRE_COMMAND} ${Python_EXECUTABLE} [args]
#

# For Makefiles
set(CMAKE_VERBOSE_MAKEFILE ON)

# For MSBuild (Visual Studio)
set(CMAKE_MSBUILD_FLAGS "/verbosity:detailed")

macro(get_python_pre_command)

    # Override PYTHONPATH to make the PyOpenColorIO build and additional paths
    # available.
    if(WIN32)
        # Use Windows path separators since this is being passed through to cmd
        file(TO_NATIVE_PATH ${PROJECT_BINARY_DIR} _WIN_BINARY_DIR)
        file(TO_NATIVE_PATH ${PROJECT_SOURCE_DIR} _WIN_SOURCE_DIR)

        set(_DLL_PATH "${_WIN_BINARY_DIR}\\src\\OpenColorIO")
        if(MSVC_IDE)
            set(_DLL_PATH "${_DLL_PATH}\\${CMAKE_BUILD_TYPE}")
        endif()

        string(CONCAT _PATH_SET
            "PATH="
            "${_DLL_PATH}"
            "\\\\;"
            "%PATH%"
        )

        set(_PYD_PATH "${_WIN_BINARY_DIR}\\src\\bindings\\python")
        if(MSVC_IDE)
            set(_PYD_PATH "${_PYD_PATH}\\${CMAKE_BUILD_TYPE}")
        endif()

        # Build path list
        set(_WIN_PATHS 
            ${_PYD_PATH} 
            "${_WIN_SOURCE_DIR}\\share\\docs"
        )
        # Include optional paths from macro arguments
        foreach(_PATH ${ARGN})
            file(TO_NATIVE_PATH ${_PATH} _WIN_PATH)
            list(APPEND _WIN_PATHS ${_WIN_PATH})
        endforeach()
        
        # I think this supposed to add a literal %PYTHONPATH% at the end of the
        # list but instead somehow it's adding an empty entry which results
        # double semicolons at the end and that seems to crash the conversion to
        # absolute path at one point in Python 3.11+.  
        # I'm not sure who converts %PYTHONPATH% to empty string, this is a
        # python script launched by a cmd.exe command that's defined as a custom
        # build step in vcxproj file which is created by CMake ' but the command
        # and that cmd.exe is launched by MSBuild. :-o 

        # ... in src/bindings/python/CMakeList.txt:23 the command is:

        # set;PYTHONPATH=D:\a\OpenColorIO\OpenColorIO\build\temp.win-amd64-cpython-311\Release\src\bindings\python\Release\;D:\a\OpenColorIO\OpenColorIO\share\docs\;;	;call C:\Users\runneradmin\AppData\Local\Temp\build-env-q0vk6lfr\Scripts\python.exe D:/a/OpenColorIO/OpenColorIO/share/docs/extract_docstrings.py xml docstrings.h 
        
        # This may be related to https://www.cve.news/cve-2023-41105/  
        # Commenting out the below line seems to fix the Windows Wheels builds.  
        # Trying with %%PYTHONPATH%% ...  
        list(APPEND _WIN_PATHS "%%PYTHONPATH%%")

        string(JOIN "\\\\;" _PYTHONPATH_VALUE ${_WIN_PATHS})
        string(CONCAT _PYTHONPATH_SET "PYTHONPATH=${_PYTHONPATH_VALUE}")

        # Mimic *nix:
        #   '> PYTHONPATH=XXX CMD'
        # on Windows with:
        #   '> set PYTHONPATH=XXX \n call CMD'
        # '\n' is here because '\\&' does not work.
        set(Python_PRE_CMD set ${_PYTHONPATH_SET} "\n" call)

        message(STATUS "Python pre-command: ${Python_PRE_CMD}")

    else()
        # Build path list
        set(_PATHS 
            "${PROJECT_BINARY_DIR}/src/bindings/python"
            "${PROJECT_SOURCE_DIR}/share/docs"
        )
        foreach(_PATH ${ARGN})
            list(APPEND _PATHS ${_PATH})
        endforeach()
        list(APPEND _PATHS "$ENV{PYTHONPATH}")

        string(JOIN  ":" _PYTHONPATH_VALUE ${_PATHS})
        set(Python_PRE_CMD "PYTHONPATH=${_PYTHONPATH_VALUE}")

        message(STATUS "Python pre-command: ${Python_PRE_CMD}")

    endif()

endmacro()
