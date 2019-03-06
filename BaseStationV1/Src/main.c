/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "stm32f4xx_hal.h"
#include "arm_math.h"
#include <arm_const_structs.h>


/* Private variables ---------------------------------------------------------*/
I2C_HandleTypeDef hi2c1;
UART_HandleTypeDef huart1;

//#define BLUETOOTH      // if defined output data through BT module
#define DEBUG          // if defined output debug messages on USART1
#define ACCEL_RAW      // if defined output raw accelerometer data
#define GYRO_RAW       // if defined output raw gyro data
//#define ROT_VECT       // if defined output rotation vector
//#define ACCEL_REAL     // if defined output real acceleration data


#ifdef DEBUG
 #define DEBUG_PRINT(x)     printf(x)
 #define DEBUG_PRINT_VAR(x,y)     printf(x,y)
#else
 #define DEBUG_PRINT(x)
#endif

#define ORIENTATION 1                  // (1) read orientation in Quaternions, (0) dont read quaternion data

#ifdef __GNUC__
  /* With GCC/RAISONANCE, small printf (option LD Linker->Libraries->Small printf
     set to 'Yes') calls __io_putchar() */
  #define PUTCHAR_PROTOTYPE int __io_putchar(int ch)
#else
  #define PUTCHAR_PROTOTYPE int fputc(int ch, FILE *f)
#endif /* __GNUC__ */
	
	
// IMU 
//Registers
#define CHANNEL_COMMAND 0
#define CHANNEL_EXECUTABLE 1
#define CHANNEL_CONTROL 2
#define CHANNEL_REPORTS 3
#define CHANNEL_WAKE_REPORTS 4
#define CHANNEL_GYRO 5

//All the ways we can configure or talk to the BNO080, figure 34, page 36 reference manual
//These are used for low level communication with the sensor, on channel 2
#define SHTP_REPORT_COMMAND_RESPONSE 0xF1
#define SHTP_REPORT_COMMAND_REQUEST 0xF2
#define SHTP_REPORT_FRS_READ_RESPONSE 0xF3
#define SHTP_REPORT_FRS_READ_REQUEST 0xF4
#define SHTP_REPORT_PRODUCT_ID_RESPONSE 0xF8
#define SHTP_REPORT_PRODUCT_ID_REQUEST 0xF9
#define SHTP_REPORT_BASE_TIMESTAMP 0xFB
#define SHTP_REPORT_SET_FEATURE_COMMAND 0xFD

//All the different sensors and features we can get reports from
//These are used when enabling a given sensor
#define SENSOR_REPORTID_ACCELEROMETER 0x01
#define SENSOR_REPORTID_GYROSCOPE 0x02
#define SENSOR_REPORTID_MAGNETIC_FIELD 0x03
#define SENSOR_REPORTID_LINEAR_ACCELERATION 0x04
#define SENSOR_REPORTID_ROTATION_VECTOR 0x05
#define SENSOR_REPORTID_GRAVITY 0x06
#define SENSOR_REPORTID_GAME_ROTATION_VECTOR 0x08
#define SENSOR_REPORTID_GEOMAGNETIC_ROTATION_VECTOR 0x09
#define SENSOR_REPORTID_TAP_DETECTOR 0x10
#define SENSOR_REPORTID_STEP_COUNTER 0x11
#define SENSOR_REPORTID_STABILITY_CLASSIFIER 0x13
#define SENSOR_REPORTID_PERSONAL_ACTIVITY_CLASSIFIER 0x1E

//Record IDs from figure 29, page 29 reference manual
//These are used to read the metadata for each sensor type
#define FRS_RECORDID_ACCELEROMETER 0xE302
#define FRS_RECORDID_GYROSCOPE_CALIBRATED 0xE306
#define FRS_RECORDID_MAGNETIC_FIELD_CALIBRATED 0xE309
#define FRS_RECORDID_ROTATION_VECTOR 0xE30B

//Command IDs from section 6.4, page 42
//These are used to calibrate, initialize, set orientation, tare etc the sensor
#define COMMAND_ERRORS 1
#define COMMAND_COUNTER 2
#define COMMAND_TARE 3
#define COMMAND_INITIALIZE 4
#define COMMAND_DCD 6
#define COMMAND_ME_CALIBRATE 7
#define COMMAND_DCD_PERIOD_SAVE 9
#define COMMAND_OSCILLATOR 10
#define COMMAND_CLEAR_DCD 11

