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
  protocol.defs
  provider.d
  data_internal.h
  internal.h
  io_internal.h
  object_internal.h
  queue_internal.h
  semaphore_internal.h
  shims.h
  source_internal.h
  trace.h
  shims/atomic.h
  shims/getprogname.h
  shims/hw_config.h
  shims/malloc_zone.h
  shims/perfmon.h
  shims/queue.h
  shims/strlcpy.h
  shims/time.h
  shims/tsd.h
)

if (HAVE_BLOCKS)
  list (APPEND sources
    data.c
    data_additions.c
    io.c
    io_additions.c
    transform.c
  )
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


set (cflags
  -Wall
  -Wextra
  -Wno-unused-parameter
  ${VISIBILITY_FLAGS}
  ${OMIT_LEAF_FP_FLAGS}
  ${CBLOCKS_FLAGS}
)

if (HAVE_DARWIN_LD)
  list (APPEND linker_flags 
    "-Wl,-compatibility_version,1"
    "-Wl,-current_version,${dispatch_VERSION}"
    "-Wl,-dead_strip"
  )
endif ()

if (USE_OBJC)
  list (APPEND sources object.m)
  set_property(SOURCE object.m APPEND_STRING PROPERTY COMPILE_FLAGS "-fobjc-gc")
  
  list (APPEND linker_flags
    -Wl,-upward-lobjc
    -Wl,-upward-lauto
    -Wl,-order_file,${dispatch_SOURCE_DIR}/xcodeconfig/libdispatch.order
    -Wl,-alias_list,${dispatch_SOURCE_DIR}/xcodeconfig/libdispatch.aliases
    -Wl,-unexported_symbols_list,${dispatch_SOURCE_DIR}/xcodeconfig/libdispatch.unexport
  )
endif ()


# if (USE_MIG)
#   set (BUILD_SOURCES
#     protocolUser.c
#     protocol.h
#     protocolServer.c
#     protocolServer.h
#   )
#
#   %User.c %.h %Server.c %Server.h: ${abs_srcdir}/%.defs
#     ${MIG} -user $*User.c -header $*.h
#         -server $*Server.c -sheader $*Server.h $<
# endif ()

add_library(libdispatch_static STATIC ${sources})
add_library(libdispatch_shared SHARED ${sources})

DSTargetAppendCompilerFlags(TARGET libdispatch_static libdispatch_shared
  FLAGS ${cflags})

DSTargetAppendLinkerFlags(TARGET libdispatch_static libdispatch_shared
  FLAGS ${linker_flags})

foreach (target libdispatch_shared libdispatch_static)
  target_link_libraries(${target}
    ${CMAKE_THREAD_LIBS_INIT}
    ${PTHREAD_WORKQUEUE_LIBRARIES}
    ${KQUEUE_LIBRARIES}
    ${BLOCKS_RUNTIME_LIBRARIES}
    ${CLOCK_GETTIME_LIBRARIES}
  )
endforeach ()

set_property(TARGET libdispatch_static libdispatch_shared PROPERTY
  OUTPUT_NAME dispatch)

set_target_properties(libdispatch_shared PROPERTIES 
  SOVERSION 0
  VERSION ${dispatch_VERSION}
)
