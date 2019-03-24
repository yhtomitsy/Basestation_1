//==================================================================================
// Verilog module generated by Clarity Designer    03/23/2019    09:13:23       
// Filename: csi2_4to1_1_synchronizer.v                                                         
// Filename: 4:1 CSI-2 to CSI-2 1.1                                    
// Copyright(c) 2016 Lattice Semiconductor Corporation. All rights reserved.        
//==================================================================================

module csi2_4to1_1_synchronizer (
    input		clk,
    input		rstn,
    input		in,

    output		out
);

reg [1:0]	sync_ff_r;
always @(posedge clk or negedge rstn)
   if (!rstn) begin
      sync_ff_r 	<= 0;
   end
   else begin
      sync_ff_r[0] 	<= in;
      sync_ff_r[1] 	<= sync_ff_r[0];
   end

assign out = sync_ff_r[1];

endmodule