#define CALIBRATE_ACCEL 0
#define CALIBRATE_GYRO 1
#define CALIBRATE_MAG 2
#define CALIBRATE_PLANAR_ACCEL 3
#define CALIBRATE_ACCEL_GYRO_MAG 4
#define CALIBRATE_STOP 5

#define MAX_PACKET_SIZE 128 //Packets can be up to 32k but we don't have that much RAM.
#define MAX_METADATA_SIZE 9 //This is in words. There can be many but we mostly only care about the first 9 (Qs, range, etc)

//Global Variables
uint8_t shtpHeader[4]; //Each packet has a header of 4 bytes
uint8_t shtpData[MAX_PACKET_SIZE];
uint8_t sequenceNumber[6] = {0, 0, 0, 0, 0, 0}; //There are 6 com channels. Each channel has its own seqnum
uint8_t commandSequenceNumber = 0; //Commands have a seqNum as well. These are inside command packet, the header uses its own seqNum per channel
uint32_t metaData[MAX_METADATA_SIZE]; //There is more than 10 words in a metadata record but

int16_t rotationVector_Q1 = 14;
int16_t accelerometer_Q1 = 8;
int16_t linear_accelerometer_Q1 = 8;
int16_t gyro_Q1 = 9;
int16_t magnetometer_Q1 = 4;

#define BNO_ADDRESS               	0x4B            				// Device address when SA0 Pin 17 = GND; 0x4B SA0 Pin 17 = VDD
#define QP(n)                       (1.0f / (1 << n))       // 1 << n ==  2^-n
#define radtodeg                    (180.0f / (22/7))


uint8_t cargo[23] = {0}; 																		// holds in coming data

// IMU data
static float quatI = {0};
static float quatJ = {0};
static float quatK = {0};
static float quatReal = {0};
static float accelX = 0;
static float accelY = 0;
static float accelZ = 0;
static float gyroX = 0;
static float gyroY = 0;
static float gyroZ = 0;
static float accelRawX = 0;
static float accelRawY = 0;
static float accelRawZ = 0;

uint8_t IMU_Data[16] = {0};
uint8_t IMU_Read_Success = 0;		
uint8_t IMU_NA_Count = 0;

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_I2C1_Init(void);
static void MX_USART1_UART_Init(void);
float qToFloat_(int16_t, uint8_t);    											// convert q point data into float
void resetIMU(void);                                        // reset the IMU
uint8_t requestProductID(void);                                 // request the product ID
uint8_t sendDataPacket(uint8_t, uint8_t);										// send data packet to IMU
uint8_t setFeature(uint8_t, uint16_t, uint32_t);						// set a feature on the IMU
uint8_t parseData(void);																				// get data from incoming packets
void initializeIMU(void);                                   // init IMU
float twosComplement(uint8_t, uint8_t, uint8_t);            // convert from twos complement to 32 bit signed intergers
void readIMUData(void);
void displayData();
uint8_t IMUAvailable(); 

// enables us to use printf function on USART1
PUTCHAR_PROTOTYPE  
{
    /* Place your implementation of fputc here */
    /* e.g. write a character to the USART */
    HAL_UART_Transmit(&huart1, (uint8_t *)&ch, 1, 100);
    return ch;
}	

int counter = 0;

int main(void)
{
  /* MCU Configuration----------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* Configure the system clock */
  SystemClock_Config();

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_I2C1_Init();
  MX_USART1_UART_Init();
	initializeIMU();         // intiailize IMU. Approx 3 seconds delay
 
  while (1)
  {
			readIMUData();
			//for debug purposes only
			displayData();
			
			//HAL_Delay(500);
  }
}

void displayData()
{	
		// Holds the string from the IMU
		uint8_t str[50]; 																						             
		memset(str, 0, sizeof(str));
		//sprintf((char*)&str[0], "%3.2f,%3.2f,%3.2f,%3.2f,%3.2f,%3.2f,%3.2f,%3.2f,%3.2f,%3.2f\n", quatReal, quatI, quatJ, quatK, accelX, accelY, accelZ, gyroX, gyroY, gyroZ);
		sprintf((char*)&str[0], "%3.2f,%3.2f,%3.2f,%3.2f,%3.2f,%3.2f\n",accelRawX, accelRawY, accelRawZ, gyroX, gyroY, gyroZ);
		DEBUG_PRINT_VAR("%s", str);
		//HAL_Delay(500);
}

