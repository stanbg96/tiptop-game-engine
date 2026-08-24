cmake_minimum_required(VERSION 3.18.1)
project("tiptop_game_engine")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/ffi_exports
)

add_library(
    tiptop_game_engine
    SHARED
    ffi_exports/engine_api.cpp
)

find_library(log-lib log)
find_library(android-lib android)

target_link_libraries(
    tiptop_game_engine
    ${log-lib}
    ${android-lib}
)
