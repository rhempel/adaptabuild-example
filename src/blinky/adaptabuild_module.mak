# ----------------------------------------------------------------------------
# blinky makefile for adaptabuild
#
# This is designed to be included as part of a make system designed
# to be expandable and maintainable using techniques found in:
#
# Managing Projects with GNU Make - Robert Mecklenburg - ISBN 0-596-00610-1
# ----------------------------------------------------------------------------

MODULE := blinky

MODULE_PATH := $(call make_current_module_path)
# $(info MODULE_PATH is $(MODULE_PATH))

$(MODULE)_PATH := $(MODULE_PATH)
# $(info $(MODULE)_PATH is $($(MODULE)_PATH))

# ----------------------------------------------------------------------------
# Source file lists go here, C dependencies are automatically generated
# by the compiler using the -m option
#
# You can set up a common source path late in the file
#
# Note that each module gets its own, privately scoped variable for building
# ----------------------------------------------------------------------------

# We need both else a previous definition is used :-) Can we make this an include?

SRC_C :=
SRC_ASM :=
SRC_TEST :=

SRC_C += src/main.c
SRC_C += src/blinky_main.c

SRC_TEST +=

# ----------------------------------------------------------------------------
# Set up the module level include path

$(MODULE)_INCPATH :=
$(MODULE)_INCPATH += $(PRODUCT)/config/$(MCU)
$(MODULE)_INCPATH += $(cmrx_PATH)/include
$(MODULE)_INCPATH += $(cmrx_PATH)/src/os/arch/arm/cmsis
$(MODULE)_INCPATH += $(cmsis_core_PATH)/Include

# ----------------------------------------------------------------------------
# NOTE: The default config file must be created somehow - it is normally
#       up to the developer to specify which defines are needed and how they
#       are to be configured.
#
# By convention we place config files in $(PRODUCT)/config/$(MCU) because
# that's an easy pace to leave things like HAL config, linker scripts etc

$(MODULE)_INCPATH += $(PRODUCT)/config/$(MCU)

# ----------------------------------------------------------------------------
ifeq (unittest,$(MAKECMDGOALS))
endif

# ----------------------------------------------------------------------------
# Set any module level compile time defaults here
#
# CMSIS_DEVICE_INCLUDE should be a product level CDEF?
# CONFIG_SOC_MAX32690 should be a product level CDEF?

$(MODULE)_CDEFS :=

$(MODULE)_CFLAGS :=
$(MODULE)_CFLAGS +=

ifeq ($(MCU),pico2040)
    SRC_C += config/pico2040/quirks/pico-sdk/cmrx_isrs.c
    SRC_ASM += config/pico2040/quirks/pico-sdk/crt0.S
endif

$(MODULE)_INCPATH += $(MCU_INCPATH) 
$(MODULE)_CDEFS += $(MCU_CDEFS)

ifeq (unittest,$(MAKECMDGOALS))
endif

# ----------------------------------------------------------------------------
# Include the adaptabuild library makefile - must be done for each module!

include $(ADAPTABUILD_PATH)/make/library.mak

# ----------------------------------------------------------------------------
# Include the unit test framework makefile that works for this module
# if the target is unittest

ifeq (unittest,$(MAKECMDGOALS))
# TESTABLE_MODULES += $(MODULE)
# $(MODULE)_test_main = $(MODULE)/test/main.o
# include $(ADAPTABUILD_PATH)/make/test/cpputest.mak
endif

# ----------------------------------------------------------------------------
# Update the generated CMRX linker scripts with information about where to
# find our libraries
#
pre_executable::
	$(call log_warning,blinky pre_executable)
	$(CMRX_GENLINK_CMSIS) --add-application $(BUILD_PATH)/$($(MODULE)_PATH)/$(MODULE).a blinky $(CUSTOM_LINKER_SCRIPT_PATH)

# ----------------------------------------------------------------------------