/*****************************************IMU code**********************************************************/

 /**
 * @brief BNO IMU initialization.
 */
void initializeIMU()
{
		// universal variable for this function
		uint8_t reg = 0;	 
	
	  // check if IMU is connected
		IMUAvailable();
		
		// reset IMU
		resetIMU();
		
		// check ID of IMU
		while(!requestProductID())
		{
				DEBUG_PRINT("Confirming IMU ID\r\n");
				HAL_Delay(500);
		}
		HAL_Delay(200);
		
		// configure quaternion output
		#ifdef ROT_VECT
				if(setFeature(SENSOR_REPORTID_ROTATION_VECTOR, 10, 0))
				{
						DEBUG_PRINT("\nRotation vector configured\r\n");
				}
				HAL_Delay(500);
		#endif
		
		// configure linear acceleration output
		#ifdef ACCEL_REAL
				if(setFeature(SENSOR_REPORTID_LINEAR_ACCELERATION, 1, 0))
				{
						DEBUG_PRINT("\nReal acceleration configured\r\n");
				}
				HAL_Delay(500);
		#endif
				
		// configure angular acceleration output
		#ifdef GYRO_RAW
				if(setFeature(SENSOR_REPORTID_GYROSCOPE, 1, 0))
				{
						DEBUG_PRINT("\nGyroscope configured\r\n");
				}
				HAL_Delay(500);
		#endif
		
		// configure angular acceleration output
		#ifdef ACCEL_RAW
				if(setFeature(SENSOR_REPORTID_ACCELEROMETER, 1, 0))
				{
						DEBUG_PRINT("\nGyroscope configured\r\n");
				}
				HAL_Delay(500);
		#endif
}

// read IMU data through i2C port
void readIMUData()
{
		uint8_t i = 0;
		if(HAL_I2C_Master_Receive(&hi2c1, BNO_ADDRESS << 1, cargo, 23, 10) == HAL_OK)
		{
				// if read data is not correct, try reading again for 5 times
				while(!parseData()) 
				{
						HAL_I2C_Master_Receive(&hi2c1, BNO_ADDRESS << 1, cargo, 23, 10);
						i++;
						if(i > 4) break;
				}
				
				//keep track of number of times IMU does not output quaternions or linear acceleration
				//if more than 50 times, initialize IMU again
				if(IMU_NA_Count >= 50)
				{
						IMU_Read_Success = 0;
						printf("Imu not available. Initializing...\r\n");
						initializeIMU();
						IMU_NA_Count = 0;
				}
				else
				{
						IMU_Read_Success = 1;
				}
		}
		else{
				// increment counter everytime there is no IMU reading available
				IMU_NA_Count++;
				//keep track of number of times IMU does not output quaternions or linear acceleration
				//if more than 50 times, initialize IMU again
				if(IMU_NA_Count >= 50)
				{
						printf("Imu not available. Initializing...\r\n");
						IMU_Read_Success = 0;
						initializeIMU();
						IMU_NA_Count = 0;
				}
		}
}

