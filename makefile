# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Move these functions to a prefix file, but be careful because MAKEFILE_LIST
# will be one deeper than you think!

ABS_PATH := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
$(info ABS_PATH is $(ABS_PATH))

ROOT_PATH := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
$(info ROOT_PATH is $(ROOT_PATH))

ADAPTABUILD_PATH := $(ROOT_PATH)/adaptabuild

MKPATH := mkdir -p

# Note the use of = (not :=) to defer evaluation until it is called
# make_current_makefile_path = $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
#
# Note also that for this conditional to work, $(ROOT_PATH) must be defined before
# the conditional is evaluated

ifeq (.,$(ROOT_PATH))
  make_current_module_path = $(patsubst $(SRC_PATH)/%/,%,$(dir $(lastword $(MAKEFILE_LIST))))
else
  make_current_module_path = $(patsubst $(ROOT_PATH)/$(SRC_PATH)/%/,%,$(dir $(lastword $(MAKEFILE_LIST))))
endif

# ----------------------------------------------------------------------------

PRODUCT_LIST := foo bar
PRODUCT_LIST += baz

ifneq ($(filter $(PRODUCT),$(PRODUCT_LIST)),)
else
  $(error PRODUCT must be one of $(PRODUCT_LIST))
endif

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

MCU_MAK :=

CDEFS :=
CFLAGS :=
LDFLAGS :=
DEPFLAGS :=

MODULE_LIBS :=

TESTABLE_MODULES :=

include $(ADAPTABUILD_PATH)/make/mcu/validate_mcu.mak
$(info MCU is $(MCU))

SRC_PATH   := src
$(info SRC_PATH is $(SRC_PATH))

BUILD_PATH := build/$(PRODUCT)/$(MCU)
$(info BUILD_PATH is $(BUILD_PATH))

ARTIFACTS_PATH := artifacts/$(PRODUCT)/$(MCU)
$(info ARTIFACTS_PATH is $(BUILD_PATH))

# ----------------------------------------------------------------------------

.SUFFIXES :

.PHONY : all clean

all: $(ROOT_PATH)/$(BUILD_PATH)/product/$(PRODUCT)/$(PRODUCT)

# ----------------------------------------------------------------------------

ifeq (host,$(MCU))
    # Do nothing - we want the standard library for host builds
else
#    $(info CFLAGS is $(CFLAGS))
#    CFLAGS += -nostdinc
#    $(info CFLAGS is $(CFLAGS))
#
    include $(SRC_PATH)/umm_libc/adaptabuild.mak
#    LIBC_INCPATH = $(umm_libc_PATH)/include
endif

include $(SRC_PATH)/umm_malloc/adaptabuild.mak
include $(SRC_PATH)/voyager-bootloader/adaptabuild.mak

include $(SRC_PATH)/product/$(PRODUCT)/adaptabuild.mak

MCU_MAK := $(addprefix $(ROOT_PATH)/$(SRC_PATH)/,$(MCU_MAK))

include $(MCU_MAK)

# ----------------------------------------------------------------------------
# Default target for now:
#
# LDSCRIPT should be names based on the project and target cpu
#
# Simplify to path to the product source and product_main and executable

LDSCRIPT = $(SRC_PATH)/product/$(PRODUCT)/config/$(MCU)/linker_script.ld

$(ROOT_PATH)/$(BUILD_PATH)/product/$(PRODUCT)/$(PRODUCT): LDFLAGS +=  -T$(LDSCRIPT)
$(ROOT_PATH)/$(BUILD_PATH)/product/$(PRODUCT)/$(PRODUCT): $(MODULE_LIBS) $(LDSCRIPT)
	$(LD) -o $@ $(SYSTEM_STARTUP_OBJ) < \
	            $(ROOT_PATH)/$(BUILD_PATH)/product/$(PRODUCT)/src/$(PRODUCT)_main.o \
              --start-group $(MODULE_LIBS) --end-group $(LDFLAGS) \
              -Map=$@.map

# SYSTEM_MAIN_OBJ := $(ROOT_PATH)/$(BUILD_PATH)/$(MODULE_PATH)/main.o

# ----------------------------------------------------------------------------
# Set up for unit testing of a specific module

$(info TEST_MODULE is $(TEST_MODULE))
$(info TESTABLE_MODULES is $(TESTABLE_MODULES))

ifeq (unittest,$(MAKECMDGOALS))
    ifneq ($(filter $(TEST_MODULE),$(TESTABLE_MODULES)),)
    else
      $(error TEST_MODULE must be one of $(TESTABLE_MODULES))
    endif
endif

# LD_LIBRARIES := -Wl,-whole-archive build/foo/unittest/umm_malloc/umm_malloc.a
# LD_LIBRARIES += -Wl,-no-whole-archive -lstdc++ -lCppUTest -lCppUTestExt -lgcov

#$(MODULE_TEST_LIBS)

# Find a way to change to a directory and make all subsequent calls
# relative to that location

