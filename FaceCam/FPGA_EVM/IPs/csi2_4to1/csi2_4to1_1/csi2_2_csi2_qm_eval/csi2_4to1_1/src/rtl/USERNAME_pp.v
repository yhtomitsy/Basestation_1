#include <orcapp_head>

module USERNAME
#(
//-----------------------------------------------------------------------------
// PARAMETERS
//-----------------------------------------------------------------------------

#ifdef PP_LATTICE_RX1
  parameter       DPHY_RX_IP_CH1   = "LATTICE",       
#else
  parameter       DPHY_RX_IP_CH1   = "MIXEL",
#endif


// valid values of TX PLL parameters :
// N = 1-32
// M = 16-255
// O = 1,2,4,8

#ifdef PP_PLL_CN
  parameter [4:0] PLL_CN           = PP_PLL_CN,      
#else 
  parameter [4:0] PLL_CN           = 5'b1_0000,      
#endif

#ifdef PP_PLL_CM
  parameter [7:0] PLL_CM           = PP_PLL_CM,   
#else
  parameter [7:0] PLL_CM           = 8'b1101_0000,   
#endif

#ifdef PP_PLL_CO
  parameter [1:0] PLL_CO           = PP_PLL_CO,          
#else
  parameter [1:0] PLL_CO           = 2'b00,          
#endif


// Virtual Channel ID assignment
// valid values are 2'd0-2'd3; cannot be the same value if cfg'd as VC merge 

#ifdef PP_VC_CH0
  parameter [1:0] VC_CH0           = PP_VC_CH0,
#else
  parameter [1:0] VC_CH0           = 2'b00,
#endif

#ifdef PP_VC_CH1
  parameter [1:0] VC_CH1           = PP_VC_CH1,
#else
  parameter [1:0] VC_CH1           = 2'b01,
#endif

// TINIT_VALUE - slave initialization time. number of byteclk cycles before 
// issuing any transaction to the slave to give it time to initialize.
// cmos2dphy parameter  

#ifdef PP_TINIT_VALUE
  parameter TINIT_VALUE=PP_TINIT_VALUE,
#else
  parameter TINIT_VALUE=9400,
#endif


// target tx byteclock frequency, in MHz

#ifdef PP_TX_FREQ_TGT
  parameter TX_FREQ_TGT=PP_TX_FREQ_TGT
#else
  parameter TX_FREQ_TGT=93
#endif

)

