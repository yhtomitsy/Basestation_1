
module dphy_scoreboard #(
   parameter name = "DPHY_SCOREBOARD",
   parameter bus_width  = 4,
   parameter word_count = 200,
   parameter long_even_en = 0
)(
   input ch0_ch1_i, // 0: transmit ch0 first, 1: transmit ch1 first
   input dvalid0,
   input [(bus_width*8)-1:0] data0,
   input pkt0_end,
   input dvalid1,
   input [(bus_width*8)-1:0] data1,
   input pkt1_end,
   input dvalid_o,
   input [(bus_width*8)-1:0] data_o,
   input pkto_end,
   input test_e
);

reg [7:0] mem0 [word_count*2-1:0];
reg [7:0] mem1 [word_count*2-1:0];
integer i, j, k;
integer data0_cnt; // data needed to be checked at the output
integer data0_ctr;
integer data1_cnt; // data needed to be checked at the output
integer data1_ctr;
integer data_o_ctr;
integer t_data_e; // expected
integer t_data_o; // actual
integer err_cnt;

reg [7:0] data0_r   [bus_width-1:0];
reg [7:0] data1_r   [bus_width-1:0];
reg [7:0] data_o_r [bus_width-1:0];

reg ch0_ch1; // 0: ch0, 1: ch1
reg odd_even; // used for toggling memory
reg long_even_line;

initial begin
  data0_ctr = 0;
  data1_ctr = 0;
  data0_cnt = 0;
  data1_cnt = 0;
  data_o_ctr = 0;
  odd_even = 0; 
  long_even_line = long_even_en;
  t_data_e = 0;
  t_data_o = 0;
  err_cnt = 0;

  #100;
  ch0_ch1  = ch0_ch1_i; // assume first line from ch0

  fork
    begin
      write_d0;
    end
    begin
      write_d1;
    end
    begin
      write_o;
    end
//    begin
//      check_data;
//    end
  join

end

task write_d0;
begin
   forever begin
      @(posedge dvalid0);
      `ifdef NUM_RX_LANE_4
      data0_r[0] = data0[7:0]; 
      data0_r[1] = data0[15:8]; 
      data0_r[2] = data0[23:16]; 
      data0_r[3] = data0[31:24]; 
      `elsif NUM_RX_LANE_2
      data0_r[0] = data0[7:0];
      data0_r[1] = data0[15:8];
      `else
      data0_r[0] = data0[7:0];
      `endif

      for (i = 0; i < bus_width; i = i + 1) begin
         mem0[data0_ctr + i] = data0_r[i];
      end
      data0_ctr = data0_ctr + bus_width;
      t_data_e = t_data_e + bus_width;
   end
end
endtask

task write_d1;
begin
   forever begin
      @(posedge dvalid1);
      `ifdef NUM_RX_LANE_4
      data1_r[0] = data1[7:0];
      data1_r[1] = data1[15:8];
      data1_r[2] = data1[23:16];
      data1_r[3] = data1[31:24];
      `elsif NUM_RX_LANE_2
      data1_r[0] = data1[7:0];
      data1_r[1] = data1[15:8];
      `else
      data1_r[0] = data1[7:0];
      `endif

      for (j = 0; j < bus_width; j = j + 1) begin
         mem1[data1_ctr + j] = data1_r[j];
      end
      data1_ctr = data1_ctr + bus_width;
      t_data_e = t_data_e + bus_width;
   end
end
endtask

task write_o;
begin
   forever begin
      @(posedge dvalid_o);
      `ifdef NUM_TX_LANE_4
      data_o_r[0] = data_o[7:0];
      data_o_r[1] = data_o[15:8];
      data_o_r[2] = data_o[23:16];
      data_o_r[3] = data_o[31:24];
      `elsif NUM_TX_LANE_2
      data_o_r[0] = data_o[7:0];
      data_o_r[1] = data_o[15:8];
      `else
      data_o_r[0] = data_o[7:0];
      `endif

      if (ch0_ch1 == 0) begin
         for (k = 0; k < bus_width; k = k + 1) begin
             if (mem0[data_o_ctr + k] === data_o_r[k]) begin
                $display ("[%0t][%0s] Data Match : Actual data[%0d] = %0x; Expected data[%0d] = %0x", $realtime, name, k, data_o_r[k], k, mem0[data_o_ctr + k]);
             end else
             begin
                $display ("[%0t][%0s] UVM_ERROR Data Mismatch : Actual data[%0d] = %0x; Expected data[%0d] = %0x", $realtime, name, k, data_o_r[k], k, mem0[data_o_ctr + k]);
                err_cnt = err_cnt + 1;
             end
         end
         data_o_ctr = data_o_ctr + bus_width;
         t_data_o = t_data_o + bus_width;
      end else
      begin
         for (k = 0; k < bus_width; k = k + 1) begin
             if (mem1[data_o_ctr + k] === data_o_r[k]) begin
                $display ("[%0t][%0s] Data Match : Actual data[%0d] = %0x; Expected data[%0d] = %0x", $realtime, name, k, data_o_r[k], k, mem1[data_o_ctr + k]);
             end else
             begin
                $display ("[%0t][%0s] UVM_ERROR Data Mismatch : Actual data[%0d] = %0x; Expected data[%0d] = %0x", $realtime, name, k, data_o_r[k], k, mem1[data_o_ctr + k]);
                err_cnt = err_cnt + 1;
             end
         end
         data_o_ctr = data_o_ctr + bus_width;
         t_data_o = t_data_o + bus_width;
      end

      if (long_even_line == 1) begin
         if (odd_even == 0) begin
            if (data_o_ctr == word_count) begin
               data_o_ctr = 0;
               ch0_ch1 = ~ch0_ch1;
               if (ch0_ch1 == ch0_ch1_i) begin  
                  odd_even = ~odd_even;
               end
            end 
         end else
         if (odd_even == 1) begin
            if (data_o_ctr == word_count*2) begin
               data_o_ctr = 0;
               ch0_ch1 = ~ch0_ch1;
               if (ch0_ch1 == ch0_ch1_i) begin
                  odd_even = ~odd_even;
               end
            end
         end
      end else
      begin
         if (data_o_ctr == word_count) begin
            data_o_ctr = 0;
            ch0_ch1 = ~ch0_ch1;
         end
      end
   end
end
endtask

always @(posedge pkt0_end) begin
  data0_cnt = data0_ctr;
  data0_ctr = 0;
end
always @(posedge pkt1_end) begin
  data1_cnt = data1_ctr;
  data1_ctr = 0;
end
always @(posedge test_e) begin
  if (t_data_e != t_data_o) begin
     $display ("[%0t][%0s] UVM_ERROR Total Output Data (%0d) does not match Expected Data (%0d)", $realtime, name, t_data_o, t_data_e);
  end else
  begin
     $display ("[%0t][%0s] Total Output Data (%0d) = Expected Data (%0d)", $realtime, name, t_data_o, t_data_e);
  end 
  if (err_cnt != 0) begin
     $display ("[%0t][%0s] %0d data mismatch detected", $realtime, name, err_cnt);
  end
end
endmodule
