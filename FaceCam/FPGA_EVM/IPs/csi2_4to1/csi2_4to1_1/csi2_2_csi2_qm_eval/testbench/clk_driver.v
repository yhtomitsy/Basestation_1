module clk_driver();
  reg clk_p_i, clk_n_i;

initial begin
  clk_p_i = 1;
  clk_n_i = 1;
end


task drv_clk_st(input dp, input dn);
begin
   clk_p_i = dp;
   clk_n_i = dn;
end
endtask

endmodule
