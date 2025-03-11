#include <cmrx/application.h>
//#include <pico/stdlib.h>
#include <cmrx/ipc/timer.h>

char data[128];

int i = 0;

int dummy_main(void * unused)
{
//    gpio_init(PICO_DEFAULT_LED_PIN);
//    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);
    while (1) {
//        gpio_put(PICO_DEFAULT_LED_PIN, 1);
        usleep(500000*5);
//        gpio_put(PICO_DEFAULT_LED_PIN, 0);
        ++i;
        usleep(500000);
        ++i;
    }
    return 0;
}

OS_APPLICATION_MMIO_RANGES(dummy, 0x40000000, 0x50000000, 0xd0000000, 0xe0000000);

//OS_APPLICATION_MMIO_RANGES(dummy, 0, 0, 0, 0);
OS_APPLICATION(dummy);
OS_THREAD_CREATE(dummy, dummy_main, NULL, 8);
