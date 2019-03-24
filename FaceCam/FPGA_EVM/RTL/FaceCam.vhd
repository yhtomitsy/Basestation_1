library ieee;
use ieee.std_logic_1164.all;

entity FaceCam is
    generic (
        VERSION         : std_logic_vector(15 downto 0) := x"0000");
    port (
        clk_ch0_n   : inout std_logic;
        clk_ch0_p   : inout std_logic;
        clk_ch1_n   : inout std_logic;
        clk_ch1_p   : inout std_logic;
        clk_ch2_n   : inout std_logic;
        clk_ch2_p   : inout std_logic;
        clk_ch3_n   : inout std_logic;
        clk_ch3_p   : inout std_logic;
        clk_n       : out   std_logic;
        clk_p       : out   std_logic;
        d0_ch0_n    : inout std_logic;
        d0_ch0_p    : inout std_logic;
        d0_ch1_n    : inout std_logic;
        d0_ch1_p    : inout std_logic;
        d0_ch2_n    : inout std_logic;
        d0_ch2_p    : inout std_logic;
        d0_ch3_n    : inout std_logic;
        d0_ch3_p    : inout std_logic;
        d0_n        : out   std_logic;
        d0_p        : out   std_logic;
        d1_ch0_n    : inout std_logic;
        d1_ch0_p    : inout std_logic;
        d1_ch1_n    : inout std_logic;
        d1_ch1_p    : inout std_logic;
        d1_ch2_n    : inout std_logic;
        d1_ch2_p    : inout std_logic;
        d1_ch3_n    : inout std_logic;
        d1_ch3_p    : inout std_logic;
        d1_n        : out   std_logic;
        d1_p        : out   std_logic;
        mux_sel_i   : in    std_logic;
        reset_n_i   : in    std_logic);
end FaceCam;

architecture RTL of FaceCam is

    component csi2_4to1 is
    port (
        csi2_4to1_1_clk_ch0_n_i : inout std_logic;
        csi2_4to1_1_clk_ch0_p_i : inout std_logic;
        csi2_4to1_1_clk_ch1_n_i : inout std_logic;
        csi2_4to1_1_clk_ch1_p_i : inout std_logic;
        csi2_4to1_1_clk_ch2_n_i : inout std_logic;
        csi2_4to1_1_clk_ch2_p_i : inout std_logic;
        csi2_4to1_1_clk_ch3_n_i : inout std_logic;
        csi2_4to1_1_clk_ch3_p_i : inout std_logic;
        csi2_4to1_1_clk_n_o     : out   std_logic;
        csi2_4to1_1_clk_p_o     : out   std_logic;
        csi2_4to1_1_d0_ch0_n_i  : inout std_logic;
        csi2_4to1_1_d0_ch0_p_i  : inout std_logic;
        csi2_4to1_1_d0_ch1_n_i  : inout std_logic;
        csi2_4to1_1_d0_ch1_p_i  : inout std_logic;
        csi2_4to1_1_d0_ch2_n_i  : inout std_logic;
        csi2_4to1_1_d0_ch2_p_i  : inout std_logic;
        csi2_4to1_1_d0_ch3_n_i  : inout std_logic;
        csi2_4to1_1_d0_ch3_p_i  : inout std_logic;
        csi2_4to1_1_d0_n_o      : out   std_logic;
        csi2_4to1_1_d0_p_o      : out   std_logic;
        csi2_4to1_1_d1_ch0_n_i  : inout std_logic;
        csi2_4to1_1_d1_ch0_p_i  : inout std_logic;
        csi2_4to1_1_d1_ch1_n_i  : inout std_logic;
        csi2_4to1_1_d1_ch1_p_i  : inout std_logic;
        csi2_4to1_1_d1_ch2_n_i  : inout std_logic;
        csi2_4to1_1_d1_ch2_p_i  : inout std_logic;
        csi2_4to1_1_d1_ch3_n_i  : inout std_logic;
        csi2_4to1_1_d1_ch3_p_i  : inout std_logic;
        csi2_4to1_1_d1_n_o      : out   std_logic;
        csi2_4to1_1_d1_p_o      : out   std_logic;
        csi2_4to1_1_mux_sel_i   : in    std_logic;
        csi2_4to1_1_reset_n_i   : in    std_logic);
    end component csi2_4to1;

    ATTRIBUTE IO_TYPE:string;
    ATTRIBUTE LOC:string;

    ATTRIBUTE IO_TYPE of reset_n_i: signal is "LVCMOS25";
    ATTRIBUTE IO_TYPE of mux_sel_i: signal is "LVCMOS25";

    ATTRIBUTE LOC of mux_sel_i: signal is "J2";
    ATTRIBUTE LOC of reset_n_i: signal is "F2";

begin

    csi2_4to1_inst : csi2_4to1
    port map (
        csi2_4to1_1_clk_ch0_n_i => clk_ch0_n,
        csi2_4to1_1_clk_ch0_p_i => clk_ch0_p,
        csi2_4to1_1_clk_ch1_n_i => clk_ch1_n,
        csi2_4to1_1_clk_ch1_p_i => clk_ch1_p,
        csi2_4to1_1_clk_ch2_n_i => clk_ch2_n,
        csi2_4to1_1_clk_ch2_p_i => clk_ch2_p,
        csi2_4to1_1_clk_ch3_n_i => clk_ch3_n,
        csi2_4to1_1_clk_ch3_p_i => clk_ch3_p,
        csi2_4to1_1_clk_n_o     => clk_n,
        csi2_4to1_1_clk_p_o     => clk_p,
        csi2_4to1_1_d0_ch0_n_i  => d0_ch0_n,
        csi2_4to1_1_d0_ch0_p_i  => d0_ch0_p,
        csi2_4to1_1_d0_ch1_n_i  => d0_ch1_n,
        csi2_4to1_1_d0_ch1_p_i  => d0_ch1_p,
        csi2_4to1_1_d0_ch2_n_i  => d0_ch2_n,
        csi2_4to1_1_d0_ch2_p_i  => d0_ch2_p,
        csi2_4to1_1_d0_ch3_n_i  => d0_ch3_n,
        csi2_4to1_1_d0_ch3_p_i  => d0_ch3_p,
        csi2_4to1_1_d0_n_o      => d0_n,
        csi2_4to1_1_d0_p_o      => d0_p,
        csi2_4to1_1_d1_ch0_n_i  => d1_ch0_n,
        csi2_4to1_1_d1_ch0_p_i  => d1_ch0_p,
        csi2_4to1_1_d1_ch1_n_i  => d1_ch1_n,
        csi2_4to1_1_d1_ch1_p_i  => d1_ch1_p,
        csi2_4to1_1_d1_ch2_n_i  => d1_ch2_n,
        csi2_4to1_1_d1_ch2_p_i  => d1_ch2_p,
        csi2_4to1_1_d1_ch3_n_i  => d1_ch3_n,
        csi2_4to1_1_d1_ch3_p_i  => d1_ch3_p,
        csi2_4to1_1_d1_n_o      => d1_n,
        csi2_4to1_1_d1_p_o      => d1_p,
        csi2_4to1_1_mux_sel_i   => mux_sel_i,
        csi2_4to1_1_reset_n_i   => reset_n_i
    );

end RTL;
