/*
 ## source file : CX3_FaceCam.c
 ## ===========================
 ##
 ##  Copyright E-Con Systems, 2013-2014,
 ##  All Rights Reserved
 ##  UNPUBLISHED, LICENSED SOFTWARE.
 ##
 ##  CONFIDENTIAL AND PROPRIETARY INFORMATION
 ##  PROPERTY OF ECON SYSTEMS

 ## www.e-consystems.com
 ##
 ##
 ## ===========================
*/

#include "cyu3system.h"
#include "cyu3os.h"
#include "cyu3dma.h"
#include "cyu3error.h"
#include "cyu3usb.h"
#include "cyu3i2c.h"
#include "cyu3uart.h"
#include "cyu3gpio.h"
#include "cyu3utils.h"
#include "cyu3pib.h"
#include "cyu3socket.h"
#include "sock_regs.h"
#include "cyu3mipicsi.h"

#include "cy_fcSensors.h"
#include "CX3_FaceCam.h"

/* Event generated on Timer overflow*/
#define ES_TIMER_RESET_EVENT		(1<<4)

/* Event generated on a USB Suspend Request*/
#define ES_USB_SUSP_EVENT_FLAG		(1<<5)

/* Firmware version*/
#define MajorVersion 				1
#define MinorVersion 				3
#define SubVersion					133
#define SubVersion1					309
#define RESET_TIMER_ENABLE 1

#ifdef RESET_TIMER_ENABLE
#define TIMER_PERIOD	(500)

static CyU3PTimer        UvcTimer;

static void UvcAppProgressTimer (uint32_t arg)
{
    /* This frame has taken too long to complete.
     * Abort it, so that the next frame can be started. */
    CyU3PEventSet(&glTimerEvent, ES_TIMER_RESET_EVENT,CYU3P_EVENT_OR);
}
#endif

volatile int32_t glDMATxCount = 0;          /* Counter used to count the Dma Transfers */
volatile int32_t glDmaDone = 0;
volatile uint8_t glActiveSocket = 0;
volatile CyBool_t doLpmDisable = CyTrue;	/* Flag used to Enable/Disable low USB 3.0 LPM */
CyBool_t glHitFV = CyFalse;             	/* Flag used for state of FV signal. */
CyBool_t glMipiActive = CyFalse;        	/* Flag set to true when Mipi interface is active. Used for Suspend/Resume. */
CyBool_t glIsClearFeature = CyFalse;    	/* Flag to signal when AppStop is called from the ClearFeature request. Need to Reset Toggle*/
CyBool_t glPreviewStarted = CyFalse;		/* Flag to support Mac os */

/* UVC Header */
uint8_t glUVCHeader[ES_UVC_HEADER_LENGTH] =
{
    0x0C,                           /* Header Length */
    0x8C,                           /* Bit field header field */
    0x00,0x00,0x00,0x00,            /* Presentation time stamp field */
    0x00,0x00,0x00,0x00,0x00,0x00   /* Source clock reference field */
};

/* Video Probe Commit Control */
uint8_t glCommitCtrl[ES_UVC_MAX_PROBE_SETTING_ALIGNED];
uint8_t glCurrentFrameIndex = 1;
uint8_t glStillCommitCtrl[ES_UVC_MAX_STILL_PROBE_SETTING_ALIGNED];
uint8_t glCurrentStillFrameIndex = 1;
uint8_t glStillTriggerCtrl = 0;
uint8_t glFrameIndexToSet = 0;
CyBool_t glStillCaptureStart = CyFalse;
CyBool_t glStillCaptured = CyFalse;
uint8_t glStillSkip = 0;

CyBool_t glIsApplnActive = CyFalse;             /* Whether the Mipi->USB application is active or not. */
CyBool_t glIsConfigured = CyFalse;              /* Whether Application is in configured state or not */
CyBool_t glIsStreamingStarted = CyFalse;        /* Whether streaming has started - Used for MAC OS support*/

/* DMA Channel */
CyU3PDmaMultiChannel glChHandleUVCStream;       /* DMA Channel Handle for UVC Stream  */
uint16_t ES_UVC_STREAM_BUF_SIZE=0;
uint16_t ES_UVC_DATA_BUF_SIZE=0;
uint8_t ES_UVC_STREAM_BUF_COUNT=0;

uint8_t g_IsAutoFocus=1;						/* Check the AutoFocus is Enabled or not*/

/* USB control request processing variables*/
#if 1

uint8_t glGet_Info = 0;
int16_t gl8GetControl = 0;
int16_t gl8SetControl = 0;
int16_t gl16GetControl = 0;

int32_t gl32GetControl = 0;

#endif

uint8_t glcommitcount=0,glcheckframe=1;

/* Application critical error handler */
    void
esUVCAppErrorHandler (
        CyU3PReturnStatus_t status        /* API return status */
        )
{
    /* Application failed with the error code status */

    /* Add custom debug or recovery actions here */

    /* Loop indefinitely */
    for (;;)
    {
        /* Thread sleep : 100 ms */
        CyU3PThreadSleep (100);
    }
}


/* UVC header addition function */
    static void
esUVCUvcAddHeader (
        uint8_t *buffer_p,      /* Buffer pointer */
        uint8_t frameInd        /* EOF or normal frame indication */
        )
{
    /* Copy header to buffer */
    CyU3PMemCopy (buffer_p, (uint8_t *)glUVCHeader, ES_UVC_HEADER_LENGTH);

    /* Check if last packet of the frame. */
    if (frameInd == ES_UVC_HEADER_EOF)
    {
        /* Modify UVC header to toggle Frame ID */
        glUVCHeader[1] ^= ES_UVC_HEADER_FRAME_ID;

        /* Indicate End of Frame in the buffer */
        buffer_p[1] |=  ES_UVC_HEADER_EOF;
    }
}


/* This function starts the video streaming application. It is called
 * when there is a SET_INTERFACE event for alternate interface 1
 * (in case of UVC over Isochronous Endpoint usage) or when a
 * COMMIT_CONTROL(SET_CUR) request is received (when using BULK only UVC).
 */
    CyU3PReturnStatus_t
esUVCUvcApplnStart (void)
{
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

    glIsApplnActive = CyTrue;
    glDmaDone = 0;
    glDMATxCount = 0;
    glHitFV = CyFalse;
    doLpmDisable = CyTrue;

#ifdef RESET_TIMER_ENABLE
    CyU3PTimerStop (&UvcTimer);
#endif


    /* Place the EP in NAK mode before cleaning up the pipe. */
    CyU3PUsbSetEpNak (ES_UVC_EP_BULK_VIDEO, CyTrue);
    CyU3PBusyWait (100);

    /* Reset USB EP and DMA */
    CyU3PUsbFlushEp(ES_UVC_EP_BULK_VIDEO);
    status = CyU3PDmaMultiChannelReset (&glChHandleUVCStream);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4,"\n\rAplnStrt:ChannelReset Err = 0x%x", status);
        return status;
    }

    status = CyU3PDmaMultiChannelSetXfer (&glChHandleUVCStream, 0, 0);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAplnStrt:SetXfer Err = 0x%x", status);
        return status;
    }

    CyU3PUsbSetEpNak (ES_UVC_EP_BULK_VIDEO, CyFalse);
    CyU3PBusyWait (200);
//
//    /* Place the EP in NAK mode before cleaning up the pipe. */
//    CyU3PUsbSetEpNak (ES_UVC_EP_BULK_VIDEO, CyTrue);
//    CyU3PBusyWait (100);
//
//    /* Reset USB EP and DMA */
//    CyU3PUsbFlushEp(ES_UVC_EP_BULK_VIDEO);
//    status = CyU3PDmaMultiChannelReset (&glChHandleUVCStream);
//    if (status != CY_U3P_SUCCESS)
//    {
//        CyU3PDebugPrint (4,"\n\rAplnStrt:ChannelReset Err = 0x%x", status);
//        return status;
//    }
//    status = CyU3PDmaMultiChannelSetXfer (&glChHandleUVCStream, 0, 0);
//    if (status != CY_U3P_SUCCESS)
//    {
//        CyU3PDebugPrint (4, "\n\rAplnStrt:SetXfer Err = 0x%x", status);
//        return status;
//    }
//    CyU3PUsbSetEpNak (ES_UVC_EP_BULK_VIDEO, CyFalse);
//    CyU3PBusyWait (200);

	 /* Night Mode function
	 *  --------------------
	 *  esOV5640_Nightmode API is used to enable the Nightmode
	 *  of OV5640 sensor.
	 *  Set Enable -- Cytrue to enable Nightmode
	 * 				  CyFalse to Disable Nightmode
	 *
	 *  Set NightMode_option -- 1 to 6 to set different night modes
	 *
	 * To test different night modes, uncomment the below statement and build the firmware
	 */
    //TODO Change this Function to "Sensor Specific" Nightmode Function to enable the nightmode(If supported by the sensor)
	/*esOV5640_Nightmode(CyTrue,3);*/


    /* Resume the Fixed Function GPIF State machine */
    CyU3PGpifSMControl(CyFalse);

    glActiveSocket = 0;
    CyU3PGpifSMSwitch(ES_UVC_INVALID_GPIF_STATE, CX3_START_SCK0,
    		ES_UVC_INVALID_GPIF_STATE, ALPHA_CX3_START_SCK0, ES_UVC_GPIF_SWITCH_TIMEOUT);

    CyU3PThreadSleep(10);

    /* Wake Mipi interface and Image Sensor */
    CyU3PMipicsiWakeup();

    //TODO Change this function with "Sensor Specific" PowerUp function to PowerUp the sensor
    CyU3PDebugPrint(4,"\r\n PowerUp the sensor : 250");
    status = fc_ImageSensor_Init();
    //esCamera_Power_Up();

    glMipiActive = CyTrue;

    //TODO Change this Function with "Sensor Specific" AutoFocus Function to Set the AutoFocus of the sensor
