#include <orcapp_head>

module USERNAME_arbiter_fsm
(
 input 		   clk_i,
 input 		   rst_n_i,

// from cmos2dphy
 input 		   c2d_rdy,

// from header buffers
 
 input 		   hdr0_req,
 input [15:0] 	   hdr0_wdcnt,
 input [5:0] 	   hdr0_dtype,
 input [1:0] 	   hdr0_chID,
 input 		   hdr0_SPtype,

 input             hdr0_rd_lbfr_en,
 input 		   hdr0_xfrdone,

 input 		   hdr1_req,
 input [15:0] 	   hdr1_wdcnt,
 input [5:0] 	   hdr1_dtype,
 input [1:0] 	   hdr1_chID,
 input 		   hdr1_SPtype,

 input             hdr1_rd_lbfr_en,
 input 		   hdr1_xfrdone,

// output to cmos2dphy ( tx clk domain)
 output  	   arb_sp_req,
 output  [15:0]    arb_wdcnt,
 output  [5:0]     arb_dtype,
 output  [1:0]     arb_chID,
 output  	   arb_SPtype,

 output         arb_lp_start,

// output to header buffers
 output  	   arb_gnt0,
 output  	   arb_gnt1,
 output  	   arb_rdy, //idle

 output  	   arb_c2dreq_o

);



endmodule
