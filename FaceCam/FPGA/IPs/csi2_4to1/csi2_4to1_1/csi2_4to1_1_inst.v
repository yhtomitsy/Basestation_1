//==================================================================================
// Verilog module generated by Clarity Designer    03/23/2019    09:13:23       
// Filename: csi2_4to1_1_inst.v                                                         
// Filename: 4:1 CSI-2 to CSI-2 1.1                                    
// Copyright(c) 2016 Lattice Semiconductor Corporation. All rights reserved.        
//==================================================================================

csi2_4to1_1 csi2_4to1_1_inst
	(
	.reset_n_i                      (reset_n_i),

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




	.clk_n_o                        (clk_n_o),
	.clk_p_o                        (clk_p_o)

);

