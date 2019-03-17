#include <orcapp_head>

module USERNAME_hdr_buffer
(
 input 		   rst_n_i,
 input 		   reset_tx_n_i,
 input 		   reset_rx_n_i,
 input 		   tx_clk_i,
 input 		   rx_clk_i,
 input 		   d2c_sp_en_i,
 input 		   d2c_lp_en_i,
 input [7:0] 	   d2c_ph_i,
 input [15:0] 	   d2c_wc_i,
 input 		   d2c_payload_en_i,
 input 		   arb_rdy,
 input 		   arb_gnt,
 input             c2d_hs_rdy,
 input             c2d_ld_pyld,
 input             c2d_phdr_done,
 input 		   lbf_txrdy,
 input 		   lbf_lastwd_ch0,

#ifdef PP_LR //------
 input 		   lbf_lastwd_ch1,  
 output 	   hdr_rd_lbfr_en1, 
#endif
 
 output  	   hdr_rd_lbfr_en0,
 output  	   hdr_req,
 output  [15:0]    hdr_wdcnt,
 output  [5:0]     hdr_dtype,
 output  [1:0]     hdr_chID,
 output  	   hdr_SPtype, 
 output  	   hdr_xfrdone

);

endmodule