//-----------------------------------------------------------------------------
// PORT DECLARATIONS
//-----------------------------------------------------------------------------
(
 input 	reset_n_i,
#ifdef PP_RX_CLK_MODE_HS_LP //~~~~~~~~~ 
 input 	ref_clk_i, 
#endif

 input  mux_sel_i,

 inout 	clk_ch0_p_i,
 inout 	clk_ch0_n_i,
 inout 	clk_ch1_p_i,
 inout 	clk_ch1_n_i,

 inout 	clk_ch2_p_i,
 inout 	clk_ch2_n_i,
 inout 	clk_ch3_p_i,
 inout 	clk_ch3_n_i,

// d0 always defined regardless of NO of LANES
 inout 	d0_ch0_n_i,
 inout 	d0_ch0_p_i,
 inout 	d0_ch1_n_i,
 inout 	d0_ch1_p_i,

 inout 	d0_ch2_n_i,
 inout 	d0_ch2_p_i,
 inout 	d0_ch3_n_i,
 inout 	d0_ch3_p_i,

#ifdef PP_NO_OF_LANE_2 //--------
 inout 	d1_ch0_n_i,
 inout 	d1_ch0_p_i,
 inout 	d1_ch1_n_i,
 inout 	d1_ch1_p_i,

 inout 	d1_ch2_n_i,
 inout 	d1_ch2_p_i,
 inout 	d1_ch3_n_i,
 inout 	d1_ch3_p_i,

#endif
#ifdef PP_NO_OF_LANE_4 //-------- 
 inout 	d1_ch0_n_i,
 inout 	d1_ch0_p_i,
 inout 	d1_ch1_n_i,
 inout 	d1_ch1_p_i,
 inout 	d1_ch2_n_i,
 inout 	d1_ch2_p_i,
 inout 	d1_ch3_n_i,
 inout 	d1_ch3_p_i,


 inout 	d2_ch0_n_i,
 inout 	d2_ch0_p_i,
 inout 	d2_ch1_n_i,
 inout 	d2_ch1_p_i,
 inout 	d2_ch2_n_i,
 inout 	d2_ch2_p_i,
 inout 	d2_ch3_n_i,
 inout 	d2_ch3_p_i,


 inout 	d3_ch0_n_i,
 inout 	d3_ch0_p_i,
 inout 	d3_ch1_n_i,
 inout 	d3_ch1_p_i,
 inout 	d3_ch2_n_i,
 inout 	d3_ch2_p_i,
 inout 	d3_ch3_n_i,
 inout 	d3_ch3_p_i,

#endif //---------------------

// these signals within MISC_ON are used only for simulations and debug
#ifdef PP_MISC_ON //..............................

 #ifdef PP_MISC_TXPLLLOCK 
 output tx_pll_lock_o,
 #endif
 #ifdef PP_MISC_TINITDONE
 output tinit_done_o,
 #endif
 #ifdef PP_MISC_RX0_SPEN
 output rx0_sp_en_o,
 #endif
 #ifdef PP_MISC_RX0_LPEN
 output rx0_lp_en_o,
 #endif
 #ifdef PP_MISC_RX0_HSSYNC
 output rx0_hs_sync_o,
 #endif
 #ifdef PP_MISC_RX1_SPEN
 output rx1_sp_en_o,
 #endif
 #ifdef PP_MISC_RX1_LPEN
 output rx1_lp_en_o,
 #endif
 #ifdef PP_MISC_RX1_HSSYNC
 output rx1_hs_sync_o,
 #endif
 #ifdef PP_MISC_TX_FVEN
 output tx_fv_en_o,
 #endif
 #ifdef PP_MISC_TX_LVEN
 output tx_lv_en_o,
 #endif
 #ifdef PP_MISC_BYTEDATVLD
 output tx_byte_data_vld,
 #endif
#endif // MISC_ON .............................


 output clk_p_o,
 output clk_n_o,

#ifdef PP_NO_OF_LANE_4 //--------
 output d3_n_o,
 output d3_p_o,
 output d2_n_o,
 output d2_p_o,
 output d1_n_o,
 output d1_p_o,
#endif
#ifdef PP_NO_OF_LANE_2 //-------- 
 output d1_n_o,
 output d1_p_o,
#endif //---------------------
 output d0_n_o,
 output d0_p_o

);	


//-----------------------------------------------------------------------------
// LOCAL PARAMETERS
//-----------------------------------------------------------------------------	
parameter test_mode=1'b0;


// WAIT_LESS - dphy2cmos checks for frame start before enabling output 
#ifdef PP_TX_WAIT_LESS_15MS
parameter           TX_WAIT_TIME    = "LESS_15MS";
#endif
#ifdef PP_TX_WAIT_OVER_15MS
parameter           TX_WAIT_TIME    = "OVER_15MS";
#endif

#ifdef PP_RX_GEAR_8
parameter           RX_GEAR         = 8;              // DPHY Rx Clock Gear
#endif
#ifdef PP_RX_GEAR_16
parameter           RX_GEAR         = 16;            // DPHY Rx Clock Gear
#endif

#ifdef PP_TX_GEAR_8
parameter           TX_GEAR         = 8;            // DPHY Tx Clock Gear
#endif
#ifdef PP_TX_GEAR_16
parameter           TX_GEAR         = 16;            // DPHY Rx Clock Gear
#endif

#ifdef PP_RGB888
parameter           DT              = "RGB888" ;       //  don't care for this Soft IP
#endif
#ifdef PP_RAW8
parameter           DT              = "RAW8";
#endif
#ifdef PP_RAW10
parameter           DT              = "RAW10";
#endif
#ifdef PP_RAW12	                 
parameter           DT              = "RAW12";
#endif
#ifdef PP_YUV420_8	                 
parameter           DT              = "YUV420_8";
#endif
#ifdef PP_YUV422_8	                 
parameter           DT              = "YUV422_8";
#endif
#ifdef PP_YUV420_10                 
parameter           DT              = "YUV420_10";
#endif
#ifdef PP_YUV422_10                 
parameter           DT              = "YUV422_10";
#endif
#ifdef PP_YUV420_8_CSPS             
parameter           DT              = "YUV420_8_CSPS";
#endif
#ifdef PP_YUV420_10_CSPS            
parameter           PP_DT              = "YUV420_10_CSPS";
#endif