//Unit responds with packet that contains the following:
//shtpHeader[0:3]: First, a 4 byte header
//shtpData[0:4]: Then a 5 byte timestamp of microsecond clicks since reading was taken
//shtpData[5 + 0]: Then a feature report ID (0x01 for Accel, 0x05 for Rotation Vector)
//shtpData[5 + 1]: Sequence number (See 6.5.18.2)
//shtpData[5 + 2]: Status
//shtpData[3]: Delay
//shtpData[4:5]: i/accel x/gyro x/etc
//shtpData[6:7]: j/accel y/gyro y/etc
//shtpData[8:9]: k/accel z/gyro z/etc
//shtpData[10:11]: real/gyro temp/etc
//shtpData[12:13]: Accuracy estimate
uint8_t parseData()
{  
		// calculate length of of incoming packet
		int16_t dataLength = ((uint16_t)cargo[1] << 8 | cargo[0]);
		dataLength &= ~(1 << 15); //Clear the MSbit. This bit indicates if this package is a continuation
		
		//Remove the header bytes from the data count
		dataLength -= 4; 
		
		// combine incoming bits bytes
		uint8_t status = shtpData[5 + 2] & 0x03; //Get status bits
		uint16_t data1 = (((int16_t)cargo[14] << 8) | cargo[13] );
		uint16_t data2 = (((int16_t)cargo[16] << 8) | cargo[15] );
		uint16_t data3 = (((int16_t)cargo[18] << 8) | cargo[17] );
		uint16_t data4 = 0;
		uint16_t data5 = 0;

		if (dataLength - 5 > 9)
		{
			data4 = (((int16_t)cargo[20] << 8) | cargo[19] );
		}
		if (dataLength - 5 > 11)
		{
			data5 = (((int16_t)cargo[22] << 8) | cargo[21] );
		}
		
    //Check to see if this packet is a sensor reporting quaternion data
    if((cargo[9] == SENSOR_REPORTID_ROTATION_VECTOR))
		{// && (cargo[2] == 0x03) && (cargo[4] == 0xFB)){
					
				#ifndef BLUETOOTH
						quatReal = qToFloat_(data4, rotationVector_Q1); 	 //pow(2, 14 * -1);//QP(14); 
						quatI = qToFloat_(data1, rotationVector_Q1);       //pow(2, 14 * -1);//QP(14); 
						quatJ = qToFloat_(data2, rotationVector_Q1);       //pow(2, 14 * -1);//QP(14); 
						quatK = qToFloat_(data3, rotationVector_Q1);       //pow(2, 14 * -1);//QP(14);                  // apply Q point (quats are already unity vector 	
				#else
						for(uint8_t i = 0; i < 8; i++)
						{
								IMU_Data[i] = cargo[13 + i];
								//dma_buffer[i + 72] = cargo[13 + i];
						}
				#endif
						
				IMU_NA_Count = 0;
				return 1;
		}
		//Check to see if this packet is a sensor reporting linear acceleration data
		else if(((cargo[9] == SENSOR_REPORTID_LINEAR_ACCELERATION)))
		{
							
				#ifndef BLUETOOTH
						accelX = qToFloat_(data1, linear_accelerometer_Q1); //pow(2, 14 * -1);//QP(14); 
						accelY = qToFloat_(data2, linear_accelerometer_Q1); //pow(2, 14 * -1);//QP(14); 
						accelZ = qToFloat_(data3, linear_accelerometer_Q1); //pow(2, 14 * -1);//QP(14); 
				#else
						for(uint8_t i = 0; i < 6; i++)
						{
								IMU_Data[i + 8] = cargo[13 + i];
								//dma_buffer[i + 72 + 8] = cargo[13 + i];
						}
				#endif
						
				IMU_NA_Count = 0;
				return 1;
    }
		//Check to see if this packet is a sensor reporting raw gyroscope data
		else if(((cargo[9] == SENSOR_REPORTID_GYROSCOPE)))
		{
								
				#ifndef BLUETOOTH
						gyroX = qToFloat_(data1, gyro_Q1); //pow(2, 14 * -1);//QP(14); 
						gyroY = qToFloat_(data2, gyro_Q1); //pow(2, 14 * -1);//QP(14); 
						gyroZ = qToFloat_(data3, gyro_Q1); //pow(2, 14 * -1);//QP(14); 
				#else
						for(uint8_t i = 0; i < 6; i++)
						{
								IMU_Data[i + 8] = cargo[13 + i];
								//dma_buffer[i + 72 + 8] = cargo[13 + i];
						}
				#endif
				IMU_NA_Count = 0;
				return 1;
    }
		//Check to see if this packet is a sensor reporting raw acceleration data
		else if(((cargo[9] == SENSOR_REPORTID_ACCELEROMETER)))
		{
								
				#ifndef BLUETOOTH
						accelRawX = qToFloat_(data1, accelerometer_Q1); //pow(2, 14 * -1);//QP(14); 
						accelRawY = qToFloat_(data2, accelerometer_Q1); //pow(2, 14 * -1);//QP(14); 
						accelRawZ = qToFloat_(data3, accelerometer_Q1); //pow(2, 14 * -1);//QP(14); 
				#else
						for(uint8_t i = 0; i < 6; i++)
						{
								IMU_Data[i + 8] = cargo[13 + i];
								//dma_buffer[i + 72 + 8] = cargo[13 + i];
						}
				#endif
				IMU_NA_Count = 0;
				return 1;
    }
		else
		{
				// increment counter everytime there is no IMU reading available
				IMU_NA_Count++;
				return 0;
		}
}

