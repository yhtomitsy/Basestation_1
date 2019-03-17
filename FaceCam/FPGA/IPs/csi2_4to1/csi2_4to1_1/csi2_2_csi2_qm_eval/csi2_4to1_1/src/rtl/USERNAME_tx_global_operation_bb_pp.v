#include <orcapp_head>

module USERNAME_tx_global_operation (
  // clock and reset
  input wire                       reset_n,
  input wire                       core_clk,
  // interface signals from pkt header and footer
  input wire                       dphy_pkten_i,
  input wire [4*PP_DATA_WIDTH-1:0] dphy_pkt_i,

  input wire                       clk_hs_en_i,
  input wire                       d_hs_en_i,

  output wire                      d_hs_rdy_o,
  // interface to DCI wrapper
  // HS i/f
  output wire                      hs_clk_gate_en_o,
  output wire                      hs_clk_en_o,
  output wire                      hs_data_en_o,
#ifdef PP_NUM_TX_LANE_4
  output wire [PP_DATA_WIDTH-1:0]  hs_data_d3_o,
  output wire [PP_DATA_WIDTH-1:0]  hs_data_d2_o,
  output wire [PP_DATA_WIDTH-1:0]  hs_data_d1_o,
  output wire [PP_DATA_WIDTH-1:0]  hs_data_d0_o,
#endif
#ifdef PP_NUM_TX_LANE_3
  output wire [PP_DATA_WIDTH-1:0]  hs_data_d2_o,
  output wire [PP_DATA_WIDTH-1:0]  hs_data_d1_o,
  output wire [PP_DATA_WIDTH-1:0]  hs_data_d0_o,
#endif
#ifdef PP_NUM_TX_LANE_2
  output wire [PP_DATA_WIDTH-1:0]  hs_data_d1_o,
  output wire [PP_DATA_WIDTH-1:0]  hs_data_d0_o,
#endif
#ifdef PP_NUM_TX_LANE_1
  output wire [PP_DATA_WIDTH-1:0]  hs_data_d0_o,
#endif	
  output wire                      c2d_ready_o,
 
  // LP i/f
  output wire                      lp_clk_en_o,
  output wire                      lp_clk_p_o,
  output wire                      lp_clk_n_o,
  output wire                      lp_data_en_o,
  output wire                      lp_data_p_o,
  output wire                      lp_data_n_o
);

endmodule
