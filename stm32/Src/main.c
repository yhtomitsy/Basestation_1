/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @DEV      : Ratchaphon Khaemphukhieo KMTIL R&D 17/03/2019
  *
  * <h2><center>&copy; Copyright (c) 2019 STMicroelectronics.
  * All rights reserved.</center></h2>
  *
  * This software component is licensed by ST under BSD 3-Clause license,
  * the "License"; You may not use this file except in compliance with the
  * License. You may obtain a copy of the License at:
  *                        opensource.org/licenses/BSD-3-Clause
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "stdio.h"
#include "string.h"
#include <stdlib.h>

/* Private variables ---------------------------------------------------------*/
ADC_HandleTypeDef hadc1;
DMA_HandleTypeDef hdma_adc1;

UART_HandleTypeDef huart1;
DMA_HandleTypeDef hdma_usart1_tx;
DMA_HandleTypeDef hdma_usart1_rx;

/* USER CODE BEGIN PV */
/* Private variables ---------------------------------------------------------*/
uint32_t _ADC_PA0,_ADC_PA1,_ADC_PA2,_ADC_PA3,_ADC_PA4;  // variables for analog sensor
uint32_t _buffer[5]; // buffer for DMA analog sensor
int32_t txFrame[10]; // buffer for protocol
char UART[21]; // buffer for test state using UART TX
char buff[7];  // buffer for test state using UART RX
char PWM_Buffer0[4]; // buffer for control PWM motor 00 state using UART RX
char PWM_Buffer1[4]; // buffer for control PWM motor 01 state using UART RX
uint8_t PWM_Control0 = 0; // variables PWM for motor 00
uint8_t PWM_Control1 = 0; // variables PWM for motor 01

/* USER CODE BEGIN STATE */

/* USER CODE BEGIN STATE */
uint8_t MAIN_STATE = 0;
uint8_t READ_STATE = 0;
uint8_t ADC_STATE = 0;
uint8_t I2C_MUX_STATE = 0;
uint8_t CONTROL_STATE = 0;
enum _MAIN_STATE { _IDLE, _READ, _CONTROL, _SENT };
enum _READ_STATE { _I2C_MUX, _ADC };
enum _I2C_MUX_STATE { _I2C_TOUCH0, _I2C_TOUCH1, _I2C_TOUCH2, _I2C_TOUCH3, _I2C_TOUCH4 };
enum _Format_Frame_STATE { _Format_Frame };
enum _CONTROL_STATE { _I2C_Haptic0, _I2C_Haptic1 };
/* USER CODE END STATE */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_DMA_Init(void);
static void MX_ADC1_Init(void);
static void MX_USART1_UART_Init(void);
void _IDLE_CHECK_Func(void);
void _READ_STATE_Func(void);
void _I2C_MUX_STATE_func(void);
void _Format_Frame_STATE_Func(void);
void _CONTROL_STATE_Func(void);
void _SENT_Func(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN DMA ADC */
void HAL_ADC_ConvCpltCallback(ADC_HandleTypeDef* hadc)
{
	for(int i=0;i<5;i++)
	{
		switch(i) 
		{
			case 0 : _ADC_PA0 = _buffer[i]; break;
			case 1 : _ADC_PA1 = _buffer[i]; break;
			case 2 : _ADC_PA2 = _buffer[i]; break;
			case 3 : _ADC_PA3 = _buffer[i]; break;
			case 4 : _ADC_PA4 = _buffer[i]; break;
		}
	}
}
/* USER CODE END DMA ADC */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_DMA_Init();
  MX_ADC1_Init();
  MX_USART1_UART_Init();
  /* USER CODE BEGIN 2 */
	HAL_ADC_Start_DMA(&hadc1,_buffer,5);
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
			/* MAIN_STATE */
			switch(MAIN_STATE) 
			{
				case _IDLE : _IDLE_CHECK_Func(); break;
				case _READ : _READ_STATE_Func(); MAIN_STATE = _SENT; break;
				case _CONTROL : _CONTROL_STATE_Func(); MAIN_STATE = _IDLE; break;
				case _SENT : _SENT_Func(); MAIN_STATE = _IDLE; break;
				default : MAIN_STATE = _IDLE;	
			}
			
			
  }
  /* USER CODE END 3 */
}

void _SENT_Func(void)
{
				for(int i=0;i<sizeof(txFrame)/sizeof(txFrame[0]);i++)
				{
					sprintf(UART,"txFrame[%d] = %d\r\n",i,txFrame[i]);
					HAL_UART_Transmit(&huart1,(uint8_t *)UART,sizeof(UART),sizeof(UART)/sizeof(UART[0]));
					for(int i=0;i<sizeof(UART)/sizeof(UART[0]);i++) UART[i] = 0;
				}
}