//	if(glStillCaptureStart!= CyTrue)
//	{
//		if(g_IsAutoFocus) {
//			//esOV5640_SetAutofocus(g_IsAutoFocus);
//		}
//	}
    return CY_U3P_SUCCESS;
}

/* This function stops the video streaming. It is called from the USB event
 * handler, when there is a reset / disconnect or SET_INTERFACE for alternate
 * interface 0 in case of ischronous implementation or when a Clear Feature (Halt)
 * request is received (in case of bulk only implementation).
 */
    void
esUVCUvcApplnStop(void)
{
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

    /* Update the flag so that the application thread is notified of this. */
    glIsApplnActive = CyFalse;

    /* Stop the image sensor and CX3 mipi interface */
    status = CyU3PMipicsiSleep();

    //TODO Change this function with "Sensor Specific" PowerDown function to PowerDown the sensor
    CyU3PDebugPrint(4,"\r\n PowerDown function to PowerDown the sensor : 281");
    //esCamera_Power_Down();

    glMipiActive = CyFalse;

#ifdef RESET_TIMER_ENABLE
    CyU3PTimerStop (&UvcTimer);
#endif

    /* Pause the GPIF interface*/
    CyU3PGpifSMControl(CyTrue);

    CyU3PUsbSetEpNak (ES_UVC_EP_BULK_VIDEO, CyTrue);
    CyU3PBusyWait (100);

    /* Abort and destroy the video streaming channel */
    /* Reset the channel: Set to DSCR chain starting point in PORD/CONS SCKT; set DSCR_SIZE field in DSCR memory*/
    status = CyU3PDmaMultiChannelReset(&glChHandleUVCStream);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4,"\n\rAplnStop:ChannelReset Err = 0x%x",status);
    }
    CyU3PThreadSleep(25);

    /* Flush the endpoint memory */
    CyU3PUsbFlushEp(ES_UVC_EP_BULK_VIDEO);
    /* Clear the stall condition and sequence numbers if ClearFeature. */
    if (glIsClearFeature)
    {
        CyU3PUsbStall (ES_UVC_EP_BULK_VIDEO, CyFalse, CyTrue);
        glIsClearFeature = CyFalse;
    }
    CyU3PUsbSetEpNak (ES_UVC_EP_BULK_VIDEO, CyFalse);
	CyU3PBusyWait (200);

    glDMATxCount = 0;
    glDmaDone = 0;

    /* Enable USB 3.0 LPM */
    CyU3PUsbLPMEnable ();
}

/* GpifCB callback function is invoked when FV triggers GPIF interrupt */
    void
esUVCGpifCB (
        CyU3PGpifEventType event,
        uint8_t currentState
        )
{
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;
    /* Handle interrupt from the State Machine */
    if (event == CYU3P_GPIF_EVT_SM_INTERRUPT)
    {
        /* Wrapup Socket 0*/
        if(currentState == CX3_PARTIAL_BUFFER_IN_SCK0)
        {
            status = CyU3PDmaMultiChannelSetWrapUp(&glChHandleUVCStream,0);
            if (status != CY_U3P_SUCCESS)
            {
                CyU3PDebugPrint (4, "\n\rGpifCB:WrapUp SCK0 Err = 0x%x",status);
            }
        }
        /* Wrapup Socket 1 */
        else if(currentState == CX3_PARTIAL_BUFFER_IN_SCK1)
        {
            status = CyU3PDmaMultiChannelSetWrapUp(&glChHandleUVCStream,1);
            if (status != CY_U3P_SUCCESS)
            {
                CyU3PDebugPrint (4, "\n\rGpifCB:WrapUp SCK1 Err = 0x%x",status);
            }
        }
    }
}


/* DMA callback function to handle the produce and consume events. */
    void
esUVCUvcAppDmaCallback (
        CyU3PDmaMultiChannel   *chHandle,
        CyU3PDmaCbType_t  type,
        CyU3PDmaCBInput_t *input
        )
{
    CyU3PDmaBuffer_t DmaBuffer;
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

    if (type == CY_U3P_DMA_CB_PROD_EVENT)
    {
        /* This is a produce event notification to the CPU. This notification is
         * received upon reception of every buffer. The buffer will not be sent
         * out unless it is explicitly committed. The call shall fail if there
         * is a bus reset / usb disconnect or if there is any application error. */

        /* Disable USB 3.0 LPM while Buffer is being transmitted out*/
        if ((CyU3PUsbGetSpeed () == CY_U3P_SUPER_SPEED) && (doLpmDisable))
        {
            CyU3PUsbLPMDisable ();
            CyU3PUsbSetLinkPowerState (CyU3PUsbLPM_U0);
            CyU3PBusyWait (200);

            doLpmDisable = CyFalse;
        }
#ifdef RESET_TIMER_ENABLE
            CyU3PTimerStart (&UvcTimer);
#endif

        status = CyU3PDmaMultiChannelGetBuffer(chHandle, &DmaBuffer, CYU3P_NO_WAIT);
        while (status == CY_U3P_SUCCESS)
        {
            /* Add Headers*/
            if(DmaBuffer.count < ES_UVC_DATA_BUF_SIZE)
            {
                esUVCUvcAddHeader ((DmaBuffer.buffer - ES_UVC_PROD_HEADER), ES_UVC_HEADER_EOF);
                glHitFV = CyTrue;
            }
            else
            {
                esUVCUvcAddHeader ((DmaBuffer.buffer - ES_UVC_PROD_HEADER), ES_UVC_HEADER_FRAME);
            }

            /* Commit Buffer to USB*/
            status = CyU3PDmaMultiChannelCommitBuffer (chHandle, (DmaBuffer.count + 12), 0);
            if (status != CY_U3P_SUCCESS)
            {
                   CyU3PEventSet(&glTimerEvent, ES_TIMER_RESET_EVENT,CYU3P_EVENT_OR);
                   break;
            }
            else
            {
                glDMATxCount++;
                glDmaDone++;
            }

            glActiveSocket ^= 1; /* Toggle the Active Socket */
            status = CyU3PDmaMultiChannelGetBuffer(chHandle, &DmaBuffer, CYU3P_NO_WAIT);
        }
    }
    else if(type == CY_U3P_DMA_CB_CONS_EVENT)
    {
        glDmaDone--;

        /* Check if Frame is completely transferred */
        glIsStreamingStarted = CyTrue;

        if((glHitFV == CyTrue) && (glDmaDone == 0))
        {
            glHitFV = CyFalse;
            glDMATxCount=0;
#ifdef RESET_TIMER_ENABLE
            CyU3PTimerStop (&UvcTimer);
#endif

            if (glActiveSocket)
                CyU3PGpifSMSwitch(ES_UVC_INVALID_GPIF_STATE, CX3_START_SCK1,
                		ES_UVC_INVALID_GPIF_STATE, ALPHA_CX3_START_SCK1, ES_UVC_GPIF_SWITCH_TIMEOUT);
            else
                CyU3PGpifSMSwitch(ES_UVC_INVALID_GPIF_STATE, CX3_START_SCK0,
                		ES_UVC_INVALID_GPIF_STATE, ALPHA_CX3_START_SCK0, ES_UVC_GPIF_SWITCH_TIMEOUT);

            CyU3PUsbLPMEnable ();
            doLpmDisable = CyTrue;
#ifdef RESET_TIMER_ENABLE
            CyU3PTimerModify (&UvcTimer, TIMER_PERIOD, 0);
#endif

            if(glStillCaptured == CyTrue)
            {
            	glStillCaptured = CyFalse;
            	glUVCHeader[1]^=ES_UVC_HEADER_STILL_IMAGE;
            	glFrameIndexToSet = glCurrentFrameIndex;
            	CyU3PEventSet(&glTimerEvent, ES_TIMER_RESET_EVENT,CYU3P_EVENT_OR);
            }
            if(glStillCaptureStart == CyTrue)
            {
            	if(glStillSkip == 3)
				{
            		glStillSkip--;
            		glFrameIndexToSet = 4;
					CyU3PEventSet(&glTimerEvent, ES_TIMER_RESET_EVENT,CYU3P_EVENT_OR);
				}
            	else if(glStillSkip == 0)
            	{
            		glStillCaptureStart = CyFalse;
					glStillCaptured = CyTrue;
					glUVCHeader[1]^=ES_UVC_HEADER_STILL_IMAGE;
            	}
            	else
            		glStillSkip--;
            }
        }
    }
}