$(info ROOT_PATH/BUILD_PATH/TEST_MODULE is $(ROOT_PATH)/$(BUILD_PATH)/$(TEST_MODULE))

TEST_MODULE_LIB := $(ROOT_PATH)/$(BUILD_PATH)/$(TEST_MODULE)/$(TEST_MODULE).a

$(info TEST_MODULE_LIB is $(TEST_MODULE_LIB))

unittest: $(ROOT_PATH)/$(BUILD_PATH)/$(TEST_MODULE)/$(TEST_MODULE)_unittest $(TEST_MODULE_LIB) artifacts_foo

# TODO: Consider moving some of the library requirements to the module level test defines

# $(ROOT_PATH)/$(BUILD_PATH)/$(TEST_MODULE)/unittest: $(MODULE_LIBS)  -lstdc++ -lgcov --copy-dt-needed-entries
$(ROOT_PATH)/$(BUILD_PATH)/$(TEST_MODULE)/$(TEST_MODULE)_unittest:
$(ROOT_PATH)/$(BUILD_PATH)/$(TEST_MODULE)/$(TEST_MODULE)_unittest: LDFLAGS := $(TEST_MODULE_LIB) $(LDFLAGS) -lCppUTest -lCppUTestExt -lm -lgcov
$(ROOT_PATH)/$(BUILD_PATH)/$(TEST_MODULE)/$(TEST_MODULE)_unittest: $(TEST_MODULE_LIB)
	$(LD) -o $@ \
         $(LDFLAGS)

artifacts_foo:
  # Create the artifacts folder
	mkdir -p $(ARTIFACTS_PATH)/$(TEST_MODULE)

  # Create a baseline for code coverage
	cd $(ARTIFACTS_PATH)/$(TEST_MODULE) && \
    lcov -z -d --rc lcov_branch_coverage=1 $(ABS_PATH)/$(BUILD_PATH)/$(TEST_MODULE)/src

  # Run the test suite
	cd $(ARTIFACTS_PATH)/$(TEST_MODULE) && \
    $(ABS_PATH)/$(BUILD_PATH)/$(TEST_MODULE)/$(TEST_MODULE)_unittest -k $(TEST_MODULE) -ojunit

  # Create the test report
	cd $(ARTIFACTS_PATH)/$(TEST_MODULE) && \
    junit2html --merge $(TEST_MODULE).xml *.xml && \
	  junit2html $(TEST_MODULE).xml $(TEST_MODULE).html && \
	  rm $(TEST_MODULE).xml

  # Update the incremental code coverage
	cd $(ARTIFACTS_PATH)/$(TEST_MODULE) && \
    lcov -c -d --rc lcov_branch_coverage=1 $(ABS_PATH)/$(BUILD_PATH)/$(TEST_MODULE)/src -o $(TEST_MODULE).info

  # Create the code coverage report
	cd $(ARTIFACTS_PATH)/$(TEST_MODULE) && \
    genhtml --rc genhtml_branch_coverage=1 *.info


# $(BUILD_PATH)/umm_malloc/unittest/umm_malloc_test
#	mkdir -p artifacts/umm_malloc
#    # Create a baseline for code coverage
#	- cd artifacts/umm_malloc && \
#      lcov -z -d ../../$(BUILD_PATH)/umm_malloc/src
#    # Run the test suite
#	- cd artifacts/umm_malloc && \
#	  ../../$(BUILD_PATH)/umm_malloc/unittest/umm_malloc_test -k umm_malloc -ojunit
#    # Create the test report
#	- cd artifacts/umm_malloc && \
#	  junit2html --merge cpputest_umm_malloc.xml *.xml && \
#	  junit2html cpputest_umm_malloc.xml umm_malloc.html && \
#	  rm cpputest_umm_malloc.xml

#    # Update the incremental code coverage
#	- cd artifacts/umm_malloc && \
#      lcov -c -d ../../$(BUILD_PATH)/umm_malloc/src -o umm_malloc.info
#    # Create the code coverage report
#	- cd artifacts/umm_malloc && \
#      genhtml *.info

# $(BUILD_PATH)/umm_malloc/unittest/umm_malloc_test: $(MODULE_LIBS)
#	@echo Building $@ from $<
#	$(LD) -o $@ $(LD_LIBRARIES)

#./umm_malloc_test -ojunit
#junit2html cpputest_FirstTestGroup.xml
#gcov -j main test
#lcov -c -i -d . -o main.info
#lcov -c  -d . -o main_test.info
#lcov -a main.info -a main_test.info -o total.info
#genhtml *.info

# ----------------------------------------------------------------------------
# .PHONY targets that provide some eye candy for the make log

#clean:
#	rm -rf build/$(PRODUCT)
#	rm -rf artifacts/$(PRODUCT)

#begin:
#	@echo
#	@echo $(MSG_BEGIN)
	
#finished:
#	@echo $(MSG_ERRORS_NONE)

#end:
#	@echo $(MSG_END)
#	@echo
	
#gccversion :
#	@$(CC) --version
