/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module csi2_4to1
//
module csi2_4to1 (csi2_4to1_1_clk_ch0_n_i, csi2_4to1_1_clk_ch0_p_i, csi2_4to1_1_clk_ch1_n_i, 
            csi2_4to1_1_clk_ch1_p_i, csi2_4to1_1_clk_ch2_n_i, csi2_4to1_1_clk_ch2_p_i, 
            csi2_4to1_1_clk_ch3_n_i, csi2_4to1_1_clk_ch3_p_i, csi2_4to1_1_clk_n_o, 
            csi2_4to1_1_clk_p_o, csi2_4to1_1_d0_ch0_n_i, csi2_4to1_1_d0_ch0_p_i, 
            csi2_4to1_1_d0_ch1_n_i, csi2_4to1_1_d0_ch1_p_i, csi2_4to1_1_d0_ch2_n_i, 
            csi2_4to1_1_d0_ch2_p_i, csi2_4to1_1_d0_ch3_n_i, csi2_4to1_1_d0_ch3_p_i, 
            csi2_4to1_1_d0_n_o, csi2_4to1_1_d0_p_o, csi2_4to1_1_d1_ch0_n_i, 
            csi2_4to1_1_d1_ch0_p_i, csi2_4to1_1_d1_ch1_n_i, csi2_4to1_1_d1_ch1_p_i, 
            csi2_4to1_1_d1_ch2_n_i, csi2_4to1_1_d1_ch2_p_i, csi2_4to1_1_d1_ch3_n_i, 
            csi2_4to1_1_d1_ch3_p_i, csi2_4to1_1_d1_n_o, csi2_4to1_1_d1_p_o, 
            csi2_4to1_1_mux_sel_i, csi2_4to1_1_reset_n_i) /* synthesis sbp_module=true */ ;
    inout csi2_4to1_1_clk_ch0_n_i;
    inout csi2_4to1_1_clk_ch0_p_i;
    inout csi2_4to1_1_clk_ch1_n_i;
    inout csi2_4to1_1_clk_ch1_p_i;
    inout csi2_4to1_1_clk_ch2_n_i;
    inout csi2_4to1_1_clk_ch2_p_i;
    inout csi2_4to1_1_clk_ch3_n_i;
    inout csi2_4to1_1_clk_ch3_p_i;
    output csi2_4to1_1_clk_n_o;
    output csi2_4to1_1_clk_p_o;
    inout csi2_4to1_1_d0_ch0_n_i;
    inout csi2_4to1_1_d0_ch0_p_i;
    inout csi2_4to1_1_d0_ch1_n_i;
    inout csi2_4to1_1_d0_ch1_p_i;
    inout csi2_4to1_1_d0_ch2_n_i;
    inout csi2_4to1_1_d0_ch2_p_i;
    inout csi2_4to1_1_d0_ch3_n_i;
    inout csi2_4to1_1_d0_ch3_p_i;
    output csi2_4to1_1_d0_n_o;
    output csi2_4to1_1_d0_p_o;
    inout csi2_4to1_1_d1_ch0_n_i;
    inout csi2_4to1_1_d1_ch0_p_i;
    inout csi2_4to1_1_d1_ch1_n_i;
    inout csi2_4to1_1_d1_ch1_p_i;
    inout csi2_4to1_1_d1_ch2_n_i;
    inout csi2_4to1_1_d1_ch2_p_i;
    inout csi2_4to1_1_d1_ch3_n_i;
    inout csi2_4to1_1_d1_ch3_p_i;
    output csi2_4to1_1_d1_n_o;
    output csi2_4to1_1_d1_p_o;
    input csi2_4to1_1_mux_sel_i;
    input csi2_4to1_1_reset_n_i;
    
    
    csi2_4to1_1 csi2_4to1_1_inst (.clk_ch0_n_i(csi2_4to1_1_clk_ch0_n_i), .clk_ch0_p_i(csi2_4to1_1_clk_ch0_p_i), 
            .clk_ch1_n_i(csi2_4to1_1_clk_ch1_n_i), .clk_ch1_p_i(csi2_4to1_1_clk_ch1_p_i), 
            .clk_ch2_n_i(csi2_4to1_1_clk_ch2_n_i), .clk_ch2_p_i(csi2_4to1_1_clk_ch2_p_i), 
            .clk_ch3_n_i(csi2_4to1_1_clk_ch3_n_i), .clk_ch3_p_i(csi2_4to1_1_clk_ch3_p_i), 
            .clk_n_o(csi2_4to1_1_clk_n_o), .clk_p_o(csi2_4to1_1_clk_p_o), 
            .d0_ch0_n_i(csi2_4to1_1_d0_ch0_n_i), .d0_ch0_p_i(csi2_4to1_1_d0_ch0_p_i), 
            .d0_ch1_n_i(csi2_4to1_1_d0_ch1_n_i), .d0_ch1_p_i(csi2_4to1_1_d0_ch1_p_i), 
            .d0_ch2_n_i(csi2_4to1_1_d0_ch2_n_i), .d0_ch2_p_i(csi2_4to1_1_d0_ch2_p_i), 
            .d0_ch3_n_i(csi2_4to1_1_d0_ch3_n_i), .d0_ch3_p_i(csi2_4to1_1_d0_ch3_p_i), 
            .d0_n_o(csi2_4to1_1_d0_n_o), .d0_p_o(csi2_4to1_1_d0_p_o), .d1_ch0_n_i(csi2_4to1_1_d1_ch0_n_i), 
            .d1_ch0_p_i(csi2_4to1_1_d1_ch0_p_i), .d1_ch1_n_i(csi2_4to1_1_d1_ch1_n_i), 
            .d1_ch1_p_i(csi2_4to1_1_d1_ch1_p_i), .d1_ch2_n_i(csi2_4to1_1_d1_ch2_n_i), 
            .d1_ch2_p_i(csi2_4to1_1_d1_ch2_p_i), .d1_ch3_n_i(csi2_4to1_1_d1_ch3_n_i), 
            .d1_ch3_p_i(csi2_4to1_1_d1_ch3_p_i), .d1_n_o(csi2_4to1_1_d1_n_o), 
            .d1_p_o(csi2_4to1_1_d1_p_o), .mux_sel_i(csi2_4to1_1_mux_sel_i), 
            .reset_n_i(csi2_4to1_1_reset_n_i));
    
endmodule

