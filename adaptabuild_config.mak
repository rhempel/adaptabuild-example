# ----------------------------------------------------------------------------
# Set any of these values to 'x' to turn on that level of
# logging
#
LOG_WARNING ?= x
LOG_NOTICE ?= 
LOG_INFO ?= 
LOG_DEBUG ?=

# ----------------------------------------------------------------------------
# Controls the output of the command line that a rule executes when building
# a dependency.
#
# Set to '@' (default) to disable output
# Set to blank value to enable output
#
# WAIT - DO WE NEED TO DO THIS OR IS IT CLEANER TO USE THE --silent FLAG?
#
ECHO_COMMAND ?=

# ROOT_PATH is the path to project relative to the directory that you called
# this makefile from. The adaptabuild system need to know this so that it can
# include the files it needs.
#
ROOT_PATH := $(dir $(firstword $(MAKEFILE_LIST)))

# The adaptabuild path MUST be at the root level - unfortunately there is
# currently no obvious (to me) way to move this boilerplate into an include file.
#
ADAPTABUILD_PATH := $(ROOT_PATH)/adaptabuild

# ----------------------------------------------------------------------------
# Now that we have ADAPTABUILD_PATH set we can import the log utilities
# 
include $(ADAPTABUILD_PATH)/make/log.mak

# There can be only one top level source directory - all of the artifacts to
# be built with adaptabuild must live under this directory! 
#
# SRC_PATH is always specified relative to the ROOT_PATH. It doesn't
# really matter how complex the path is, the adaptabuild system will
# normalize it relative to the ROOT_PATH internally. 
#
# For example, if you have organized all the artifact source code under a
# directory called "src" you would write:
#
# SRC_PATH := $(ROOT_PATH)/src
#
# If the artifacts at the same level as the ROOT_PATH, the following values
# can be used and are equivalent:
#
# SRC_PATH := $(ROOT_PATH)
# SRC_PATH := $(ROOT_PATH)/
# SRC_PATH := $(ROOT_PATH)/.
#
SRC_PATH := $(ROOT_PATH)/src

# ----------------------------------------------------------------------------
# Do NOT move this include - it MUST be before the definition of MCU_MAK
#                            and after the definition of SRC_PATH
#
include $(ADAPTABUILD_PATH)/make/adaptabuild.mak
