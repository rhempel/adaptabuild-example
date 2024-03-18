#include "voyager.h"

void __libc_init_array(void) {};

voyager_error_E voyager_bootloader_send_to_host(void const *const data, size_t len)
{
    return VOYAGER_ERROR_NONE;    
}

voyager_error_E voyager_bootloader_nvm_write(const voyager_nvm_key_E key, voyager_bootloader_nvm_data_t const *const data)
{
    return VOYAGER_ERROR_NONE;
}

extern char OTA_IMAGE_START;
extern char OTA_IMAGE_END;

struct application_space_t {
    uint32_t app_start_address;
    uint32_t app_end_address;
} application_space = {
    .app_start_address = (uint32_t)&OTA_IMAGE_START,
    .app_end_address = (uint32_t)&OTA_IMAGE_END,
};

struct application_info_t {
    uint32_t app_crc;
    uint32_t app_size;
} application_info = {
    .app_crc = 0xcccc,
    .app_size = 0x1111,
};


voyager_error_E voyager_bootloader_nvm_read(const voyager_nvm_key_E key, voyager_bootloader_nvm_data_t *const data)
{
    voyager_error_E error = VOYAGER_ERROR_NONE;
    switch (key)
    {
        case VOYAGER_NVM_KEY_APP_CRC:
            data->app_crc = application_info.app_crc;
            break;
        case VOYAGER_NVM_KEY_APP_SIZE:
            data->app_size = application_info.app_size;
            break;
        case VOYAGER_NVM_KEY_APP_START_ADDRESS:
            data->app_start_address = application_space.app_start_address;
            break;
        case VOYAGER_NVM_KEY_APP_END_ADDRESS:
            data->app_end_address = application_space.app_end_address;
            break;
        default:
            error = VOYAGER_ERROR_INVALID_ARGUMENT;
            break;
    }

    return error;
}

voyager_error_E voyager_bootloader_hal_erase_flash(const voyager_bootloader_addr_size_t start_address,
                                                   const voyager_bootloader_addr_size_t end_address)
{
    return VOYAGER_ERROR_NONE;
}

voyager_error_E voyager_bootloader_hal_write_flash(const voyager_bootloader_addr_size_t address, void const *const data,
                                                   size_t const length)
{
    return VOYAGER_ERROR_NONE;
}

voyager_error_E voyager_bootloader_hal_read_flash(const voyager_bootloader_addr_size_t address, void *const data,
                                                  size_t const length)
{
    return VOYAGER_ERROR_NONE;
}

voyager_error_E voyager_bootloader_hal_jump_to_app(const voyager_bootloader_addr_size_t app_start_address)
{
    return VOYAGER_ERROR_NONE;
}

const voyager_bootloader_config_t voyager_bootloader_config = {
    .jump_to_app_after_dfu_recv_complete = false,
    .custom_crc_stream = NULL,
};

int main(void)
{
  voyager_bootloader_init(&voyager_bootloader_config);

  // For this application, we unlock DFU mode instantly
  voyager_bootloader_request(VOYAGER_REQUEST_ENTER_DFU);

  /* Infinite loop */
  while (1)
  {
    voyager_bootloader_run();
  }
}