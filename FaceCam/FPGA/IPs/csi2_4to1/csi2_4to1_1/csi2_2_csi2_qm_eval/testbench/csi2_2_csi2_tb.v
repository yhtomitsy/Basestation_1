// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2004~2010 by Lattice Semiconductor Corporation
// --------------------------------------------------------------------
//
// Permission:
//
//   Lattice Semiconductor grants permission to use this code for use
//   in synthesis for any Lattice programmable logic product.  Other
//   use of this code, including the selling or duplication of any
//   portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL or Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Lattice Semiconductor provides no warranty
//   regarding the use or functionality of this code.
//
// --------------------------------------------------------------------
//
//                     Lattice Semiconductor Corporation
//                     5555 NE Moore Court
//                     Hillsboro, OR 97214
//                     U.S.A
//
//                     TEL: 1-800-Lattice (USA and Canada)
//                          408-826-6000 (other locations)
//
//                     web: http://www.latticesemi.com/
//                     email: techsupport@latticesemi.com
//
// --------------------------------------------------------------------
//
// This is the test bench module of the DUAL DPHY 2 DUAL design.  
// 
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V0.1 :| caquino           :| 04/20/16  :| Pre-Release
// --------------------------------------------------------------------

`timescale 1ps / 10fs

`include "dphy_model.v"
`include "dphy_monitor.v"
`include "dphy_scoreboard.v"

module top(); 
`ifndef NUM_FRAMES
   parameter num_frames = 1;
`else
   parameter num_frames = `NUM_FRAMES;
`endif

`ifndef NUM_LINES
   parameter num_lines  = 2;
`else
   parameter num_lines = `NUM_LINES;
`endif

`ifdef NO_OF_LANE_4
   parameter active_dphy_lanes = 4;
`elsif NO_OF_LANE_2
   parameter active_dphy_lanes = 2;
`else
   parameter active_dphy_lanes = 1;
`endif


`ifndef DPHY_CLK_PERIOD
   parameter dphy_clk_period = (1000000/(`TX_FREQ_TGT*8))*2;
`else
   parameter dphy_clk_period = `DPHY_CLK_PERIOD;
`endif

`ifndef DPHY_LPX
   parameter t_lpx = 50000; //in ps, min of 50000ps
`else
   parameter t_lpx = `DPHY_LPX;
`endif   

`ifndef DPHY_CLK_PREPARE
   parameter t_clk_prepare = 38000; //in ps, set between 38000 to 95000 ps
`else
   parameter t_clk_prepare = `DPHY_CLK_PREPARE;
`endif

`ifndef DPHY_CLK_ZERO
   parameter t_clk_zero = 262000;  //in ps, clk_prepare + clk_zero minimum should be 300000ps
`else
   parameter t_clk_zero = `DPHY_CLK_ZERO;
`endif

`ifndef DPHY_CLK_TRAIL
   parameter t_clk_trail = 60000; //in ps, min of 60000ps
`else
   parameter t_clk_trail = `DPHY_CLK_TRAIL;
`endif

`ifndef DPHY_CLK_PRE
   parameter t_clk_pre = (8*dphy_clk_period/2); //min of 8*UI
`else
   parameter t_clk_pre = `DPHY_CLK_PRE;
`endif

`ifndef DPHY_CLK_POST
   parameter t_clk_post = (60000 + (52*dphy_clk_period/2)); // min of 60ns + 52*UI
`else
   parameter t_clk_post = `DPHY_CLK_POST;
`endif

`ifndef DPHY_HS_PREPARE
   parameter t_hs_prepare = (40000 + (4*dphy_clk_period/2)); //in ps, set between 40ns+4*UI to max of 85ns+6*UI
`else
   parameter t_hs_prepare = `DPHY_HS_PREPARE;
`endif

`ifndef DPHY_HS_ZERO
   parameter t_hs_zero = ((145000 + (10*dphy_clk_period/2)) - t_hs_prepare); //in ns, hs_prepare + hs_zero minimum should be 145ns+10*UI
`else
   parameter t_hs_zero = `DPHY_HS_ZERO;
