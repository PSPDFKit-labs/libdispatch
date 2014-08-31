include (CheckFunctionExists)
include (CheckIncludeFile)
include (CheckLibraryExists)
include (CheckSymbolExists)
include (CMakeParseArguments)

function (dispatch_check_decls)
    cmake_parse_arguments(args "REQUIRED" "" "INCLUDES" ${ARGN})

    foreach (decl IN LISTS args_UNPARSED_ARGUMENTS)
        string (REGEX REPLACE "[^a-zA-Z0-9_]" "_" var "${decl}")
        string(TOUPPER "${var}" var)
        set(var "HAVE_DECL_${var}")
        check_symbol_exists("${decl}" "${args_INCLUDES}" "${var}")

        if (args_REQUIRED AND NOT ${var})
            unset("${var}" CACHE)
            message(FATAL_ERROR "Could not find symbol ${decl}")
        endif ()
    endforeach ()
endfunction ()


function (dispatch_check_funcs)
    cmake_parse_arguments(args "REQUIRED" "" "" ${ARGN})

    foreach (function IN LISTS args_UNPARSED_ARGUMENTS)
        string (REGEX REPLACE "[^a-zA-Z0-9_]" "_" var "${function}")
        string(TOUPPER "${var}" var)
        set(var "HAVE_${var}")
        check_function_exists("${function}" "${var}")

        if (args_REQUIRED AND NOT ${var})
            unset("${var}" CACHE)
            message(FATAL_ERROR "Could not find function ${function}")
        endif ()
    endforeach ()
endfunction ()


function (dispatch_check_headers)
    cmake_parse_arguments(args "REQUIRED" "" "" ${ARGN})

    foreach (header IN LISTS args_UNPARSED_ARGUMENTS)
        string (REGEX REPLACE "[^a-zA-Z0-9_]" "_" var "${header}")
        string(TOUPPER "${var}" var)
        set(var "HAVE_${var}")
        check_include_file("${header}" "${var}")

        if (args_REQUIRED AND NOT ${var})
            unset("${var}" CACHE)
            message(FATAL_ERROR "Could not find header ${header}")
        endif ()
    endforeach ()
endfunction ()


function (dispatch_search_libs function)
    cmake_parse_arguments(args "REQUIRED" "" "LIBRARIES" ${ARGN})

    set (have_function_variable_name "HAVE_${function}")
    string(TOUPPER "${have_function_variable_name}" have_function_variable_name)

    set (function_libraries_variable_name "${function}_LIBRARIES")
    string(TOUPPER "${function_libraries_variable_name}"
        function_libraries_variable_name)

    if (DEFINED ${have_function_variable_name})
        return ()
    endif ()

    # First, check without linking anything in particular.
    check_function_exists("${function}" "${have_function_variable_name}")
    if (${have_function_variable_name})
        # No extra libs needed
        set (${function_libraries_variable_name} "" CACHE INTERNAL "Libraries for ${function}")
        return ()
    else ()
        unset (${have_function_variable_name} CACHE)
    endif ()

    foreach (lib IN LISTS args_LIBRARIES)
        check_library_exists("${lib}" "${function}" "" "${have_function_variable_name}")
        if (${have_function_variable_name})
            set (${function_libraries_variable_name} "${lib}" CACHE INTERNAL "Libraries for ${function}")
            return ()
        else ()
            unset (${have_function_variable_name} CACHE)
        endif ()
    endforeach ()

    if (args_REQUIRED)
        message(FATAL_ERROR "Could not find ${function} in any of: " ${args_LIBRARIES})
    endif ()

    set (${function_libraries_variable_name} "" CACHE INTERNAL "Libraries for ${function}")
    set (${have_function_variable_name} NO CACHE INTERNAL "Have function ${function}")
endfunction ()


