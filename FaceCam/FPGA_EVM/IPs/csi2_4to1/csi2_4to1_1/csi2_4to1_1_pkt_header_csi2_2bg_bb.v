//==================================================================================
// Verilog module generated by Clarity Designer    03/17/2019    11:26:36       
// Filename: csi2_4to1_1_pkt_header_csi2_2bg_bb.v                                                         
// Filename: 4:1 CSI-2 to CSI-2 1.1                                    
// Copyright(c) 2016 Lattice Semiconductor Corporation. All rights reserved.        
//==================================================================================

module csi2_4to1_1_pkt_header_csi2_2bg (
  // clock and reset
  input wire                        core_rstn,
  input wire                        core_clk_i, 
  // packet settings
  input wire [1:0]                  vc_i,
  input wire [5:0]                  dt_i,
  input wire [15:0]                 wc_i,
  input wire                        gear16_i,
  // control/data from pixel2byte
  input wire                        sp_req_i,
  input wire                        lp_req_i,
  // from pkt_header
  input	wire                        d_hs_rdy_i,

  input wire [4*16-1:0]  byte_data_i,
  input wire                        byte_data_en_i,

   // to hdr_buffers
  output wire                       ld_pyld_o,

  output wire                       pix2byte_rstn_o,
  output wire                       phdr_xfr_done,
  output wire [4*16-1:0] dphy_pkt_o,
  output wire                       dphy_pkten_o
);

endmodule
