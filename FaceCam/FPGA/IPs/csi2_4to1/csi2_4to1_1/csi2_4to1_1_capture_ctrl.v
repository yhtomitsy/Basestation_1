//==================================================================================
// Verilog module generated by Clarity Designer    03/23/2019    09:13:24       
// Filename: csi2_4to1_1_capture_ctrl.v                                                         
// Filename: 4:1 CSI-2 to CSI-2 1.1                                    
// Copyright(c) 2016 Lattice Semiconductor Corporation. All rights reserved.        
//==================================================================================

module csi2_4to1_1_capture_ctrl
(
    input  wire	                          reset_n_i,
    input  wire	                          clk_byte_i,
    input  wire [8-1:0]             bd0_i,
    input  wire [8-1:0]             bd1_i,
    input  wire [8-1:0]             bd2_i,
    input  wire [8-1:0]             bd3_i,
    input  wire                           capture_en_i, // HS Sync from Rx Global Controller

    output wire                           sp_en_o,      // Short Packet Enable
    output wire                           sp2_en_o,     // Short Packet Enable #2 (only for 4lane Gear16)
    output wire                           lp_en_o,      // Long Packet Enable
    output wire                           lp2_en_o,	// Long Packet Enable #2 (only for 4lane Gear16)
    output wire                           lp_av_en_o,   // Long Packet Enable for Active Video
    output wire                           lp2_av_en_o,	// Long Packet Enable #2 for Active Video (only for 4lane Gear16)
    output wire [1*8-1:0]       bd_o,         // DPHY byte data (Gear8 only)
    output wire [1:0]                     vc_o,         // Virtual Channel
    output wire [1:0]                     vc2_o,        // Virtual Channel #2 (only for 4lane Gear16)
    output wire                           payload_en_o,	// Payload data Enable
    output wire [1*8-1:0] payload_o,    // Payload data
    output wire [15:0]                    wc_o,         // payload byte count
    output wire [15:0]                    wc2_o,        // payload byte count #2 (only for 4lane Gear16)
    output wire [5:0]                     dt_o,         // Data Type
    output wire [5:0]                     dt2_o,        // Data Type #2 (only for 4lane Gear16)
    output wire [7:0]                     ecc_o,        // ECC
    output wire [7:0]                     ecc2_o        // ECC #2 (only for 4lane Gear16)
);

capture_ctrl 
#(
    .NUM_RX_LANE    (1),
    .RX_GEAR        (8),
    .RX_TYPE        ("CSI2"),
    .TX_TYPE        ("CSI2"),
    .DT             ("RAW10"),
    .TX_WAIT_TIME   ("LESS_15MS")
)
capture_ctrl (
    .reset_n_i      (reset_n_i),
    .clk_byte_i     (clk_byte_i),
    .bd0_i          (bd0_i),
    .bd1_i          (bd1_i),
    .bd2_i          (bd2_i),
    .bd3_i          (bd3_i),
    .capture_en_i   (capture_en_i),
    .sp_en_o        (sp_en_o),
    .sp2_en_o       (sp2_en_o),
    .lp_en_o        (lp_en_o),
    .lp_av_en_o     (lp_av_en_o),
    .lp2_en_o       (lp2_en_o),
    .lp2_av_en_o    (lp2_av_en_o),
    .payload_en_o   (payload_en_o),
    .payload_o      (payload_o),
    .bd_o           (bd_o),
    .vc_o           (vc_o),
    .vc2_o          (vc2_o),
    .wc_o           (wc_o),
    .wc2_o          (wc2_o),
    .dt_o           (dt_o),
    .dt2_o          (dt2_o),
    .ecc_o          (ecc_o),
    .ecc2_o         (ecc2_o)
);

endmodule
