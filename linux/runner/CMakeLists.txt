# The minimum version of CMake that can be used.
cmake_minimum_required(VERSION 3.10)

# The name of the project.
project(runner LANGUAGES CXX)

# The C++ standard to use.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.28)

# Compilation settings that should be applied to most targets.
function(apply_standard_settings TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE
    -Wall
    -Werror
  )
  # Disable exceptions.
  target_compile_options(${TARGET} PRIVATE -fno-exceptions)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  # Add _DEBUG definition for debug builds.
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "my_application.h"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.h"
)

apply_standard_settings(${BINARY_NAME})

target_include_directories(${BINARY_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"
)

target_link_libraries(${BINARY_NAME} PRIVATE
  flutter
  PkgConfig::GTK
)