
#include "Arduino.h"
#include <esp_wifi_types.h>
//#include "freertos/FreeRTOS.h"
#include "esp_wifi.h"
#include "esp_system.h"
#include "esp_event.h"
#include "esp_event_loop.h"
#include "nvs_flash.h"
#include "driver/gpio.h"
#include <string>


#define LED_PIN 5

esp_err_t event_handler(void *ctx, system_event_t *event)
{
	return ESP_OK;
}


void setup() {


	pinMode(LED_PIN, OUTPUT);
	digitalWrite(LED_PIN, LOW);

	nvs_flash_init();
	tcpip_adapter_init();
	ESP_ERROR_CHECK( esp_event_loop_init(event_handler, NULL) );
	wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
	ESP_ERROR_CHECK( esp_wifi_init(&cfg) );
	ESP_ERROR_CHECK( esp_wifi_set_storage(WIFI_STORAGE_RAM) );
	ESP_ERROR_CHECK( esp_wifi_set_mode(WIFI_MODE_STA) );
	wifi_config_t sta_config;
	sta_config.ap.authmode = WIFI_AUTH_WPA2_PSK;
	sta_config.ap.channel = 0;

	sta_config.ap.ssid[0] = 'E';
	sta_config.ap.ssid[1] = 'S';
	sta_config.ap.ssid[2] = 'P';
	sta_config.ap.ssid[3] = '3';
	sta_config.ap.ssid[4] = '2';
	sta_config.ap.ssid[5] = 'A';
	sta_config.ap.ssid[6] = 'P';
	sta_config.ap.ssid[7] = '0';
	sta_config.ap.ssid_len = 7;

	sta_config.ap.password[0] = 'f';
	sta_config.ap.password[1] = 'o';
	sta_config.ap.password[2] = 'r';
	sta_config.ap.password[3] = 't';
	sta_config.ap.password[4] = 'i';
	sta_config.ap.password[5] = 's';
	sta_config.ap.password[6] = 's';
	sta_config.ap.password[7] = '1';
	sta_config.ap.password[8] = '2';
	sta_config.ap.password[9] = '3';
	sta_config.ap.password[10] = 0;


	sta_config.ap.ssid_hidden = 0;
	sta_config.ap.max_connection = 1;
	sta_config.ap.beacon_interval = 100;
	ESP_ERROR_CHECK( esp_wifi_set_config(WIFI_IF_STA, &sta_config) );
	ESP_ERROR_CHECK( esp_wifi_start() );
	ESP_ERROR_CHECK( esp_wifi_connect() );

	gpio_set_direction(GPIO_NUM_13, GPIO_MODE_OUTPUT);
}

void loop() {

	for (int i = 0; i < 2; i++) {
		digitalWrite(LED_PIN, HIGH);
		delay(1000);
		digitalWrite(LED_PIN, LOW);
		delay(1000);
	}

	//vTaskDelay(300 / portTICK_PERIOD_MS);

}