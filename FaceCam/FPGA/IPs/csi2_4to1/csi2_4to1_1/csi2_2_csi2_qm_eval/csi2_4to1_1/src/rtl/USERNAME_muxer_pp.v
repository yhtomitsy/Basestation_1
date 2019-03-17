#include <orcapp_head>

module USERNAME_muxer
#(
//-----------------------------------------------------------------------------
// PARAMETERS
//-----------------------------------------------------------------------------

parameter           RX_DATA_WIDTH = 8 // RX_DATA_WIDTH = RX_GEAR*LANE_COUNT;
  
)


(
input                          mux_sel,		    
			                            
input                          lp_en_chA,	    
input                          sp_en_chA,	    
//input                          rx_byte_clk_fr_chA,
input                          d2c_payload_en_chA,  
input [RX_DATA_WIDTH-1:0]      d2c_data_chA,	    
input [15:0]                   wc_chA,		    
input [1:0]                    vc_chA,		    
input [5:0]                    dt_chA,		    
			                            
input                          lp_en_chB,	    
input                          sp_en_chB,	    
//input                          rx_byte_clk_fr_chB,
input                          d2c_payload_en_chB,  
input [RX_DATA_WIDTH-1:0]      d2c_data_chB,	    
input [15:0]                   wc_chB,		    
input [1:0]                    vc_chB,		    
input [5:0]                    dt_chB,		    
			                            
			                            
// muxed output between RXch0 & ch2		    
output reg                     lp_en_mux,	    
output reg                     sp_en_mux,	    
//output reg                   rx_byte_clk_fr_mux,
output reg                     d2c_payload_en_mux,  
output reg [RX_DATA_WIDTH-1:0] d2c_data_mux,	    
output reg [15:0]              wc_mux,		    
output reg [1:0]               vc_mux,		    
output reg [5:0]               dt_mux                   

);

// added sp_en. vc and dt mux for channels 1 & 3. 
// for VC muxing

// if mux_sel = 1, this selects ch2 and ch3
// if mux_sel = 0, this selects ch0 and ch1   

// even channel muxing
always @* begin
 lp_en_mux          = mux_sel ? lp_en_chB          : lp_en_chA;
 sp_en_mux          = mux_sel ? sp_en_chB          : sp_en_chA;
// rx_byte_clk_fr_mux = mux_sel ? rx_byte_clk_fr_chB : rx_byte_clk_fr_chA;
 d2c_payload_en_mux = mux_sel ? d2c_payload_en_chB : d2c_payload_en_chA;
 d2c_data_mux       = mux_sel ? d2c_data_chB       : d2c_data_chA;
 wc_mux             = mux_sel ? wc_chB             : wc_chA;
 vc_mux             = mux_sel ? vc_chB             : vc_chA;
 dt_mux             = mux_sel ? dt_chB             : dt_chA;
end


endmodule