void _IDLE_CHECK_Func(void)
{
	memset( buff, 0, 7 );
	HAL_UART_Receive(&huart1, (uint8_t *)buff, 7, 10 );
	if(buff[0]=='r')
	{
		sprintf(UART,"RX = %s\r\n",buff);
		HAL_UART_Transmit(&huart1,(uint8_t *)UART,sizeof(UART),sizeof(UART)/sizeof(UART[0]));
		for(int i=0;i<sizeof(UART)/sizeof(UART[0]);i++) UART[i] = 0;
		MAIN_STATE = _READ;
	}
	else if(buff[0]=='c')
	{
		PWM_Buffer0[0] = buff[1];
		PWM_Buffer0[1] = buff[2];
		PWM_Buffer0[2] = buff[3];
		PWM_Buffer1[0] = buff[4];
		PWM_Buffer1[1] = buff[5];
		PWM_Buffer1[2] = buff[6];
		PWM_Control0 = atoi(PWM_Buffer0);
		PWM_Control1 = atoi(PWM_Buffer1);
		sprintf(UART,"RX = %s\r\n",buff);
		HAL_UART_Transmit(&huart1,(uint8_t *)UART,sizeof(UART),sizeof(UART)/sizeof(UART[0]));
		for(int i=0;i<sizeof(UART)/sizeof(UART[0]);i++) UART[i] = 0;
		MAIN_STATE = _CONTROL;
	}
	else MAIN_STATE = _IDLE;
}

void _READ_STATE_Func(void)
{
		switch(READ_STATE) 
		{
			case _ADC : 
			{
				txFrame[0] = _ADC_PA0;
				txFrame[1] = _ADC_PA1;
				txFrame[2] = _ADC_PA2;
				txFrame[3] = _ADC_PA3;
				txFrame[4] = _ADC_PA4;
				READ_STATE = _I2C_MUX;	
			}
			case _I2C_MUX : 
			{
				_I2C_MUX_STATE_func();
				READ_STATE = _ADC;
				break;
			}
			default : READ_STATE = _ADC;	
		}
}

void _I2C_MUX_STATE_func(void)
{
		switch(I2C_MUX_STATE) 
		{
			case _I2C_TOUCH0 : 
			{
				txFrame[5] = 0;
				I2C_MUX_STATE = _I2C_TOUCH1;
			}
			case _I2C_TOUCH1 : 
			{
				txFrame[6] = 0;
				I2C_MUX_STATE = _I2C_TOUCH2;
			}
			case _I2C_TOUCH2 : 
			{
				txFrame[7] = 0;
				I2C_MUX_STATE = _I2C_TOUCH3;
			}
			case _I2C_TOUCH3 : 
			{
				txFrame[8] = 0;
				I2C_MUX_STATE = _I2C_TOUCH4;
			}
			case _I2C_TOUCH4 : 
			{
				txFrame[9] = 0;
				I2C_MUX_STATE = _I2C_TOUCH0;
				break;
			}
			default : I2C_MUX_STATE = _I2C_TOUCH0;	
		}
}

void _Format_Frame_STATE_Func(void)
{
   // Create Protocol
}

void _CONTROL_STATE_Func(void)
{
		switch(CONTROL_STATE) 
		{
			case _I2C_TOUCH0 : 
			{
				//PWM_Control0 (0 - 100%)
				sprintf(UART,"PWM_Control0 = %d\r\n",PWM_Control0);
				HAL_UART_Transmit(&huart1,(uint8_t *)UART,sizeof(UART),sizeof(UART)/sizeof(UART[0]));
				for(int i=0;i<sizeof(UART)/sizeof(UART[0]);i++) UART[i] = 0;
				I2C_MUX_STATE = _I2C_Haptic1;
			}
			case _I2C_TOUCH1 : 
			{
				//PWM_Control1 (0 - 100%)
				sprintf(UART,"PWM_Control1 = %d\r\n",PWM_Control1);
				HAL_UART_Transmit(&huart1,(uint8_t *)UART,sizeof(UART),sizeof(UART)/sizeof(UART[0]));
				for(int i=0;i<sizeof(UART)/sizeof(UART[0]);i++) UART[i] = 0;
				I2C_MUX_STATE = _I2C_Haptic0;
				break;
			}
		}
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage 
  */
  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);
  /** Initializes the CPU, AHB and APB busses clocks 
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
  RCC_OscInitStruct.PLL.PLLM = 8;
  RCC_OscInitStruct.PLL.PLLN = 168;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 4;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }
  /** Initializes the CPU, AHB and APB busses clocks 
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_5) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief ADC1 Initialization Function
  * @param None
  * @retval None
  */