/* This is the Callback function to handle the USB Events */
    static void
esUVCUvcApplnUSBEventCB (
        CyU3PUsbEventType_t evtype,     /* Event type */
        uint16_t            evdata      /* Event data */
        )
{
    uint8_t interface = 0, altSetting = 0;

    switch (evtype)
    {
        case CY_U3P_USB_EVENT_SUSPEND:
            /* Suspend the device with Wake On Bus Activity set */
            glIsStreamingStarted = CyFalse;
            CyU3PEventSet (&glTimerEvent, ES_USB_SUSP_EVENT_FLAG, CYU3P_EVENT_OR);
            break;
        case CY_U3P_USB_EVENT_SETINTF:
            /* Start the video streamer application if the
             * interface requested was 1. If not, stop the
             * streamer. */
            interface = CY_U3P_GET_MSB(evdata);
            altSetting = CY_U3P_GET_LSB(evdata);

            glIsStreamingStarted = CyFalse;

            if ((altSetting == ES_UVC_STREAM_INTERFACE) && (interface == 1))
            {
                /* Stop the application before re-starting. */
                if (glIsApplnActive)
                {
                	glIsClearFeature = CyTrue;
                    esUVCUvcApplnStop ();
                }
                esUVCUvcApplnStart ();

            }
            else if ((altSetting == 0x00) && (interface == 1))
            {
            	glPreviewStarted = CyFalse;
            	/* Stop the application before re-starting. */
            	glIsClearFeature = CyTrue;
				esUVCUvcApplnStop ();
				glcommitcount = 0;
            }
            break;

            /* Fall-through. */

        case CY_U3P_USB_EVENT_SETCONF:
        case CY_U3P_USB_EVENT_RESET:
        case CY_U3P_USB_EVENT_DISCONNECT:
        case CY_U3P_USB_EVENT_CONNECT:
            glIsStreamingStarted = CyFalse;
            if (evtype == CY_U3P_USB_EVENT_SETCONF)
                glIsConfigured = CyTrue;
            else
                glIsConfigured = CyFalse;

            /* Stop the video streamer application and enable LPM. */
            CyU3PUsbLPMEnable ();
            if (glIsApplnActive)
            {
            	glIsClearFeature = CyTrue;
                esUVCUvcApplnStop ();
            }
            break;
        default:
            break;
    }
}

/* Callback for LPM requests. Always return true to allow host to transition device
 * into required LPM state U1/U2/U3. When data transmission is active LPM management
 * is explicitly disabled to prevent data transmission errors.
 */
static CyBool_t esUVCApplnLPMRqtCB (
        CyU3PUsbLinkPowerMode link_mode         /*USB 3.0 linkmode requested by Host */
        )
{
    return CyTrue;
}

//TODO Change this function with "Sensor Specific" function to write the sensor settings & configure the CX3 for supported resolutions
void esSetCameraResolution(uint8_t FrameIndex)
{
	CyU3PReturnStatus_t status = CY_U3P_SUCCESS;
	CyU3PDebugPrint (4, "\n\resSetCameraResolution");
	/* Super Speed USB Streams*/
	if (CyU3PUsbGetSpeed () == CY_U3P_SUPER_SPEED)
	{
		if(FrameIndex == 0x01)
		{
			/* Write 1080pSettings */
			status = CyU3PMipicsiSetIntfParams (&cfgUvc1080p30NoMclk, CyFalse);
			if (status != CY_U3P_SUCCESS)
			{
				CyU3PDebugPrint (4, "\n\rUSBStpCB:SetIntfParams SS1 Err = 0x%x", status);
			}
//			esOV5640_1080P_config();
		}
		else if(FrameIndex == 0x02)
		{
			/* Write VGA Settings */
			status = CyU3PMipicsiSetIntfParams (&cfgUvcVga30NoMclk, CyFalse);
			if (status != CY_U3P_SUCCESS)
			{
				CyU3PDebugPrint (4, "\n\rUSBStpCB:SetIntfParams FS Err = 0x%x", status);
			}
//			esOV5640_VGA_config();
		}
		else if(FrameIndex == 0x03)
		{
			/* Write 720pSettings */
			status = CyU3PMipicsiSetIntfParams (&cfgUvc720p60NoMclk, CyFalse);
			if (status != CY_U3P_SUCCESS)
			{
				CyU3PDebugPrint (4, "\n\rUSBStpCB:SetIntfParams SS2 Err = 0x%x", status);
			}
//			esOV5640_720P_config();
		}
		else if(FrameIndex == 0x04)
		{
			status = CyU3PMipicsiSetIntfParams (&cfgUvc5Mp15NoMclk, CyFalse);
			if (status != CY_U3P_SUCCESS)
			{
				CyU3PDebugPrint (4, "\n\rUSBStpCB:SetIntfParams SS2 Err = 0x%x", status);
			}
//			esOV5640_5MP_config();
		}
	}
	/* High Speed USB Streams*/
	else if (CyU3PUsbGetSpeed () == CY_U3P_HIGH_SPEED)
	{
		/* Write VGA Settings */
		status = CyU3PMipicsiSetIntfParams (&cfgUvcVga30NoMclk, CyFalse);
		if (status != CY_U3P_SUCCESS)
		{
			CyU3PDebugPrint (4, "\n\rUSBStpCB:SetIntfParams HS Err = 0x%x", status);
		}
//		esOV5640_VGA_config();
//		esOV5640_VGA_HS_config();
	}
	/* Full Speed USB Streams*/
	else
	{
		/* Write VGA Settings */
//		esOV5640_VGA_config();
		status = CyU3PMipicsiSetIntfParams (&cfgUvcVga30NoMclk, CyFalse);
		if (status != CY_U3P_SUCCESS)
		{
			CyU3PDebugPrint (4, "\n\rUSBStpCB:SetIntfParams FS Err = 0x%x", status);
		}
	}
}

/* Callback to handle the USB Setup Requests and UVC Class events */
    static CyBool_t
