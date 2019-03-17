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
);


line_buffer
#(
.LANE_COUNT    (PP_LANE_COUNT),
.TX_DATA_WIDTH (PP_TX_DATA_WIDTH),
.RX_DATA_WIDTH (PP_RX_DATA_WIDTH),
.BUFFER_DEPTH  (PP_LBUF_DEPTH),
.CHANNEL_ID    (0)
)
line_buffer (
.rst_n_i                      (rst_n_i),
.reset_tx_n_i                 (reset_tx_n_i),
.reset_rx_n_i                 (reset_rx_n_i),
.lp_en                        (lp_en),
.rx_clk_i                     (rx_clk_i),
.tx_clk_i                     (tx_clk_i),
.d2c_payload_en_i             (d2c_payload_en_i),
.byte_i                       (byte_i),
.d2c_wc_i                     (d2c_wc_i),
.hdr_rd_lbfr_en               (hdr_rd_lbfr_en),
.hdr_wdcnt                    (hdr_wdcnt),
.rd_counter                   (rd_counter),
.byte_o                       (byte_o),
.word_valid_o                 (word_valid_o),
.lbfr_halffull                (lbfr_halffull),
.empty_o                      (empty_o),
.lbf_lastwd                   (lbf_lastwd)
);

endmodule
