#include <orcapp_head>

module USERNAME_tinit_count (
  input wire    clk	,
  input wire    resetn	,
  output wire   tinit_done_o
);

tinit_count #(
  .TINIT_VALUE  (PP_TINIT_VALUE)
)
tinit_count_inst(
  .clk          (clk),
  .resetn       (resetn),
  .tinit_done_o (tinit_done_o)
);

endmodule