esUVCUvcApplnUSBSetupCB (
        uint32_t setupdat0,     /* SETUP Data 0 */
        uint32_t setupdat1      /* SETUP Data 1 */
        )
{
    uint8_t  bRequest, bType,bRType, bTarget;
    uint16_t wValue, wIndex, wLength;
    uint16_t readCount = 0;
    uint8_t  ep0Buf[2];
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;
    uint8_t temp = 0;
    CyBool_t isHandled = CyFalse;
    //uint8_t RequestOption = 0;

    /* Decode the fields from the setup request. */
    bRType = (setupdat0 & CY_U3P_USB_REQUEST_TYPE_MASK);
    bType    = (bRType & CY_U3P_USB_TYPE_MASK);
    bTarget  = (bRType & CY_U3P_USB_TARGET_MASK);
    bRequest = ((setupdat0 & CY_U3P_USB_REQUEST_MASK) >> CY_U3P_USB_REQUEST_POS);
    wValue   = ((setupdat0 & CY_U3P_USB_VALUE_MASK)   >> CY_U3P_USB_VALUE_POS);
    wIndex   = ((setupdat1 & CY_U3P_USB_INDEX_MASK)   >> CY_U3P_USB_INDEX_POS);
    wLength  = ((setupdat1 & CY_U3P_USB_LENGTH_MASK)  >> CY_U3P_USB_LENGTH_POS);

#if 1
   	CyU3PDebugPrint(4, "\n\rbRType = 0x%x, bRequest = 0x%x, wValue = 0x%x, wIndex = 0x%x, wLength= 0x%x",bRType, bRequest, wValue, wIndex, wLength);
#endif

    /* ClearFeature(Endpoint_Halt) received on the Streaming Endpoint. Stop Streaming */
    if((bTarget == CY_U3P_USB_TARGET_ENDPT) && (bRequest == CY_U3P_USB_SC_CLEAR_FEATURE)
            && (wIndex == ES_UVC_EP_BULK_VIDEO) && (wValue == CY_U3P_USBX_FS_EP_HALT))
    {
        if ((glIsApplnActive) && (glIsStreamingStarted))
        {
        	glPreviewStarted = CyFalse;
            glIsClearFeature = CyTrue;
            esUVCUvcApplnStop();
            glcommitcount = 0;
        }
        return CyFalse;
    }

    if( bRType == CY_U3P_USB_GS_DEVICE)
    {
        /* Make sure that we bring the link back to U0, so that the ERDY can be sent. */
        if (CyU3PUsbGetSpeed () == CY_U3P_SUPER_SPEED)
            CyU3PUsbSetLinkPowerState (CyU3PUsbLPM_U0);
    }

    if ((bTarget == CY_U3P_USB_TARGET_INTF) && ((bRequest == CY_U3P_USB_SC_SET_FEATURE)
                || (bRequest == CY_U3P_USB_SC_CLEAR_FEATURE)) && (wValue == 0))
    {
        if (glIsConfigured)
        {
            CyU3PUsbAckSetup ();
        }
        else
        {
            CyU3PUsbStall (0, CyTrue, CyFalse);
        }
        return CyTrue;
    }

    if ((bRequest == CY_U3P_USB_SC_GET_STATUS) &&
            (bTarget == CY_U3P_USB_TARGET_INTF))
    {
        /* We support only interface 0. */
        if (wIndex == 0)
        {
            ep0Buf[0] = 0;
            ep0Buf[1] = 0;
            CyU3PUsbSendEP0Data (0x02, ep0Buf);
        }
        else
            CyU3PUsbStall (0, CyTrue, CyFalse);
        return CyTrue;
    }

    /* Check for UVC Class Requests */
    if (bType == CY_U3P_USB_CLASS_RQT)
    {

        /* UVC Class Requests */
        /* Requests to the Video Streaming Interface (IF 1) */
        if((wIndex & 0x00FF) == ES_UVC_STREAM_INTERFACE)
        {
            /* GET_CUR Request Handling Probe/Commit Controls*/
            if ((bRequest == ES_UVC_USB_GET_CUR_REQ)||(bRequest == ES_UVC_USB_GET_MIN_REQ) || (bRequest == ES_UVC_USB_GET_MAX_REQ)||(bRequest == ES_UVC_USB_GET_DEF_REQ))
            {
                isHandled = CyTrue;
                if((wValue == ES_UVC_VS_PROBE_CONTROL) || (wValue == ES_UVC_VS_COMMIT_CONTROL))
                {
                	//TODO Modify this "glProbeCtrl" according to the Supported Preview Resolutions that are supported by the sensor

					/* Host requests for probe data of 34 bytes (UVC 1.1) or 26 Bytes (UVC1.0). Send it over EP0. */
					if (CyU3PUsbGetSpeed () == CY_U3P_SUPER_SPEED)
					{
						if(glCurrentFrameIndex == 4)
						{
							CyU3PMemCopy(glProbeCtrl, (uint8_t *)gl5MpProbeCtrl, ES_UVC_MAX_PROBE_SETTING);
						}
						/* Probe Control for 1280x720 stream*/
						else if(glCurrentFrameIndex == 3)
						{
							CyU3PMemCopy(glProbeCtrl, (uint8_t *)gl720pProbeCtrl, ES_UVC_MAX_PROBE_SETTING);
						}
						/* Probe Control for 640x480 stream*/
						else  if(glCurrentFrameIndex == 2)
						{
							CyU3PMemCopy(glProbeCtrl, (uint8_t *)glVga60ProbeCtrl, ES_UVC_MAX_PROBE_SETTING);
						}
						/* Probe Control for 1920x1080 stream*/
						else  if(glCurrentFrameIndex == 1)
						{
							CyU3PMemCopy(glProbeCtrl, (uint8_t *)gl1080pProbeCtrl, ES_UVC_MAX_PROBE_SETTING);
						}

					}
					else if (CyU3PUsbGetSpeed () == CY_U3P_HIGH_SPEED)
					{
						/* Probe Control for 640x480 stream*/
						CyU3PMemCopy(glProbeCtrl, (uint8_t *)glVga30ProbeCtrl, ES_UVC_MAX_PROBE_SETTING);
					}
					else /* FULL-Speed*/
					{
						CyU3PDebugPrint (4, "\n\rFull Speed Not Supported!");
					}

					status = CyU3PUsbSendEP0Data(ES_UVC_MAX_PROBE_SETTING, glProbeCtrl);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:GET_CUR:SendEP0Data Err = 0x%x", status);
					}
                }
                else if((wValue == ES_UVC_STILL_PROBE_CONTROL) || (wValue == ES_UVC_STILL_COMMIT_CONTROL))
                {
                	if (CyU3PUsbGetSpeed () == CY_U3P_SUPER_SPEED)
                	{
						status = CyU3PUsbSendEP0Data(ES_UVC_MAX_STILL_PROBE_SETTING, glStillProbeCtrl);
						if (status != CY_U3P_SUCCESS)
						{
							CyU3PDebugPrint (4, "\n\rUSBStpCB:GET_CUR:SendEP0Data Err = 0x%x", status);
						}
                	}
                }
            }
            /* SET_CUR request handling Probe/Commit controls */
            else if (bRequest == ES_UVC_USB_SET_CUR_REQ)
            {
                isHandled = CyTrue;
                if((wValue == ES_UVC_VS_PROBE_CONTROL) || (wValue == ES_UVC_VS_COMMIT_CONTROL))
                {
					/* Get the UVC probe/commit control data from EP0 */
					status = CyU3PUsbGetEP0Data(ES_UVC_MAX_PROBE_SETTING_ALIGNED,
							glCommitCtrl, &readCount);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:SET_CUR:GetEP0Data Err = 0x%x.", status);
					}
					/* Check the read count. Expecting a count of CX3_UVC_MAX_PROBE_SETTING bytes. */
					if (readCount > (uint16_t)ES_UVC_MAX_PROBE_SETTING)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:Invalid SET_CUR Rqt Len.");
					}
					else
					{
						/* Set Probe Control */
						if(wValue == ES_UVC_VS_PROBE_CONTROL)
						{
							glCurrentFrameIndex = glCommitCtrl[3];
						}
						/* Set Commit Control and Start Streaming*/
						else if(wValue == ES_UVC_VS_COMMIT_CONTROL)
						{

							if((glcommitcount==0)||(glcheckframe!=glCommitCtrl[3]))
							{
								glcommitcount++;
								glcheckframe=glCommitCtrl[3];
							glCurrentFrameIndex = glCommitCtrl[3];
							glFrameIndexToSet = glCurrentFrameIndex;
							glPreviewStarted = CyTrue;

							//TODO Change this function with "Sensor Specific" function to write the sensor settings & configure the CX3 for supported resolutions
						    CyU3PDebugPrint(4,"\r\n Write the sensor settings & configure the CX3 for supported resolutions");
						//	esSetCameraResolution(glCurrentFrameIndex);
						//	esSetCameraResolution(glCommitCtrl[3]);

							if (glIsApplnActive)
							{
								if(glcommitcount)
									glIsClearFeature = CyFalse;
								else
									glIsClearFeature = CyTrue;

								esUVCUvcApplnStop();
							}
							esUVCUvcApplnStart();
							}
						}
					}
                }
                else if((wValue == ES_UVC_STILL_PROBE_CONTROL) || (wValue == ES_UVC_STILL_COMMIT_CONTROL))
                {
                	/* Get the UVC STILL probe/commit control data from EP0 */
					status = CyU3PUsbGetEP0Data(ES_UVC_MAX_STILL_PROBE_SETTING_ALIGNED,glStillCommitCtrl, &readCount);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:SET_CUR:GetEP0Data Err = 0x%x.", status);
					}
					/* Check the read count. Expecting a count of CX3_UVC_MAX_PROBE_SETTING bytes. */
					if (readCount > (uint16_t)ES_UVC_MAX_STILL_PROBE_SETTING)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:Invalid SET_CUR Rqt Len.");
					}
					else
					{
						/* Set Probe Control */
						if(wValue == ES_UVC_STILL_PROBE_CONTROL)
						{
							glCurrentStillFrameIndex = glStillCommitCtrl[1];
						}
						/* Set Commit Control and Start Streaming*/
						else if(wValue == ES_UVC_STILL_COMMIT_CONTROL)
						{
							glCurrentStillFrameIndex = glStillCommitCtrl[1];
						}
					}

                }
                else if(wValue == ES_UVC_STILL_TRIGGER)
                {
					status = CyU3PUsbGetEP0Data(ES_UVC_STILL_TRIGGER_ALIGNED,&glStillTriggerCtrl, &readCount);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:SET_CUR:GetEP0Data Err = 0x%x.", status);
					}
					/* Check the read count. Expecting a count of CX3_UVC_MAX_PROBE_SETTING bytes. */
					if (readCount > (uint16_t)ES_UVC_STILL_TRIGGER_COUNT)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:Invalid SET_CUR Rqt Len.");
					}
					else
					{
						if(glStillTriggerCtrl == 0x01)
						{
							glStillSkip = 3;
							glStillCaptureStart = CyTrue;
						}
					}
                }
            }
            else
            {
                /* Mark with error. */
                status = CY_U3P_ERROR_FAILURE;
            }
        }
        else if((wIndex & 0x00FF) == ES_UVC_CONTROL_INTERFACE) /* Video Control Interface */
        {
            isHandled = CyTrue;
            /* Respond to VC_REQUEST_ERROR_CODE_CONTROL and stall every other request as this example does not support
               any of the Video Control features */
            if((wIndex == 0x200) && (wValue == 0x200))/*Brightness*/
            {
            	switch(bRequest)
            	{
            	case ES_UVC_USB_GET_INFO_REQ:
            		glGet_Info=0x03;
            		status = CyU3PUsbSendEP0Data(1,&glGet_Info);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					break;
            	case ES_UVC_USB_GET_MIN_REQ:
            	case ES_UVC_USB_GET_MAX_REQ:
            	case ES_UVC_USB_GET_RES_REQ:
            	case ES_UVC_USB_GET_CUR_REQ:
            	case ES_UVC_USB_GET_DEF_REQ:
//            		//RequestOption = (bRequest & 0x0F);
//
//            		//TODO Change this function with the "Sensor specific" function to Service all the GET requests for brightness Control
////            		gl16GetControl = esOV5640_GetBrightness(RequestOption);
//            		//status = CyU3PUsbSendEP0Data(2,(uint8_t*)&gl16GetControl);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
            		break;
            	case ES_UVC_USB_SET_CUR_REQ:
//            		status = CyU3PUsbGetEP0Data(16,(uint8_t*)&gl16SetControl,&readCount);
//            		if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
            		//TODO Change this function with the "Sensor specific" function to Service the SET request for brightness Control & write the brightness settings into the sensor
//					esOV5640_SetBrightness((int8_t)gl16SetControl);
					break;
            	}
            }
            else if((wIndex == 0x100) && (wValue == 0x200))/*Auto Exposure*/
			{
            //	CyU3PDebugPrint (4, "\n\rAuto Exposure");
				switch(bRequest)
				{
				case ES_UVC_USB_GET_INFO_REQ:
					glGet_Info=0x03;
					status = CyU3PUsbSendEP0Data(1,&glGet_Info);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					break;
				case ES_UVC_USB_GET_MIN_REQ:
				case ES_UVC_USB_GET_MAX_REQ:
				case ES_UVC_USB_GET_RES_REQ:
				case ES_UVC_USB_GET_CUR_REQ:
				case ES_UVC_USB_GET_DEF_REQ:
//					RequestOption = (bRequest & 0x0F);
					//TODO Change this function with the "Sensor specific" function to Service all the GET requests for AutoExposure Control
				    CyU3PDebugPrint(4,"\r\n GET requests for AutoExposure Control : 952");
//					gl8GetControl = esOV5640_GetAutoExposure(RequestOption);
//					status = CyU3PUsbSendEP0Data(1,(uint8_t*)&gl8GetControl);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					break;
				case ES_UVC_USB_SET_CUR_REQ:
					status = CyU3PUsbGetEP0Data(16,(uint8_t*)&gl8SetControl,&readCount);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					//TODO Change this function with the "Sensor specific" function to Service the SET request for AutoExposure Control & write AutoExposure settings into the sensor
					CyU3PDebugPrint (4, "\n\rAuto Exposure= %d",gl8SetControl);
//					//esOV5640_SetAutoExposure(gl8SetControl);
					break;
				}
			}
            else if((wIndex == 0x200) && (wValue == 0x300))/*Contrast*/
            {
            	switch(bRequest)
				{
				case ES_UVC_USB_GET_INFO_REQ:
					glGet_Info=0x03;
					status = CyU3PUsbSendEP0Data(1,&glGet_Info);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					break;
				case ES_UVC_USB_GET_MIN_REQ:
				case ES_UVC_USB_GET_MAX_REQ:
				case ES_UVC_USB_GET_RES_REQ:
				case ES_UVC_USB_GET_CUR_REQ:
				case ES_UVC_USB_GET_DEF_REQ:
					//RequestOption = (bRequest & 0x0F);
					//TODO Change this function with the "Sensor specific" function to Service all the GET requests for Contrast Control
//					gl16GetControl = esOV5640_GetContrast(RequestOption);
					//status = CyU3PUsbSendEP0Data(2,(uint8_t*)&gl16GetControl);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					break;
				case ES_UVC_USB_SET_CUR_REQ:
//					status = CyU3PUsbGetEP0Data(16,(uint8_t*)&gl16SetControl,&readCount);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					//TODO Change this function with the "Sensor specific" function to Service the SET request for Contrast Control & write Contrast settings into the sensor
//					esOV5640_SetContrast((int8_t)gl16SetControl);
					break;
				}
            }
            else if((wIndex == 0x100) && (wValue == 0x400))/*Manual Exposure*/
			{
            	//CyU3PDebugPrint (4, "\n\rManual Exposure ");
				switch(bRequest)
				{
				case ES_UVC_USB_GET_INFO_REQ:
					glGet_Info=0x03;
					status = CyU3PUsbSendEP0Data(1,&glGet_Info);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					break;
				case ES_UVC_USB_GET_MIN_REQ:
				case ES_UVC_USB_GET_MAX_REQ:
				case ES_UVC_USB_GET_RES_REQ:
				case ES_UVC_USB_GET_CUR_REQ:
				case ES_UVC_USB_GET_DEF_REQ:
					//RequestOption = (bRequest & 0x0F);
					//TODO Change this function with the "Sensor specific" function to Service all the GET requests for ManualExposure Control
//					gl32GetControl = esOV5640_GetExposure(RequestOption);
					//status = CyU3PUsbSendEP0Data(4,(uint8_t*)&gl32GetControl);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					break;
				case ES_UVC_USB_SET_CUR_REQ:
//					status = CyU3PUsbGetEP0Data(16,(uint8_t*)&gl32SetControl,&readCount);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					//TODO Change this function with the "Sensor specific" function to Service the SET request for ManualExposure Control & write ManualExposure settings into the sensor
				//	CyU3PDebugPrint (4, "\n\rManual Exposure = %d", gl32SetControl);
//					esOV5640_SetExposure(gl32SetControl);
					break;
				}
			}
            else if((wIndex == 0x200) && (wValue == 0x600))/*Hue*/
			{
				switch(bRequest)
				{
				case ES_UVC_USB_GET_INFO_REQ:
					glGet_Info=0x03;
					status = CyU3PUsbSendEP0Data(1,&glGet_Info);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					break;
				case ES_UVC_USB_GET_MIN_REQ:
				case ES_UVC_USB_GET_MAX_REQ:
				case ES_UVC_USB_GET_RES_REQ:
				case ES_UVC_USB_GET_CUR_REQ:
				case ES_UVC_USB_GET_DEF_REQ:
					//RequestOption = (bRequest & 0x0F);
					//TODO Change this function with the "Sensor specific" function to Service all the GET requests for Hue Control
//					gl32GetControl = (int32_t)esOV5640_GetHue(RequestOption);
					//status = CyU3PUsbSendEP0Data(4,(uint8_t*)&gl32GetControl);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					break;
				case ES_UVC_USB_SET_CUR_REQ:
//					status = CyU3PUsbGetEP0Data(16,(uint8_t*)&gl32SetControl,&readCount);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					//TODO Change this function with the "Sensor specific" function to Service the SET request for Hue Control & write Hue settings into the sensor
//					esOV5640_SetHue((int8_t)gl32SetControl);
					break;
				}
			}
            else if((wIndex == 0x100) && (wValue == 0x600))/*Manual Focus*/
			{
            	//CyU3PDebugPrint (4, "\n\rManual Focus ");
				switch(bRequest)
				{
				case ES_UVC_USB_GET_INFO_REQ:
					glGet_Info=0x03;
					status = CyU3PUsbSendEP0Data(1,&glGet_Info);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					break;
				case ES_UVC_USB_GET_MIN_REQ:
				case ES_UVC_USB_GET_MAX_REQ:
				case ES_UVC_USB_GET_RES_REQ:
				case ES_UVC_USB_GET_CUR_REQ:
				case ES_UVC_USB_GET_DEF_REQ:
					//TODO Change this function with the "Sensor specific" function to Service all the GET requests for ManualFocus Control
					//RequestOption = (bRequest & 0x0F);
//					gl16GetControl = esOV5640_GetManualfocus(RequestOption);
					//status = CyU3PUsbSendEP0Data(2,(uint8_t*)&gl16GetControl);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					break;
				case ES_UVC_USB_SET_CUR_REQ:
//					status = CyU3PUsbGetEP0Data(16,(uint8_t*)&gl16SetControl,&readCount);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					//TODO Change this function with the "Sensor specific" function to Service the SET request for ManualFocus Control & write ManualFocus settings into the sensor
				//	CyU3PDebugPrint (4, "\n\rManual Focus= %d",gl16SetControl);
//					esOV5640_SetManualfocus((uint16_t)gl16SetControl);
					g_IsAutoFocus = 0;
					break;
				}
			}
            else if((wIndex == 0x200) && (wValue == 0x700))/*Saturation*/
			{
				switch(bRequest)
				{
				case ES_UVC_USB_GET_INFO_REQ:
					glGet_Info=0x03;
					status = CyU3PUsbSendEP0Data(1,&glGet_Info);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					break;
				case ES_UVC_USB_GET_MIN_REQ:
				case ES_UVC_USB_GET_MAX_REQ:
				case ES_UVC_USB_GET_RES_REQ:
				case ES_UVC_USB_GET_CUR_REQ:
				case ES_UVC_USB_GET_DEF_REQ:
					//RequestOption = (bRequest & 0x0F);
					//TODO Change this function with the "Sensor specific" function to Service all the GET requests for Saturation Control
//					gl16GetControl = esOV5640_GetSaturation(RequestOption);
					//status = CyU3PUsbSendEP0Data(2,(uint8_t*)&gl16GetControl);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					break;
				case ES_UVC_USB_SET_CUR_REQ:
//					status = CyU3PUsbGetEP0Data(16,(uint8_t*)&gl16SetControl,&readCount);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					//TODO Change this function with the "Sensor specific" function to Service the SET request for Saturation Control & write Saturation settings into the sensor
//					esOV5640_SetSaturation((uint32_t)gl16SetControl);
					break;
				}
			}
            else if((wIndex == 0x200) && (wValue == 0x800))/*Sharpness*/
			{
				switch(bRequest)
				{
				case ES_UVC_USB_GET_INFO_REQ:
					glGet_Info=0x03;
					status = CyU3PUsbSendEP0Data(1,&glGet_Info);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					break;
				case ES_UVC_USB_GET_MIN_REQ:
				case ES_UVC_USB_GET_MAX_REQ:
				case ES_UVC_USB_GET_RES_REQ:
				case ES_UVC_USB_GET_CUR_REQ:
				case ES_UVC_USB_GET_DEF_REQ:
					//RequestOption = (bRequest & 0x0F);
					//TODO Change this function with the "Sensor specific" function to Service all the GET requests for Sharpness Control
//					gl16GetControl = esOV5640_GetSharpness(RequestOption);
					//status = CyU3PUsbSendEP0Data(2,(uint8_t*)&gl16GetControl);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					break;
				case ES_UVC_USB_SET_CUR_REQ:
//					status = CyU3PUsbGetEP0Data(16,(uint8_t*)&gl16SetControl,&readCount);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					//TODO Change this function with the "Sensor specific" function to Service the SET request for Sharpness Control & write Sharpness settings into the sensor
//					esOV5640_SetSharpness((uint8_t)gl16SetControl);
					break;
				}
			}
            else if((wIndex == 0x100) && (wValue == 0x800))/*Auto Focus*/
			{
            	CyU3PDebugPrint (4, "\n\rAuto Focus");
				switch(bRequest)
				{
				case ES_UVC_USB_GET_INFO_REQ:
					glGet_Info=0x03;
					status = CyU3PUsbSendEP0Data(1,&glGet_Info);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					break;
				case ES_UVC_USB_GET_MIN_REQ:
				case ES_UVC_USB_GET_MAX_REQ:
				case ES_UVC_USB_GET_RES_REQ:
				case ES_UVC_USB_GET_CUR_REQ:
				case ES_UVC_USB_GET_DEF_REQ:
					//RequestOption = (bRequest & 0x0F);
					//TODO Change this function with the "Sensor specific" function to Service all the GET requests for AutoFocus Control
//					gl8GetControl = esOV5640_GetAutofocus(RequestOption);
					//status = CyU3PUsbSendEP0Data(2,(uint8_t*)&gl8GetControl);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					break;
				case ES_UVC_USB_SET_CUR_REQ:
					status = CyU3PUsbGetEP0Data(16,(uint8_t*)&gl8SetControl,&readCount);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					//TODO Change this function with the "Sensor specific" function to Service the SET request for AutoFocus Control & write AutoFocus settings into the sensor
				//	CyU3PDebugPrint (4, "\n\rAuto Focus =%d",gl8SetControl);
//					esOV5640_SetAutofocus((uint8_t)gl8SetControl);
					g_IsAutoFocus = 1;
					break;
				}
			}
            else if((wIndex == 0x200) && (wValue == 0xA00))/*White Balance manual*/
			{
				switch(bRequest)
				{
				case ES_UVC_USB_GET_INFO_REQ:
					glGet_Info=0x03;
					status = CyU3PUsbSendEP0Data(1,&glGet_Info);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					break;
				case ES_UVC_USB_GET_MIN_REQ:
				case ES_UVC_USB_GET_MAX_REQ:
				case ES_UVC_USB_GET_RES_REQ:
				case ES_UVC_USB_GET_CUR_REQ:
				case ES_UVC_USB_GET_DEF_REQ:
					//RequestOption = (bRequest & 0x0F);
					//TODO Change this function with the "Sensor specific" function to Service all the GET requests for ManualWhiteBalance Control
//					gl16GetControl = esOV5640_GetWhiteBalance(RequestOption);
					//status = CyU3PUsbSendEP0Data(2,(uint8_t*)&gl16GetControl);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					break;
				case ES_UVC_USB_SET_CUR_REQ:
//					status = CyU3PUsbGetEP0Data(16,(uint8_t*)&gl16SetControl,&readCount);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					//TODO Change this function with the "Sensor specific" function to Service the SET request for ManualWhiteBalance Control & write ManualWhiteBalance settings into the sensor
//					esOV5640_SetWhiteBalance((uint8_t)gl16SetControl);
					break;
				}
			}
            else if((wIndex == 0x200) && (wValue == 0xB00))/*White Balance Auto*/
			{
				switch(bRequest)
				{
				case ES_UVC_USB_GET_INFO_REQ:
					glGet_Info=0x03;
					status = CyU3PUsbSendEP0Data(1,&glGet_Info);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					break;
				case ES_UVC_USB_GET_MIN_REQ:
				case ES_UVC_USB_GET_MAX_REQ:
				case ES_UVC_USB_GET_RES_REQ:
				case ES_UVC_USB_GET_CUR_REQ:
				case ES_UVC_USB_GET_DEF_REQ:
					//RequestOption = (bRequest & 0x0F);
					//TODO Change this function with the "Sensor specific" function to Service all the GET requests for AutoWhiteBalance Control
//					gl16GetControl = esOV5640_GetAutoWhiteBalance(RequestOption);
					//status = CyU3PUsbSendEP0Data(2,(uint8_t*)&gl16GetControl);
					if (status != CY_U3P_SUCCESS)
					{
						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
					}
					break;
				case ES_UVC_USB_SET_CUR_REQ:
//					status = CyU3PUsbGetEP0Data(16,(uint8_t*)&gl16SetControl,&readCount);
//					if (status != CY_U3P_SUCCESS)
//					{
//						CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
//					}
					//TODO Change this function with the "Sensor specific" function to Service the SET request for AutoWhiteBalance Control & write AutoWhiteBalance settings into the sensor
//					esOV5640_SetAutoWhiteBalance((uint8_t)gl16SetControl);
					break;
				}
			}
            else if((wValue == ES_UVC_VC_REQUEST_ERROR_CODE_CONTROL) && (wIndex == 0x00))
            {
                temp = ES_UVC_ERROR_INVALID_CONTROL;
                status = CyU3PUsbSendEP0Data(0x01, &temp);
                if (status != CY_U3P_SUCCESS)
                {
                    CyU3PDebugPrint (4, "\n\rUSBStpCB:VCI SendEP0Data = %d", status);
                }
            }
            else
                CyU3PUsbStall(0,CyTrue, CyTrue);
        }
    }
    return isHandled;
}



