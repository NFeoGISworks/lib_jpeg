################################################################################
# Project:  Lib JPEG
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nexgis.com
################################################################################
# Copyright (C) 2015, NextGIS <info@nextgis.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

function(check_version major minor)

    file(READ ${CMAKE_CURRENT_SOURCE_DIR}/jpeglib.h _jpeglib_h_contents)
    string(REGEX MATCH "JPEG_LIB_VERSION_MAJOR[ \t]+([0-9]+)"
      JPEG_LIB_VERSION_MAJOR ${_jpeglib_h_contents})
    string (REGEX MATCH "([0-9]+)"
      JPEG_LIB_VERSION_MAJOR ${JPEG_LIB_VERSION_MAJOR})
    string(REGEX MATCH "JPEG_LIB_VERSION_MINOR[ \t]+([0-9]+)"
      JPEG_LIB_VERSION_MINOR ${_jpeglib_h_contents})
    string (REGEX MATCH "([0-9]+)"
      JPEG_LIB_VERSION_MINOR ${JPEG_LIB_VERSION_MINOR})

    set(${major} ${JPEG_LIB_VERSION_MAJOR} PARENT_SCOPE)
    set(${minor} ${JPEG_LIB_VERSION_MINOR} PARENT_SCOPE)

    # Store version string in file for installer needs
    file(TIMESTAMP ${CMAKE_CURRENT_SOURCE_DIR}/jpeglib.h VERSION_DATETIME "%Y-%m-%d %H:%M:%S" UTC)
    set(VERSION ${JPEG_LIB_VERSION_MAJOR}.${JPEG_LIB_VERSION_MINOR})
    get_cpack_filename(${VERSION} PROJECT_CPACK_FILENAME)
    file(WRITE ${CMAKE_BINARY_DIR}/version.str "${VERSION}\n${VERSION_DATETIME}\n${PROJECT_CPACK_FILENAME}")

endfunction(check_version)


function(report_version name ver)

    string(ASCII 27 Esc)
    set(BoldYellow  "${Esc}[1;33m")
    set(ColourReset "${Esc}[m")

    message("${BoldYellow}${name} version ${ver}${ColourReset}")

endfunction()


function(get_cpack_filename ver name)
    get_compiler_version(COMPILER)
    if(BUILD_STATIC_LIBS)
        set(STATIC_PREFIX "static-")
    endif()

    set(${name} ${PROJECT_NAME}-${STATIC_PREFIX}${ver}-${COMPILER} PARENT_SCOPE)
endfunction()

function(get_compiler_version ver)
    ## Limit compiler version to 2 or 1 digits
    string(REPLACE "." ";" VERSION_LIST ${CMAKE_C_COMPILER_VERSION})
    list(LENGTH VERSION_LIST VERSION_LIST_LEN)
    if(VERSION_LIST_LEN GREATER 2 OR VERSION_LIST_LEN EQUAL 2)
        list(GET VERSION_LIST 0 COMPILER_VERSION_MAJOR)
        list(GET VERSION_LIST 1 COMPILER_VERSION_MINOR)
        set(COMPILER ${CMAKE_C_COMPILER_ID}-${COMPILER_VERSION_MAJOR}.${COMPILER_VERSION_MINOR})
    else()
        set(COMPILER ${CMAKE_C_COMPILER_ID}-${CMAKE_C_COMPILER_VERSION})
    endif()

    if(WIN32)
        if(CMAKE_CL_64)
            set(COMPILER "${COMPILER}-64bit")
        endif()
    endif()

    set(${ver} ${COMPILER} PARENT_SCOPE)
endfunction()
