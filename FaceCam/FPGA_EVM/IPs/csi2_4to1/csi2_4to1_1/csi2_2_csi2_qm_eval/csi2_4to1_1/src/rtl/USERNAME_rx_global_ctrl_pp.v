#include <orcapp_head>

module USERNAME_rx_global_ctrl
(
    input  wire	              reset_n_i,
    input  wire	              reset_lp_n_i,
    input  wire	              reset_byte_fr_n_i,
    input  wire               clk_lp_ctrl_i,
    input  wire	              clk_byte_hs_i,
    input  wire	              clk_byte_i,
    input  wire	              clk_byte_fr_i,
    input  wire	              pll_lock_i,         // PLL Lock indicator, active high

    input wire [PP_RX_GEAR-1:0]  bd0_i,
    input wire [PP_RX_GEAR-1:0]  bd1_i,
    input wire [PP_RX_GEAR-1:0]  bd2_i,
    input wire [PP_RX_GEAR-1:0]  bd3_i,
    input wire                lp_clk_p_i,         // LP P on CLK lane
    input wire                lp_clk_n_i,         // LP N on CLK lane
    input wire                lp_d0_p_i,          // LP P on D0 lane
    input wire                lp_d0_n_i,          // LP N on D0 lane
    input wire                lp_d1_p_i,          // LP P on D1 lane
    input wire                lp_d1_n_i,          // LP N on D1 lane
    input wire                lp_d2_p_i,          // LP P on D2 lane
    input wire                lp_d2_n_i,          // LP N on D2 lane
    input wire                lp_d3_p_i,          // LP P on D3 lane
    input wire                lp_d3_n_i,          // LP N on D3 lane
    input wire                hs_sync_i,          // HS sync from Lane Aligner, active high
    output wire [PP_RX_GEAR-1:0] bd0_o,
    output wire [PP_RX_GEAR-1:0] bd1_o,
    output wire [PP_RX_GEAR-1:0] bd2_o,
    output wire [PP_RX_GEAR-1:0] bd3_o,
    output wire               term_clk_en_o,      // Termination Enable on CLK lane for HS mode, active high
    output wire               term_d0_en_o,       // Termination Enable on Data lane 0 for HS mode, active high
    output wire               hs_d0_en_o,   	  // HS mode Enable on Data lane 0, active high
    output wire               term_d1_en_o,       // Termination Enable on Data lane 1 for HS mode, active high
    output wire               hs_d1_en_o,         // HS mode Enable on Data lane 1, active high
    output wire               term_d2_en_o,       // Termination Enable on Data lane 2 for HS mode, active high
    output wire               hs_d2_en_o,         // HS mode Enable on Data lane 2, active high
    output wire               term_d3_en_o,       // Termination Enable on Data lane 3 for HS mode, active high
    output wire               hs_d3_en_o,         // HS mode Enable on Data lane 3, active high
    output wire               hs_sync_o,          // HS sync, active high
    output wire [1:0]         lp_hs_state_clk_o,  // LP HS state machine (CLK) for debug
    output wire [1:0]         lp_hs_state_d_o     // LP HS state machine (D0) for debug
);

rx_global_ctrl 
#(
    .NUM_RX_LANE   (PP_NUM_RX_LANE),
    .RX_GEAR       (PP_RX_GEAR),
    .RX_FIFO       (PP_RX_FIFO),
    .RX_CLK_MODE   (PP_RX_CLK_MODE)
)
rx_global_ctrl (
    .reset_n_i         (reset_n_i),
    .reset_lp_n_i      (reset_lp_n_i),
    .reset_byte_fr_n_i (reset_byte_fr_n_i),
    .clk_lp_ctrl_i     (clk_lp_ctrl_i),
    .clk_byte_i        (clk_byte_i),
    .clk_byte_hs_i     (clk_byte_hs_i),
    .clk_byte_fr_i     (clk_byte_fr_i),// use stoppable byteclk clk_hs (clk_byte_fr_i),
    .pll_lock_i        (pll_lock_i),
    .bd0_i             (bd0_i),
    .bd1_i             (bd1_i),
    .bd2_i             (bd2_i),
    .bd3_i             (bd3_i),
    .lp_clk_p_i        (lp_clk_p_i),
    .lp_clk_n_i        (lp_clk_n_i),
    .lp_d0_p_i         (lp_d0_p_i),
    .lp_d0_n_i         (lp_d0_n_i),
    .lp_d1_p_i         (lp_d1_p_i),
    .lp_d1_n_i         (lp_d1_n_i),
    .lp_d2_p_i         (lp_d2_p_i),
    .lp_d2_n_i         (lp_d2_n_i),
    .lp_d3_p_i         (lp_d3_p_i),
    .lp_d3_n_i         (lp_d3_n_i),
    .hs_sync_i         (hs_sync_i),
    .bd0_o             (bd0_o),
    .bd1_o             (bd1_o),
    .bd2_o             (bd2_o),
    .bd3_o             (bd3_o),
    .term_clk_en_o     (term_clk_en_o),
    .term_d0_en_o      (term_d0_en_o),
    .hs_d0_en_o        (hs_d0_en_o),
    .term_d1_en_o      (term_d1_en_o),
    .hs_d1_en_o        (hs_d1_en_o),
    .term_d2_en_o      (term_d2_en_o),
    .hs_d2_en_o        (hs_d2_en_o),
    .term_d3_en_o      (term_d3_en_o),
    .hs_d3_en_o        (hs_d3_en_o),
    .hs_sync_o         (hs_sync_o),
    .lp_hs_state_clk_o (lp_hs_state_clk_o),
    .lp_hs_state_d_o   (lp_hs_state_d_o)
);

endmodule