/* This function initializes the USB Module, creates event group,
   sets the enumeration descriptors, configures the Endpoints and
   configures the DMA module for the UVC Application */
    void
esUVCUvcApplnInit (void)
{
    CyU3PEpConfig_t endPointConfig;
    CyU3PDmaMultiChannelConfig_t dmaCfg;
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

    /* Initialize the I2C interface for Mipi Block Usage and Camera. */
    status = CyU3PMipicsiInitializeI2c (CY_U3P_MIPICSI_I2C_400KHZ);
    if( status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:I2CInit Err = 0x%x.",status);
        esUVCAppErrorHandler(status);
    }

    /* Initialize GPIO module. */
    status = CyU3PMipicsiInitializeGPIO ();
    if( status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:GPIOInit Err = 0x%x",status);
        esUVCAppErrorHandler(status);
    }

    /* Initialize the PIB block */
    status = CyU3PMipicsiInitializePIB ();
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:PIBInit Err = 0x%x",status);
        esUVCAppErrorHandler(status);
    }

    /* Start the USB functionality */
    status = CyU3PUsbStart();
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:UsbStart Err = 0x%x",status);
        esUVCAppErrorHandler(status);
    }
    /* The fast enumeration is the easiest way to setup a USB connection,
     * where all enumeration phase is handled by the library. Only the
     * class / vendor requests need to be handled by the application. */
    CyU3PUsbRegisterSetupCallback(esUVCUvcApplnUSBSetupCB, CyTrue);

    /* Setup the callback to handle the USB events */
    CyU3PUsbRegisterEventCallback(esUVCUvcApplnUSBEventCB);

    /* Register a callback to handle LPM requests from the USB 3.0 host. */
    CyU3PUsbRegisterLPMRequestCallback (esUVCApplnLPMRqtCB);

    /* Set the USB Enumeration descriptors */

    /* Super speed device descriptor. */
    status = CyU3PUsbSetDesc(CY_U3P_USB_SET_SS_DEVICE_DESCR, 0, (uint8_t *)esUVCUSB30DeviceDscr);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:Set_SS_Device_Dscr Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    /* High speed device descriptor. */
    status = CyU3PUsbSetDesc(CY_U3P_USB_SET_HS_DEVICE_DESCR, 0, (uint8_t *)esUVCUSB20DeviceDscr);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:Set_HS_Device_Dscr Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    /* BOS descriptor */
    status = CyU3PUsbSetDesc(CY_U3P_USB_SET_SS_BOS_DESCR, 0, (uint8_t *)esUVCUSBBOSDscr);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:Set_BOS_Dscr Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    /* Device qualifier descriptor */
    status = CyU3PUsbSetDesc(CY_U3P_USB_SET_DEVQUAL_DESCR, 0, (uint8_t *)esUVCUSBDeviceQualDscr);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:Set_DEVQUAL_Dscr Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    /* Super speed configuration descriptor */
    status = CyU3PUsbSetDesc(CY_U3P_USB_SET_SS_CONFIG_DESCR, 0, (uint8_t *)esUVCUSBSSConfigDscr);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:Set_SS_CFG_Dscr Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    /* High speed configuration descriptor */
    status = CyU3PUsbSetDesc(CY_U3P_USB_SET_HS_CONFIG_DESCR, 0, (uint8_t *)esUVCUSBHSConfigDscr);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:Set_HS_CFG_Dscr Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    /* Full speed configuration descriptor */
    status = CyU3PUsbSetDesc(CY_U3P_USB_SET_FS_CONFIG_DESCR, 0, (uint8_t *)esUVCUSBFSConfigDscr);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:Set_FS_CFG_Dscr Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    /* String descriptor 0 */
    status = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 0, (uint8_t *)esUVCUSBStringLangIDDscr);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:Set_STRNG_Dscr0 Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    /* String descriptor 1 */
    status = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 1, (uint8_t *)esUVCUSBManufactureDscr);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:Set_STRNG_Dscr1 Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    /* String descriptor 2 */
    status = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 2, (uint8_t *)esUVCUSBProductDscr);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:Set_STRNG_Dscr2 Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }
    /* String descriptor 3 */
    status = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 3, (uint8_t *)esUVCUSBConfigSSDscr);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:Set_STRNG_Dscr3 Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    /* String descriptor 4 */
    status = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 4, (uint8_t *)esUVCUSBConfigHSDscr);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:Set_STRNG_Dscr4 Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }
    /* String descriptor 2 */
    status = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 5, (uint8_t *)esUVCUSBConfigFSDscr);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:Set_STRNG_Dscr5 Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    CyU3PUsbVBattEnable (CyTrue);
    CyU3PUsbControlVBusDetect (CyFalse, CyTrue);

    //TODO Change this function with the "Sensor specific" function to Write the Base I2C settings into the sensor
    /* Setup Image Sensor */
	//esOV5640_Base_Config();
    status = fc_ImageSensor_Init();
	 //TODO Change this function with the "Sensor specific" function to Write the Base I2C settings for autofocus into the sensor
	//esOV5640_Auto_Focus_Config();
	//TODO Change this function with "Sensor Specific" PowerDown function to PowerDown the sensor
    CyU3PDebugPrint(4,"\r\n PowerDown function to PowerDown the sensor : 1495");
	//esCamera_Power_Down();

    /* Connect the USB pins and enable super speed operation */
    status = CyU3PConnectState(CyTrue, CyTrue);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:ConnectState Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    /* Since the status interrupt endpoint is not used in this application,
     * just enable the EP in the beginning. */
    /* Control status interrupt endpoint configuration */
    endPointConfig.enable = 1;
    endPointConfig.epType = CY_U3P_USB_EP_INTR;
    endPointConfig.pcktSize = 64;
    endPointConfig.isoPkts  = 1;
    endPointConfig.burstLen = 1;

    status = CyU3PSetEpConfig(ES_UVC_EP_CONTROL_STATUS, &endPointConfig);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:CyU3PSetEpConfig CtrlEp Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    CyU3PUsbFlushEp(ES_UVC_EP_CONTROL_STATUS);

    /* Setup the Bulk endpoint used for Video Streaming */
    endPointConfig.enable = CyTrue;
    endPointConfig.epType = CY_U3P_USB_EP_BULK;

    endPointConfig.isoPkts  = 0;
    endPointConfig.streams = 0;

    CyU3PThreadSleep(1000);

    switch(CyU3PUsbGetSpeed())
    {
        case CY_U3P_HIGH_SPEED:
            endPointConfig.pcktSize = 0x200;
            endPointConfig.burstLen = 1;
            ES_UVC_STREAM_BUF_SIZE 	= ES_UVC_HS_STREAM_BUF_SIZE;
            ES_UVC_DATA_BUF_SIZE 	= ES_UVC_HS_DATA_BUF_SIZE;
            ES_UVC_STREAM_BUF_COUNT	= ES_UVC_HS_STREAM_BUF_COUNT;
            break;

        case CY_U3P_FULL_SPEED:
            endPointConfig.pcktSize = 0x40;
            endPointConfig.burstLen = 1;
            break;

        case CY_U3P_SUPER_SPEED:
        default:
            endPointConfig.pcktSize = ES_UVC_EP_BULK_VIDEO_PKT_SIZE;
            endPointConfig.burstLen = 16;
            ES_UVC_STREAM_BUF_SIZE 	= ES_UVC_SS_STREAM_BUF_SIZE;
            ES_UVC_DATA_BUF_SIZE 	= ES_UVC_SS_DATA_BUF_SIZE;
            ES_UVC_STREAM_BUF_COUNT	= ES_UVC_SS_STREAM_BUF_COUNT;
            break;
    }

    status = CyU3PSetEpConfig(ES_UVC_EP_BULK_VIDEO, &endPointConfig);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:CyU3PSetEpConfig BulkEp Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    CyU3PUsbEPSetBurstMode (ES_UVC_EP_BULK_VIDEO, CyTrue);

    /* Flush the endpoint memory */
    CyU3PUsbFlushEp(ES_UVC_EP_BULK_VIDEO);

    /* Create a DMA Manual OUT channel for streaming data */
    /* Video streaming Channel is not active till a stream request is received */
    dmaCfg.size                 = ES_UVC_STREAM_BUF_SIZE;
    dmaCfg.count                = ES_UVC_STREAM_BUF_COUNT;
    dmaCfg.validSckCount        = 2;

    dmaCfg.prodSckId[0]         = ES_UVC_PRODUCER_PPORT_SOCKET_0;
    dmaCfg.prodSckId[1]         = ES_UVC_PRODUCER_PPORT_SOCKET_1;

    dmaCfg.consSckId[0]         = ES_UVC_EP_VIDEO_CONS_SOCKET;
    dmaCfg.dmaMode              = CY_U3P_DMA_MODE_BYTE;
    dmaCfg.notification         = CY_U3P_DMA_CB_PROD_EVENT | CY_U3P_DMA_CB_CONS_EVENT;
    dmaCfg.cb                   = esUVCUvcAppDmaCallback;
    dmaCfg.prodHeader           = ES_UVC_PROD_HEADER;
    dmaCfg.prodFooter           = ES_UVC_PROD_FOOTER;
    dmaCfg.consHeader           = 0;
    dmaCfg.prodAvailCount       = 0;

    status = CyU3PDmaMultiChannelCreate (&glChHandleUVCStream, CY_U3P_DMA_TYPE_MANUAL_MANY_TO_ONE , &dmaCfg);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:DmaMultiChannelCreate Err = 0x%x", status);
    }
    CyU3PThreadSleep(100);

    /* Reset the channel: Set to DSCR chain starting point in PORD/CONS SCKT; set
       DSCR_SIZE field in DSCR memory */
    status = CyU3PDmaMultiChannelReset(&glChHandleUVCStream);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4,"\n\rAppInit:MultiChannelReset Err = 0x%x", status);
    }

    /* Configure the Fixed Function GPIF on the CX3 to use a 16 bit bus, and
     * a DMA Buffer of size CX3_UVC_DATA_BUF_SIZE
     */
    status = CyU3PMipicsiGpifLoad(CY_U3P_MIPICSI_BUS_16, ES_UVC_DATA_BUF_SIZE);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:MipicsiGpifLoad Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }
    CyU3PThreadSleep(50);

    CyU3PGpifRegisterCallback(esUVCGpifCB);
    CyU3PThreadSleep(50);

    /* Start the state machine. */
    status = CyU3PGpifSMStart (CX3_START_SCK0, ALPHA_CX3_START_SCK0);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:GpifSMStart Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }
    CyU3PThreadSleep(50);

    /* Pause the GPIF*/
    CyU3PGpifSMControl(CyTrue);

    /* Initialize the MIPI block */
    status =  CyU3PMipicsiInit();
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:MipicsiInit Err = 0x%x", status);
        esUVCAppErrorHandler(status);
    }

    status = CyU3PMipicsiSetIntfParams(&cfgUvcVgaNoMclk, CyFalse);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\rAppInit:MipicsiSetIntfParams Err = 0x%x",status);
        esUVCAppErrorHandler(status);
    }