//Given a register value and a Q point, convert to float
//See https://en.wikipedia.org/wiki/Q_(number_format)
float qToFloat_(int16_t fixedPointValue, uint8_t qPoint)
{
		float qFloat = fixedPointValue;
		qFloat *= pow(2, (qPoint * -1));
		return (qFloat);
}

//Given a sensor's report ID, this tells the BNO080 to begin reporting the values
//Also sets the specific config word. Useful for personal activity classifier
uint8_t setFeature(uint8_t reportID, uint16_t timeBetweenReports, uint32_t specificConfig)
{
		long microsBetweenReports = (long)timeBetweenReports * 1000L;
		shtpData[4] = SHTP_REPORT_SET_FEATURE_COMMAND; //Set feature command. Reference page 55
		shtpData[5] = reportID; //Feature Report ID. 0x01 = Accelerometer, 0x05 = Rotation vector
		shtpData[6] = 0; //Feature flags
		shtpData[7] = 0; //Change sensitivity (LSB)
		shtpData[8] = 0; //Change sensitivity (MSB)
		shtpData[9] = (microsBetweenReports >> 0) & 0xFF; //Report interval (LSB) in microseconds. 0x7A120 = 500ms
		shtpData[10] = (microsBetweenReports >> 8) & 0xFF; //Report interval
		shtpData[11] = (microsBetweenReports >> 16) & 0xFF; //Report interval
		shtpData[12] = (microsBetweenReports >> 24) & 0xFF; //Report interval (MSB)
		shtpData[13] = 0; //Batch Interval (LSB)
		shtpData[14] = 0; //Batch Interval
		shtpData[15] = 0; //Batch Interval
		shtpData[16] = 0; //Batch Interval (MSB)
		shtpData[17] = (specificConfig >> 0) & 0xFF; //Sensor-specific config (LSB)
		shtpData[18] = (specificConfig >> 8) & 0xFF; //Sensor-specific config
		shtpData[19] = (specificConfig >> 16) & 0xFF; //Sensor-specific config
		shtpData[20] = (specificConfig >> 24) & 0xFF; //Sensor-specific config (MSB)

		//Transmit packet on channel 2, 17 bytes
		return sendDataPacket(CHANNEL_CONTROL, 17);
}

//Send command to reset IC
//Read all advertisement packets from sensor
//The sensor has been seen to reset twice if we attempt too much too quickly.
//This seems to work reliably.
void resetIMU()
{
		// universal variable for this function
		uint8_t zeroTrack = 0;
	
		DEBUG_PRINT("Reset IMU\r\n");
	
		shtpData[4] = 1; //Reset command
	
		//Attempt to start communication with sensor
		sendDataPacket(CHANNEL_EXECUTABLE, 1); //Transmit packet on channel 1, 1 byte
	
		// flush meta data from IMU
		while(HAL_I2C_Master_Receive(&hi2c1, BNO_ADDRESS << 1, cargo, 23, 100) == HAL_OK)
		{
			  zeroTrack = 0;
			
				// check if the packet is made up of only zeros
				// this means that the IMU has been reset successfully
				for(uint8_t j = 0; j < 23; j++)
				{
						if(cargo[j] == 0)zeroTrack++;
				}
				
				DEBUG_PRINT(".");
				if(zeroTrack == 23) break;
		}	
		DEBUG_PRINT("Reset IMU\r\n");
}

//Function that checks if IMU is connected.
//sends 0 to IMU and checks if transfer was successful
uint8_t IMUAvailable()
{
		uint8_t reg = 0;
	
		while(HAL_I2C_Master_Transmit(&hi2c1, BNO_ADDRESS << 1, &reg, 1, 100) != HAL_OK)
		{	
				DEBUG_PRINT("IMU not available\r\n");
				HAL_Delay(500);
		}
		HAL_Delay(100);
		return 1;
}

uint8_t requestProductID()
{
		//Check communication with device
		shtpData[4] = SHTP_REPORT_PRODUCT_ID_REQUEST; //Request the product ID and reset info
		shtpData[5] = 0; //Reserved

		//Transmit packet on channel 2, 2 bytes
		sendDataPacket(CHANNEL_CONTROL, 2);
		HAL_Delay(10);
		while(HAL_I2C_Master_Receive(&hi2c1, BNO_ADDRESS << 1, cargo, 23, 100) != HAL_OK)
		{
				sendDataPacket(CHANNEL_CONTROL, 2);
				HAL_Delay(10);
		}
		//for(uint8_t i = 0; i < 23; i++)printf("%d\t",cargo[i]);
		//printf("\r\n");
		if(cargo[4] == SHTP_REPORT_PRODUCT_ID_RESPONSE)
		{
				return 1;
		}
		return 0;
}

