/*
 * cy_fcSensors.h
 *
 *  Created on: April 7, 2019
 *      Author: Auiki
 */

#ifndef CY_FCSENSORS_H_
#define CY_FCSENSORS_H_

#include <cyu3types.h>


/* Enumeration defining Stream Format used for CyCx3_ImageSensor_Set_Format */
typedef enum CyU3PSensorStreamFormat_t
{
    SENSOR_YUV2 = 0,    /* UVC YUV2 Format*/
    SENSOR_RGB565       /* RGB565 Format  */
}CyU3PSensorStreamFormat_t;


/* Initialize Image Sensor*/
CyU3PReturnStatus_t CyCx3_ImageSensor_Init(void);

/* Set Sensor to output 720p Stream */
CyU3PReturnStatus_t CyCx3_ImageSensor_Set_720p(void);

/* Set Sensor to output 1080p Stream */
CyU3PReturnStatus_t CyCx3_ImageSensor_Set_1080p(void);

/* Set Sensor to output QVGA Stream */
CyU3PReturnStatus_t CyCx3_ImageSensor_Set_Qvga(void);

/* Set Sensor to output VGA Stream */
CyU3PReturnStatus_t CyCx3_ImageSensor_Set_Vga(void);

/* Set Sensor to output 5Megapixel Stream */
CyU3PReturnStatus_t CyCx3_ImageSensor_Set_5M(void);


/* Put Image Sensor to Sleep/Low Power Mode */
CyU3PReturnStatus_t CyCx3_ImageSensor_Sleep(void);

/* Wake Image Sensor from Sleep/Low Power Mode to Active Mode */
CyU3PReturnStatus_t CyCx3_ImageSensor_Wakeup(void);

/* Set Image Sensor Data Format */
CyU3PReturnStatus_t CyCx3_ImageSensor_Set_Format(CyU3PSensorStreamFormat_t format);

/* Trigger Autofocus for the Sensor*/
CyU3PReturnStatus_t CyCx3_ImageSensor_Trigger_Autofocus(void);

// From CX3OV5640 e-con lib
// Need to replace these functions

int32_t gl32SetControl;
int16_t gl16SetControl;

#define GET_DEF 0x07
#define GET_MIN	0x02
#define GET_MAX 0x03
#define GET_CUR 0x01
#define GET_RES 0x04

//

// Camera Configuration functions
// fc prefix is a replacement version
void esOV5640_Base_Config(void);
void fc_ImageSensor_Config(void);

void esOV5640_VGA_config(void);
void esOV5640_VGA_HS_config(void);
void esOV5640_720P_config(void);
void esOV5640_1080P_config(void);
void esOV5640_5MP_config(void);
void esCamera_Power_Down(void);
void esCamera_Power_Up(void);

//Brighntess
void esOV5640_SetBrightness(int8_t Brightness);
int8_t esOV5640_GetBrightness(uint8_t option);
//Contrast
void esOV5640_SetContrast(int8_t Contrast);
int8_t esOV5640_GetContrast(uint8_t option);
//Hue
void esOV5640_SetHue(int32_t Hue);
int32_t esOV5640_GetHue(uint8_t option);
//Saturation
void esOV5640_SetSaturation(uint32_t Saturation);
int8_t esOV5640_GetSaturation(uint8_t option);
//Sharpness
void esOV5640_SetSharpness(uint8_t Sharp);
int8_t esOV5640_GetSharpness(uint8_t option);
//White Balance Manual
void esOV5640_SetWhiteBalance(uint8_t WhiteBalance);
uint8_t esOV5640_GetWhiteBalance(uint8_t option);
//White Balance Auto
void esOV5640_SetAutoWhiteBalance(uint8_t AutoWhiteBalance);
uint8_t esOV5640_GetAutoWhiteBalance(uint8_t option);
//Manual Exposure
void esOV5640_SetExposure(int32_t Exposure);
int32_t esOV5640_GetExposure(uint8_t option);
//Auto Exposure
uint8_t esOV5640_GetAutoExposure(uint8_t option);
void esOV5640_SetAutoExposure(uint8_t AutoExp);
//AutoFocus
void esOV5640_SetAutofocus(uint8_t Is_Enable);
uint8_t esOV5640_GetAutofocus(uint8_t option);
void esOV5640_Auto_Focus_Config(void);
//Manual Focus
void esOV5640_SetManualfocus(uint16_t manualfocus);
uint16_t esOV5640_GetManualfocus(uint8_t option);

//NightMode
void esOV5640_Nightmode(CyBool_t Enable,uint8_t NightMode_option);


#endif /* CY_FCSENSORS_H_ */
