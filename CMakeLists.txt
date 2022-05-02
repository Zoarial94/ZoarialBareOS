cmake_minimum_required(VERSION 3.16...3.21)

if(${CMAKE_VERSION} VERSION_LESS 3.12)
    cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_SYSTEM_NAME ZoarialBareOS)
set(CMAKE_SYSTEM_PROCESSOR i686)

set(tools /home/hwhite/opt/cross/bin)
set(CMAKE_C_COMPILER ${tools}/i686-elf-gcc)
set(CMAKE_CXX_COMPILER ${tools}/i686-elf-g++)
set(CMAKE_ASM-ATT_COMPILER ${tools}/i686-elf-gcc)

set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

project(ZoarialBareOS VERSION 0.0.1
				      DESCRIPTION "An x86 bare OS"
					  HOMEPAGE_URL "https://github.com/Zoarial94/ZoarialBareOS"
					  LANGUAGES C CXX ASM)

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}" CACHE FILEPATH "Path to a compiler launcher program, e.g. ccache")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}" CACHE FILEPATH "Path to a compiler launcher program, e.g. ccache")
endif()

set(OS_ARCH i686 CACHE STRING "ZoarialBareOS architecture")

add_compile_options(-Wall)
add_compile_options(-Wextra)

# The following warnings are sorted by the "base" name (the part excluding the initial Wno or W).
add_compile_options(-Wno-address-of-packed-member)
add_compile_options(-Wcast-qual)
#add_compile_options(-Wdeprecated-copy)
add_compile_options(-Wduplicated-cond)
add_compile_options(-Wno-expansion-to-defined)
add_compile_options(-Wformat=2)
add_compile_options(-Wimplicit-fallthrough)
add_compile_options(-Wlogical-op)
add_compile_options(-Wmisleading-indentation)
#add_compile_options(-Wmissing-declarations)
#add_compile_options(-Wnon-virtual-dtor)
#add_compile_options(-Wno-unknown-warning-option)
add_compile_options(-Wundef)
add_compile_options(-Wunused)
#add_compile_options(-Wno-unused-private-field)
add_compile_options(-Wno-unused-const-variable)
#add_compile_options(-Wno-unused-command-line-argument)
add_compile_options(-Wwrite-strings)
add_compile_options(-Wno-maybe-uninitialized)

add_compile_options(-fdiagnostics-color=always)
add_compile_options(-fno-delete-null-pointer-checks)
add_compile_options(-fno-exceptions)
add_compile_options(-fno-semantic-interposition)
#add_compile_options(-fsized-deallocation)
add_compile_options(-fstack-clash-protection)
add_compile_options(-fstack-protector-strong)
add_compile_options(-g1)

add_compile_options(-O3)
add_compile_options(-Werror)
add_compile_options(-Wpedantic)
add_compile_options(-D__is_kernel)
add_compile_options(-D__is_libk)
add_compile_options(-D__is_libc=0)
add_compile_options(-ffreestanding)
add_compile_options(-fstack-protector)

include_directories(.)
include_directories(./include)
include_directories(./include/libc)

add_subdirectory(kernel)

add_custom_target(run 
    COMMAND "${ZoarialBareOS_SOURCE_DIR}/Meta/run-image-libvirt.fish"
    DEPENDS image
)

add_custom_target(image
    DEPENDS grub-image 
)

add_custom_target(grub-image
    COMMAND "${ZoarialBareOS_SOURCE_DIR}/Meta/build-image-grub.fish"
    DEPENDS kernel
    USES_TERMINAL
)

#add_dependencies(grub-image kernel)