uint8_t sendDataPacket(uint8_t channelNumber, uint8_t dataLength)
{
    uint8_t packetLength = dataLength + 4; //Add four bytes for the header
    //if(packetLength > I2C_BUFFER_LENGTH) return(false); //You are trying to send too much. Break into smaller packets.

    //set the 4 byte packet header
    shtpData[0] = packetLength & 0xFF;//Set feature command. Reference page 55
		shtpData[1] = packetLength >> 8; 	//Feature Report ID. 0x01 = Accelerometer, 0x05 = Rotation vector
		shtpData[2] = channelNumber; 			//Feature flags
		shtpData[3] = sequenceNumber[channelNumber]++; //Change sensitivity (LSB)
    
		//err_code = nrf_drv_twi_tx(&m_twi_bno, BNO_ADDRESS, shtpData, packetLength, false); 
		if(HAL_I2C_Master_Transmit(&hi2c1, BNO_ADDRESS << 1, shtpData, packetLength, 100) != HAL_OK)
    {
      return (0);
    }
    return 1;
}


/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{

  RCC_OscInitTypeDef RCC_OscInitStruct;
  RCC_ClkInitTypeDef RCC_ClkInitStruct;

    /**Configure the main internal regulator output voltage 
    */
  __HAL_RCC_PWR_CLK_ENABLE();

  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

    /**Initializes the CPU, AHB and APB busses clocks 
    */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = 16;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
  RCC_OscInitStruct.PLL.PLLM = 8;
  RCC_OscInitStruct.PLL.PLLN = 168;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 4;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    _Error_Handler(__FILE__, __LINE__);
  }

    /**Initializes the CPU, AHB and APB busses clocks 
    */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_5) != HAL_OK)
  {
    _Error_Handler(__FILE__, __LINE__);
  }

    /**Configure the Systick interrupt time 
    */
  HAL_SYSTICK_Config(HAL_RCC_GetHCLKFreq()/1000);

    /**Configure the Systick 
    */
  HAL_SYSTICK_CLKSourceConfig(SYSTICK_CLKSOURCE_HCLK);

  /* SysTick_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(SysTick_IRQn, 0, 0);
}

/* I2C1 init function */
static void MX_I2C1_Init(void)
{

  hi2c1.Instance = I2C1;
  hi2c1.Init.ClockSpeed = 400000;
  hi2c1.Init.DutyCycle = I2C_DUTYCYCLE_2;
  hi2c1.Init.OwnAddress1 = 0;
  hi2c1.Init.AddressingMode = I2C_ADDRESSINGMODE_7BIT;
  hi2c1.Init.DualAddressMode = I2C_DUALADDRESS_DISABLE;
  hi2c1.Init.OwnAddress2 = 0;
  hi2c1.Init.GeneralCallMode = I2C_GENERALCALL_DISABLE;
  hi2c1.Init.NoStretchMode = I2C_NOSTRETCH_DISABLE;
  if (HAL_I2C_Init(&hi2c1) != HAL_OK)
  {
    _Error_Handler(__FILE__, __LINE__);
  }

}

/* USART1 init function */
static void MX_USART1_UART_Init(void)
{

  huart1.Instance = USART1;
  huart1.Init.BaudRate = 115200;
  huart1.Init.WordLength = UART_WORDLENGTH_8B;
  huart1.Init.StopBits = UART_STOPBITS_1;
  huart1.Init.Parity = UART_PARITY_NONE;
  huart1.Init.Mode = UART_MODE_TX_RX;
  huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart1.Init.OverSampling = UART_OVERSAMPLING_16;
  if (HAL_UART_Init(&huart1) != HAL_OK)
  {
    _Error_Handler(__FILE__, __LINE__);
  }

}

/** Configure pins as 
        * Analog 
        * Input 
        * Output
        * EVENT_OUT
        * EXTI
*/
static void MX_GPIO_Init(void)
{

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOH_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();

}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @param  file: The file name as string.
  * @param  line: The line in file as a number.
  * @retval None
  */
void _Error_Handler(char *file, int line)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  while(1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t* file, uint32_t line)
{ 
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     tex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */

/**
  * @}
  */

/**
  * @}
  */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
