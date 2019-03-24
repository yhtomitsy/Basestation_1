#include <orcapp_head>

module USERNAME_synchronizer (
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
