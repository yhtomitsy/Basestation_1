// --------------------------------------------------------------------
//
// CSI2_2_CSI2_top.v -- 4:1 CSI2 to CSI2 mux/merge Bridge IP Design
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author               :| Mod. Date :| Changes Made:
//
// --------------------------------------------------------------------

//==================================================================================
// Verilog module generated by Clarity Designer    03/23/2019    09:13:23       
// Filename: csi2_4to1_1_csi2_2_csi2_ip.v                                                         
// Filename: 4:1 CSI-2 to CSI-2 1.1                                    
// Copyright(c) 2016 Lattice Semiconductor Corporation. All rights reserved.        
//==================================================================================

module csi2_4to1_1_csi2_2_csi2_ip
#(
//-----------------------------------------------------------------------------
// PARAMETERS
//-----------------------------------------------------------------------------

    parameter PLL_M        = 8'd192,
    parameter PLL_N        = 5'd0,
    parameter PLL_O        = 2'd0,
////added TINIT_COUNT parameter for disabling tinit counter
////added TINIT_COUNT parameter for disabling tinit counter
    parameter TINIT_COUNT  = "ON",
    parameter TINIT_VALUE  = 500,
    parameter TX_FREQ_TGT  = 120,
//HS_LP or HS_ONLY
    parameter RX_CLK_MODE  = "HS_LP",
    parameter LANE_ALIGN   = "OFF",
//RX Channel 1 DPHY selection (Hard/Soft)
    parameter DPHY_RX_IP_CH1 = "MIXEL",

////added TX clock mode parameter
    parameter TX_CLK_MODE  = "HS_ONLY", 
    parameter TX_WAIT_TIME = "LESS_15MS", // "OVER_15MS" or "LESS_15MS"
    parameter MIN_INTERVAL = 150,         // timing req for cmos2dphy ip


    parameter RX_GEAR      = 8,           // DPHY Rx Clock Gear
    parameter TX_GEAR      = 8,          // DPHY Tx Clock Gear
    parameter VC_CH0       = 00,
    parameter VC_CH1       = 01,
    parameter LBUF_DEPTH   = 2048, 

    parameter LANE_COUNT   = 1,

    parameter DT           = "RGB888"
)
//-----------------------------------------------------------------------------
// PORT DECLARATIONS
//-----------------------------------------------------------------------------

	 (
		input wire 	   reset_n_i,
		input wire 	   reset_lp_n_i, // Active low reset for sync release of FFs using clk_lp_ctrl_i
		input wire 	   reset_byte_fr_n_i, // Active low reset for sync release of FFs using clk_byte_fr_i

                input wire         mux_sel_i,
		input wire 	   ref_clk_i, // for mixel pll
		input wire 	   clk_lp_ctrl_i, // for tx
	  // separate pix_clk/rx_byteclk from mixel pll refclk
	        input wire 	   pll_lock_i,
                input wire 	   pix_clk_i,
                input wire         tx_refclk_i,

		inout wire 	   clk_ch0_p_i,
		inout wire 	   clk_ch0_n_i,
		inout wire 	   clk_ch1_p_i,
		inout wire 	   clk_ch1_n_i,
		inout wire 	   clk_ch2_p_i,
		inout wire 	   clk_ch2_n_i,
		inout wire 	   clk_ch3_p_i,
		inout wire 	   clk_ch3_n_i,



		inout wire 	   d0_ch0_p_i,
		inout wire 	   d0_ch0_n_i,
		inout wire 	   d0_ch1_p_i,
		inout wire 	   d0_ch1_n_i,
		inout wire 	   d0_ch2_p_i,
		inout wire 	   d0_ch2_n_i,
		inout wire 	   d0_ch3_p_i,
		inout wire 	   d0_ch3_n_i,

		output wire 	   d0_p_o,
		output wire 	   d0_n_o,
		output wire 	   clk_p_o,
		output wire 	   clk_n_o,
		output wire 	   tx_pll_lock_o,
		output wire 	   tinit_done_o,
                output wire 	   rx_byte_clk_fr_ch0,

		// debug ports when necessary
		output wire [15:0] debug_cnt,
		output wire [1:0]  debug_state_c,
		output wire [1:0]  debug_state_n,
		output wire 	   rx0_hs_sync_o,
		output wire 	   rx0_sp_en_o,
		output wire 	   rx0_lp_en_o,
		output wire [5:0]  rx0_dt_o,
		output wire 	   rx1_hs_sync_o,
		output wire 	   rx1_sp_en_o,
		output wire 	   rx1_lp_en_o,
		output wire [5:0]  rx1_dt_o,
		output wire 	   tx_fv_en_o,
		output wire 	   tx_lv_en_o,
		output wire 	   tx_byte_data_vld,
		output wire [5:0]  tx_dt_o
			);