// number of dphy data lanes
#ifdef PP_NO_OF_LANE_1  
parameter           LANE_COUNT = 1;
#endif
#ifdef PP_NO_OF_LANE_2 
parameter           LANE_COUNT = 2;
#endif
#ifdef PP_NO_OF_LANE_4 
parameter           LANE_COUNT = 4;
#endif

//1024 deep for lane4 cfg
parameter           LBUF_DEPTH      = 4096/PP_LANE_COUNT;


//RX_CLK_MODE parameter
#ifdef PP_RX_CLK_MODE_HS_LP //.............. 
parameter        RX_CLK_MODE = "HS_LP";  //"HS_LP" or "HS_ONLY"
#else  // RX_CLK_MODE_HS_ONLY
parameter        RX_CLK_MODE = "HS_ONLY";
#endif

//TX_CLK_MODE parameter
#ifdef PP_TX_CLK_MODE_HS_LP //..............
parameter        TX_CLK_MODE = "HS_LP";  //"HS_LP" or "HS_ONLY"
#else  // TX_CLK_MODE_HS_ONLY
parameter        TX_CLK_MODE = "HS_ONLY";
#endif

//TINIT_COUNT parameter
#ifdef PP_BYPASS_TINIT //..............
parameter        TINIT_COUNT = "OFF";  //"HS_LP" or "HS_ONLY"
#else  
parameter        TINIT_COUNT = "ON";
#endif

//Lane aligner enable
#ifdef PP_LANE_ALIGN
parameter        LANE_ALIGN = "ON";
#else
parameter        LANE_ALIGN = "OFF";
#endif

//-----------------------------------------------------------------------------
// WIRE and REGISTER DECLARATIONS
//-----------------------------------------------------------------------------
wire tx_refclk;
wire pix_clk;
wire pll_clkop;

wire clk_byte_fr;
wire clk_lp_ctrl;
wire pll_lock;
wire reset_lp_n;
wire reset_byte_fr_n;
wire tinit_done_w;

// Registers for synchronizing reset to different clock domains
reg         reset_lp_n_meta;
reg         reset_lp_n_sync;
reg         reset_byte_fr_n_meta;
reg         reset_byte_fr_n_sync;

assign reset_lp_n         = reset_lp_n_sync;
assign reset_byte_fr_n    = reset_byte_fr_n_sync;
#ifdef PP_MISC_ON
assign tinit_done_o       = tinit_done_w;
#endif
// Synchronized reset for each clock domain

#ifdef PP_RX_CLK_MODE_HS_LP //~~~~~~~~~
////added option to use Snow PLL to avoid frequency holes of Mixel PLL
assign pix_clk   = ref_clk_i;
#else // RX_CLK_MODE_HS_LP
assign pix_clk  = clk_byte_fr;
#endif


