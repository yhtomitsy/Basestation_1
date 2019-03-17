======================================
1. Create new project using Lattice Diamond for Windows
2. Open Active-HDL Lattice Edition GUI tool
3. Modify the "do" file located in \<project_dir>\<core_instance_name>\<core_name>_eval\<core_instance_name>\sim\aldec\
   a. Specify working directory (sim_working_folder).
      ex. set sim_working_folder "C:/my_design"
   b. Specify workspace name that will be created in working directory.
      ex. set workspace_name "design_space"
   c. Specify design name.
      ex. set design_name "DesignA"
   d. Specify design path where the IP Core generated using Clarity Designer is located.
      ex. set design_path "C:/my_designs/DesignA"
   e. Specify design instance name (same as the instance name specified in Clarity Designer).
      ex. set design_inst "DesignA_inst"
   f. Specify Lattice Diamond Primitive path (diamond_dir) to where it is installed.
      ex. set diamond_dir "C:/lscc/diamond/3.8_x64"
   g. Update testbench parameters to customize data size, clock and/or other settings. See additional info related to
      Testbench Parameters below.
4. Click Tools -> Execute macro, then select the do file
5. Wait for simulation to finish

###############
Testbench Parameters

Below are the testbench directives which can be modified by setting the define in the vlog command in the "do" file.
Example:
vlog \
+define+NUM_FRAMES=60 \
+define+NUM_LINES=1080 \
....

   * NUM_PIXELS      : Number of pixels per line
   * NUM_LINES       : Number of lines per frame
   * NUN_FRAMES      : Number of frames to be transmitted
     *These parameters can be manually included in a "do" file or TB define file.

   Optional:
   a. The following timing parameters (in ps) are set to minimum based from MIPI specs:
     - DPHY_LPX
     - DPHY_CLK_PREPARE
     - DPHY_CLK_ZERO
     - DPHY_CLK_TRAIL
     - DPHY_CLK_PRE
     - DPHY_CLK_POST
     - DPHY_HS_PREPARE
     - DPHY_HS_ZERO
     - DPHY_HS_TRAIL

   b. The following timing parameters are related to start of dphy model driving:
     - DPHY_INIT_DRIVE_DELAY : delay from reset deassertion or tinit_done assertion before ch0 starts driving data.
                               if tinit_done signal does not exist, testbench will skip waiting for tinit_done signal
                               the tester can adjust this parameter to meet the initialization before driving data.
     - CH0_INIT_DELAY        : delay from initialization before ch0 starts transmitting data in byte clock. Default is 0.
     - CH1_INIT_DELAY        : delay from initialization before ch1 starts transmitting data in byte clock. Default is 0.
     - CH2_INIT_DELAY        : delay from initialization before ch2 starts transmitting data in byte clock. Default is 0.
     - CH3_INIT_DELAY        : delay from initialization before ch3 starts transmitting data in byte clock. Default is 0.

   c. Data types
     - DT_RAW8               : used to set the data transaction to RAW8
     - DT_RAW10              : used to set the data transaction to DT_RAW10
     - DT_RAW12              : used to set the data transaction to DT_RAW12
     - DT_RGB888             : used to set the data transaction to DT_RGB888
     - DT_YUV420_10          : used to set the data transaction to DT_YUV420_10
     - DT_YUV420_8           : used to set the data transaction to DT_YUV420_8
     - DT_YUV422_10          : used to set the data transaction to DT_YUV422_10
     - DT_YUV422_8           : used to set the data transaction to DT_YUV422_8
      * Default is RAW10 if data type is not specified by user.

   d. Other parameters
     - DPHY_CLK_PERIOD       : used to set the DPHY clock frequency of the design
     - DPHY_LPS_GAP          : used to inject LPS delay (in ps) in between HS transactions
     - FRAME_GAP             : used to inject LPS delay (in ps) in between frames
     - VC_CH0                : used to set virtual channel of DPHY CSI2 model 0
     - VC_CH1                : used to set virtual channel of DPHY CSI2 model 1
     - VC_CH2                : used to set virtual channel of DPHY CSI2 model 2
     - VC_CH3                : used to set virtual channel of DPHY CSI2 model 3
     - LS_LE_EN              : used to enable DPHY model transmission of LS/LE short packets

   *User can override the default timing parameters using defines above.
======================================
