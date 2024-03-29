# ----------------------------------------------------------------------------
# adaptabuild_product.mak - product specific include file
#
# Here is where you specify your product options
# ----------------------------------------------------------------------------

PRODUCT_LIST := baz bar
PRODUCT_LIST += foo 

ifneq ($(filter $(PRODUCT),$(PRODUCT_LIST)),)
else
  $(error PRODUCT must be one of $(PRODUCT_LIST))
endif
