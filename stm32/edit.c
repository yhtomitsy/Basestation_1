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

int main(void)
{
  /* USER CODE BEGIN 1 */
	HAL_ADC_Start_DMA(&hadc1,_buffer,5);
  /* USER CODE END 1 */

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