#ifdef RESET_TIMER_ENABLE
    CyU3PTimerCreate (&UvcTimer, UvcAppProgressTimer, 0x00, TIMER_PERIOD, 0, CYU3P_NO_ACTIVATE);
#endif

    CyU3PDebugPrint (4, "\n\rFirmware Version: %d.%d.%d.%d",MajorVersion,MinorVersion,SubVersion,SubVersion1);
}

/* This function initializes the debug module for the UVC application */
    void
esUVCUvcApplnDebugInit (void)
{
    CyU3PUartConfig_t uartConfig;
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

    /* Initialize the UART for printing debug messages */
    status = CyU3PUartInit();
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\resUVCUvcApplnDebugInit:CyU3PUartInit failed Error = 0x%x",status);
    }

    /* Set UART Configuration */
    uartConfig.baudRate = CY_U3P_UART_BAUDRATE_115200;
    uartConfig.stopBit = CY_U3P_UART_ONE_STOP_BIT;
    uartConfig.parity = CY_U3P_UART_NO_PARITY;
    uartConfig.txEnable = CyTrue;
    uartConfig.rxEnable = CyFalse;
    uartConfig.flowCtrl = CyFalse;
    uartConfig.isDma = CyTrue;

    /* Set the UART configuration */
    status = CyU3PUartSetConfig (&uartConfig, NULL);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\resUVCUvcApplnDebugInit:CyU3PUartSetConfig failed Error = 0x%x",status);
    }

    /* Set the UART transfer */
    status = CyU3PUartTxSetBlockXfer (0xFFFFFFFF);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\resUVCUvcApplnDebugInit:CyU3PUartTxSetBlockXfer failed Error = 0x%x",status);
    }

    /* Initialize the debug application */
    status = CyU3PDebugInit (CY_U3P_LPP_SOCKET_UART_CONS, 8);
    if (status != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "\n\resUVCUvcApplnDebugInit:CyU3PDebugInit failed Error = 0x%x",status);
    }
    CyU3PDebugPreamble (CyFalse);

}

