set (bsdtests_sources
  bsdtests.c
  bsdtests.h
  dispatch_test.c
  dispatch_test.h
  shims.h
  shims/asprintf.c
  shims/asprintf.h
  shims/arc4random.c
  shims/arc4random.h
  shims/fgetln.c
  shims/fgetln.h
)

set (check_PROGRAMS
  bsdtestharness
  bsdtestsummarize
  ${TESTS}
)

set (TESTS
  dispatch_apply
  dispatch_api
  dispatch_c99
  dispatch_debug
  dispatch_queue_finalizer
  dispatch_group
  dispatch_overcommit
  dispatch_pingpong
  dispatch_plusplus
  dispatch_priority
  dispatch_priority2
  dispatch_concur
  dispatch_context_for_key
  dispatch_proc
  dispatch_read
  dispatch_read2
  dispatch_after
  dispatch_timer
  dispatch_timer_short
  dispatch_timer_timeout
  dispatch_sema
  dispatch_suspend_timer
  dispatch_timer_bit31
  dispatch_timer_bit63
  dispatch_timer_set_time
  dispatch_starfish
  dispatch_cascade
  dispatch_drift
  dispatch_readsync
  dispatch_data
  dispatch_io
  dispatch_io_net
  dispatch_vm
  dispatch_vnode
  dispatch_select
)

if (HAVE_MACH)
  list (APPEND TESTS dispatch_deadname)
endif ()

set (dispatch_c99_CFLAGS ${AM_CFLAGS} -set(std c99))
set (dispatch_plusplus_SOURCES dispatch_plusplus.cpp)
set (dispatch_priority2_SOURCES dispatch_priority.c)
set (dispatch_priority2_CPPFLAGS ${AM_CPPFLAGS} -set(DUSE_SET_TARGET_QUEUE 1))

set (AM_CPPFLAGS -I${dispatch_BINARY_DIR} -I${dispatch_SOURCE_DIR})

set (AM_CFLAGS -Wall ${MARCH_FLAGS} ${CBLOCKS_FLAGS} ${KQUEUE_CFLAGS})
set (AM_OBJCFLAGS -Wall ${MARCH_FLAGS} ${CBLOCKS_FLAGS} -fobjc-gc)
set (AM_CXXFLAGS -Wall ${MARCH_FLAGS} ${CXXBLOCKS_FLAGS})

set (LDADD libbsdtests.la ../src/libdispatch.la)
set (libbsdtests_la_LDFLAGS -avoid-version)

set (TESTS_ENVIRONMENT ./bsdtestharness)
set (DISTCLEAN bench.cc)

if (HAVE_COREFOUNDATION)
  list (APPEND TESTS
    dispatch_cf_main
    dispatch_transform
    dispatch_sync_on_main
    cffd
  )

  set(dispatch_cf_main_LDFLAGS -framework CoreFoundation)
  set(dispatch_transform_LDFLAGS -framework CoreFoundation -framework Security)
  set(dispatch_sync_on_main_LDFLAGS -framework CoreFoundation)
  set(cffd_LDFLAGS -framework CoreFoundation)
endif ()

if (HAVE_FOUNDATION)
  list (APPEND TESTS
    dispatch_sync_gc
    dispatch_apply_gc
    nsoperation
    bench
  )

  set(dispatch_sync_gc_SOURCES dispatch_sync_gc.m)
  set(dispatch_sync_gc_LDFLAGS -framework Foundation)
  set(dispatch_apply_gc_SOURCES dispatch_apply_gc.m)
  set(dispatch_apply_gc_LDFLAGS -framework Foundation)
  set(nsoperation_SOURCES nsoperation.m)
  set(nsoperation_LDFLAGS -framework Foundation)
  set(nodist_bench_SOURCES bench.cc)
  set(bench_SOURCES func.c)
  set(bench_LDFLAGS -framework Foundation)
endif ()
