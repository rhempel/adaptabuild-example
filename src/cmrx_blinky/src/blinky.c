#include <cmrx/application.h>
#include <cmrx/ipc/timer.h>

#include <pico/stdlib.h>

#include <boards/pico.h>

int blinky_main(void * unused)
{
    int i = 0;
    gpio_init(PICO_DEFAULT_LED_PIN);
    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);
    while (1) {
        gpio_put(PICO_DEFAULT_LED_PIN, 1);
        usleep(500000);
        gpio_put(PICO_DEFAULT_LED_PIN, 0);
        ++i;
        usleep(500000);
        ++i;
    }
    return 0;
}

OS_APPLICATION_MMIO_RANGES(cmrx_blinky, 0x40000000, 0x50000000, 0xd0000000, 0xe0000000);
OS_APPLICATION(cmrx_blinky);
OS_THREAD_CREATE(cmrx_blinky, blinky_main, NULL, 8);
