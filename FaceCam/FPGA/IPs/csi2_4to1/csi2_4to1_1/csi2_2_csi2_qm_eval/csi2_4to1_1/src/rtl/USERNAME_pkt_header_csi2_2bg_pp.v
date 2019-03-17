#include <orcapp_head>

module USERNAME_pkt_header_csi2_2bg (
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

  input wire [4*PP_DATA_WIDTH-1:0]  byte_data_i,
  input wire                        byte_data_en_i,

   // to hdr_buffers
  output wire                       ld_pyld_o,

  output wire                       pix2byte_rstn_o,
  output wire                       phdr_xfr_done,
  output wire [4*PP_DATA_WIDTH-1:0] dphy_pkt_o,
  output wire                       dphy_pkten_o
);

pkt_header_csi2_2bg #(
  .LANE_WIDTH    (PP_LANE_WIDTH),
  .DATA_WIDTH    (PP_DATA_WIDTH),
  .GEAR_16       (PP_GEAR_16),
  .CRC16         (PP_CRC16)
)
pkt_header_csi2_2bg_inst (
  .core_rstn       (core_rstn),
  .core_clk_i      (core_clk_i),
  .vc_i            (vc_i),
  .dt_i            (dt_i),
  .gear16_i        (gear16_i),
  .wc_i            (wc_i),    
  .sp_req_i        (sp_req_i),
  .lp_req_i        (lp_req_i),
  .d_hs_rdy_i      (d_hs_rdy_i),
  .byte_data_i     (byte_data_i),
  .byte_data_en_i  (byte_data_en_i),
  .ld_pyld_o       (ld_pyld_o),
  .pix2byte_rstn_o (pix2byte_rstn_o),
  .phdr_xfr_done   (phdr_xfr_done),
  .dphy_pkt_o      (dphy_pkt_o),
  .dphy_pkten_o    (dphy_pkten_o)
);

endmodule
