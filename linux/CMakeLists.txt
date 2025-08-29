# The minimum version of CMake that can be used.
cmake_minimum_required(VERSION 3.10)

# The name of the executable created for the application.
set(BINARY_NAME "eth_hunter")

# The name of the project.
project(${BINARY_NAME} LANGUAGES CXX)

# The C++ standard to use.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.28)

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
      STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Profile" "Release")
  endif()
endif()
# Define settings for the Profile build mode.
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Compilation settings that should be applied to most targets.
# This function is now defined to match what plugins like bitsdojo_window expect.
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

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# System-level dependencies.
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

# Application build.
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply standard settings to the main executable.
apply_standard_settings(${BINARY_NAME})

# Add support for GStreamer if the video_player plugin is used.
if (video_player_gstreamer_INCLUDE_DIRS)
  target_include_directories(${BINARY_NAME} PRIVATE
    ${video_player_gstreamer_INCLUDE_DIRS}
  )
  target_link_libraries(${BINARY_NAME} PRIVATE
    ${video_player_gstreamer_LIBRARIES}
  )
endif()

# Add dependency libraries and include directories.
target_link_libraries(${BINARY_NAME} PRIVATE
  flutter
  PkgConfig::GTK
)

# Flutter best practices.
target_compile_definitions(${BINARY_NAME} PRIVATE
  "FLUTTER_VERSION=\"${FLUTTER_VERSION}\""
  "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}"
  "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}"
  "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}"
  "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}"
)

# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)

# === Installation ===
# By default, "make install" will copy the executable to "install/linux", the
# data files to "install/linux/data", and the shared libraries to
# "install/linux/lib".
set(INSTALL_DIR "install/linux")
install(TARGETS ${BINARY_NAME} DESTINATION "${INSTALL_DIR}")

set(INSTALL_LIB_DIR "${INSTALL_DIR}/lib")
install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_LIB_DIR}")

if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}" DESTINATION "${INSTALL_LIB_DIR}")
endif()

# Copy the native assets provided by the build.dart from all packages.
set(NATIVE_ASSETS_DIR "${PROJECT_BUILD_DIR}native_assets/linux/")
install(DIRECTORY "${NATIVE_ASSETS_DIR}"
   DESTINATION "${INSTALL_LIB_DIR}"
   COMPONENT Runtime)

set(INSTALL_DATA_DIR "${INSTALL_DIR}/data")
install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_DATA_DIR}")

# Fully re-copy the assets directory on each build to avoid having stale files
# from a previous install.
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURse \"${INSTALL_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${INSTALL_DATA_DIR}")

# Install the AOT library on non-Debug builds only.
install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_DATA_DIR}"
  CONFIGURATIONS Profile;Release)