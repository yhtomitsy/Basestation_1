#include <orcapp_head>

module USERNAME_capture_ctrl
(
    input  wire	                          reset_n_i,
    input  wire	                          clk_byte_i,
    input  wire [PP_RX_GEAR-1:0]             bd0_i,
    input  wire [PP_RX_GEAR-1:0]             bd1_i,
    input  wire [PP_RX_GEAR-1:0]             bd2_i,
    input  wire [PP_RX_GEAR-1:0]             bd3_i,
    input  wire                           capture_en_i, // HS Sync from Rx Global Controller

    output wire                           sp_en_o,      // Short Packet Enable
    output wire                           sp2_en_o,     // Short Packet Enable #2 (only for 4lane Gear16)
    output wire                           lp_en_o,      // Long Packet Enable
    output wire                           lp2_en_o,	// Long Packet Enable #2 (only for 4lane Gear16)
    output wire                           lp_av_en_o,   // Long Packet Enable for Active Video
    output wire                           lp2_av_en_o,	// Long Packet Enable #2 for Active Video (only for 4lane Gear16)
    output wire [PP_NUM_RX_LANE*8-1:0]       bd_o,         // DPHY byte data (Gear8 only)
    output wire [1:0]                     vc_o,         // Virtual Channel
    output wire [1:0]                     vc2_o,        // Virtual Channel #2 (only for 4lane Gear16)
    output wire                           payload_en_o,	// Payload data Enable
    output wire [PP_NUM_RX_LANE*PP_RX_GEAR-1:0] payload_o,    // Payload data
    output wire [15:0]                    wc_o,         // payload byte count
    output wire [15:0]                    wc2_o,        // payload byte count #2 (only for 4lane Gear16)
    output wire [5:0]                     dt_o,         // Data Type
    output wire [5:0]                     dt2_o,        // Data Type #2 (only for 4lane Gear16)
    output wire [7:0]                     ecc_o,        // ECC
    output wire [7:0]                     ecc2_o        // ECC #2 (only for 4lane Gear16)
);

capture_ctrl 
#(
    .NUM_RX_LANE    (PP_NUM_RX_LANE),
    .RX_GEAR        (PP_RX_GEAR),
    .RX_TYPE        (PP_RX_TYPE),
    .TX_TYPE        (PP_TX_TYPE),
    .DT             (PP_DT),
    .TX_WAIT_TIME   (PP_TX_WAIT_TIME)
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
