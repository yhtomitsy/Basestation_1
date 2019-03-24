#include <orcapp_head>
`timescale 1ns/1ps

module USERNAME_cmos_2_dphy_ip #(
////added support for HS_ONLY mode
  parameter CLK_MODE         = "HS_ONLY",
////added disable tinit count
  parameter TINIT_COUNT      = "ON",

  parameter  VC              = 2,           // 2-bit Virtual channel number
  parameter  WC              = 16'd36,	    // 16-bit Word Count in DPHY packet
  parameter  CRC16           = 1,           // Appends 16-bit checksum to the end of packet.  
                                            // 0 = off, 1 = on by default. CRC is always set to 1.
                                            // Turning off will append 16'hFFFF to end of packet.
  parameter  DATA_WIDTH      = 16,          // Internally used. Always set to 16.              
  parameter  TINIT_VALUE     = 1000,        // Specify time for the DPHY Tinit requirement. 
                                            // This is dependent on byte clock
  parameter  ROM_WAIT_TIME   = 200,         // Specify delay time for sending DCS commands. 
                                            // This is dependent on DCS clock.
  parameter  CN              = 5'b11100,    // Tx PLL Input Divider
                                            // (25 <= pix_clk/N <= 30)  
  parameter  CM              = 8'b11101110, // Tx PLL Feedback Divider
                                            // (640 <= (pix_clk/(N*O))*M) <= 1500)                 
  parameter  CO              = 2'b00,       // Tx PLL Output Divider
                                            // Refer to Mixel PLL Specs for valid values
  parameter  TX_FREQ_TGT     = 8'd112,      // Set the target Tx byte clock which is used by DPHY TX.
                                            // Setting this parameter does not mean that design will
                                            // output the specified byte clock. This is just used as a
                                            // reference value inside the design.											
#ifdef PP_NUM_TX_LANE_4                        // Sets number of Tx DPHY Lanes
  parameter	LANE_WIDTH       = 4,
#endif
#ifdef PP_NUM_TX_LANE_3
  parameter	LANE_WIDTH       = 3,
#endif
#ifdef PP_NUM_TX_LANE_2
  parameter	LANE_WIDTH       = 2,
#endif
#ifdef PP_NUM_TX_LANE_1
  parameter	LANE_WIDTH       = 1,
#endif // NUM_TX_LANE

#ifdef PP_NUM_PIX_LANE_10                      // Sets the number of incoming pixel per pixel clock
  parameter	NUM_PIX_LANE	 = 10,
#endif
#ifdef PP_NUM_PIX_LANE_8        
  parameter	NUM_PIX_LANE	 = 8,
#endif
#ifdef PP_NUM_PIX_LANE_6        
  parameter	NUM_PIX_LANE	 = 6,
#endif
#ifdef PP_NUM_PIX_LANE_4        
  parameter	NUM_PIX_LANE	 = 4,
#endif
#ifdef PP_NUM_PIX_LANE_2        
  parameter	NUM_PIX_LANE	 = 2,
#endif
#ifdef PP_NUM_PIX_LANE_1        
  parameter	NUM_PIX_LANE	 = 1,
#endif // NUM_PIX_LANE

#ifdef PP_TX_GEAR_16                           // Sets the Tx gearing 
  parameter	GEAR_16         = 1,            // 16:1 gearing
#endif
#ifdef PP_TX_GEAR_8
  parameter	GEAR_16         = 0,            // 8:1 gearing
#endif // TX_GEAR

#ifdef PP_TX_DSI                               // Used for DSI interface
  parameter DSI_FORMAT      = 1,            // Internally used to set if CMOS2DPHY interfaces
                                            // with DSI or CSI: 0 - CSI2 ; 1 = DSI
  parameter EOTP            = 1'b1,         // appends end of transfer packet. 0 = off, 1 = on
  parameter FILTER_1STLINE  = 0,            // 0 - Disable, 1 - Enable ;
                                            // Internally used for CSI2CSI Passthrough format.         
#ifdef PP_RGB888                               // Sets RGB888/RGB666 data type
  parameter	DT              = 6'h3E,
  parameter	WORD_WIDTH      = 24,
#endif
#ifdef PP_RGB666
  parameter	DT              = 6'h1E,
  parameter	WORD_WIDTH      = 18,
#endif // DSI: RGB Data type                // End of DSI Interface
#endif
#ifdef PP_TX_CSI2                              // Used for CSI2 interface
  parameter DSI_FORMAT      = 0,
  parameter EOTP            = 1'b0,
  parameter FILTER_1STLINE  = 0,

#ifdef PP_RGB888                               // Sets the CSI Data Type
  parameter DT              = 6'h24,
  parameter WORD_WIDTH      = 24,
#endif
#ifdef PP_RAW8
  parameter DT              = 6'h2A,
  parameter WORD_WIDTH      = 8,
#endif
#ifdef PP_RAW10
  parameter	DT              = 6'h2B,
  parameter	WORD_WIDTH      = 10,
#endif
#ifdef PP_RAW12
  parameter DT              = 6'h2C,
  parameter WORD_WIDTH      = 12,
#endif
#ifdef PP_YUV420_8
  parameter DT              = 6'h18,
  parameter WORD_WIDTH      = 8,
#endif
#ifdef PP_YUV420_10
  parameter DT              = 6'h19,
  parameter WORD_WIDTH      = 10,
#endif
#ifdef PP_YUV422_8
  parameter DT              = 6'h1E,
  parameter WORD_WIDTH      = 8,
#endif
#ifdef PP_YUV422_10
  parameter DT              = 6'h1F,
  parameter WORD_WIDTH      = 10,
#endif // CSI: CSI Data format              // End of CSI2 Data type CSI interface
#endif

// not available in CSI2 to CSI2 IP
// Used for debugging purposes. Used to set parameters for color bar generator.
#ifdef PP_PATTERN_GEN	
  parameter H_ACTIVE        = 1920,
  parameter H_TOTAL         = 2200,
  parameter V_ACTIVE        = 1080,
  parameter V_TOTAL         = 1125,
  parameter H_SYNC          = 44,
  parameter H_BACK_PORCH    = 148,
  parameter H_FRONT_PORCH   = 88,
  parameter V_SYNCH         = 5,
  parameter V_BACK_PORCH    = 36,
  parameter V_FRONT_PORCH   = 4,
  parameter PATTERN_MODE    = 1,
#endif // PATTERN_GEN
  parameter TESTMODE        = 0
)
(
////added ports for handshaking between Rx/bridge and Tx
  input 		   clk_hs_en_i, // request LP->HS for clock lane
  input 		   d_hs_en_i, // request LP->HS for data lane
  output 		   d_hs_rdy_o, // data lane is in HS mode
  output wire 		   d_hs_en_o, // request LP->HS for data lane from pixel2byte
 // used by CSI2CSI
  output wire 		   ld_pyld_o,
  output wire              phdr_xfr_done_o,

  input 		   reset_n_i, // (active low) asynchronous reset
  input 		   pix_clk_i, // pixel clock

////Added separate port for Mixel PLL refclk, and Snow PLL lock
  input 		   ref_clk_i, // Mixel PLL refclk
  input 		   pll_lock_i, // Snow PLL lock
  
  output 		   byte_clk_o, // byte clock from DPHY
  output 		   pll_lock_o, // PLL clock lock signal
  output 		   tinit_done_o, // Tinit done
  
  input 		   core_clk_i, // core clock 
  input 		   pd_dphy_i, // DPHY PD signal

#ifdef PP_CSI2CSI                              // ports for CSI2CSI IP
  input 		   sp_req_i, // Short packet request
  input 		   lp_req_i, // start trigger of line valid
  
  input [15:0] 		   wc_i, // Word count value
  input [1:0] 		   vc_i, // Virtual channel
  input [5:0] 		   dt_i, // data type
  
  input 		   byte_data_en_i,// Byte data enable input
  input [4*DATA_WIDTH-1:0] byte_data_i, // Byte data
#else
#ifdef PP_DSI2DSI                              // ports for DSI2DSI IP
  input 		   dphy_pkten_i,
  input [4*DATA_WIDTH-1:0] dphy_pkt_i,
  // DCS ROM related signals 
  input 		   start_i,
  input 		   escape_i,
  input 		   stop_i,
  input [7:0] 		   data_i,
  input 		   rom_done_i,
  input 		   dcs_clk_i, 
  output 		   ready_o, 
  output 		   dcsrom_done_o, // complete sending DCS ROM commands

#else                                       // For all ip using pixel bus
#ifdef PP_TX_DSI                               // DSI Interface
  input 		   dcs_clk_i, // dcs clock
  input 		   vsync_i, // vertical sync input for CMOS interface
  input 		   hsync_i, // horizontal sync input for CMOS interface
  input 		   de_i, // data enable input for CMOS interface
#ifdef PP_NUM_PIX_LANE_4
  input [WORD_WIDTH-1:0]   pixdata_d3_i, // pixel data for CMOS interface
  input [WORD_WIDTH-1:0]   pixdata_d2_i, 
  input [WORD_WIDTH-1:0]   pixdata_d1_i, 
  input [WORD_WIDTH-1:0]   pixdata_d0_i, 
#endif
#ifdef PP_NUM_PIX_LANE_2
  input [WORD_WIDTH-1:0]   pixdata_d1_i, // pixel data for CMOS interface
  input [WORD_WIDTH-1:0]   pixdata_d0_i, 
#endif
#ifdef PP_NUM_PIX_LANE_1
  input [WORD_WIDTH-1:0]   pixdata_d0_i, // pixel data for CMOS interface
#endif // NUM_PIX_LANE_
  // DCS ROM Related signals     
  input 		   start_i,
  input 		   escape_i,
  input 		   stop_i,
  input [7:0] 		   data_i,
  input 		   rom_done_i,
  input 		   hsdcs_done_i,
  input 		   hsdcs_pkten_i,
  input [4*DATA_WIDTH-1:0] hsdcs_pktdata_i,

  output 		   ready_o, //Controller will idle unless ready_i = 1'b1
  output 		   dcsrom_done_o, // complete sending DCS ROM commands
#endif // TX_DSI

#ifdef PP_TX_CSI2                              // CSI Interface
  input 		   fv_i, // frame valid input for CMOS i/f
  input 		   lv_i, // line valid input for CMOS i/f
  input 		   dvalid_i, // data valid
#ifdef PP_NUM_PIX_LANE_10 // Sets number of pixel per pixel clock
  input [WORD_WIDTH-1:0]   pixdata_d9_i,
  input [WORD_WIDTH-1:0]   pixdata_d8_i,
  input [WORD_WIDTH-1:0]   pixdata_d7_i,
  input [WORD_WIDTH-1:0]   pixdata_d6_i,
  input [WORD_WIDTH-1:0]   pixdata_d5_i,
  input [WORD_WIDTH-1:0]   pixdata_d4_i,
  input [WORD_WIDTH-1:0]   pixdata_d3_i,
  input [WORD_WIDTH-1:0]   pixdata_d2_i,
  input [WORD_WIDTH-1:0]   pixdata_d1_i,
  input [WORD_WIDTH-1:0]   pixdata_d0_i,
#endif
#ifdef PP_NUM_PIX_LANE_8
  input [WORD_WIDTH-1:0]   pixdata_d7_i,
  input [WORD_WIDTH-1:0]   pixdata_d6_i,
  input [WORD_WIDTH-1:0]   pixdata_d5_i,
  input [WORD_WIDTH-1:0]   pixdata_d4_i,
  input [WORD_WIDTH-1:0]   pixdata_d3_i,
  input [WORD_WIDTH-1:0]   pixdata_d2_i,
  input [WORD_WIDTH-1:0]   pixdata_d1_i,
  input [WORD_WIDTH-1:0]   pixdata_d0_i,
#endif
#ifdef PP_NUM_PIX_LANE_6
  input [WORD_WIDTH-1:0]   pixdata_d5_i,
  input [WORD_WIDTH-1:0]   pixdata_d4_i,
  input [WORD_WIDTH-1:0]   pixdata_d3_i,
  input [WORD_WIDTH-1:0]   pixdata_d2_i,
  input [WORD_WIDTH-1:0]   pixdata_d1_i,
  input [WORD_WIDTH-1:0]   pixdata_d0_i,
#endif
#ifdef PP_NUM_PIX_LANE_4
  input [WORD_WIDTH-1:0]   pixdata_d3_i,
  input [WORD_WIDTH-1:0]   pixdata_d2_i,
  input [WORD_WIDTH-1:0]   pixdata_d1_i,
  input [WORD_WIDTH-1:0]   pixdata_d0_i,
#endif
#ifdef PP_NUM_PIX_LANE_2
  input [WORD_WIDTH-1:0]   pixdata_d1_i,
  input [WORD_WIDTH-1:0]   pixdata_d0_i,
#endif
#ifdef PP_NUM_PIX_LANE_1
  input [WORD_WIDTH-1:0]   pixdata_d0_i,
#endif //NUM_PIX_LANE
#endif // TX_CSI2
#endif
#endif // Interface selection directive

  // DPHY Ports
  inout 		   clk_p_o,
  inout 		   clk_n_o,
#ifdef PP_NUM_TX_LANE_1
  inout 		   d0_p_io,
  inout 		   d0_n_io,
#endif
#ifdef PP_NUM_TX_LANE_2
  inout 		   d0_p_io,
  inout 		   d0_n_io,
  inout 		   d1_p_o,
  inout 		   d1_n_o,
#endif
#ifdef PP_NUM_TX_LANE_3
  inout 		   d0_p_io,
  inout 		   d0_n_io,
  inout 		   d1_p_o,
  inout 		   d1_n_o,
  inout 		   d2_p_o,
  inout 		   d2_n_o,
#endif
#ifdef PP_NUM_TX_LANE_4
  inout 		   d0_p_io,
  inout 		   d0_n_io,
  inout 		   d1_p_o,
  inout 		   d1_n_o,
  inout 		   d2_p_o,
  inout 		   d2_n_o,
  inout 		   d3_p_o,
  inout 		   d3_n_o,
#endif // NUM_TX_LANE_

// Debug ports
#ifdef PP_PIX_DPHY
#ifdef PP_TX_DSI
  output 		   vsync_start_o,
  output 		   hsync_start_o,
#else
  output 		   fv_start_o,
  output 		   lv_start_o,
#endif
#endif // PIX_DPHY
  output 		   c2d_ready_o,
  output 		   hs_clk_gate_en_o,
  output 		   hs_clk_en_o,
  output 		   lp_clk_en_o,
  output 		   dphy_pkten_o,
  output 		   byte_data_en_o					
);

//------------------------------------------------------------------------------
// WIRE DECLARATION
//------------------------------------------------------------------------------
wire [4*DATA_WIDTH-1:0]      byte_data_w;
wire [5:0]                   data_type_w;		
wire [15:0]                  chksum_w;
wire [4*DATA_WIDTH-1:0]      dphy_pkt_w;
wire [DATA_WIDTH-1:0]        hs_data_d3_w;
wire [DATA_WIDTH-1:0]        hs_data_d2_w;
wire [DATA_WIDTH-1:0]        hs_data_d1_w;
wire [DATA_WIDTH-1:0]        hs_data_d0_w;

wire                         vsync_w, vsync_gen_w;
wire                         hsync_w, hsync_gen_w;
wire                         de_w, de_gen_w;
wire [23:0]                  data_gen_w;
wire                         fv_w, fv_gen_w;
wire                         lv_w, lv_gen_w;

wire [WORD_WIDTH-1:0]        pixdata_d9_w;
wire [WORD_WIDTH-1:0]        pixdata_d8_w;
wire [WORD_WIDTH-1:0]        pixdata_d7_w;
wire [WORD_WIDTH-1:0]        pixdata_d6_w;
wire [WORD_WIDTH-1:0]        pixdata_d5_w;
wire [WORD_WIDTH-1:0]        pixdata_d4_w;
wire [WORD_WIDTH-1:0]        pixdata_d3_w;
wire [WORD_WIDTH-1:0]        pixdata_d2_w;
wire [WORD_WIDTH-1:0]        pixdata_d1_w;
wire [WORD_WIDTH-1:0]        pixdata_d0_w;

wire                         hs_clk_gate_en_w;
wire                         hs_clk_en_w;
wire                         lp_clk_en_w;
wire                         dphy_pkten_w;
wire                         byte_data_en_w;
wire                         vsync_start_w;
wire                         hsync_start_w;
wire                         fv_start_w;
wire                         lv_start_w;

wire                         start_ptrn_gen;  // Internally used to start pattern_gen module.
                                              // For debugging purposes only.
wire                         pix2byte_rstn_w;
wire [7:0]                   data_w;

wire                         odd_line_w;

wire [1:0]                   yuv420_wc;

wire                         c2d_ready_w;

// Wires for HS_DCS Support
wire done_dcs_crtl_w;
wire dphy_pkten_frmtr_w;
wire [4*DATA_WIDTH-1:0] dphy_pkt_frmtr_w;
wire done_w;


//prevents undeclared identifier compile error
#ifdef PP_DSI2DSI
wire [63:0] hsdcs_pktdata_i;
assign hsdcs_pktdata_i = 64'h0000;
#endif

// Mapping of data when HS_DCS is selected
#ifdef PP_TX_DSI
#ifdef PP_TX_GEAR_16
  wire [4*DATA_WIDTH-1:0]  dphy_pkt_dcs_w  =  hsdcs_pktdata_i[63:0];
#else //TX_GEAR_8
  wire [4*DATA_WIDTH-1:0]  dphy_pkt_dcs_w = {8'hFF,hsdcs_pktdata_i[31:24],
                                 8'hFF,hsdcs_pktdata_i[23:16],
                                 8'hFF,hsdcs_pktdata_i[15:8],
                                 8'hFF,hsdcs_pktdata_i[7:0]};
#endif// TX_GEAR
#endif// TX_DSI

////added wire to define start of LP->HS transition during HS_ONLY and HS_LP modes
wire clk_hs_en;

// Debug ports
assign hs_clk_gate_en_o = hs_clk_gate_en_w;
assign hs_clk_en_o      = hs_clk_en_w;
assign lp_clk_en_o      = lp_clk_en_w;
assign dphy_pkten_o     = dphy_pkten_w;
assign byte_data_en_o   = byte_data_en_w;

// Word count tracker for YUV420 data type for CSI2
// WC is twice for even lines compare to odd lines
assign yuv420_wc = (odd_line_w) ? 1 : 2;


///////////////////////////////////////////////////////////////
// Synchronize reset input to different clock domain
//////////////////////////////////////////////////////////////
////add reset for refclk
wire ref_rstn;
wire pix_rstn;
wire core_rstn;
USERNAME_synchronizer sync_u0 (.clk(core_clk_i), .rstn(reset_n_i), .in(reset_n_i & pll_lock_o), .out(core_rstn)); 
USERNAME_synchronizer sync_u1 (.clk(pix_clk_i), .rstn(reset_n_i), .in(reset_n_i), .out(pix_rstn)); 
////reset Mixel until Snow PLL lock is detected. If Snow PLL is not used, PLL lock input is tied to 1.
USERNAME_synchronizer sync_u2 (.clk(ref_clk_i), .rstn(reset_n_i), .in(reset_n_i & pll_lock_i), .out(ref_rstn));

// Data mapping for HS_DCS Support
#ifdef PP_PIX_DPHY
#ifdef PP_HS_DCS
assign dphy_pkten_w = (done_w==1'b1)? dphy_pkten_frmtr_w : hsdcs_pkten_i;
assign dphy_pkt_w   = (done_w==1'b1)? dphy_pkt_frmtr_w   : dphy_pkt_dcs_w;
#else
assign dphy_pkten_w = dphy_pkten_frmtr_w;
assign dphy_pkt_w   = dphy_pkt_frmtr_w;
#endif // HS_DCS
#endif // PIX_DPHY


// Debug ports
#ifdef PP_PIX_DPHY
#ifdef PP_TX_DSI
  assign vsync_start_o = vsync_start_w;
  assign hsync_start_o = hsync_start_w;
#else
  assign fv_start_o = fv_start_w;
  assign lv_start_o = lv_start_w;
#endif
#endif


assign c2d_ready_o = (tinit_done_o) ? c2d_ready_w : tinit_done_o; 

#ifdef PP_PIX_DPHY
#ifdef PP_PATTERN_GEN
//----------Used for debugging purposes. Not used in soft IP.
#ifdef PP_TX_DSI
  assign vsync_w      = vsync_gen_w;
  assign hsync_w      = hsync_gen_w;
  assign de_w         = de_gen_w;
#ifdef PP_NUM_PIX_LANE_4
  assign pixdata_d3_w = data_gen_w[23:0]; 
  assign pixdata_d2_w = data_gen_w[23:0]; 
  assign pixdata_d1_w = data_gen_w[23:0]; 
  assign pixdata_d0_w = data_gen_w[23:0]; 
#endif
#ifdef PP_NUM_PIX_LANE_2
  assign pixdata_d1_w = data_gen_w[23:0]; 
  assign pixdata_d0_w = data_gen_w[23:0]; 
#else
  assign pixdata_d0_w = data_gen_w[23:0]; 
#endif // NUM_PIX_LANE DSI
#else  // CSI Interface
  assign fv_w = fv_gen_w;
  assign lv_w = lv_gen_w;
#ifdef PP_NUM_PIX_LANE_10
  assign pixdata_d9_w = data_gen_w[9:0];
  assign pixdata_d8_w = data_gen_w[9:0];
  assign pixdata_d7_w = data_gen_w[9:0];
  assign pixdata_d6_w = data_gen_w[9:0];
  assign pixdata_d5_w = data_gen_w[9:0];
  assign pixdata_d4_w = data_gen_w[9:0];
  assign pixdata_d3_w = data_gen_w[9:0];
  assign pixdata_d2_w = data_gen_w[9:0];
  assign pixdata_d1_w = data_gen_w[9:0];
  assign pixdata_d0_w = data_gen_w[9:0];
#endif
#ifdef PP_NUM_PIX_LANE_8
  assign pixdata_d7_w = data_gen_w[9:0];
  assign pixdata_d6_w = data_gen_w[9:0];
  assign pixdata_d5_w = data_gen_w[9:0];
  assign pixdata_d4_w = data_gen_w[9:0];
  assign pixdata_d3_w = data_gen_w[9:0];
  assign pixdata_d2_w = data_gen_w[9:0];
  assign pixdata_d1_w = data_gen_w[9:0];
  assign pixdata_d0_w = data_gen_w[9:0];
#endif
#ifdef PP_NUM_PIX_LANE_6
  assign pixdata_d5_w = data_gen_w[9:0];
  assign pixdata_d4_w = data_gen_w[9:0];
  assign pixdata_d3_w = data_gen_w[9:0];
  assign pixdata_d2_w = data_gen_w[9:0];
  assign pixdata_d1_w = data_gen_w[9:0];
  assign pixdata_d0_w = data_gen_w[9:0];
#endif
#ifdef PP_NUM_PIX_LANE_4
  assign pixdata_d3_w = data_gen_w[9:0];
  assign pixdata_d2_w = data_gen_w[9:0];
  assign pixdata_d1_w = data_gen_w[9:0];
  assign pixdata_d0_w = data_gen_w[9:0];
#endif
#ifdef PP_NUM_PIX_LANE_2
  assign pixdata_d1_w = data_gen_w[9:0];
  assign pixdata_d0_w = data_gen_w[9:0];
#endif // NUM_PIX_LANE_   
#endif // TX_DSI/TX_CSI
//----------End of Pattern Gen. Not used in soft IP.
#else
#ifdef PP_TX_DSI
  assign vsync_w      = vsync_i;
  assign hsync_w      = hsync_i;
  assign de_w         = de_i;
#ifdef PP_NUM_PIX_LANE_4
  assign pixdata_d3_w = pixdata_d3_i[WORD_WIDTH-1:0]; 
  assign pixdata_d2_w = pixdata_d2_i[WORD_WIDTH-1:0]; 
  assign pixdata_d1_w = pixdata_d1_i[WORD_WIDTH-1:0]; 
  assign pixdata_d0_w = pixdata_d0_i[WORD_WIDTH-1:0]; 
#endif
#ifdef PP_NUM_PIX_LANE_2
  assign pixdata_d1_w = pixdata_d1_i[WORD_WIDTH-1:0]; 
  assign pixdata_d0_w = pixdata_d0_i[WORD_WIDTH-1:0]; 
#else
  assign pixdata_d0_w = pixdata_d0_i[WORD_WIDTH-1:0]; 
#endif // NUM_PIX_LANE_
#else  // CSI Interface
  assign fv_w         = fv_i;
  assign lv_w         = lv_i;
#ifdef PP_NUM_PIX_LANE_10
  assign pixdata_d9_w = pixdata_d9_i[WORD_WIDTH-1:0];
  assign pixdata_d8_w = pixdata_d8_i[WORD_WIDTH-1:0];
  assign pixdata_d7_w = pixdata_d7_i[WORD_WIDTH-1:0];
  assign pixdata_d6_w = pixdata_d6_i[WORD_WIDTH-1:0];
  assign pixdata_d5_w = pixdata_d5_i[WORD_WIDTH-1:0];
  assign pixdata_d4_w = pixdata_d4_i[WORD_WIDTH-1:0];
  assign pixdata_d3_w = pixdata_d3_i[WORD_WIDTH-1:0];
  assign pixdata_d2_w = pixdata_d2_i[WORD_WIDTH-1:0];
  assign pixdata_d1_w = pixdata_d1_i[WORD_WIDTH-1:0];
  assign pixdata_d0_w = pixdata_d0_i[WORD_WIDTH-1:0];
#endif
#ifdef PP_NUM_PIX_LANE_8
  assign pixdata_d7_w = pixdata_d7_i[WORD_WIDTH-1:0];
  assign pixdata_d6_w = pixdata_d6_i[WORD_WIDTH-1:0];
  assign pixdata_d5_w = pixdata_d5_i[WORD_WIDTH-1:0];
  assign pixdata_d4_w = pixdata_d4_i[WORD_WIDTH-1:0];
  assign pixdata_d3_w = pixdata_d3_i[WORD_WIDTH-1:0];
  assign pixdata_d2_w = pixdata_d2_i[WORD_WIDTH-1:0];
  assign pixdata_d1_w = pixdata_d1_i[WORD_WIDTH-1:0];
  assign pixdata_d0_w = pixdata_d0_i[WORD_WIDTH-1:0];
#endif
#ifdef PP_NUM_PIX_LANE_6
  assign pixdata_d5_w = pixdata_d5_i[WORD_WIDTH-1:0];
  assign pixdata_d4_w = pixdata_d4_i[WORD_WIDTH-1:0];
  assign pixdata_d3_w = pixdata_d3_i[WORD_WIDTH-1:0];
  assign pixdata_d2_w = pixdata_d2_i[WORD_WIDTH-1:0];
  assign pixdata_d1_w = pixdata_d1_i[WORD_WIDTH-1:0];
  assign pixdata_d0_w = pixdata_d0_i[WORD_WIDTH-1:0];
#endif
#ifdef PP_NUM_PIX_LANE_4
  assign pixdata_d3_w = pixdata_d3_i[WORD_WIDTH-1:0];
  assign pixdata_d2_w = pixdata_d2_i[WORD_WIDTH-1:0];
  assign pixdata_d1_w = pixdata_d1_i[WORD_WIDTH-1:0];
  assign pixdata_d0_w = pixdata_d0_i[WORD_WIDTH-1:0];
#endif
#ifdef PP_NUM_PIX_LANE_2
  assign pixdata_d1_w = pixdata_d1_i[WORD_WIDTH-1:0];
  assign pixdata_d0_w = pixdata_d0_i[WORD_WIDTH-1:0];
#endif // NUM_PIX_LANE_
#endif // TX_DSI/CSI
#endif // Selection directive between PATTERN_GEN and NORMAL mode

///////////////////////////////////////////////////////////////
   // pixel2byte instance
///////////////////////////////////////////////////////////////
USERNAME_pixel2byte pixel2byte_inst (
////added ports for handshaking with LP HS controller
  .d_hs_rdy_i    (d_hs_rdy_o),
  .d_hs_en_o     (d_hs_en_o),

  // clock and reset
  .pix_clk       (pix_clk_i),
  .core_clk      (core_clk_i),
#ifdef PP_YUV420_8
  .reset_n       (reset_n_i),
#endif
#ifdef PP_YUV420_10
  .reset_n       (reset_n_i),
#else
  .reset_n       (reset_n_i & pix2byte_rstn_w),
#endif
  .pix_rstn      (pix_rstn & pix2byte_rstn_w), 
#ifdef PP_TX_DSI
  .vsync_i       (vsync_w),        // vertical sync input for CMOS interface
  .hsync_i       (hsync_w),        // horizontal sync input for CMOS interface
  .de_i          (de_w),           // data enable input for CMOS interface
#ifdef PP_NUM_PIX_LANE_4
  .pixdata_d3_i  (pixdata_d3_w),   // pixel data for CMOS interface
  .pixdata_d2_i  (pixdata_d2_w),			
  .pixdata_d1_i  (pixdata_d1_w),			
  .pixdata_d0_i  (pixdata_d0_w),			
#endif
#ifdef PP_NUM_PIX_LANE_2
  .pixdata_d1_i  (pixdata_d1_w),   // pixel data for CMOS interface
  .pixdata_d0_i  (pixdata_d0_w),			
#else 
  .pixdata_d0_i  (pixdata_d0_w),  // pixel data for CMOS interface
#endif // NUM_PIX_LANE
#endif // TX_DSI

#ifdef PP_TX_CSI2
  .fv_i          (fv_w),          // frame valid input for CMOS i/f
  .lv_i          (lv_w),          // line valid input for CMOS i/f
  .dvalid_i      (dvalid_i),      // data valid
#ifdef PP_NUM_PIX_LANE_10
  .pixdata_d9_i  (pixdata_d9_w),
  .pixdata_d8_i  (pixdata_d8_w),
  .pixdata_d7_i  (pixdata_d7_w),
  .pixdata_d6_i  (pixdata_d6_w),
  .pixdata_d5_i  (pixdata_d5_w),
  .pixdata_d4_i  (pixdata_d4_w),
  .pixdata_d3_i  (pixdata_d3_w),
  .pixdata_d2_i  (pixdata_d2_w),
  .pixdata_d1_i  (pixdata_d1_w),
  .pixdata_d0_i  (pixdata_d0_w),
#endif
#ifdef PP_NUM_PIX_LANE_8
  .pixdata_d7_i  (pixdata_d7_w),
  .pixdata_d6_i  (pixdata_d6_w),
  .pixdata_d5_i  (pixdata_d5_w),
  .pixdata_d4_i  (pixdata_d4_w),
  .pixdata_d3_i  (pixdata_d3_w),
  .pixdata_d2_i  (pixdata_d2_w),
  .pixdata_d1_i  (pixdata_d1_w),
  .pixdata_d0_i  (pixdata_d0_w),
#endif
#ifdef PP_NUM_PIX_LANE_6
  .pixdata_d5_i  (pixdata_d5_w),
  .pixdata_d4_i  (pixdata_d4_w),
  .pixdata_d3_i  (pixdata_d3_w),
  .pixdata_d2_i  (pixdata_d2_w),
  .pixdata_d1_i  (pixdata_d1_w),
  .pixdata_d0_i  (pixdata_d0_w),
#endif
#ifdef PP_NUM_PIX_LANE_4
  .pixdata_d3_i  (pixdata_d3_w),
  .pixdata_d2_i  (pixdata_d2_w),
  .pixdata_d1_i  (pixdata_d1_w),
  .pixdata_d0_i  (pixdata_d0_w),
#endif
#ifdef PP_NUM_PIX_LANE_2
  .pixdata_d1_i  (pixdata_d1_w),
  .pixdata_d0_i  (pixdata_d0_w),
#endif // NUM_PIX_LANE
#endif // TX_CSI

  // DPHY data width for RGB and RAW
  .byte_data_en_o (byte_data_en_w),
  .byte_data_o    (byte_data_w),	
  .data_type_o    (data_type_w),

  // Frame format for RGB
#ifdef PP_TX_DSI
  .vsync_start_o  (vsync_start_w),
  .vsync_end_o    (vsync_end_w),
  .hsync_start_o  (hsync_start_w),
  .hsync_end_o    (hsync_end_w)
 #endif
#ifdef PP_TX_CSI2
  .fv_start_o     (fv_start_w),
  .fv_end_o       (fv_end_w),
  .lv_start_o     (lv_start_w),
  .lv_end_o       (lv_end_w),
  .odd_line_o     (odd_line_w)
 #endif 
);
#endif

#ifdef PP_CSI2CSI
///////////////////////////////////////////////////////////////
// packet header instance
///////////////////////////////////////////////////////////////
USERNAME_pkt_header_csi2_2bg pkt_header_csi2_2bg_inst (
  // clock and reset
  .core_rstn      (core_rstn),
  .core_clk_i     (core_clk_i),
  
  // packet settings
  .vc_i          (vc_i),
  .dt_i          (dt_i),
  .gear16_i      (GEAR_16),
  .wc_i          (wc_i),   

  // to bridge
  .ld_pyld_o     (ld_pyld_o),  

  // control/data from pixel2byte
  .sp_req_i      (sp_req_i),
  .lp_req_i      (lp_req_i), // from csi2csi arb

  //input from tx global
  .d_hs_rdy_i    (d_hs_rdy_o),
  
  .byte_data_i    (byte_data_i),
  .byte_data_en_i (byte_data_en_i),
  .phdr_xfr_done   (phdr_xfr_done_o),  
  .pix2byte_rstn_o (pix2byte_rstn_w),
  .dphy_pkt_o      (dphy_pkt_w),
  .dphy_pkten_o    (dphy_pkten_w)
);
 
#endif
#ifdef PIX_DPHY
///////////////////////////////////////////////////////////////
// packet formatter instance
///////////////////////////////////////////////////////////////
USERNAME_pkt_formatter pkt_formatter_inst (
  // clock and reset
  .reset_n        (core_rstn),
  .core_clk       (core_clk_i),
  
  // packet settings
  .vc_i           (VC),
  .dt_i           (data_type_w),
#ifdef PP_YUV420_10
  .wc_i           (WC*yuv420_wc),
#endif
#ifdef PP_YUV420_8
  .wc_i           (WC*yuv420_wc),
#else
  .wc_i           (WC),
#endif
  .eotp_i         (EOTP),

  // control/data from pixel2byte
#ifdef PP_TX_DSI
  .vsync_start_i  (vsync_start_w),
  .vsync_end_i    (vsync_end_w),
  .hsync_start_i  (hsync_start_w),
  .hsync_end_i    (hsync_end_w),
#endif
#ifdef PP_TX_CSI2
  .fv_start_i     (fv_start_w),
  .fv_end_i       (fv_end_w),
  .lv_start_i     (lv_start_w),
  .lv_end_i       (lv_end_w),
#endif
  
  .byte_data_i    (byte_data_w),
  .byte_data_en_i (byte_data_en_w),
  
  .pix2byte_rstn_o (pix2byte_rstn_w),
  .dphy_pkt_o      (dphy_pkt_frmtr_w),
  .dphy_pkten_o    (dphy_pkten_frmtr_w)
);
#endif


///////////////////////////////////////////////////////////////
// tx_global_operation instance
///////////////////////////////////////////////////////////////
generate 
  if (CLK_MODE=="HS_ONLY") begin: gen_clk_hs_en_hs
#ifdef PP_PP_HS_DCS
    assign clk_hs_en = tinit_done_o;
#else 
    assign clk_hs_en = done_w;
#endif
  end
  else begin: gen_clk_hs_en_hslp
    assign clk_hs_en = clk_hs_en_i;
  end
endgenerate 

USERNAME_tx_global_operation tx_global_operation_inst (
 ////added ports for handshaking with Rx/bridge/pixel2byte
  .clk_hs_en_i (clk_hs_en),
  .d_hs_en_i   (d_hs_en_i),
  .d_hs_rdy_o  (d_hs_rdy_o),

  // clock and reset
  .reset_n     (core_rstn),
  .core_clk    (core_clk_i),
  
#ifdef PP_DSI2DSI
  // interface signals from pkt header and footer
  .dphy_pkten_i (dphy_pkten_i),
  .dphy_pkt_i   (dphy_pkt_i),
#else
  .dphy_pkten_i (dphy_pkten_w),
  .dphy_pkt_i   (dphy_pkt_w),
#endif

  // interface to DCI wrapper
  // HS i/f
  .hs_clk_gate_en_o (hs_clk_gate_en_w),
  .hs_clk_en_o      (hs_clk_en_w),
  .hs_data_en_o     (hs_data_en_w),
#ifdef PP_NUM_TX_LANE_4
  .hs_data_d3_o     (hs_data_d3_w),
  .hs_data_d2_o     (hs_data_d2_w),
  .hs_data_d1_o     (hs_data_d1_w),
  .hs_data_d0_o     (hs_data_d0_w),
#endif
#ifdef PP_NUM_TX_LANE_3
  .hs_data_d2_o     (hs_data_d2_w),
  .hs_data_d1_o     (hs_data_d1_w),
  .hs_data_d0_o     (hs_data_d0_w),
#endif
#ifdef PP_NUM_TX_LANE_2
  .hs_data_d1_o     (hs_data_d1_w),
  .hs_data_d0_o     (hs_data_d0_w),
  #endif
#ifdef PP_NUM_TX_LANE_1
      .hs_data_d0_o (hs_data_d0_w),
  #endif	

  .c2d_ready_o      (c2d_ready_w),
  
  // LP i/f
  .lp_clk_en_o      (lp_clk_en_w),
  .lp_clk_p_o       (lp_clk_p_w),
  .lp_clk_n_o       (lp_clk_n_w),
  .lp_data_en_o     (lp_data_en_w),
  .lp_data_p_o      (lp_data_p_w),
  .lp_data_n_o      (lp_data_n_w)
);

//-----------------------------------------------------------------
// Mixel DPHY instance
// Using HW model for now
//-----------------------------------------------------------------
wire lp_data_dcs_p_w;
wire lp_data_dcs_n_w;
wire dcs_lp_w;
wire dcs_ln_w;


#ifdef PP_TX_DSI
#ifdef PP_HS_DCS
assign lp_data_dcs_p_w = lp_data_p_w;
assign lp_data_dcs_n_w = lp_data_n_w;
#else
assign lp_data_dcs_p_w = done_w ? lp_data_p_w : dcs_lp_w;
assign lp_data_dcs_n_w = done_w ? lp_data_n_w : dcs_ln_w;
#endif
#else
assign lp_data_dcs_p_w = done_w ? lp_data_p_w : 1'b1;
assign lp_data_dcs_n_w = done_w ? lp_data_n_w : 1'b1;
#endif

///////////////////////////////////////////////////////////////
// dci_wrapper instance
///////////////////////////////////////////////////////////////
USERNAME_dci_wrapper dci_wrapper_inst   (
 // clock and reset
////separate refclk from pix_clk to add option to use Snow PLL
  .refclk          (ref_clk_i),
////change to reset for refclk
  .reset_n         (ref_rstn),
  
  // MIPI interface signals
  .clk_p_o         (clk_p_o),
  .clk_n_o         (clk_n_o),
#ifdef PP_NUM_TX_LANE_4
  .d3_p_o          (d3_p_o),
  .d3_n_o          (d3_n_o),
  .d2_p_o          (d2_p_o),
  .d2_n_o          (d2_n_o),
  .d1_p_o          (d1_p_o),
  .d1_n_o          (d1_n_o),
  .d0_p_io         (d0_p_io),
  .d0_n_io         (d0_n_io),
#endif
#ifdef PP_NUM_TX_LANE_3
  .d2_p_o          (d2_p_o),
  .d2_n_o          (d2_n_o),
  .d1_p_o          (d1_p_o),
  .d1_n_o          (d1_n_o),
  .d0_p_io         (d0_p_io),
  .d0_n_io         (d0_n_io),
#endif
#ifdef PP_NUM_TX_LANE_2
  .d1_p_o          (d1_p_o),
  .d1_n_o          (d1_n_o),
  .d0_p_io         (d0_p_io),
  .d0_n_io         (d0_n_io),
#endif
#ifdef PP_NUM_TX_LANE_1
  .d0_p_io         (d0_p_io),
  .d0_n_io         (d0_n_io),
#endif

  // high-speed transmit signals
  .txbyte_clkhs_o  (byte_clk_o),
  .pll_lock_o      (pll_lock_o),
  
#ifdef PP_TX_DSI
#ifdef PP_HS_DCS
  .txclk_hsen_i   (hs_clk_en_w),
#else
  .txclk_hsen_i   (hs_clk_en_w & done_w),
#endif // HS_DCS
#else  
  .txclk_hsen_i   (hs_clk_en_w & done_w), 
#endif //TX_DSI
  .txclk_hsgate_i  (hs_clk_gate_en_w),
  .pd_dphy_i       (pd_dphy_i),

#ifdef PP_NUM_TX_LANE_4
  .dl3_txdata_hs_i    (hs_data_d3_w),
  .dl2_txdata_hs_i    (hs_data_d2_w),
  .dl1_txdata_hs_i    (hs_data_d1_w),
  .dl0_txdata_hs_i    (hs_data_d0_w),
#ifdef PP_HS_DCS
  .dl3_txdata_hs_en_i (hs_data_en_w),
  .dl2_txdata_hs_en_i (hs_data_en_w),
  .dl1_txdata_hs_en_i (hs_data_en_w),
  .dl0_txdata_hs_en_i (hs_data_en_w),
#else
  .dl3_txdata_hs_en_i (hs_data_en_w & done_w),
  .dl2_txdata_hs_en_i (hs_data_en_w & done_w),
  .dl1_txdata_hs_en_i (hs_data_en_w & done_w),
  .dl0_txdata_hs_en_i (hs_data_en_w & done_w),
#endif
#endif
#ifdef PP_NUM_TX_LANE_3
  .dl2_txdata_hs_i    (hs_data_d2_w),
  .dl1_txdata_hs_i    (hs_data_d1_w),
  .dl0_txdata_hs_i    (hs_data_d0_w),
#ifdef PP_HS_DCS
  .dl2_txdata_hs_en_i (hs_data_en_w),
  .dl1_txdata_hs_en_i (hs_data_en_w),
  .dl0_txdata_hs_en_i (hs_data_en_w),
#else
  .dl2_txdata_hs_en_i (hs_data_en_w & done_w),
  .dl1_txdata_hs_en_i (hs_data_en_w & done_w),
  .dl0_txdata_hs_en_i (hs_data_en_w & done_w),
#endif
#endif
#ifdef PP_NUM_TX_LANE_2
  .dl1_txdata_hs_i    (hs_data_d1_w),
  .dl0_txdata_hs_i    (hs_data_d0_w),
#ifdef PP_HS_DCS
  .dl1_txdata_hs_en_i (hs_data_en_w),
  .dl0_txdata_hs_en_i (hs_data_en_w),
#else
  .dl1_txdata_hs_en_i (hs_data_en_w & done_w),
  .dl0_txdata_hs_en_i (hs_data_en_w & done_w),
#endif
#endif
#ifdef PP_NUM_TX_LANE_1
  .dl0_txdata_hs_i    (hs_data_d0_w),
#ifdef PP_HS_DCS
  .dl0_txdata_hs_en_i (hs_data_en_w),
#else  
  .dl0_txdata_hs_en_i (hs_data_en_w & done_w),
#endif  
#endif

  // low-power transmit signals
#ifdef PP_HS_DCS
  .txclk_lp_p_i       (lp_clk_p_w),
  .txclk_lp_n_i       (lp_clk_n_w),
  .clk_lpen_i         (lp_clk_en_w),
  .lp_direction_i     (),

#ifdef PP_LP_4
  .dl3_txdata_lp_p_i  (lp_data_p_w),
  .dl3_txdata_lp_n_i  (lp_data_n_w),
  .dl2_txdata_lp_p_i  (lp_data_p_w),
  .dl2_txdata_lp_n_i  (lp_data_n_w),
  .dl1_txdata_lp_p_i  (lp_data_p_w),
  .dl1_txdata_lp_n_i  (lp_data_n_w),
  .dl0_txdata_lp_p_i  (lp_data_dcs_p_w),
  .dl0_txdata_lp_n_i  (lp_data_dcs_n_w),
  
  .dl3_txdata_lp_en_i (lp_data_en_w),
  .dl2_txdata_lp_en_i (lp_data_en_w),
  .dl1_txdata_lp_en_i (lp_data_en_w),
  .dl0_txdata_lp_en_i (lp_data_en_w),
#endif
#ifdef PP_LP_3
  .dl2_txdata_lp_p_i  (lp_data_p_w),
  .dl2_txdata_lp_n_i  (lp_data_n_w),
  .dl1_txdata_lp_p_i  (lp_data_p_w),
  .dl1_txdata_lp_n_i  (lp_data_n_w),
  .dl0_txdata_lp_p_i  (lp_data_dcs_p_w),
  .dl0_txdata_lp_n_i  (lp_data_dcs_n_w),
  
  .dl2_txdata_lp_en_i (lp_data_en_w),
  .dl1_txdata_lp_en_i (lp_data_en_w),
  .dl0_txdata_lp_en_i (lp_data_en_w),
#endif
#ifdef PP_LP_2
  .dl1_txdata_lp_p_i  (lp_data_p_w),
  .dl1_txdata_lp_n_i  (lp_data_n_w),
  .dl0_txdata_lp_p_i  (lp_data_dcs_p_w),
  .dl0_txdata_lp_n_i  (lp_data_dcs_n_w),
  
  .dl1_txdata_lp_en_i (lp_data_en_w),
  .dl0_txdata_lp_en_i (lp_data_en_w),
#endif
#ifdef PP_LP_1
  .dl0_txdata_lp_p_i  (lp_data_dcs_p_w),
  .dl0_txdata_lp_n_i  (lp_data_dcs_n_w),
  
  .dl0_txdata_lp_en_i (lp_data_en_w),
#endif
#else
  .txclk_lp_p_i       (done_w ? lp_clk_p_w : 1'b1),
  .txclk_lp_n_i       (done_w ? lp_clk_n_w : 1'b1),
  .clk_lpen_i         (done_w ? lp_clk_en_w : 1'b1),
  .lp_direction_i     (),

#ifdef PP_LP_4
  .dl3_txdata_lp_p_i  (done_w ? lp_data_p_w : 1'b1),
  .dl3_txdata_lp_n_i  (done_w ? lp_data_n_w : 1'b1),
  .dl2_txdata_lp_p_i  (done_w ? lp_data_p_w : 1'b1),
  .dl2_txdata_lp_n_i  (done_w ? lp_data_n_w : 1'b1),
  .dl1_txdata_lp_p_i  (done_w ? lp_data_p_w : 1'b1),
  .dl1_txdata_lp_n_i  (done_w ? lp_data_n_w : 1'b1),
  .dl0_txdata_lp_p_i  (lp_data_dcs_p_w),
  .dl0_txdata_lp_n_i  (lp_data_dcs_n_w),
  
  .dl3_txdata_lp_en_i (done_w ? lp_data_en_w : 1'b1),
  .dl2_txdata_lp_en_i (done_w ? lp_data_en_w : 1'b1),
  .dl1_txdata_lp_en_i (done_w ? lp_data_en_w : 1'b1),
  .dl0_txdata_lp_en_i (done_w ? lp_data_en_w : 1'b1),
#endif
#ifdef PP_LP_3
  .dl2_txdata_lp_p_i  (done_w ? lp_data_p_w : 1'b1),
  .dl2_txdata_lp_n_i  (done_w ? lp_data_n_w : 1'b1),
  .dl1_txdata_lp_p_i  (done_w ? lp_data_p_w : 1'b1),
  .dl1_txdata_lp_n_i  (done_w ? lp_data_n_w : 1'b1),
  .dl0_txdata_lp_p_i  (lp_data_dcs_p_w),
  .dl0_txdata_lp_n_i  (lp_data_dcs_n_w),
  
  .dl2_txdata_lp_en_i (done_w ? lp_data_en_w : 1'b1),
  .dl1_txdata_lp_en_i (done_w ? lp_data_en_w : 1'b1),
  .dl0_txdata_lp_en_i (done_w ? lp_data_en_w : 1'b1),
#endif
#ifdef PP_LP_2
  .dl1_txdata_lp_p_i  (done_w ? lp_data_p_w : 1'b1),
  .dl1_txdata_lp_n_i  (done_w ? lp_data_n_w : 1'b1),
  .dl0_txdata_lp_p_i  (lp_data_dcs_p_w),
  .dl0_txdata_lp_n_i  (lp_data_dcs_n_w),
  
  .dl1_txdata_lp_en_i (done_w ? lp_data_en_w : 1'b1),
  .dl0_txdata_lp_en_i (done_w ? lp_data_en_w : 1'b1),
#endif
#ifdef PP_LP_1
  .dl0_txdata_lp_p_i  (lp_data_dcs_p_w),
  .dl0_txdata_lp_n_i  (lp_data_dcs_n_w),
  
  .dl0_txdata_lp_en_i (done_w ? lp_data_en_w : 1'b1),
#endif
#endif

  // Not use - in case to support bus turn-around
  .rxclk_lp_p_o       (),
  .rxclk_lp_n_o       (),
  .dl0_rxdata_lp_p_o  (),
  .dl0_rxdata_lp_n_o  ()
);

#ifdef PP_TX_DSI
// For debugging purposes only: Used to bypass DCS transaction for faster debugging
#ifdef PP_BYPASS_DCS
  assign done_w = tinit_done_o;
  assign dcsrom_done_o = tinit_done_o;
  assign dcs_lp_w = 1'b1;
  assign dcs_ln_w = 1'b1;

#endif
#ifdef PP_HS_DCS
  assign done_w = hsdcs_done_i;
  assign dcsrom_done_o = done_w;
#else
///////////////////////////////////////////////////////////////
   // DCS Controller instance
///////////////////////////////////////////////////////////////
USERNAME_dcs_control dcs_control_inst(
  .clk          (dcs_clk_i),
  .reset_n      (core_rstn & tinit_done_o),
  .start_i      (start_i),                 // Inititate an 8-bit data transfer
  .escape_i     (escape_i),                // Initiate a LP11,LP10,LP00,LP01,LP00 transmission
  .stop_i       (stop_i),                  // stop data transfer
  .data_i       (data_i),
  .rom_done_i   (rom_done_i),
  
  .ready_o      (ready_o),
  .done_o       (done_dcs_crtl_w),           //Data transfer from ROM is complete
  .lp_o         (dcs_lp_w),
  .ln_o         (dcs_ln_w)
);

assign done_w = done_dcs_crtl_w;
assign dcsrom_done_o = done_w;
#endif  // BYPASS_DCS

#else  // TX_CSI
// Used to mimic DCS Transaction for CSI interface
assign done_w = tinit_done_o;
//sig_delay sig_delay_inst(
//  .clk      (pix_clk_i),
//  .rstn     (pix_rstn),
//  .in       (pll_lock_o),
//  
//  .out      (done_w)
//);

#endif // TX_DSI

#ifdef PP_TX_DSI
// Control logic for start signal of pattern_gen
// For internal use only. Not used as soft IP feature
  assign start_ptrn_gen = done_w;     // start when dcsrom_done
#else
  assign start_ptrn_gen = tinit_done_o;     // start when tinit_done_o is high
#endif

///////////////////////////////////////////////////////////////
// Tinit counter instance
///////////////////////////////////////////////////////////////
generate
if (TINIT_COUNT == "ON") begin: gen_tinit_count_on
  USERNAME_tinit_count tinit_count_inst(
    .clk          (core_clk_i),
    .resetn       (core_rstn),
    
    .tinit_done_o (tinit_done_o)
  );
end
else begin: gen_tinit_count_off
  assign tinit_done_o = pll_lock_o;
end
endgenerate

// For internal use only. Not used as a feature of the soft IP.
#ifdef PP_PATTERN_GEN
///////////////////////////////////////////////////////////////
// Pattern Generator instance
///////////////////////////////////////////////////////////////
USERNAME_pattern_gen #(
  .H_ACTIVE       (H_ACTIVE),
  .H_TOTAL        (H_TOTAL),
  .V_ACTIVE       (V_ACTIVE),
  .V_TOTAL        (V_TOTAL),
  .H_SYNCH        (H_SYNC),
  .H_BACK_PORCH   (H_BACK_PORCH),
  .H_FRONT_PORCH  (H_FRONT_PORCH),
  .V_SYNCH        (V_SYNCH),
  .V_BACK_PORCH   (V_BACK_PORCH),
  .V_FRONT_PORCH  (V_FRONT_PORCH),
  .MODE           (PATTERN_MODE)     // 0 = colorbar, 1 = incrementing
)
pattern_gen_inst (
  .reset_n        (pix_rstn),
  .clk            (pix_clk_i),
  .start_i        (start_ptrn_gen),
  // DPI format
  .vsync_o        (vsync_gen_w),
  .hsync_o        (hsync_gen_w),
  .de_o           (de_gen_w),
  .data_o         (data_gen_w),
  
  // CSI format
  .fv_o           (fv_gen_w),
  .lv_o           (lv_gen_w)
);
#endif

endmodule
