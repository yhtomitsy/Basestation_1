module bus_driver#(
   parameter ch = 0
  )
  (
   input clk_p_i
   );
//  input clk_p_i;
  reg do_p_i, do_n_i;

integer i;

initial begin
  i = 0;
  do_p_i = 1;
  do_n_i = 1;
end

task drive_datax(input [7:0] data);
begin
   $display("%0t Data[%0d] : Driving with data = %0x", $time, ch, data);
   for (i = 0; i < 8; i = i + 1) begin
      @(clk_p_i);
      do_p_i = data[i];
      do_n_i = ~data[i];
   end
end
endtask

task drv_dat_st(input dp, input dn);
begin
   do_p_i = dp;
   do_n_i = dn;
end
endtask

task drv_trail;
begin
   $display("%0t Data[%0d] : Driving trail bytes", $time, ch);
   @(clk_p_i);
   do_p_i = ~do_p_i;
   do_n_i = ~do_n_i;
end
endtask

task drv_stop;
begin
   $display("%0t Data[%0d] : Driving stop", $time, ch);
   @(clk_p_i);
   do_p_i = 1;
   do_n_i = 1;
end
endtask

endmodule
