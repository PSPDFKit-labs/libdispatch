include (FindPackageHandleStandardArgs)
include (CheckFunctionExists)

find_path(BLOCKS_RUNTIME_PUBLIC_INCLUDE_DIR Block.h)
find_path(BLOCKS_RUNTIME_PRIVATE_INCLUDE_DIR Block_private.h)

check_function_exists(BLOCKS_RUNTIME_IN_LIBC _Block_copy)

if (BLOCKS_RUNTIME_IN_LIBC)
  set (BLOCKS_RUNTIME_LIBRARIES " ")
else ()
  find_library(BLOCKS_RUNTIME_LIBRARIES "BlocksRuntime")
endif ()

find_package_handle_standard_args(BlocksRuntime DEFAULT_MSG
  BLOCKS_RUNTIME_LIBRARIES
  BLOCKS_RUNTIME_PUBLIC_INCLUDE_DIR
  BLOCKS_RUNTIME_PRIVATE_INCLUDE_DIR
)

set(BLOCKS_RUNTIME_INCLUDE_DIRS 
  "${BLOCKS_RUNTIME_PUBLIC_INCLUDE_DIR}"
  "${BLOCKS_RUNTIME_PRIVATE_INCLUDE_DIR}"
)
