#include <orcapp_head>

module USERNAME_dphy_rx_wrap (
    input wire                reset_n_i,
    input wire                reset_byte_n_i,
    input wire                reset_byte_fr_n_i,
    input wire                clk_byte_fr_i,
    inout wire                clk_p_i,
    inout wire                clk_n_i,
#ifdef PP_NUM_RX_LANE_4
    inout wire                d0_p_io,	
    inout wire                d0_n_io,	
    inout wire                d1_p_i,	
    inout wire                d1_n_i,	
    inout wire                d2_p_i,	
    inout wire                d2_n_i,	
    inout wire                d3_p_i,	
    inout wire                d3_n_i,
#endif
#ifdef PP_NUM_RX_LANE_2
    inout wire                d0_p_io,	
    inout wire                d0_n_io,	
    inout wire                d1_p_i,	
    inout wire                d1_n_i,	
#endif
#ifdef PP_NUM_RX_LANE_1
    inout wire                d0_p_io,	
    inout wire                d0_n_io,
#endif	
    input wire                term_clk_en_i,
    input wire                term_d0_en_i,
    input wire                term_d1_en_i,
    input wire                term_d2_en_i,
    input wire                term_d3_en_i,
    input wire                hs_d0_en_i,
    input wire                hs_d1_en_i,
    input wire                hs_d2_en_i,
    input wire                hs_d3_en_i,
    input wire                lp_d0_tx_en_i,
    input wire                lp_d0_tx_p_i,
    input wire                lp_d0_tx_n_i,

    output wire               clk_hs_o,
    output wire               clk_byte_o,
    output wire [PP_RX_GEAR-1:0] bd0_o,
    output wire [PP_RX_GEAR-1:0] bd1_o,
    output wire [PP_RX_GEAR-1:0] bd2_o,
    output wire [PP_RX_GEAR-1:0] bd3_o,
    output wire               hs_sync_o,       // aligned to B8(Gear8) or B800(Gear16)

    output wire               lp_clk_rx_p_o,
    output wire               lp_clk_rx_n_o,
    output wire               lp_d0_rx_p_o,
    output wire               lp_d0_rx_n_o,
    output wire               lp_d1_rx_p_o,
    output wire               lp_d1_rx_n_o,
    output wire               lp_d2_rx_p_o,
    output wire               lp_d2_rx_n_o,
    output wire               lp_d3_rx_p_o,
    output wire               lp_d3_rx_n_o,
    output wire               cd_clk_o,
    output wire               cd_d0_o
) /*synthesis syn_black_box black_box_pad_pin="clk_p_i,clk_n_i,d0_p_io,d0_n_io,d1_p_i,d1_n_i,d2_p_i,d2_n_i,d3_p_i,d3_n_i" */ ;

// synthesis directives are added as workaround for synthesis issue of inout parts having both active and tristate drivers
// see SOF-126609

endmodule
