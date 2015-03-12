set (sources
    apply.c
    benchmark.c
    init.c
    object.c
    once.c
    queue.c
    semaphore.c
    source.c
    time.c
)

if (COMPILER_HAS_BLOCKS_SUPPORT)
    list (APPEND sources
        data.c
        io.c
        transform.c
    )
    add_definitions (-fblocks)
endif ()

include_directories (
    "${dispatch_SOURCE_DIR}"
    "${dispatch_BINARY_DIR}"
    "${dispatch_SOURCE_DIR}/private"
    "${dispatch_SOURCE_DIR}/os"

    "${KQUEUE_INCLUDE_DIRS}"
    "${PTHREAD_WORKQUEUE_INCLUDE_DIRS}"
    "${BLOCKS_RUNTIME_INCLUDE_DIRS}"
)

add_definitions(
    -Wall
    -Wextra
    -Wno-unused-parameter
    -fvisibility=hidden
)

if (CMAKE_C_COMPILER_ID MATCHES "GNU")
    add_definitions(-Wno-unknown-pragmas)
endif ()

if (SUPPORTS_MOMIT_LEAF_FRAME_POINTER)
    add_definitions(-momit-leaf-frame-pointer)
endif ()

add_library(libdispatch_static STATIC ${sources})
add_library(libdispatch_shared SHARED ${sources})

foreach (target libdispatch_shared libdispatch_static)
    target_link_libraries(${target}
        ${PTHREAD_WORKQUEUE_LIBRARIES}
        ${KQUEUE_LIBRARIES}
        ${BLOCKS_RUNTIME_LIBRARIES}
        rt
        -pthread
    )
endforeach ()

set_property(TARGET libdispatch_static libdispatch_shared PROPERTY
    OUTPUT_NAME dispatch)

set_target_properties(libdispatch_shared PROPERTIES 
    SOVERSION ${DISPATCH_ABI_VERSION}
    VERSION ${DISPATCH_VERSION}
)

install(
    TARGETS libdispatch_shared libdispatch_static
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

