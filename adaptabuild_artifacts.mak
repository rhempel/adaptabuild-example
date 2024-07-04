# ----------------------------------------------------------------------------
# adaptabuild_artifacts.mak - product specific libraries file
#
# Here is where you specify the libraries or other artifacts your product
# needs to have built.
# ----------------------------------------------------------------------------

ifeq (host,$(MCU))
    # Do nothing - we want the standard library for host builds
else
#    CFLAGS += -nostdinc
#    include $(SRC_PATH)/umm_libc/adaptabuild.mak
#    LIBC_INCPATH = $(umm_libc_PATH)/include
endif

include $(SRC_PATH)/third_party/umm_malloc/adaptabuild.mak
include $(SRC_PATH)/third_party/voyager-bootloader/adaptabuild.mak
include $(SRC_PATH)/third_party/nanopb/adaptabuild.mak
# include $(SRC_PATH)/CANopenNode/adaptabuild.mak

# Notes in useful generic CFLAGS
# https://stackoverflow.com/questions/3375697/what-are-the-useful-gcc-flags-for-c
#
# -Wextra and -Wall: essential.
# -Wfloat-equal: useful because usually testing floating-point numbers for equality is bad.
# -Wundef: warn if an uninitialized identifier is evaluated in an #if directive.
# -Wshadow: warn whenever a local variable shadows another local variable, parameter or global variable or whenever a built-in function is shadowed.
# -Wpointer-arith: warn if anything depends upon the size of a function or of void.
# -Wcast-align: warn whenever a pointer is cast such that the required alignment of the target is increased. For example, warn if a char * is cast to an int * on machines where integers can only be accessed at two- or four-byte boundaries.
# -Wstrict-prototypes: warn if a function is declared or defined without specifying the argument types.
# -Wstrict-overflow=5: warns about cases where the compiler optimizes based on the assumption that signed overflow does not occur. (The value 5 may be too strict, see the manual page.)
# -Wwrite-strings: give string constants the type const char[length] so that copying the address of one into a non-const char * pointer will get a warning.
# -Waggregate-return: warn if any functions that return structures or unions are defined or called.
# -Wcast-qual: warn whenever a pointer is cast to remove a type qualifier from the target type*.
# -Wswitch-default: warn whenever a switch statement does not have a default case*.
# -Wswitch-enum: warn whenever a switch statement has an index of enumerated type and lacks a case for one or more of the named codes of that enumeration*.
# -Wconversion: warn for implicit conversions that may alter a value*.
# -Wunreachable-code: warn if the compiler detects that code will never be executed*.
#
# ----------------------------------------------------------------------------
