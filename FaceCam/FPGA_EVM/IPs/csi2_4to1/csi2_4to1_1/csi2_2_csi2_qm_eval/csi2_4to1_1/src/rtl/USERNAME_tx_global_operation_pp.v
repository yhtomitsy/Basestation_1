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

tx_global_operation #(
////added support for HS_ONLY
  .CLK_MODE    (PP_TX_CLK_MODE),
  .LANE_WIDTH  (PP_LANE_WIDTH),
  .DATA_WIDTH  (PP_DATA_WIDTH),
  .GEAR_16     (PP_GEAR_16),
  .TX_FREQ_TGT (PP_TX_FREQ_TGT),
#ifdef PP_T_DATPREP
  .T_DATPREP      (PP_T_DATPREP),
#endif
#ifdef PP_T_DAT_HSZERO
  .T_DAT_HSZERO   (PP_T_DAT_HSZERO),
#endif
#ifdef PP_T_CLKPOST
  .T_CLKPOST      (PP_T_CLKPOST),
#endif
#ifdef PP_T_CLKPRE
  .T_CLKPRE       (PP_T_CLKPRE),
#endif
  .LPHS_FIFO_IMPL (PP_LPHS_FIFO_IMPL)
)
tx_global_operation_inst (
  // clock and reset
  .reset_n          (reset_n),
  .core_clk         (core_clk),
  // interface signals from pkt header and footer
  .dphy_pkten_i     (dphy_pkten_i),
  .dphy_pkt_i       (dphy_pkt_i),

  .clk_hs_en_i      (clk_hs_en_i),
  .d_hs_en_i        (d_hs_en_i),

  .d_hs_rdy_o       (d_hs_rdy_o),
  // interface to DCI wrapper
  // HS i/f
  .hs_clk_gate_en_o (hs_clk_gate_en_o),
  .hs_clk_en_o      (hs_clk_en_o),
  .hs_data_en_o     (hs_data_en_o),
#ifdef PP_NUM_TX_LANE_4
  .hs_data_d3_o     (hs_data_d3_o),
  .hs_data_d2_o     (hs_data_d2_o),
  .hs_data_d1_o     (hs_data_d1_o),
  .hs_data_d0_o     (hs_data_d0_o),
#endif	
#ifdef PP_NUM_TX_LANE_3
  .hs_data_d2_o     (hs_data_d2_o),
  .hs_data_d1_o     (hs_data_d1_o),
  .hs_data_d0_o     (hs_data_d0_o),
#endif	
#ifdef PP_NUM_TX_LANE_2
  .hs_data_d1_o     (hs_data_d1_o),
  .hs_data_d0_o     (hs_data_d0_o),
#endif	
#ifdef PP_NUM_TX_LANE_1
  .hs_data_d0_o     (hs_data_d0_o),
#endif	
  .c2d_ready_o      (c2d_ready_o),
  // LP i/f
  .lp_clk_en_o      (lp_clk_en_o),
  .lp_clk_p_o       (lp_clk_p_o),
  .lp_clk_n_o       (lp_clk_n_o),
  .lp_data_en_o     (lp_data_en_o),
  .lp_data_p_o      (lp_data_p_o),
  .lp_data_n_o      (lp_data_n_o)
);

endmodule