`endif

`ifndef DPHY_HS_TRAIL
   parameter t_hs_trail = (60000 + (4*dphy_clk_period/2)); //in ns, minimum should be 60ns+4*UI, max should be 105ns+12*UI
`else
   parameter t_hs_trail = `DPHY_HS_TRAIL;
`endif

`ifndef DPHY_LPS_GAP 
   parameter lps_gap = 5000000;
`else
   parameter lps_gap = `DPHY_LPS_GAP;
`endif

`ifndef FRAME_GAP
   parameter frame_gap = 5000000;
`else
   parameter frame_gap = `FRAME_GAP;
`endif

`ifndef DPHY_INIT_DRIVE_DELAY
   `ifdef MISC_ON
   parameter init_drive_delay = 100000;
   `else
   parameter init_drive_delay = 80000000;
   `endif
`else
   parameter init_drive_delay = `DPHY_INIT_DRIVE_DELAY;
`endif

//`ifndef CH0_CH1_DELAY
//   parameter ch0_ch1_delay = 0;
//`else
//   parameter ch0_ch1_delay = `CH0_CH1_DELAY;
//`endif

`ifndef CH0_INIT_DELAY // in dphy_clk cycles
   parameter ch0_init_delay = 0;
`else
   parameter ch0_init_delay = `CH0_INIT_DELAY;
`endif

`ifndef CH1_INIT_DELAY
   parameter ch1_init_delay = 0;
`else
   parameter ch1_init_delay = `CH1_INIT_DELAY;
`endif

`ifndef CH2_INIT_DELAY
   parameter ch2_init_delay = 0;
`else
   parameter ch2_init_delay = `CH2_INIT_DELAY;
`endif

`ifndef CH3_INIT_DELAY
   parameter ch3_init_delay = 0;
`else
   parameter ch3_init_delay = `CH3_INIT_DELAY;
`endif


`ifndef VC_CH0
   parameter ch0_vc = 0;
`else
   parameter ch0_vc = `VC_CH0;
`endif

`ifndef VC_CH1
   parameter ch1_vc = 0;
`else
   parameter ch1_vc = `VC_CH1;
`endif

`ifndef VC_CH2
   parameter ch2_vc = 0;
`else
   parameter ch2_vc = `VC_CH2;
`endif

`ifndef VC_CH3
   parameter ch3_vc = 0;
`else
   parameter ch3_vc = `VC_CH3;
`endif

`ifndef LS_LE_EN
   parameter ls_le_en = 0;
`else
   parameter ls_le_en = 1;
`endif

`ifndef DEBUG
   parameter debug = 0;
`else
   parameter debug = 1;
`endif

`ifdef DT_RAW8
   parameter data_type = 6'h2a;
   parameter num_pixels = `NUM_PIXELS;
   parameter long_even_line_en    = 0;
`elsif DT_RAW10
   parameter data_type = 6'h2b;
   parameter num_pixels = `NUM_PIXELS * 5/4;
   parameter long_even_line_en    = 0;
`elsif DT_RAW12
   parameter data_type = 6'h2c;
   parameter num_pixels = `NUM_PIXELS * 3/2;
   parameter long_even_line_en    = 0;
`elsif DT_RGB888
   parameter data_type = 6'h24;
   parameter num_pixels = `NUM_PIXELS * 3;
   parameter long_even_line_en    = 0;
`elsif DT_YUV420_10
   parameter data_type = 6'h19;
   parameter num_pixels = `NUM_PIXELS * 5/4; // odd line
   parameter long_even_line_en    = 1;
`elsif DT_YUV420_8
   parameter data_type = 6'h18;
   parameter num_pixels = `NUM_PIXELS ; // odd line
   parameter long_even_line_en    = 1;
`elsif DT_YUV422_10
   parameter data_type = 6'h1f;
   parameter num_pixels = `NUM_PIXELS * 2 * 5/4;
   parameter long_even_line_en    = 0;
`elsif DT_YUV422_8
   parameter data_type = 6'h1e;
   parameter num_pixels = `NUM_PIXELS * 2;
   parameter long_even_line_en    = 0;
`else
   parameter data_type = 6'h2b;
   parameter num_pixels = `NUM_PIXELS * 5/4;
   parameter long_even_line_en    = 0;