//-----------------------------------------------------------------------------
// LOCAL PARAMETER DECLARATIONS
//-----------------------------------------------------------------------------
parameter RX_DATA_WIDTH = RX_GEAR*LANE_COUNT;
parameter TX_DATA_WIDTH = TX_GEAR*LANE_COUNT;

//-----------------------------------------------------------------------------
// WIRE DECLARATIONS
//-----------------------------------------------------------------------------
wire 				  tx_byte_clk;
assign tx_byte_clk_o = tx_byte_clk;

wire 				  rx_plllock;////add Snow pll lock
assign rx_plllock = pll_lock_i;

wire tx_pll_lock;
wire reset_n_w;


wire tinit_done;
assign tinit_done_o=tinit_done;
wire [15:0] wc_int;
wire [15:0] wc0_int;
wire [15:0] wc1_int;
assign wc_int=wc0_int;


assign tx_pll_lock_o=tx_pll_lock;

// wires from ch0..................
wire[RX_GEAR-1:0]ch0_byte_data0;
wire[RX_GEAR-1:0]ch0_byte_data1;
wire[RX_GEAR-1:0]ch0_byte_data2;
wire[RX_GEAR-1:0]ch0_byte_data3;

wire sp_en_ch0; 
wire lp_en_ch0; 
wire lv_ch0;
wire fv_ch0;
wire [1:0] vc_ch0;
wire[15:0] wc_ch0;
wire [1:0] vc_bufout_ch0;
wire empty0;
wire byte_valid_ch0;

// wires from ch1..................
wire[RX_GEAR-1:0]ch1_byte_data0;
wire[RX_GEAR-1:0]ch1_byte_data1;
wire[RX_GEAR-1:0]ch1_byte_data2;
wire[RX_GEAR-1:0]ch1_byte_data3;

wire sp_en_ch1; 
wire lp_en_ch1; 
wire lv_ch1;
wire fv_ch1;
wire [1:0] vc_ch1;
wire[15:0] wc_ch1;
wire [1:0] vc_bufout_ch1;
wire empty1;
wire byte_valid_ch1;

// wires from ch2..................
wire[RX_GEAR-1:0]ch2_byte_data0;
wire[RX_GEAR-1:0]ch2_byte_data1;
wire[RX_GEAR-1:0]ch2_byte_data2;
wire[RX_GEAR-1:0]ch2_byte_data3;

wire sp_en_ch2; 
wire lp_en_ch2; 
wire lv_ch2;
wire fv_ch2;
wire [1:0] vc_ch2;
wire[15:0] wc_ch2;
wire [1:0] vc_bufout_ch2;
wire empty2;
wire byte_valid_ch2;

// wires from ch3.................
wire[RX_GEAR-1:0]ch3_byte_data0;
wire[RX_GEAR-1:0]ch3_byte_data1;
wire[RX_GEAR-1:0]ch3_byte_data2;
wire[RX_GEAR-1:0]ch3_byte_data3;

wire sp_en_ch3; 
wire lp_en_ch3; 
wire lv_ch3;
wire fv_ch3;
wire [1:0] vc_ch3;
wire[15:0] wc_ch3;
wire [1:0] vc_bufout_ch3;
wire empty3;
wire byte_valid_ch3;


// end of RX wires ...............




wire[TX_GEAR-1:0]byte_bufout_ch0;
wire[TX_GEAR-1:0]byte_bufout_ch1;
wire[TX_GEAR-1:0]byte_bufout_ch1_adj;
wire[63:0]tx_byte_data;
wire[15:0] tx_byte_data_adj;

wire read_en_ch0;
wire read_en_ch1;
wire write_en_ch0;
wire write_en_ch1;

wire [1:0] vc_muxout;
wire sel;
wire [5:0] dt_int;
wire fv_start;
wire lv_start;
wire fv_end;
wire lv_end;

//wire rx_byte_clk_fr_ch0;
wire rx_byte_clk_fr_ch1;
wire rx_byte_clk_fr_o_ch0;
wire rx_byte_clk_fr_o_ch1;


wire c2d_hs_rdy;

wire data1_valid_stretch_en;
wire integer_rd;
wire [2:0] remainder;
wire even_rd_en0;
wire even_rd_en1;