/* Entry function for the UVC application thread. */
void esUVCUvcAppThread_Entry (uint32_t input)
{
    uint16_t wakeReason;
    uint32_t eventFlag;
    //CyU3PReturnStatus_t status;

    /* Initialize the Debug Module */
    esUVCUvcApplnDebugInit();

    /* Initialize the UVC Application */
    esUVCUvcApplnInit();

    for (;;)
    {
        CyU3PEventGet (&glTimerEvent,ES_USB_SUSP_EVENT_FLAG|ES_TIMER_RESET_EVENT, CYU3P_EVENT_OR_CLEAR, &eventFlag, CYU3P_WAIT_FOREVER);

        /* Handle TimerReset Event*/
        if( eventFlag & ES_TIMER_RESET_EVENT)
        {
            if (glIsApplnActive)
            {
            	glIsClearFeature = CyFalse;
                //esUVCUvcApplnStop();
            }
            if(glPreviewStarted == CyTrue)
            {
            	//TODO Change this function with "Sensor Specific" function to write the sensor settings & configure the CX3 for supported resolutions
                CyU3PDebugPrint(4,"\r\n Write the sensor settings & configure the CX3 for supported resolutions : line 1724");
            	//esSetCameraResolution(glFrameIndexToSet);
            	//esUVCUvcApplnStart();
            }
#ifdef RESET_TIMER_ENABLE
            CyU3PTimerModify (&UvcTimer, TIMER_PERIOD, 0);
#endif
        }
        /* Handle Suspend Event*/
        if(eventFlag & ES_USB_SUSP_EVENT_FLAG)
        {
            /* Place CX3 in Low Power Suspend mode, with USB bus activity as the wakeup source. */
            CyU3PMipicsiSleep();
            //TODO Change this function with "Sensor Specific" PowerDown function to PowerDown the sensor
            CyU3PDebugPrint(4,"\r\n PowerDown function to PowerDown the sensor : 1740");
//            esCamera_Power_Down();

            //status = CyU3PSysEnterSuspendMode (CY_U3P_SYS_USB_BUS_ACTVTY_WAKEUP_SRC, 0, &wakeReason);
            CyU3PSysEnterSuspendMode (CY_U3P_SYS_USB_BUS_ACTVTY_WAKEUP_SRC, 0, &wakeReason);
            if(glMipiActive)
            {
                CyU3PMipicsiWakeup();
                //TODO Change this function with "Sensor Specific" PowerUp function to PowerUp the sensor
                CyU3PDebugPrint(4,"\r\n PowerDown function to PowerUp the sensor : 1750");
//                esCamera_Power_Up();
            }
            continue;
        }
    } /* End of for(;;) */
}


