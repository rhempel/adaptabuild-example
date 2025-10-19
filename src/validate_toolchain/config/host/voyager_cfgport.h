/*
 * PRODUCT and MCU specific configuration for voyager-bootloader
 *
 * Refer to voyager-bootloader/inc/voyager_cfg.h file for details
 * on how to maintain this file.
 */

#ifndef _VOYAGER_CFGPORT_H
#define _VOYAGER_CFGPORT_H

/* ----------------------------------------------------------------------------
 * NOTE WELL: For the command line -D options to take highest priority, your
 *            project level override file must check that the
 *            VOYAGER_BOOTLOADER_xxx value is not already defined before
 *            overriding the value.
 *
 * Unless otherwise noted, the default state of these values is #undef-ined!
 * ----------------------------------------------------------------------------
 */

#ifndef VOYAGER_BOOTLOADER_MAX_RECEIVE_PACKET_SIZE
    #define VOYAGER_BOOTLOADER_MAX_RECEIVE_PACKET_SIZE (64)
#endif

#endif /* _VOYAGER_CFGPORT_H */
