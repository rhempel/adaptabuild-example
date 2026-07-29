#include <cmrx/application.h>
#include <cmrx/ipc/timer.h>

#include "blinky_conf.h"

int blinky_off_main(void * unused)
{
    int i = 0;
    while (1) {
        usleep(505000);
        HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_RESET );
    }
    return 0;
}

OS_APPLICATION_MMIO_RANGES(cmrx_blinky_off, 0x40000000, 0x50000000, 0xd0000000, 0xe0000000);
OS_APPLICATION(cmrx_blinky_off);
OS_THREAD_CREATE(cmrx_blinky_off, blinky_off_main, NULL, 8);