//-----------------------------------------------------------------------------
// PROCEDURAL BLOCKS
//-----------------------------------------------------------------------------
 /*synthesis translate_off*/
 GSR GSR_INST (1'b1);
 /*synthesis translate_on*/

////added option to use Snow PLL to avoid frequency holes of Mixel PLL
#ifdef PP_USE_PLL_X2
assign tx_refclk = pll_clkop;
#else
#ifdef PP_USE_PLL_X4
assign tx_refclk = pll_clkop;
#else
#ifdef PP_USE_PLL_X8
assign tx_refclk = pll_clkop;
#else //no Snow PLL
assign tx_refclk = pix_clk;
assign pll_lock  = 1'b1;
#endif
#endif
#endif

//// Snow PLL
#ifdef PP_USE_PLL_X2
pll_wrapper pll_wrapper_inst (
  .CLKI (pix_clk),
  .CLKOP (pll_clkop),
  .LOCK  (pll_lock)
);
#endif
#ifdef PP_USE_PLL_X4
pll_wrapper pll_wrapper_inst (
  .CLKI (pix_clk),
  .CLKOP (pll_clkop),
  .LOCK  (pll_lock)
);
#endif
#ifdef PP_USE_PLL_X8
pll_wrapper pll_wrapper_inst (
  .CLKI (pix_clk),
  .CLKOP (pll_clkop),
  .LOCK  (pll_lock)
);
#endif


  always @(posedge clk_lp_ctrl or negedge reset_n_i)
  begin
      if (~reset_n_i)
      begin
          reset_lp_n_meta <= 0;
          reset_lp_n_sync <= 0;
      end
      else
      begin
          reset_lp_n_meta <= reset_n_i;
          reset_lp_n_sync <= reset_lp_n_meta;
      end
  end


// tx pll is already locked before the rx can start data transfer
  always @(posedge clk_byte_fr or negedge reset_n_i)
  begin
      if (~reset_n_i)
      begin
          reset_byte_fr_n_meta <= 0;
          reset_byte_fr_n_sync <= 0;
      end
      else
      begin
        //  reset_byte_fr_n_meta <= reset_n_i & tx_pll_lock_o;
          reset_byte_fr_n_meta <= reset_n_i && tinit_done_w ;
          reset_byte_fr_n_sync <= reset_byte_fr_n_meta;
      end
  end


USERNAME_csi2_2_csi2_ip # (
        .RX_CLK_MODE                    (RX_CLK_MODE),
        .TX_CLK_MODE                    (TX_CLK_MODE),
        .DPHY_RX_IP_CH1                 (DPHY_RX_IP_CH1),
        .TINIT_COUNT                    (TINIT_COUNT),
        .LANE_ALIGN                     (LANE_ALIGN),
	.LANE_COUNT                     (PP_LANE_COUNT),	  
	.PLL_M                          (PLL_CM),
	.PLL_N                          (PLL_CN),
	.PLL_O                          (PLL_CO),
	.TINIT_VALUE                    (TINIT_VALUE),
	.TX_WAIT_TIME                   (TX_WAIT_TIME),
        .TX_FREQ_TGT                    (TX_FREQ_TGT),
        .RX_GEAR                        (RX_GEAR),
        .TX_GEAR                        (TX_GEAR),
        .DT                             (DT),
        .LBUF_DEPTH                     (LBUF_DEPTH),     
        .VC_CH0                         (VC_CH0),
        .VC_CH1                         (VC_CH1)

	)
	csi2csi_inst
	(
	.reset_n_i                      (reset_n_i),
	//.reset_n_i                    (reset_n_i),
	.reset_lp_n_i                   (reset_lp_n),
	.reset_byte_fr_n_i              (reset_byte_fr_n),

  	.mux_sel_i                      (mux_sel_i),
	.ref_clk_i                      (ref_clk_i), // used as byteclk_fr for hs_lp gear8
////added separate port for pixel clock, added pll lock
        .pix_clk_i                      (pix_clk),
        .pll_lock_i                     (pll_lock),
        .tx_refclk_i                    (tx_refclk),

	.clk_lp_ctrl_i                  (clk_lp_ctrl),
	 

#ifdef PP_RX_CLK_MODE_HS_ONLY
        .rx_byte_clk_fr_ch0             (clk_byte_fr), // from rx_byteclk_ch0
#endif
#ifdef PP_RX_CLK_MODE_HS_LP
        .tx_byte_clk_o                  (clk_byte_fr),// from tx mixel pll  
#endif
        .clk_ch0_p_i                    (clk_ch0_p_i),
        .clk_ch0_n_i                    (clk_ch0_n_i),
        .clk_ch1_p_i                    (clk_ch1_p_i),
        .clk_ch1_n_i                    (clk_ch1_n_i),
        .clk_ch2_p_i                    (clk_ch2_p_i),
        .clk_ch2_n_i                    (clk_ch2_n_i),
        .clk_ch3_p_i                    (clk_ch3_p_i),
        .clk_ch3_n_i                    (clk_ch3_n_i),

	.d0_ch0_p_i                     (d0_ch0_p_i),
        .d0_ch0_n_i                     (d0_ch0_n_i),
        .d0_ch1_p_i                     (d0_ch1_p_i),
        .d0_ch1_n_i                     (d0_ch1_n_i),
	.d0_ch2_p_i                     (d0_ch2_p_i),
        .d0_ch2_n_i                     (d0_ch2_n_i),
        .d0_ch3_p_i                     (d0_ch3_p_i),
        .d0_ch3_n_i                     (d0_ch3_n_i),

        .d0_p_o                         (d0_p_o),
        .d0_n_o                         (d0_n_o),
#ifdef PP_NO_OF_LANE_2 //--------
        .d1_ch0_p_i                     (d1_ch0_p_i),
        .d1_ch0_n_i                     (d1_ch0_n_i),
        .d1_ch1_p_i                     (d1_ch1_p_i),
        .d1_ch1_n_i                     (d1_ch1_n_i),
        .d1_ch2_p_i                     (d1_ch2_p_i),
        .d1_ch2_n_i                     (d1_ch2_n_i),
        .d1_ch3_p_i                     (d1_ch3_p_i),
        .d1_ch3_n_i                     (d1_ch3_n_i),


        .d1_p_o                         (d1_p_o),
        .d1_n_o                         (d1_n_o),
#endif
#ifdef PP_NO_OF_LANE_4 //--------

        .d1_ch0_p_i                     (d1_ch0_p_i),
        .d1_ch0_n_i                     (d1_ch0_n_i),
        .d1_ch1_p_i                     (d1_ch1_p_i),
        .d1_ch1_n_i                     (d1_ch1_n_i),
        .d1_ch2_p_i                     (d1_ch2_p_i),
        .d1_ch2_n_i                     (d1_ch2_n_i),
        .d1_ch3_p_i                     (d1_ch3_p_i),
        .d1_ch3_n_i                     (d1_ch3_n_i),
	 
        .d2_ch0_p_i                     (d2_ch0_p_i),
        .d2_ch0_n_i                     (d2_ch0_n_i),
        .d2_ch1_p_i                     (d2_ch1_p_i),
        .d2_ch1_n_i                     (d2_ch1_n_i),
        .d2_ch2_p_i                     (d2_ch2_p_i),
        .d2_ch2_n_i                     (d2_ch2_n_i),
        .d2_ch3_p_i                     (d2_ch3_p_i),
        .d2_ch3_n_i                     (d2_ch3_n_i),

        .d3_ch0_p_i                     (d3_ch0_p_i),
        .d3_ch0_n_i                     (d3_ch0_n_i),
        .d3_ch1_p_i                     (d3_ch1_p_i),
        .d3_ch1_n_i                     (d3_ch1_n_i),
        .d3_ch2_p_i                     (d3_ch2_p_i),
        .d3_ch2_n_i                     (d3_ch2_n_i),
        .d3_ch3_p_i                     (d3_ch3_p_i),
        .d3_ch3_n_i                     (d3_ch3_n_i),

        .d1_p_o                         (d1_p_o),
        .d1_n_o                         (d1_n_o),
        .d2_p_o                         (d2_p_o),
        .d2_n_o                         (d2_n_o),
        .d3_p_o                         (d3_p_o),
        .d3_n_o                         (d3_n_o),

#endif //---------------------

	.clk_n_o                        (clk_n_o),
	.clk_p_o                        (clk_p_o),


	.tx_pll_lock_o                  (tx_pll_lock_o),
	.tinit_done_o                   (tinit_done_w),
	// debug port
	.rx0_sp_en_o                    (rx0_sp_en_o),
        .rx0_lp_en_o                    (rx0_lp_en_o),
        .rx0_hs_sync_o                  (rx0_hs_sync_o),
        .rx1_sp_en_o                    (rx1_sp_en_o),
	.rx1_lp_en_o                    (rx1_lp_en_o),
    	.rx1_hs_sync_o                  (rx1_hs_sync_o),
        .tx_fv_en_o                     (tx_fv_en_o),
        .tx_lv_en_o                     (tx_lv_en_o),
        .tx_byte_data_vld               (tx_byte_data_vld)
);



#ifdef PP_RX_CLK_MODE_HS_ONLY //------------------
  assign clk_lp_ctrl = 1'b1;
#else // RX_CLK_MODE_HS_LP  //-----------------
  #ifdef PP_TX_GEAR_8
    assign clk_lp_ctrl  = ref_clk_i; 
  #else
    assign clk_lp_ctrl  = clk_byte_fr;
  #endif
#endif // clk mode ----------------------------



endmodule 