/* Application define function which creates the threads. */
    void
CyFxApplicationDefine (
        void)
{
    void *ptr = NULL;
    uint32_t retThrdCreate = CY_U3P_SUCCESS;

    /* Allocate the memory for the thread and create the thread */
    ptr = CyU3PMemAlloc (UVC_APP_THREAD_STACK);
    retThrdCreate = CyU3PThreadCreate (&uvcAppThread,   /* UVC Thread structure */
            "30:UVC_app_thread",         /* Thread Id and name */
            esUVCUvcAppThread_Entry,          /* UVC Application Thread Entry function */
            0,                           /* No input parameter to thread */
            ptr,                         /* Pointer to the allocated thread stack */
            UVC_APP_THREAD_STACK,        /* UVC Application Thread stack size */
            UVC_APP_THREAD_PRIORITY,     /* UVC Application Thread priority */
            UVC_APP_THREAD_PRIORITY,     /* Pre-emption threshold */
            CYU3P_NO_TIME_SLICE,         /* No time slice for the application thread */
            CYU3P_AUTO_START             /* Start the Thread immediately */
            );

    /* Check the return code */
    if (retThrdCreate != 0)
    {
        /* Thread Creation failed with the error code retThrdCreate */

        /* Add custom recovery or debug actions here */

        /* Application cannot continue */
        /* Loop indefinitely */
        while(1);
    }

    /* Create GPIO application event group */
    retThrdCreate = CyU3PEventCreate(&glTimerEvent);
    if (retThrdCreate != 0)
    {
        /* Event group creation failed with the error code retThrdCreate */

        /* Add custom recovery or debug actions here */

        /* Application cannot continue */
        /* Loop indefinitely */
        while(1);
    }
}

/*
 * Main function
 */

int main (void)
{
    CyU3PIoMatrixConfig_t io_cfg;
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

    /* Initialize the device */
    status = CyU3PDeviceInit (NULL);
    if (status != CY_U3P_SUCCESS)
    {
        goto handle_fatal_error;
    }

    /* Initialize the caches. Enable instruction cache and keep data cache disabled.
     * The data cache is useful only when there is a large amount of CPU based memory
     * accesses. When used in simple cases, it can decrease performance due to large
     * number of cache flushes and cleans and also it adds to the complexity of the
     * code. */
    status = CyU3PDeviceCacheControl (CyTrue, CyFalse, CyFalse);
    if (status != CY_U3P_SUCCESS)
    {
        goto handle_fatal_error;
    }

    /* Configure the IO matrix for the device.*/
    io_cfg.isDQ32Bit = CyFalse;

    io_cfg.useUart   = CyTrue;
    io_cfg.useI2C    = CyTrue;
    io_cfg.useI2S    = CyFalse;
    io_cfg.useSpi    = CyFalse;
    io_cfg.lppMode   = CY_U3P_IO_MATRIX_LPP_DEFAULT;
    /* No GPIOs are enabled. */
    io_cfg.gpioSimpleEn[0]  = 0;
    io_cfg.gpioSimpleEn[1]  = 0;
    io_cfg.gpioComplexEn[0] = 0;
    io_cfg.gpioComplexEn[1] = 0;
    status = CyU3PDeviceConfigureIOMatrix (&io_cfg);
    if (status != CY_U3P_SUCCESS)
    {
        goto handle_fatal_error;
    }

    /* This is a non returnable call for initializing the RTOS kernel */
    CyU3PKernelEntry ();

    /* Dummy return to make the compiler happy */
    return 0;

handle_fatal_error:
    /* Cannot recover from this error. */
    while (1);
}
/* [ ] */
