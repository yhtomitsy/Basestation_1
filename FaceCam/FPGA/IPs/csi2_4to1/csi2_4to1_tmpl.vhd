--VHDL instantiation template

component csi2_4to1 is
    port (csi2_4to1_1_clk_ch0_n_i: inout std_logic;
        csi2_4to1_1_clk_ch0_p_i: inout std_logic;
        csi2_4to1_1_clk_ch1_n_i: inout std_logic;
        csi2_4to1_1_clk_ch1_p_i: inout std_logic;
        csi2_4to1_1_clk_ch2_n_i: inout std_logic;
        csi2_4to1_1_clk_ch2_p_i: inout std_logic;
        csi2_4to1_1_clk_ch3_n_i: inout std_logic;
        csi2_4to1_1_clk_ch3_p_i: inout std_logic;
        csi2_4to1_1_clk_n_o: out std_logic;
        csi2_4to1_1_clk_p_o: out std_logic;
        csi2_4to1_1_d0_ch0_n_i: inout std_logic;
        csi2_4to1_1_d0_ch0_p_i: inout std_logic;
        csi2_4to1_1_d0_ch1_n_i: inout std_logic;
        csi2_4to1_1_d0_ch1_p_i: inout std_logic;
        csi2_4to1_1_d0_ch2_n_i: inout std_logic;
        csi2_4to1_1_d0_ch2_p_i: inout std_logic;
        csi2_4to1_1_d0_ch3_n_i: inout std_logic;
        csi2_4to1_1_d0_ch3_p_i: inout std_logic;
        csi2_4to1_1_d0_n_o: out std_logic;
        csi2_4to1_1_d0_p_o: out std_logic;
        csi2_4to1_1_mux_sel_i: in std_logic;
        csi2_4to1_1_reset_n_i: in std_logic
    );
    
end component csi2_4to1; -- sbp_module=true 
_inst: csi2_4to1 port map (csi2_4to1_1_clk_ch0_n_i => __,csi2_4to1_1_clk_ch0_p_i => __,
            csi2_4to1_1_clk_ch1_n_i => __,csi2_4to1_1_clk_ch1_p_i => __,csi2_4to1_1_clk_ch2_n_i => __,
            csi2_4to1_1_clk_ch2_p_i => __,csi2_4to1_1_clk_ch3_n_i => __,csi2_4to1_1_clk_ch3_p_i => __,
            csi2_4to1_1_clk_n_o => __,csi2_4to1_1_clk_p_o => __,csi2_4to1_1_d0_ch0_n_i => __,
            csi2_4to1_1_d0_ch0_p_i => __,csi2_4to1_1_d0_ch1_n_i => __,csi2_4to1_1_d0_ch1_p_i => __,
            csi2_4to1_1_d0_ch2_n_i => __,csi2_4to1_1_d0_ch2_p_i => __,csi2_4to1_1_d0_ch3_n_i => __,
            csi2_4to1_1_d0_ch3_p_i => __,csi2_4to1_1_d0_n_o => __,csi2_4to1_1_d0_p_o => __,
            csi2_4to1_1_mux_sel_i => __,csi2_4to1_1_reset_n_i => __);
