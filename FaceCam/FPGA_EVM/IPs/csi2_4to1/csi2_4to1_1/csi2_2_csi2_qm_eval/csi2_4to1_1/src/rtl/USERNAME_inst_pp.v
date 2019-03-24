#include <orcapp_head>

USERNAME USERNAME_inst
	(
	.reset_n_i                      (reset_n_i),
#ifdef PP_RX_CLK_MODE_HS_LP
        .refclk_i                       (refclk_i),
#endif 

        .clk_ch0_p_i                    (clk_ch0_p_i),
        .clk_ch0_n_i                    (clk_ch0_n_i),
        .clk_ch1_p_i                    (clk_ch1_p_i),
        .clk_ch1_n_i                    (clk_ch1_n_i),

	.d0_ch0_p_i                     (d0_ch0_p_i),
        .d0_ch0_n_i                     (d0_ch0_n_i),
        .d0_ch1_p_i                     (d0_ch1_p_i),
        .d0_ch1_n_i                     (d0_ch1_n_i),

        .d0_p_o                         (d0_p_o),
        .d0_n_o                         (d0_n_o),
#ifdef PP_NO_OF_LANE_2 
        .d1_ch0_p_i                     (d1_ch0_p_i),
        .d1_ch0_n_i                     (d1_ch0_n_i),
        .d1_ch1_p_i                     (d1_ch1_p_i),
        .d1_ch1_n_i                     (d1_ch1_n_i),

        .d1_p_o                         (d1_p_o),
        .d1_n_o                         (d1_n_o),
#endif

#ifdef PP_NO_OF_LANE_4 
        .d1_ch0_p_i                     (d1_ch0_p_i),
        .d1_ch0_n_i                     (d1_ch0_n_i),
        .d1_ch1_p_i                     (d1_ch1_p_i),
        .d1_ch1_n_i                     (d1_ch1_n_i),	 
        .d2_ch0_p_i                     (d2_ch0_p_i),
        .d2_ch0_n_i                     (d2_ch0_n_i),
        .d2_ch1_p_i                     (d2_ch1_p_i),
        .d2_ch1_n_i                     (d2_ch1_n_i),
        .d3_ch0_p_i                     (d3_ch0_p_i),
        .d3_ch0_n_i                     (d3_ch0_n_i),
        .d3_ch1_p_i                     (d3_ch1_p_i),
        .d3_ch1_n_i                     (d3_ch1_n_i),
        .d1_p_o                         (d1_p_o),
        .d1_n_o                         (d1_n_o),
        .d2_p_o                         (d2_p_o),
        .d2_n_o                         (d2_n_o),
        .d3_p_o                         (d3_p_o),
        .d3_n_o                         (d3_n_o),

#endif


 #ifdef PP_MISC_TXPLLLOCK 	 
	.tx_pll_lock_o                  (tx_pll_lock_o),
 #endif
 #ifdef PP_MISC_TINITDONE
	.tinit_done_o                   (tinit_done_o),
 #endif
 #ifdef PP_MISC_RX0_SPEN
	.rx0_sp_en_o                    (rx0_sp_en_o),
 #endif
 #ifdef PP_MISC_RX0_LPEN
        .rx0_lp_en_o                    (rx0_lp_en_o),
 #endif
 #ifdef PP_MISC_RX0_HSSYNC
        .rx0_hs_sync_o                  (rx0_hs_sync_o),
 #endif
 #ifdef PP_MISC_RX1_SPEN
        .rx1_sp_en_o                    (rx1_sp_en_o),
 #endif
 #ifdef PP_MISC_RX1_LPEN
	.rx1_lp_en_o                    (rx1_lp_en_o),
 #endif
 #ifdef PP_MISC_RX1_HSSYNC
    	.rx1_hs_sync_o                  (rx1_hs_sync_o),
 #endif
 #ifdef PP_MISC_TX_FVEN
        .tx_fv_en_o                     (tx_fv_en_o),
 #endif
 #ifdef PP_MISC_TX_LVEN
        .tx_lv_en_o                     (tx_lv_en_o),
 #endif
 #ifdef PP_MISC_BYTEDATVLD
        .tx_byte_data_vld               (tx_byte_data_vld),
 #endif

	.clk_n_o                        (clk_n_o),
	.clk_p_o                        (clk_p_o)

);

