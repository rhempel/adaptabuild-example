#include <extra/systick.h>
#include <cmrx/cmrx.h>
#include <RTE_Components.h>
#include CMSIS_device_header

#include "blinky_conf.h"

long timing_get_current_cpu_freq(void)
{
    return SystemCoreClock;
}
 
int main(void)
{
   timing_provider_setup(1);

#if (MCU_FAMILY == stm32g4xx)
   HAL_Init();

   __HAL_RCC_GPIOA_CLK_ENABLE();

   GPIO_InitTypeDef gpio_init = {0};
   
   gpio_init.Pin = GPIO_PIN_5;
   gpio_init.Mode = GPIO_MODE_OUTPUT_PP;
   gpio_init.Pull = GPIO_NOPULL;
   gpio_init.Speed = GPIO_SPEED_FREQ_MEDIUM;

   HAL_GPIO_Init(GPIOA, &gpio_init);
#endif

   os_start();
   return 0;
}
