cmake_minimum_required(VERSION 3.10.2)

project(tiptop_game_engine LANGUAGES C CXX)

# Използване на модерен C++17 стандарт
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Включване на заглавните C++ файлове
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/../cpp_engine/include
)

# Дефиниране на споделената библиотека (.so)
add_library(
    tiptop_game_engine
    SHARED
    ${CMAKE_CURRENT_SOURCE_DIR}/../cpp_engine/src/tiptop_engine.cpp
)

# Системни библиотеки на Android (Log & Native API)
find_library(log-lib log)
find_library(android-lib android)

# Свързване на библиотеките
target_link_libraries(
    tiptop_game_engine
    ${log-lib}
    ${android-lib}
)
