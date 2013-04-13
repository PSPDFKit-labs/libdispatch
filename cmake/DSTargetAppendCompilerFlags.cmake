include (CMakeParseArguments)

function (DSTargetAppendCompilerFlags)
  cmake_parse_arguments(args "" "" "TARGET;FLAGS" ${ARGN})

  set (space_separated_flags " ")
  foreach (flag IN LISTS args_FLAGS)
    set (space_separated_flags "${space_separated_flags} ${flag} ")
  endforeach ()

  foreach (target IN LISTS args_TARGET)
    set_property(TARGET "${target}" APPEND_STRING
      PROPERTY COMPILE_FLAGS "${space_separated_flags}")
  endforeach ()
endfunction ()