#include <orcapp_head>

module USERNAME_dci_wrapper (
  // clock and reset
  input wire                      refclk,
  input wire                      reset_n, 
  // MIPI interface signals
  inout wire                      clk_p_o,
  inout wire                      clk_n_o,
#ifdef PP_NUM_TX_LANE_4
  inout wire                      d3_p_o,
  inout wire                      d3_n_o,
  inout wire                      d2_p_o,
  inout wire                      d2_n_o,
  inout wire                      d1_p_o,
  inout wire                      d1_n_o,
  inout wire                      d0_p_io,
  inout wire                      d0_n_io,
#endif
#ifdef PP_NUM_TX_LANE_3
  inout wire                      d2_p_o,
  inout wire                      d2_n_o,
  inout wire                      d1_p_o,
  inout wire                      d1_n_o,
  inout wire                      d0_p_io,
  inout wire                      d0_n_io,
#endif
#ifdef PP_NUM_TX_LANE_2
  inout wire                      d1_p_o,
  inout wire                      d1_n_o,
  inout wire                      d0_p_io,
  inout wire                      d0_n_io,
#endif
#ifdef PP_NUM_TX_LANE_1
  inout wire                      d0_p_io,
  inout wire                      d0_n_io,
#endif
  // high-speed transmit signals
  output wire                     txbyte_clkhs_o,
  output wire                     pll_lock_o,
  input wire                      txclk_hsen_i,
  input wire                      txclk_hsgate_i,
  input wire                      pd_dphy_i,
#ifdef PP_NUM_TX_LANE_4
  input wire [PP_DATA_WIDTH-1:0]  dl3_txdata_hs_i,
  input wire [PP_DATA_WIDTH-1:0]  dl2_txdata_hs_i,
  input wire [PP_DATA_WIDTH-1:0]  dl1_txdata_hs_i,
  input wire [PP_DATA_WIDTH-1:0]  dl0_txdata_hs_i,
  input wire                      dl3_txdata_hs_en_i,
  input wire                      dl2_txdata_hs_en_i,
  input wire                      dl1_txdata_hs_en_i,
  input wire                      dl0_txdata_hs_en_i,
#endif
#ifdef PP_NUM_TX_LANE_3
  input wire [PP_DATA_WIDTH-1:0]  dl2_txdata_hs_i,
  input wire [PP_DATA_WIDTH-1:0]  dl1_txdata_hs_i,
  input wire [PP_DATA_WIDTH-1:0]  dl0_txdata_hs_i,
  input wire                      dl2_txdata_hs_en_i,
  input wire                      dl1_txdata_hs_en_i,
  input wire                      dl0_txdata_hs_en_i,
#endif
#ifdef PP_NUM_TX_LANE_2
  input wire [PP_DATA_WIDTH-1:0]  dl1_txdata_hs_i,
  input wire [PP_DATA_WIDTH-1:0]  dl0_txdata_hs_i,
  input wire                      dl1_txdata_hs_en_i,
  input wire                      dl0_txdata_hs_en_i,
#endif
#ifdef PP_NUM_TX_LANE_1
  input wire [PP_DATA_WIDTH-1:0]  dl0_txdata_hs_i,
  input wire                      dl0_txdata_hs_en_i,
#endif
  // low-power transmit signals
  input wire                      txclk_lp_p_i,
  input wire                      txclk_lp_n_i,
  input wire                      clk_lpen_i,
  input wire                      lp_direction_i,
#ifdef PP_LP_4
  input wire                      dl3_txdata_lp_p_i,
  input wire                      dl3_txdata_lp_n_i,
  input wire                      dl2_txdata_lp_p_i,
  input wire                      dl2_txdata_lp_n_i,
  input wire                      dl1_txdata_lp_p_i,
  input wire                      dl1_txdata_lp_n_i,
  input wire                      dl0_txdata_lp_p_i,
  input wire                      dl0_txdata_lp_n_i,
  input wire                      dl3_txdata_lp_en_i,
  input wire                      dl2_txdata_lp_en_i,
  input wire                      dl1_txdata_lp_en_i,
  input wire                      dl0_txdata_lp_en_i,
#endif
#ifdef PP_LP_3
  input wire                      dl2_txdata_lp_p_i,
  input wire                      dl2_txdata_lp_n_i,
  input wire                      dl1_txdata_lp_p_i,
  input wire                      dl1_txdata_lp_n_i,
  input wire                      dl0_txdata_lp_p_i,
  input wire                      dl0_txdata_lp_n_i,
  input wire                      dl2_txdata_lp_en_i,
  input wire                      dl1_txdata_lp_en_i,
  input wire                      dl0_txdata_lp_en_i,
#endif
#ifdef PP_LP_2
  input wire                      dl1_txdata_lp_p_i,
  input wire                      dl1_txdata_lp_n_i,
  input wire                      dl0_txdata_lp_p_i,
  input wire                      dl0_txdata_lp_n_i,
  input wire                      dl1_txdata_lp_en_i,
  input wire                      dl0_txdata_lp_en_i,
#endif
#ifdef PP_LP_1
  input wire                      dl0_txdata_lp_p_i,
  input wire                      dl0_txdata_lp_n_i,
  input wire                      dl0_txdata_lp_en_i,
#endif
  // Not use - in case to support bus turn-around
  output wire                     rxclk_lp_p_o,
  output wire                     rxclk_lp_n_o,
  output wire                     dl0_rxdata_lp_p_o,
  output wire                     dl0_rxdata_lp_n_o
) /*synthesis syn_black_box black_box_pad_pin="clk_p_o,clk_n_o,d3_p_o,d3_n_o,d2_p_o,d2_n_o,d1_p_o,d1_n_o,d0_p_io,d0_n_io" */;

endmodule
