#include <orcapp_head>

module USERNAME_line_buffer
(
  input                          rst_n_i,
  input                          reset_rx_n_i,
  input                          reset_tx_n_i,
  input                          rx_clk_i,
  input                          tx_clk_i,
  input                          d2c_payload_en_i,	
  input [PP_RX_DATA_WIDTH-1:0]      byte_i,
  input [15:0]                   d2c_wc_i,
  input                          hdr_rd_lbfr_en,
  input [15:0]                   hdr_wdcnt,
  input                          lp_en,
  output  [15:0] 		 rd_counter,
  output  [PP_TX_DATA_WIDTH-1:0] byte_o,
  output                      word_valid_o,
  output                      empty_o,
  output                      lbfr_halffull,
  output                      lbf_lastwd
) ;

endmodule
