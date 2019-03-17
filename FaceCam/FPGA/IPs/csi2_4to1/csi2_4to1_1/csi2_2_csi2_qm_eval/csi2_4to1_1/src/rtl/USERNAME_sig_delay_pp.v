#include <orcapp_head>

module USERNAME_sig_delay (
  input wire   clk,
  input wire   rstn,
  input wire   in, 
  output wire  out
);

sig_delay sig_delay_inst(
  .clk      (clk),
  .rstn     (rstn),
  .in       (in),
  .out      (out)
);

endmodule