`endif

   //DUT input ports
   wire ch0_resetn;
   wire ch0_clk_p_i;
   wire ch0_clk_n_i;
   wire [3:0] ch0_do_p_i;
   wire [3:0] ch0_do_n_i;
   wire ch0_dvalid_o;
   wire [31:0] ch0_data_o;
   wire ch0_pkt_end_o;

   wire ch1_resetn;
   wire ch1_clk_p_i;
   wire ch1_clk_n_i;
   wire [3:0] ch1_do_p_i;
   wire [3:0] ch1_do_n_i;
   wire ch1_dvalid_o;
   wire [31:0] ch1_data_o;
   wire ch1_pkt_end_o;

   wire ch2_resetn;
   wire ch2_clk_p_i;
   wire ch2_clk_n_i;
   wire [3:0] ch2_do_p_i;
   wire [3:0] ch2_do_n_i;
   wire ch2_dvalid_o;
   wire [31:0] ch2_data_o;
   wire ch2_pkt_end_o;

   wire ch3_resetn;
   wire ch3_clk_p_i;
   wire ch3_clk_n_i;
   wire [3:0] ch3_do_p_i;
   wire [3:0] ch3_do_n_i;
   wire ch3_dvalid_o;
   wire [31:0] ch3_data_o;
   wire ch3_pkt_end_o;

   wire dphy_clk_p_o;
   wire dphy_clk_n_o;
   wire [3:0] dphy_do_p_o;
   wire [3:0] dphy_do_n_o;
   wire dphy_dvalid_o;
   wire [31:0] dphy_data_o;
   wire dphy_pkto_end_o;

   wire ch0_do_p_0;
   wire ch0_do_n_0;
   wire ch0_do_p_1;
   wire ch0_do_n_1;
   wire ch0_do_p_2;
   wire ch0_do_n_2;
   wire ch0_do_p_3;
   wire ch0_do_n_3;

   wire ch1_do_p_0;
   wire ch1_do_n_0;
   wire ch1_do_p_1;
   wire ch1_do_n_1;
   wire ch1_do_p_2;
   wire ch1_do_n_2;
   wire ch1_do_p_3;
   wire ch1_do_n_3;

   wire ch2_do_p_0;
   wire ch2_do_n_0;
   wire ch2_do_p_1;
   wire ch2_do_n_1;
   wire ch2_do_p_2;
   wire ch2_do_n_2;
   wire ch2_do_p_3;
   wire ch2_do_n_3;

   wire ch3_do_p_0;
   wire ch3_do_n_0;
   wire ch3_do_p_1;
   wire ch3_do_n_1;
   wire ch3_do_p_2;
   wire ch3_do_n_2;
   wire ch3_do_p_3;
   wire ch3_do_n_3;

   wire dphy_do_p_0;
   wire dphy_do_n_0;
   wire dphy_do_p_1;
   wire dphy_do_n_1;
   wire dphy_do_p_2;
   wire dphy_do_n_2;
   wire dphy_do_p_3;
   wire dphy_do_n_3;

   wire refclk_w;
   reg resetn;

   reg refclk_i;
   reg dphy_clk_i;
   reg dphy_clk_start; 
   reg dphy_data_start;
   reg test_e;
   reg ch0_ch1_i;

   //
   reg [15:0] wc;
   reg [7:0]  ecc;
   reg [15:0] chksum;
   reg [15:0] cur_crc;

   reg fnum;

   wire pll_lock;
   wire tinit_done;

   assign refclk_w = refclk_i;
   assign ch0_resetn = resetn;
   assign ch1_resetn = resetn;

   assign ch0_do_p_0 = ch0_do_p_i[0];
   assign ch0_do_n_0 = ch0_do_n_i[0];
   assign ch0_do_p_1 = ch0_do_p_i[1];
   assign ch0_do_n_1 = ch0_do_n_i[1];
   assign ch0_do_p_2 = ch0_do_p_i[2];
   assign ch0_do_n_2 = ch0_do_n_i[2];
   assign ch0_do_p_3 = ch0_do_p_i[3];
   assign ch0_do_n_3 = ch0_do_n_i[3];

   assign ch1_do_p_0 = ch1_do_p_i[0];
   assign ch1_do_n_0 = ch1_do_n_i[0];
   assign ch1_do_p_1 = ch1_do_p_i[1];
   assign ch1_do_n_1 = ch1_do_n_i[1];
   assign ch1_do_p_2 = ch1_do_p_i[2];
   assign ch1_do_n_2 = ch1_do_n_i[2];
   assign ch1_do_p_3 = ch1_do_p_i[3];
   assign ch1_do_n_3 = ch1_do_n_i[3];

   assign ch2_do_p_0 = ch2_do_p_i[0];
   assign ch2_do_n_0 = ch2_do_n_i[0];
   assign ch2_do_p_1 = ch2_do_p_i[1];
   assign ch2_do_n_1 = ch2_do_n_i[1];
   assign ch2_do_p_2 = ch2_do_p_i[2];
   assign ch2_do_n_2 = ch2_do_n_i[2];
   assign ch2_do_p_3 = ch2_do_p_i[3];
   assign ch2_do_n_3 = ch2_do_n_i[3];

   assign ch3_do_p_0 = ch3_do_p_i[0];
   assign ch3_do_n_0 = ch3_do_n_i[0];
   assign ch3_do_p_1 = ch3_do_p_i[1];
   assign ch3_do_n_1 = ch3_do_n_i[1];
   assign ch3_do_p_2 = ch3_do_p_i[2];
   assign ch3_do_n_2 = ch3_do_n_i[2];
   assign ch3_do_p_3 = ch3_do_p_i[3];
   assign ch3_do_n_3 = ch3_do_n_i[3];

   assign dphy_do_p_o[0] = dphy_do_p_0;
   assign dphy_do_n_o[0] = dphy_do_n_0;
   assign dphy_do_p_o[1] = dphy_do_p_1;
   assign dphy_do_n_o[1] = dphy_do_n_1;
   assign dphy_do_p_o[2] = dphy_do_p_2;
   assign dphy_do_n_o[2] = dphy_do_n_2;
   assign dphy_do_p_o[3] = dphy_do_p_3;
   assign dphy_do_n_o[3] = dphy_do_n_3;

   PUR PUR_INST(resetn);

   dphy_model #(
   .num_lines         (num_lines        ),  
   .num_pixels        (num_pixels       ),  
   .num_frames        (num_frames       ),
   .active_dphy_lanes (active_dphy_lanes),  
   .dphy_clk_period   (dphy_clk_period  ),  
   .data_type         (data_type        ),
   .t_lpx             (t_lpx            ),  
   .t_clk_prepare     (t_clk_prepare    ),  
   .t_clk_zero        (t_clk_zero       ),  
   .t_clk_trail       (t_clk_trail      ),  
   .t_clk_pre         (t_clk_pre        ),
   .t_clk_post        (t_clk_post       ),
   .t_hs_prepare      (t_hs_prepare     ),  
   .t_hs_zero         (t_hs_zero        ),  
   .t_hs_trail        (t_hs_trail       ),  
   .lps_gap           (lps_gap          ),  
   .frame_gap         (frame_gap        ),
   .init_drive_delay  (init_drive_delay),
   .dphy_ch           (0),
   .dphy_vc           (ch0_vc),
   .long_even_line_en (long_even_line_en),
   .ls_le_en          (ls_le_en),
   .debug             (debug)
      )
   dphy_ch0 (
      .refclk_i(dphy_clk_i ),
      .resetn  (ch0_resetn ),
`ifndef RX_CLK_MODE_HS_ONLY
      .clk_p_i (ch0_clk_p_i ),
      .clk_n_i (ch0_clk_n_i ),
      .cont_clk_p_i ( ),
      .cont_clk_n_i ( ),
