cmake_minimum_required(VERSION 3.20)
project(recast_native LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(PYBIND11_FINDPYTHON ON)
find_package(Python COMPONENTS Interpreter Development.Module REQUIRED)
find_package(pybind11 CONFIG REQUIRED)

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(RECASTNAVIGATION_ENABLE_ASSERTS 0)
set(RECASTNAVIGATION_DT_POLYREF64 0)
set(RECASTNAVIGATION_DT_VIRTUAL_QUERYFILTER 0)
include(GNUInstallDirs)
set(SOVERSION 1)
set(LIB_VERSION 1.6.0)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../third_party/recastnavigation/Recast
                 ${CMAKE_CURRENT_BINARY_DIR}/recast EXCLUDE_FROM_ALL)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../third_party/recastnavigation/Detour
                 ${CMAKE_CURRENT_BINARY_DIR}/detour EXCLUDE_FROM_ALL)

pybind11_add_module(recast_native src/recast_native.cpp
    ../third_party/recastnavigation/RecastDemo/Source/PartitionedMesh.cpp)
target_include_directories(recast_native PRIVATE
    ../third_party/recastnavigation/RecastDemo/Include)
target_link_libraries(recast_native PRIVATE RecastNavigation::Recast RecastNavigation::Detour)

if(MSVC)
    target_compile_definitions(recast_native PRIVATE _CRT_SECURE_NO_WARNINGS)
    target_compile_options(recast_native PRIVATE /W4 /EHsc /wd4458)
else()
    target_compile_options(recast_native PRIVATE -Wall -Wextra -Wpedantic)
endif()
