# ----------------------------------------------------------------------------
# Do NOT move these functions - they must live in the top level makefile
#
ABS_PATH := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
$(call log_info,ABS_PATH is $(ABS_PATH))

ROOT_PATH := $(patsubst %/,%,$(dir $(firstword $(MAKEFILE_LIST))))
$(call log_info,ROOT_PATH is $(ROOT_PATH))

# The adaptabuild path MUST be at the root level
#
ADAPTABUILD_PATH := $(ROOT_PATH)/adaptabuild

LOG_ERROR ?=
LOG_WARNING ?=
LOG_NOTICE ?=
LOG_INFO ?=
LOG_DEBUG ?=

include $(ADAPTABUILD_PATH)/make/adaptabuild.mak
