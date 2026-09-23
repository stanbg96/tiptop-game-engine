cmake_minimum_required(VERSION 3.10.2)
project(tiptop_game_engine)

set(CMAKE_CXX_STANDARD 17)

include_directories(include)

add_library(tiptop_game_engine SHARED
    src/tiptop_engine.cpp
    ffi_exports/engine_api.cpp
)

find_library(log-lib log)
target_link_libraries(tiptop_game_engine ${log-lib})
