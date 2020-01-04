# CMake's built-in Android support requires 3.7.0
if(CMAKE_SYSTEM_NAME MATCHES "Android")
    cmake_minimum_required(VERSION 3.7.2)
else()
    cmake_minimum_required(VERSION 3.0.2)
endif()

project (DSFML)

option(STATIC_SFML "Build CSFML expecting static SFML libs" ON)

set(CMAKE_BUILD_TYPE Release)

#we want to make sure we're linking to static crt libs
#Stolen from stack overflow
if(MSVC)
# We statically link to reduce dependencies
foreach(flag_var CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)
    if(${flag_var} MATCHES "/MD")
        string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
    endif(${flag_var} MATCHES "/MD")
    if(${flag_var} MATCHES "/MDd")
        string(REGEX REPLACE "/MDd" "/MTd" ${flag_var} "${${flag_var}}")
    endif(${flag_var} MATCHES "/MDd")
endforeach(flag_var)
endif(MSVC)


#DSFML should work for all patch versions
set(VERSION_MAJOR 2)
set(VERSION_MINOR 5)

if(STATIC_SFML)
    add_definitions(-DSFML_STATIC)
endif(STATIC_SFML)

# Build SFML and CSFML
add_subdirectory(SFML)
add_subdirectory(CSFML)
