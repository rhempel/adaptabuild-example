# ----------------------------------------------------------------------------
# adaptabuild_product.mak - product specific include file
#
# Here is where you specify your product options
# ----------------------------------------------------------------------------

PRODUCT_LIST := baz bar nanopb_poc blinky
PRODUCT_LIST += foo 

ifneq ($(filter $(PRODUCT),$(PRODUCT_LIST)),)
else
  $(error PRODUCT must be one of $(PRODUCT_LIST))
endif

# NOTE: We probably need a BOOTLOADER_MAIN unless bootloader is a separate product

PRODUCT_MAIN := $(PRODUCT)/src/main