`else
      .clk_p_i (),
      .clk_n_i (),
      .cont_clk_p_i (ch0_clk_p_i),
      .cont_clk_n_i (ch0_clk_n_i),
`endif
      .do_p_i  (ch0_do_p_i ),
      .do_n_i  (ch0_do_n_i )
      );

   dphy_model #(
   .num_lines         (num_lines        ),
   .num_pixels        (num_pixels       ),
   .num_frames        (num_frames       ),
   .active_dphy_lanes (active_dphy_lanes),
   .dphy_clk_period   (dphy_clk_period  ),
   .data_type         (data_type        ),
   .t_lpx             (t_lpx            ),
   .t_clk_prepare     (t_clk_prepare    ),
   .t_clk_zero        (t_clk_zero       ),
   .t_clk_trail       (t_clk_trail      ),
   .t_clk_pre         (t_clk_pre        ),
   .t_clk_post        (t_clk_post       ),
   .t_hs_prepare      (t_hs_prepare     ),
   .t_hs_zero         (t_hs_zero        ),
   .t_hs_trail        (t_hs_trail       ),
   .lps_gap           (lps_gap          ),
   .frame_gap         (frame_gap        ),
   .init_drive_delay  (init_drive_delay ),
   .dphy_ch           (1),
   .dphy_vc           (ch1_vc),
   .long_even_line_en (long_even_line_en),
   .ls_le_en          (ls_le_en),
   .debug             (debug)
      )
   dphy_ch1 (
      .refclk_i(dphy_clk_i ),
      .resetn  (ch1_resetn ),
`ifndef RX_CLK_MODE_HS_ONLY
      .clk_p_i (ch1_clk_p_i ),
      .clk_n_i (ch1_clk_n_i ),
      .cont_clk_p_i ( ),
      .cont_clk_n_i ( ),
`else
      .clk_p_i ( ),
      .clk_n_i ( ),
      .cont_clk_p_i (ch1_clk_p_i ),
      .cont_clk_n_i (ch1_clk_n_i ),
`endif
      .do_p_i  (ch1_do_p_i ),
      .do_n_i  (ch1_do_n_i )
      );

   dphy_model #(
   .num_lines         (num_lines        ),
   .num_pixels        (num_pixels       ),
   .num_frames        (num_frames       ),
   .active_dphy_lanes (active_dphy_lanes),
   .dphy_clk_period   (dphy_clk_period  ),
   .data_type         (data_type        ),
   .t_lpx             (t_lpx            ),
   .t_clk_prepare     (t_clk_prepare    ),
   .t_clk_zero        (t_clk_zero       ),
   .t_clk_trail       (t_clk_trail      ),
   .t_clk_pre         (t_clk_pre        ),
   .t_clk_post        (t_clk_post       ),
   .t_hs_prepare      (t_hs_prepare     ),
   .t_hs_zero         (t_hs_zero        ),
   .t_hs_trail        (t_hs_trail       ),
   .lps_gap           (lps_gap          ),
   .frame_gap         (frame_gap        ),
   .init_drive_delay  (init_drive_delay ),
   .dphy_ch           (2),
   .dphy_vc           (ch2_vc),
   .long_even_line_en (long_even_line_en),
   .ls_le_en          (ls_le_en),
   .debug             (debug)
      )
   dphy_ch2 (
      .refclk_i(dphy_clk_i ),
      .resetn  (ch2_resetn ),
`ifndef RX_CLK_MODE_HS_ONLY
      .clk_p_i (ch2_clk_p_i ),
      .clk_n_i (ch2_clk_n_i ),
      .cont_clk_p_i ( ),
      .cont_clk_n_i ( ),
`else
      .clk_p_i ( ),
      .clk_n_i ( ),
      .cont_clk_p_i (ch2_clk_p_i ),
      .cont_clk_n_i (ch2_clk_n_i ),
`endif
      .do_p_i  (ch2_do_p_i ),
      .do_n_i  (ch2_do_n_i )
      );

   dphy_model #(
   .num_lines         (num_lines        ),
   .num_pixels        (num_pixels       ),
   .num_frames        (num_frames       ),
   .active_dphy_lanes (active_dphy_lanes),
   .dphy_clk_period   (dphy_clk_period  ),
   .data_type         (data_type        ),
   .t_lpx             (t_lpx            ),
   .t_clk_prepare     (t_clk_prepare    ),
   .t_clk_zero        (t_clk_zero       ),
   .t_clk_trail       (t_clk_trail      ),
   .t_clk_pre         (t_clk_pre        ),
   .t_clk_post        (t_clk_post       ),
   .t_hs_prepare      (t_hs_prepare     ),
   .t_hs_zero         (t_hs_zero        ),
   .t_hs_trail        (t_hs_trail       ),
   .lps_gap           (lps_gap          ),
   .frame_gap         (frame_gap        ),
   .init_drive_delay  (init_drive_delay ),
   .dphy_ch           (3),
   .dphy_vc           (ch3_vc),
   .long_even_line_en (long_even_line_en),
   .ls_le_en          (ls_le_en),
   .debug             (debug)
      )
   dphy_ch3 (
      .refclk_i(dphy_clk_i ),
      .resetn  (ch3_resetn ),
`ifndef RX_CLK_MODE_HS_ONLY
      .clk_p_i (ch3_clk_p_i ),
      .clk_n_i (ch3_clk_n_i ),
      .cont_clk_p_i ( ),
      .cont_clk_n_i ( ),
`else
      .clk_p_i ( ),
      .clk_n_i ( ),
      .cont_clk_p_i (ch3_clk_p_i ),
      .cont_clk_n_i (ch3_clk_n_i ),
`endif
      .do_p_i  (ch3_do_p_i ),
      .do_n_i  (ch3_do_n_i )
      );

dphy_monitor#(
   .name       ("DPHY_MON_CH0_I"),
   .bus_width  (active_dphy_lanes),
   .data_width (4)
)
dphy_ch0_mon(
   .clk_p_i(ch0_clk_p_i),
   .clk_n_i(ch0_clk_n_i),
   .do_p_i (ch0_do_p_i),
   .do_n_i (ch0_do_n_i),
   .dvalid (ch0_dvalid_o),
   .data_out(ch0_data_o),
   .pkt_end (ch0_pkt_end_o)
);

dphy_monitor#(
   .name       ("DPHY_MON_CH1_I"),
   .bus_width  (active_dphy_lanes),
   .data_width (4)
)
dphy_ch1_mon(
   .clk_p_i(ch1_clk_p_i),
   .clk_n_i(ch1_clk_n_i),
   .do_p_i (ch1_do_p_i),
   .do_n_i (ch1_do_n_i),
   .dvalid (ch1_dvalid_o),
   .data_out(ch1_data_o),
   .pkt_end (ch1_pkt_end_o)
);

dphy_monitor#(
   .name       ("DPHY_MON_CH2_I"),
   .bus_width  (active_dphy_lanes),
   .data_width (4)
)
dphy_ch2_mon(
   .clk_p_i(ch2_clk_p_i),
   .clk_n_i(ch2_clk_n_i),
   .do_p_i (ch2_do_p_i),
   .do_n_i (ch2_do_n_i),
   .dvalid (ch2_dvalid_o),
   .data_out(ch2_data_o),
   .pkt_end (ch2_pkt_end_o)
);

dphy_monitor#(
   .name       ("DPHY_MON_CH3_I"),
   .bus_width  (active_dphy_lanes),
   .data_width (4)
)
dphy_ch3_mon(
   .clk_p_i(ch3_clk_p_i),
   .clk_n_i(ch3_clk_n_i),
   .do_p_i (ch3_do_p_i),
   .do_n_i (ch3_do_n_i),
   .dvalid (ch3_dvalid_o),
   .data_out(ch3_data_o),
   .pkt_end (ch3_pkt_end_o)
);


dphy_monitor#(
   .name       ("DPHY_MON_O"),
   .bus_width  (active_dphy_lanes),
   .data_width (4)
)
dphy_out_mon(
   .clk_p_i(dphy_clk_p_o),
   .clk_n_i(dphy_clk_n_o),
   .do_p_i (dphy_do_p_o),
   .do_n_i (dphy_do_n_o),
   .dvalid (dphy_dvalid_o),
   .data_out(dphy_data_o),
   .pkt_end (dphy_pkto_end_o)
);

dphy_scoreboard#(
    .name      ("DPHY_SCOREBOARD"),
    .bus_width (active_dphy_lanes),
    .word_count(num_pixels),
    .long_even_en(long_even_line_en)
)
dphy_scoreboard(
    .ch0_ch1_i(ch0_ch1_i),
`ifdef MUX_SEL1
    .dvalid0  (ch2_dvalid_o),
    .data0    (ch2_data_o),
    .pkt0_end (ch2_pkt_end_o),
    .dvalid1  (ch3_dvalid_o),
    .data1    (ch3_data_o),
    .pkt1_end (ch3_pkt_end_o),
`else
    .dvalid0  (ch0_dvalid_o),
    .data0    (ch0_data_o),
    .pkt0_end (ch0_pkt_end_o),
    .dvalid1  (ch1_dvalid_o),
    .data1    (ch1_data_o),
    .pkt1_end (ch1_pkt_end_o),
`endif
    .dvalid_o (dphy_dvalid_o),
    .data_o   (dphy_data_o),
    .pkto_end (dphy_pkto_end_o),
    .test_e   (test_e)
);

  csi2_2_csi2_ip_wrapper I_quad_dphy_2_dphy_camera (
        .reset_n_i(resetn),
`ifdef RX_CLK_MODE_HS_LP 
        .ref_clk_i(refclk_w),
`endif

`ifdef MUX_SEL1
        .mux_sel_i(1),
`else
        .mux_sel_i(0),
`endif
        .clk_ch0_p_i(ch0_clk_p_i),
        .clk_ch0_n_i(ch0_clk_n_i),
        .clk_ch1_p_i(ch1_clk_p_i),
        .clk_ch1_n_i(ch1_clk_n_i),
        .clk_ch2_p_i(ch2_clk_p_i),
        .clk_ch2_n_i(ch2_clk_n_i),
        .clk_ch3_p_i(ch3_clk_p_i),
        .clk_ch3_n_i(ch3_clk_n_i),
        .d0_ch0_n_i (ch0_do_n_0),
        .d0_ch0_p_i (ch0_do_p_0),
        .d0_ch1_n_i (ch1_do_n_0),
        .d0_ch1_p_i (ch1_do_p_0),
        .d0_ch2_n_i (ch2_do_n_0),
        .d0_ch2_p_i (ch2_do_p_0),
        .d0_ch3_n_i (ch3_do_n_0),
        .d0_ch3_p_i (ch3_do_p_0),
        .d0_n_o(dphy_do_n_0),
        .d0_p_o(dphy_do_p_0),
`ifdef NO_OF_LANE_2
        .d1_ch0_n_i (ch0_do_n_1),
        .d1_ch0_p_i (ch0_do_p_1),
        .d1_ch1_n_i (ch1_do_n_1),
        .d1_ch1_p_i (ch1_do_p_1),
        .d1_ch2_n_i (ch2_do_n_1),
        .d1_ch2_p_i (ch2_do_p_1),
        .d1_ch3_n_i (ch3_do_n_1),
        .d1_ch3_p_i (ch3_do_p_1),
        .d1_n_o(dphy_do_n_1),
        .d1_p_o(dphy_do_p_1),
`endif

`ifdef NO_OF_LANE_4
        .d1_ch0_n_i (ch0_do_n_1),
        .d1_ch0_p_i (ch0_do_p_1),
        .d2_ch0_n_i (ch0_do_n_2),
        .d2_ch0_p_i (ch0_do_p_2),
        .d3_ch0_n_i (ch0_do_n_3),
        .d3_ch0_p_i (ch0_do_p_3),
        .d1_ch1_n_i (ch1_do_n_1),
        .d1_ch1_p_i (ch1_do_p_1),
        .d2_ch1_n_i (ch1_do_n_2),
        .d2_ch1_p_i (ch1_do_p_2),
        .d3_ch1_n_i (ch1_do_n_3),
        .d3_ch1_p_i (ch1_do_p_3),
        .d1_ch2_n_i (ch2_do_n_1),
        .d1_ch2_p_i (ch2_do_p_1),
        .d2_ch2_n_i (ch2_do_n_2),
        .d2_ch2_p_i (ch2_do_p_2),
        .d3_ch2_n_i (ch2_do_n_3),
        .d3_ch2_p_i (ch2_do_p_3),
        .d1_ch3_n_i (ch3_do_n_1),
        .d1_ch3_p_i (ch3_do_p_1),
        .d2_ch3_n_i (ch3_do_n_2),
        .d2_ch3_p_i (ch3_do_p_2),
        .d3_ch3_n_i (ch3_do_n_3),
        .d3_ch3_p_i (ch3_do_p_3),
        .d1_n_o(dphy_do_n_1),
        .d1_p_o(dphy_do_p_1),
        .d2_n_o(dphy_do_n_2),
        .d2_p_o(dphy_do_p_2),
        .d3_n_o(dphy_do_n_3),
        .d3_p_o(dphy_do_p_3),
`endif
`ifdef MISC_ON
    `ifdef MISC_TXPLLLOCK
        .tx_pll_lock_o(pll_lock)  ,
    `endif
    `ifdef MISC_TINITDONE
        .tinit_done_o (tinit_done),
    `endif
`endif
        .clk_p_o(dphy_clk_p_o),
        .clk_n_o(dphy_clk_n_o)
);

   initial begin
      refclk_i = 0;
      dphy_clk_i = 0;
      dphy_clk_start = 0;
      dphy_data_start = 0;
      resetn = 0;
      test_e = 0;

   `ifdef VC
      `ifdef MUX_SEL0
         // init delay is in terms of byte clock
         if (ch1_init_delay < ch0_init_delay) begin
            ch0_ch1_i = 1;
         end else
         begin
            ch0_ch1_i = 0;
         end
      `elsif MUX_SEL1
         if (ch3_init_delay < ch2_init_delay) begin // byte clock
            ch0_ch1_i = 1;
         end else
         begin
            ch0_ch1_i = 0;
         end
      `endif
   `elsif LR
      ch0_ch1_i = 0; // channel 0 is always transmitted first in LR mode
   `endif

      wc = num_pixels ;
      fnum = 0;
      chksum = 16'hffff;
      
      $display("%0t TEST START\n", $time);
      #(50000);
      resetn = 1;

      `ifdef MISC_ON
        `ifdef MISC_TINITDONE
            @(tinit_done);
            $display("%0t tinit_done detected\n", $time);
        `elsif MISC_TXPLLLOCK
            @(pll_lock);
            $display("%0t pll_lock detected\n", $time);
        `else
        `endif
      `endif

      #(50000);
      $display("%0t Activating dphy models\n", $time);
      fork
         begin
//           #ch0_init_delay;
           repeat (ch0_init_delay*8) @ (dphy_clk_i);
           dphy_ch0.dphy_active = 1;
         end
         begin
//           #ch1_init_delay;
           repeat (ch1_init_delay*8) @ (dphy_clk_i); //
           dphy_ch1.dphy_active = 1;
         end
         begin
//           #ch2_init_delay;
           repeat (ch2_init_delay*8) @ (dphy_clk_i);
           dphy_ch2.dphy_active = 1;
         end
         begin
//           #ch3_init_delay;
           repeat (ch3_init_delay*8) @ (dphy_clk_i);
           dphy_ch3.dphy_active = 1;
         end
     join
//      #ch0_ch1_delay; // insert delay before activating ch1
//      dphy_ch1.dphy_active = 1;
//      dphy_ch2.dphy_active = 1;
//      dphy_ch3.dphy_active = 1;

      // wait until end of test
      fork
        @(dphy_ch0.dphy_active == 0);
        @(dphy_ch1.dphy_active == 0);
        @(dphy_ch2.dphy_active == 0);
        @(dphy_ch3.dphy_active == 0);
      join
//      #(50000);
      repeat (20000) @ (dphy_clk_i);
      test_e = 1; // initiating data count check in scoreboard
      #(10000);
      $display("%0t TEST END\n", $time);
      $finish;
   end

   initial begin
      $shm_open("./dump.shm");
      $shm_probe(top, ("AC"));
   end

   //always #(refclk_period/2) refclk_i =~ refclk_i;
   `ifndef RX_CLK_MODE_HS_ONLY 
      always #(dphy_clk_period*4/2) refclk_i =~ refclk_i;
   `endif
   always #(dphy_clk_period/2) dphy_clk_i =~ dphy_clk_i;

endmodule