// RX Channel 0.............
wire hs_en_ch0;
wire [5:0] dt_ch0;
wire [1:0] lp_hs_state_ch0;
wire hs_sync_ch0;
// RX Channel 1.............
wire hs_en_ch1;
wire [5:0] dt_ch1;
wire [1:0] lp_hs_state_ch1;
wire hs_sync_ch1;
// RX Channel 2.............
wire hs_en_ch2;
wire [5:0] dt_ch2;
wire [1:0] lp_hs_state_ch2;
wire hs_sync_ch2;
// RX Channel 3.............
wire hs_en_ch3;
wire [5:0] dt_ch3;
wire [1:0] lp_hs_state_ch3;
wire hs_sync_ch3;


assign tx_dt_o=dt_int;
assign tx_data_en_o=read_en_ch0 || read_en_ch1;
assign tx_fv_en_o=fv_ch0;
assign tx_lv_en_o=lv_ch0;


wire [15:0] hdr0_wdcnt;
wire [5:0]  hdr0_dtype;
wire [1:0]  hdr0_chID;

wire [15:0] hdr1_wdcnt;
wire [5:0]  hdr1_dtype;
wire [1:0]  hdr1_chID;

wire [15:0] arb_wdcnt;
wire [5:0]  arb_dtype;
wire [1:0]  arb_chID;


// DATA from DPHY2CMOS
wire [RX_DATA_WIDTH-1:0]	    d2c_data_ch0;
wire [RX_DATA_WIDTH-1:0]	    d2c_data_ch1;
wire [RX_DATA_WIDTH-1:0]	    d2c_data_ch2;
wire [RX_DATA_WIDTH-1:0]	    d2c_data_ch3;

assign d2c_data_ch0 = ch0_byte_data0;
assign d2c_data_ch1 = ch1_byte_data0;
assign d2c_data_ch2 = ch2_byte_data0;
assign d2c_data_ch3 = ch3_byte_data0;


wire 				    lbfr_halffull_ch0;

wire [15:0] 			    rd_counter_ch0;


// mux wires
wire 				    lp_en_mux0;	    
wire 				    sp_en_mux0;	    
//wire                   rx_byte_clk_fr_mux0;
wire 				    d2c_payload_en_mux0;  
wire [RX_DATA_WIDTH-1:0] 	    d2c_data_mux0;	    
wire [15:0] 			    wc_mux0;		    
wire [1:0] 			    vc_mux0;		    
wire [5:0] 			    dt_mux0;   

wire 				    lp_en_mux1;
wire 				    sp_en_mux1;	    
//wire                   rx_byte_clk_fr_mux1;
wire 				    d2c_payload_en_mux1;  
wire [RX_DATA_WIDTH-1:0] 	    d2c_data_mux1;	    
wire [15:0] 			    wc_mux1;		    
wire [1:0] 			    vc_mux1;		    
wire [5:0]                          dt_mux1;


// debug wire assignment......................
assign rx0_sp_en_o   = sp_en_mux0;
assign rx0_lp_en_o   = lp_en_mux0;
assign rx0_hs_sync_o = mux_sel_i ? hs_sync_ch0 : hs_sync_ch2;

assign rx0_hs_en_o   = hs_en_ch0;
assign rx0_dt_o      = dt_ch0;


assign rx1_sp_en_o   = sp_en_mux1;
assign rx1_lp_en_o   = lp_en_mux1;
assign rx1_hs_sync_o = mux_sel_i ? hs_sync_ch1 : hs_sync_ch3;

assign rx1_hs_en_o   = hs_en_ch1;
assign rx1_dt_o      = dt_ch1;
//...........................................


//-----------------------------------------------------------------------------
// MODULE INSTANTIATIONS
//-----------------------------------------------------------------------------

csi2_4to1_1_synchronizer sync_tx_reset (
			. clk (tx_byte_clk),
			. rstn (reset_n_i),
			. in (reset_n_i & tx_pll_lock),
			. out (reset_n_w));