static void MX_ADC1_Init(void)
{

  /* USER CODE BEGIN ADC1_Init 0 */

  /* USER CODE END ADC1_Init 0 */

  ADC_ChannelConfTypeDef sConfig = {0};

  /* USER CODE BEGIN ADC1_Init 1 */

  /* USER CODE END ADC1_Init 1 */
  /** Configure the global features of the ADC (Clock, Resolution, Data Alignment and number of conversion) 
  */
  hadc1.Instance = ADC1;
  hadc1.Init.ClockPrescaler = ADC_CLOCK_SYNC_PCLK_DIV4;
  hadc1.Init.Resolution = ADC_RESOLUTION_12B;
  hadc1.Init.ScanConvMode = ENABLE;
  hadc1.Init.ContinuousConvMode = ENABLE;
  hadc1.Init.DiscontinuousConvMode = DISABLE;
  hadc1.Init.ExternalTrigConvEdge = ADC_EXTERNALTRIGCONVEDGE_NONE;
  hadc1.Init.ExternalTrigConv = ADC_SOFTWARE_START;
  hadc1.Init.DataAlign = ADC_DATAALIGN_RIGHT;
  hadc1.Init.NbrOfConversion = 5;
  hadc1.Init.DMAContinuousRequests = ENABLE;
  hadc1.Init.EOCSelection = ADC_EOC_SINGLE_CONV;
  if (HAL_ADC_Init(&hadc1) != HAL_OK)
  {
    Error_Handler();
  }
  /** Configure for the selected ADC regular channel its corresponding rank in the sequencer and its sample time. 
  */
  sConfig.Channel = ADC_CHANNEL_0;
  sConfig.Rank = 1;
  sConfig.SamplingTime = ADC_SAMPLETIME_3CYCLES;
  if (HAL_ADC_ConfigChannel(&hadc1, &sConfig) != HAL_OK)
  {
    Error_Handler();
  }
  /** Configure for the selected ADC regular channel its corresponding rank in the sequencer and its sample time. 
  */
  sConfig.Channel = ADC_CHANNEL_1;
  sConfig.Rank = 2;
  if (HAL_ADC_ConfigChannel(&hadc1, &sConfig) != HAL_OK)
  {
    Error_Handler();
  }
  /** Configure for the selected ADC regular channel its corresponding rank in the sequencer and its sample time. 
  */
  sConfig.Channel = ADC_CHANNEL_2;
  sConfig.Rank = 3;
  if (HAL_ADC_ConfigChannel(&hadc1, &sConfig) != HAL_OK)
  {
    Error_Handler();
  }
  /** Configure for the selected ADC regular channel its corresponding rank in the sequencer and its sample time. 
  */
  sConfig.Channel = ADC_CHANNEL_3;
  sConfig.Rank = 4;
  if (HAL_ADC_ConfigChannel(&hadc1, &sConfig) != HAL_OK)
  {
    Error_Handler();
  }
  /** Configure for the selected ADC regular channel its corresponding rank in the sequencer and its sample time. 
  */
  sConfig.Channel = ADC_CHANNEL_4;
  sConfig.Rank = 5;
  if (HAL_ADC_ConfigChannel(&hadc1, &sConfig) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN ADC1_Init 2 */

  /* USER CODE END ADC1_Init 2 */

}

/**
  * @brief USART1 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART1_UART_Init(void)
{

  /* USER CODE BEGIN USART1_Init 0 */

  /* USER CODE END USART1_Init 0 */

  /* USER CODE BEGIN USART1_Init 1 */

  /* USER CODE END USART1_Init 1 */
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
    Error_Handler();
  }
  /* USER CODE BEGIN USART1_Init 2 */

  /* USER CODE END USART1_Init 2 */

}

/** 
  * Enable DMA controller clock
  */
static void MX_DMA_Init(void) 
{
  /* DMA controller clock enable */
  __HAL_RCC_DMA2_CLK_ENABLE();

  /* DMA interrupt init */
  /* DMA2_Stream0_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA2_Stream0_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA2_Stream0_IRQn);
  /* DMA2_Stream2_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA2_Stream2_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA2_Stream2_IRQn);
  /* DMA2_Stream7_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA2_Stream7_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA2_Stream7_IRQn);

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOH_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, GPIO_PIN_RESET);

  /*Configure GPIO pin : PA6 */
  GPIO_InitStruct.Pin = GPIO_PIN_6;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */

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
void assert_failed(uint8_t *file, uint32_t line)
{ 
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     tex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
