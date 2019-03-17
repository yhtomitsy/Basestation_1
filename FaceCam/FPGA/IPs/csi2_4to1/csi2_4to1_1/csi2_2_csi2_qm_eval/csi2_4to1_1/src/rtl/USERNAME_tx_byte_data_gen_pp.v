#include <orcapp_head>

module USERNAME_tx_byte_data_gen (		
  input                       rst_n_i,
  input                       tx_clk,

  input                       lbf_lastwd_ch0,
  input [PP_TX_GEAR*PP_NO_LANE-1:0] byte_bufout_ch0,
  input [PP_TX_GEAR*PP_NO_LANE-1:0] byte_bufout_ch1,
  input                       lbfr_wdvalid_ch0,
  input                       lbfr_wdvalid_ch1,
  input [15:0]                rd_counter_ch0, 

  output [63:0]           gen_word_o,
  output                  gen_data_valid_o
);

tx_byte_data_gen
#(
.NO_LANE   (PP_NO_LANE),
.TX_GEAR   (PP_TX_GEAR)
)
tx_byte_data_gen (

.rst_n_i            (rst_n_i),
.tx_clk             (tx_clk),
.lbf_lastwd_ch0     (lbf_lastwd_ch0),
.byte_bufout_ch0    (byte_bufout_ch0),
.byte_bufout_ch1    (byte_bufout_ch1),
.lbfr_wdvalid_ch0   (lbfr_wdvalid_ch0),
.lbfr_wdvalid_ch1   (lbfr_wdvalid_ch1),
.rd_counter_ch0     (rd_counter_ch0),
.gen_data_valid_o   (gen_data_valid_o),
.gen_word_o         (gen_word_o)
);

endmodule