csi2_4to1_1_dphy_2_cmos_ip dphy2cmos_ch0 (
				.reset_n_i (reset_n_i),
				.reset_byte_n_i (reset_n_i),
			        .reset_byte_fr_n_i (reset_byte_fr_n_i),
				.reset_lp_n_i (reset_lp_n_i),
				.clk_lp_ctrl_i (clk_lp_ctrl_i),
				.clk_pixel_i (1'b0),
				.pll_lock_i (tx_pll_lock),
				.lp_d0_tx_en_i (1'b0),
				.lp_d0_tx_n_i (1'b0),
				.lp_d0_tx_p_i (1'b0),
				.reset_pixel_n_i (1'b0),
				.clk_byte_fr_i (rx_byte_clk_fr_ch0),
				.clk_byte_fr_o (rx_byte_clk_fr_ch0),
				.clk_p_i (clk_ch0_p_i),
				.clk_n_i (clk_ch0_n_i),
				.d0_p_i (d0_ch0_p_i),
				.d0_n_i (d0_ch0_n_i),
				.bd_o (ch0_byte_data0),
				.wc_o(wc_ch0),
				.vc_o(vc_ch0),
			// debug pins
				.lp_en_o (lp_en_ch0),
				.sp_en_o (sp_en_ch0),
                                .payload_en_o(d2c_payload_en_ch0),
				.dt_o (dt_ch0),
				.hs_sync_o (hs_sync_ch0),
				.lp_hs_state_d_o (lp_hs_state_ch0)
			
);
defparam dphy2cmos_ch0.RX_TYPE="CSI2";
defparam dphy2cmos_ch0.TX_TYPE="CSI2";
defparam dphy2cmos_ch0.PD_BUS_WIDTH=10;
defparam dphy2cmos_ch0.NUM_RX_LANE=1;
defparam dphy2cmos_ch0.RX_GEAR=RX_GEAR;
defparam dphy2cmos_ch0.DPHY_RX_IP="LATTICE";
defparam dphy2cmos_ch0.LANE_ALIGN=LANE_ALIGN; 
defparam dphy2cmos_ch0.DATA_TYPE=DT;
defparam dphy2cmos_ch0.NUM_TX_CH=1;
defparam dphy2cmos_ch0.RX_CLK_MODE=RX_CLK_MODE;
defparam dphy2cmos_ch0.BYTECLK_MHZ=TX_FREQ_TGT/2;

defparam dphy2cmos_ch0.TX_WAIT_TIME=TX_WAIT_TIME;
//defparam dphy2cmos_ch0.FS_POSITION=FS_POSITION;



csi2_4to1_1_dphy_2_cmos_ip dphy2cmos_ch2 (
				.reset_n_i (reset_n_i),
				.reset_byte_n_i (reset_n_i),
			        .reset_byte_fr_n_i (reset_byte_fr_n_i),
				.reset_lp_n_i (reset_lp_n_i),
				.clk_lp_ctrl_i (clk_lp_ctrl_i),
				.clk_pixel_i (1'b0),
				.pll_lock_i (tx_pll_lock),
				.lp_d0_tx_en_i (1'b0),
				.lp_d0_tx_n_i (1'b0),
				.lp_d0_tx_p_i (1'b0),
				.reset_pixel_n_i (1'b0),
				.clk_byte_fr_i (rx_byte_clk_fr_ch0), // use fr from ch0
				.clk_byte_fr_o (rx_byte_clk_fr_ch2),
				.clk_p_i (clk_ch2_p_i),
				.clk_n_i (clk_ch2_n_i),
				.d0_p_i (d0_ch2_p_i),
				.d0_n_i (d0_ch2_n_i),
				.bd_o (ch2_byte_data0),
				.wc_o(wc_ch2),
				.vc_o(vc_ch2),
			// debug pins
				.lp_en_o (lp_en_ch2),
				.sp_en_o (sp_en_ch2),
                                .payload_en_o(d2c_payload_en_ch2),
				.dt_o (dt_ch2),
				.hs_sync_o (hs_sync_ch2),
				.lp_hs_state_d_o (lp_hs_state_ch2)
			
);
defparam dphy2cmos_ch2.RX_TYPE="CSI2";
defparam dphy2cmos_ch2.TX_TYPE="CSI2";
defparam dphy2cmos_ch2.PD_BUS_WIDTH=10;
defparam dphy2cmos_ch2.NUM_RX_LANE=1;
defparam dphy2cmos_ch2.RX_GEAR=RX_GEAR;
defparam dphy2cmos_ch2.DPHY_RX_IP="LATTICE";
defparam dphy2cmos_ch2.LANE_ALIGN=LANE_ALIGN; 
defparam dphy2cmos_ch2.DATA_TYPE=DT;
defparam dphy2cmos_ch2.NUM_TX_CH=1;
defparam dphy2cmos_ch2.RX_CLK_MODE=RX_CLK_MODE;
defparam dphy2cmos_ch2.BYTECLK_MHZ=TX_FREQ_TGT/2;

defparam dphy2cmos_ch2.TX_WAIT_TIME=TX_WAIT_TIME;
//defparam dphy2cmos_ch2.FS_POSITION=FS_POSITION;



//mux between ch0 and ch2
csi2_4to1_1_muxer #(
  .RX_DATA_WIDTH              (RX_DATA_WIDTH)
)
muxer_ch0 (
.mux_sel                      (mux_sel_i),	      
                      		                        
.lp_en_chA                    (lp_en_ch0),	      
.sp_en_chA                    (sp_en_ch0),	      
// .rx_byte_clk_fr_chA        (rx_byte_clk_fr_ch0),
.d2c_payload_en_chA           (d2c_payload_en_ch0),  
.d2c_data_chA                 (d2c_data_ch0),	      
.wc_chA                       (wc_ch0),	      
.vc_chA                       (vc_ch0),	      
.dt_chA                       (dt_ch0),	      
                      		                        
.lp_en_chB                    (lp_en_ch2),	      
.sp_en_chB                    (sp_en_ch2),	      
// .rx_byte_clk_fr_chB	      (rx_byte_clk_fr_ch2),
.d2c_payload_en_chB           (d2c_payload_en_ch2),  
.d2c_data_chB                 (d2c_data_ch2),	      
.wc_chB                       (wc_ch2),	      
.vc_chB                       (vc_ch2),	      
.dt_chB                       (dt_ch2), 	      
                      		                        
.lp_en_mux                    (lp_en_mux0),   
.sp_en_mux                    (sp_en_mux0),	      
// .rx_byte_clk_fr_mux        (rx_byte_clk_fr_mux0),
.d2c_payload_en_mux           (d2c_payload_en_mux0),  
.d2c_data_mux                 (d2c_data_mux0),	      
.wc_mux                       (wc_mux0),	      
.vc_mux                       (vc_mux0),	      
.dt_mux                       (dt_mux0)
);           



csi2_4to1_1_hdr_buffer 
hdr_buffer_ch0 (
.rst_n_i                      (reset_n_i),
.rx_clk_i                     (rx_byte_clk_fr_ch0),
.tx_clk_i                     (tx_byte_clk),
.reset_rx_n_i                 (reset_byte_fr_n_i && tx_pll_lock),
.reset_tx_n_i                 (reset_n_w),
.d2c_sp_en_i                  (sp_en_mux0),
.d2c_lp_en_i                  (lp_en_mux0),
.d2c_ph_i                     ({vc_mux0[1:0],dt_mux0[5:0]}),
.d2c_wc_i                     (wc_mux0),

.arb_rdy                      (arb_rdy),
.arb_gnt		      (arb_gnt0),
.c2d_hs_rdy                   (c2d_hs_rdy),
.c2d_ld_pyld                  (c2d_ld_pyld),
.c2d_phdr_done                (c2d_phdr_done),
//.xfr_done                     (empty1),
.lbf_txrdy                    (lbfr_halffull_ch0),
.lbf_lastwd_ch0               (lbf_lastwd_ch0),

.lbf_lastwd_ch1               (lbf_lastwd_ch1),
.hdr_rd_lbfr_en1              (hdr0_rd_lbfr_en_ch1),

.hdr_rd_lbfr_en0              (hdr0_rd_lbfr_en_ch0),
.hdr_req                      (hdr0_req),
.hdr_wdcnt                    (hdr0_wdcnt),
.hdr_dtype                    (hdr0_dtype),
.hdr_chID                     (hdr0_chID),
.hdr_SPtype                   (hdr0_SPtype),
.hdr_xfrdone                  (hdr0_xfrdone)
);

csi2_4to1_1_line_buffer 
line_buffer_ch0 (
.rst_n_i                      (reset_n_i),
.reset_tx_n_i                 (reset_n_w),
.reset_rx_n_i                 (reset_byte_fr_n_i && tx_pll_lock),
.lp_en                        (lp_en_mux0),
.rx_clk_i                     (rx_byte_clk_fr_ch0),
.tx_clk_i                     (tx_byte_clk),
.d2c_payload_en_i             (d2c_payload_en_mux0),
.byte_i                       (d2c_data_mux0),
.d2c_wc_i                     (wc_mux0),	
 
 		 
.hdr_rd_lbfr_en               (hdr0_rd_lbfr_en_ch0), //hdr0 if LR
.hdr_wdcnt                    (hdr0_wdcnt),
.rd_counter                   (rd_counter_ch0),

.byte_o                       (byte_bufout_ch0),
.word_valid_o                 (lbfr_wdvalid_ch0),
.lbfr_halffull                (lbfr_halffull_ch0),
.empty_o                      (empty0),
.lbf_lastwd                   (lbf_lastwd_ch0)
);





csi2_4to1_1_dphy_2_cmos_ip dphy2cmos_ch1 (
				.reset_n_i (reset_n_i),
				.reset_byte_n_i (reset_n_i),
			        .reset_byte_fr_n_i (reset_byte_fr_n_i),
				.reset_lp_n_i (reset_lp_n_i),
				.clk_lp_ctrl_i (clk_lp_ctrl_i),
				.clk_pixel_i (1'b0),
				.pll_lock_i (tx_pll_lock),
				.lp_d0_tx_en_i (1'b0),
				.lp_d0_tx_n_i (1'b0),
				.lp_d0_tx_p_i (1'b0),
				.reset_pixel_n_i (1'b0),
				.clk_byte_fr_i (rx_byte_clk_fr_ch1),
				.clk_byte_fr_o (rx_byte_clk_fr_ch1),
				.clk_p_i (clk_ch1_p_i),
				.clk_n_i (clk_ch1_n_i),
				.d0_p_i (d0_ch1_p_i),
				.d0_n_i (d0_ch1_n_i),
				.bd_o (ch1_byte_data0),
				.lv_o (),
				.fv_o (),
				.wc_o(wc_ch1),
				.vc_o(vc_ch1),
			// debug pins
				.lp_en_o (lp_en_ch1),
				.sp_en_o (sp_en_ch1),
				.dt_o (dt_ch1),
                                .payload_en_o(d2c_payload_en_ch1),
				//.hs_en_o (hs_en_ch1),
				.hs_sync_o (hs_sync_ch1),
				.lp_hs_state_d_o (lp_hs_state_ch1)
			
);
defparam dphy2cmos_ch1.RX_TYPE="CSI2";
defparam dphy2cmos_ch1.TX_TYPE="CSI2";
defparam dphy2cmos_ch1.PD_BUS_WIDTH=10;
defparam dphy2cmos_ch1.NUM_RX_LANE=1;
defparam dphy2cmos_ch1.RX_GEAR=RX_GEAR;
defparam dphy2cmos_ch1.DPHY_RX_IP="LATTICE"; //DPHY_RX_IP_CH1;
defparam dphy2cmos_ch1.LANE_ALIGN=LANE_ALIGN; 
defparam dphy2cmos_ch1.DATA_TYPE=DT;
defparam dphy2cmos_ch1.NUM_TX_CH=1;
defparam dphy2cmos_ch1.RX_CLK_MODE=RX_CLK_MODE;

defparam dphy2cmos_ch1.BYTECLK_MHZ=TX_FREQ_TGT/2;
defparam dphy2cmos_ch1.TX_WAIT_TIME=TX_WAIT_TIME;
//defparam dphy2cmos_ch1.FS_POSITION=FS_POSITION;




csi2_4to1_1_dphy_2_cmos_ip dphy2cmos_ch3 (
				.reset_n_i (reset_n_i),
				.reset_byte_n_i (reset_n_i),
			        .reset_byte_fr_n_i (reset_byte_fr_n_i),
				.reset_lp_n_i (reset_lp_n_i),
				.clk_lp_ctrl_i (clk_lp_ctrl_i),
				.clk_pixel_i (1'b0),
				.pll_lock_i (tx_pll_lock),
				.lp_d0_tx_en_i (1'b0),
				.lp_d0_tx_n_i (1'b0),
				.lp_d0_tx_p_i (1'b0),
				.reset_pixel_n_i (1'b0),
				.clk_byte_fr_i (rx_byte_clk_fr_ch1), // use fr from ch1
				.clk_byte_fr_o (rx_byte_clk_fr_ch3),
				.clk_p_i (clk_ch3_p_i),
				.clk_n_i (clk_ch3_n_i),
				.d0_p_i (d0_ch3_p_i),
				.d0_n_i (d0_ch3_n_i),
				.bd_o (ch3_byte_data0),
				.wc_o(wc_ch3),
				.vc_o(vc_ch3),
			// debug pins
				.lp_en_o (lp_en_ch3),
				.sp_en_o (sp_en_ch3),
                                .payload_en_o(d2c_payload_en_ch3),
				.dt_o (dt_ch3),
				.hs_sync_o (hs_sync_ch3),
				.lp_hs_state_d_o (lp_hs_state_ch3)
			
);
defparam dphy2cmos_ch3.RX_TYPE="CSI2";
defparam dphy2cmos_ch3.TX_TYPE="CSI2";
defparam dphy2cmos_ch3.PD_BUS_WIDTH=10;
defparam dphy2cmos_ch3.NUM_RX_LANE=1;
defparam dphy2cmos_ch3.RX_GEAR=RX_GEAR;
defparam dphy2cmos_ch3.DPHY_RX_IP="LATTICE";
defparam dphy2cmos_ch3.LANE_ALIGN=LANE_ALIGN; 
defparam dphy2cmos_ch3.DATA_TYPE=DT;
defparam dphy2cmos_ch3.NUM_TX_CH=1;
defparam dphy2cmos_ch3.RX_CLK_MODE=RX_CLK_MODE;
defparam dphy2cmos_ch3.BYTECLK_MHZ=TX_FREQ_TGT/2;

defparam dphy2cmos_ch3.TX_WAIT_TIME=TX_WAIT_TIME;
//defparam dphy2cmos_ch3.FS_POSITION=FS_POSITION;


//mux between ch1 and ch3
csi2_4to1_1_muxer #(
  .RX_DATA_WIDTH              (RX_DATA_WIDTH)
)
muxer_ch1 (
.mux_sel                      (mux_sel_i),	      
                      		                        
.lp_en_chA                    (lp_en_ch1),	      
.sp_en_chA                    (sp_en_ch1),	      
// .rx_byte_clk_fr_chA        (rx_byte_clk_fr_ch1),
.d2c_payload_en_chA           (d2c_payload_en_ch1),  
.d2c_data_chA                 (d2c_data_ch1),	      
.wc_chA                       (wc_ch1),	      
.vc_chA                       (vc_ch1),	      
.dt_chA                       (dt_ch1),	      
                      		                        
.lp_en_chB                    (lp_en_ch3),	      
.sp_en_chB                    (sp_en_ch3),	      
// .rx_byte_clk_fr_chB	      (rx_byte_clk_fr_ch3),
.d2c_payload_en_chB           (d2c_payload_en_ch3),  
.d2c_data_chB                 (d2c_data_ch3),	      
.wc_chB                       (wc_ch3),	      
.vc_chB                       (vc_ch3),	      
.dt_chB                       (dt_ch3), 	      
                      		                        
.lp_en_mux                    (lp_en_mux1),   
.sp_en_mux                    (sp_en_mux1),	      
// .rx_byte_clk_fr_mux        (rx_byte_clk_fr_mux1),
.d2c_payload_en_mux           (d2c_payload_en_mux1),  
.d2c_data_mux                 (d2c_data_mux1),	      
.wc_mux                       (wc_mux1),	      
.vc_mux                       (vc_mux1),	      
.dt_mux                       (dt_mux1)
);           






csi2_4to1_1_line_buffer

 line_buffer_ch1 (
.rst_n_i                      (reset_n_i),
.reset_tx_n_i                 (reset_n_w),
.reset_rx_n_i                 (reset_byte_fr_n_i && tx_pll_lock),
.lp_en                        (lp_en_mux1),
.rx_clk_i                     (rx_byte_clk_fr_ch1),
.tx_clk_i                     (tx_byte_clk),
.d2c_payload_en_i             (d2c_payload_en_mux1),
.byte_i                       (d2c_data_mux1),
.d2c_wc_i                     (wc_mux1),
.hdr_rd_lbfr_en               (hdr0_rd_lbfr_en_ch1),
.hdr_wdcnt                    (hdr0_wdcnt),
.byte_o                       (byte_bufout_ch1),
.word_valid_o                 (lbfr_wdvalid_ch1),
.lbfr_halffull                (lbfr_halffull_ch1),
.empty_o                      (empty1),
.lbf_lastwd                   (lbf_lastwd_ch1)
);



csi2_4to1_1_tx_byte_data_gen 

tbdg_inst (
		
.rst_n_i                      (reset_n_w),
.tx_clk                       (tx_byte_clk),

.lbf_lastwd_ch0               (lbf_lastwd_ch0),
.byte_bufout_ch0              (byte_bufout_ch0),
.byte_bufout_ch1              (byte_bufout_ch1),
.lbfr_wdvalid_ch0             (lbfr_wdvalid_ch0),
.lbfr_wdvalid_ch1             (lbfr_wdvalid_ch1),
.rd_counter_ch0               (rd_counter_ch0),
.gen_data_valid_o             (tx_byte_data_vld),
.gen_word_o                   (tx_byte_data));



    

csi2_4to1_1_synchronizer sync_rst_byteclk_fr_ch0 (
  .clk                        (rx_byte_clk_fr_ch0),
  .rstn                       (reset_n_i),
  .in                         (reset_n_i),
  .out                        (rst_byteclkfr_sync));





csi2_4to1_1_arbiter_fsm arbiter_fsm_inst(
.clk_i             (tx_byte_clk),
.rst_n_i           (reset_n_w),
.c2d_rdy           (c2d_lanerdy),
.hdr0_req          (hdr0_req),   
.hdr0_wdcnt  	   (hdr0_wdcnt),  
.hdr0_dtype  	   (hdr0_dtype),  
.hdr0_chID   	   (hdr0_chID),   
.hdr0_SPtype 	   (hdr0_SPtype),
.hdr0_rd_lbfr_en   (hdr0_rd_lbfr_en_ch0),
.hdr0_xfrdone	   (hdr0_xfrdone),
.hdr1_req          (1'b0),
.hdr1_wdcnt	   (hdr1_wdcnt),  
.hdr1_dtype	   (hdr1_dtype),
.hdr1_chID	   (hdr1_chID),   
.hdr1_SPtype	   (hdr1_SPtype),
.hdr1_rd_lbfr_en   (hdr1_rd_lbfr_en_ch1),
.hdr1_xfrdone	   (hdr1_xfrdone),
.arb_lp_start      (arb_lp_start),
.arb_sp_req        (arb_sp_req),
.arb_wdcnt         (arb_wdcnt),
.arb_dtype	   (arb_dtype),
.arb_chID	   (arb_chID),	
.arb_SPtype	   (arb_SPtype),	
.arb_gnt0	   (arb_gnt0),	
.arb_gnt1	   (arb_gnt1),
.arb_rdy           (arb_rdy),	
.arb_c2dreq_o      (arb_c2dreq_o) //for both sp_req and lp_req 

);



csi2_4to1_1_cmos_2_dphy_ip cmos2dphy_inst (
		
  .reset_n_i                  (rst_byteclkfr_sync),
  .pix_clk_i                  (rx_byte_clk_fr_ch0),//refclk from generated freerunning rx byteclk
  .ref_clk_i                  (tx_refclk_i), // input to pll
  .pll_lock_i                 (rx_plllock),

  .core_clk_i                 (tx_byte_clk),
  .byte_clk_o                 (tx_byte_clk),
  .pd_dphy_i                  (1'b0),
  .pll_lock_o                 (tx_pll_lock),
  .tinit_done_o               (tinit_done),
  .c2d_ready_o                (c2d_lanerdy),
  .wc_i                       (arb_wdcnt),
// handshake between bridge & TX
// wait for d_hs_rdy_o before transmitting
  .ld_pyld_o                  (c2d_ld_pyld),   
  .clk_hs_en_i                (arb_c2dreq_o), // for TX_HS_LP mode; pulse to start LP-> HS clk transition
  .d_hs_en_i                  (arb_c2dreq_o), // for HS_ONLY mode; pulse to start TX data transition
  .d_hs_rdy_o                 (c2d_hs_rdy), // status signal : data lanes are ready to transmit
  .d_hs_en_o                  (), // for pixel2byte only
  .phdr_xfr_done_o            (c2d_phdr_done),			        


  .byte_data_i                (tx_byte_data),

  .d0_p_io                    (d0_p_o),
  .d0_n_io                    (d0_n_o),
  .vc_i (arb_chID),

  .byte_data_en_i (tx_byte_data_vld), 
  .sp_req_i (arb_sp_req),
  .lp_req_i (arb_lp_start),
 // data type
  .dt_i (arb_dtype),
 // output clock
  .clk_p_o (clk_p_o),
  .clk_n_o (clk_n_o)
 );
defparam cmos2dphy_inst.TESTMODE =0; // no testmode
defparam cmos2dphy_inst.CN=PLL_N;
defparam cmos2dphy_inst.CM=PLL_M;
defparam cmos2dphy_inst.CO=PLL_O;
defparam cmos2dphy_inst.CRC16=1;
defparam cmos2dphy_inst.FILTER_1STLINE=0;
defparam cmos2dphy_inst.TINIT_COUNT=TINIT_COUNT;
defparam cmos2dphy_inst.TINIT_VALUE=TINIT_VALUE;
defparam cmos2dphy_inst.TX_FREQ_TGT=TX_FREQ_TGT;
defparam cmos2dphy_inst.CLK_MODE=TX_CLK_MODE;
endmodule
