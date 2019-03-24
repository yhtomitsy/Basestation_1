
module dphy_monitor#(
   parameter name = "DPHY_MON",
   parameter bus_width  = 4,
   parameter data_width = 4
)(
   input clk_p_i,
   input clk_n_i,
   input [3:0] do_p_i,
   input [3:0] do_n_i,
   output reg dvalid,
   output reg [(bus_width*8-1):0] data_out,
   output reg pkt_end
);

reg [7:0] data_type;
reg [15:0] word_count;
reg [7:0] data0_r ;
reg [7:0] data1_r ;
reg [7:0] data2_r ;
reg [7:0] data3_r ;
reg sync_det;
reg start_check;
integer i, n, data_cycle, data_ctr, data_mod;
integer err_cnt;
reg active_data;
reg [7:0] data0_out;
reg [7:0] data1_out;
reg [7:0] data2_out;
reg [7:0] data3_out;
reg [7:0] ecc;
reg [7:0] exp_ecc;
reg [15:0] chksum;
reg [15:0] cur_crc;
reg [15:0] crc;
reg [15:0] exp_crc;
reg short_pkt;
reg [7:0] header0;
reg [7:0] header1;
wire [(bus_width*8-1):0] data_out_w;

initial begin
   i = 0;
   err_cnt = 0;
   data0_r = 0;
   data1_r = 0;
   data2_r = 0;
   data3_r = 0;
   data0_out = 0;
   data1_out = 0;
   data2_out = 0;
   data3_out = 0;
   sync_det = 0;
   active_data = 0;
   data_ctr = 0;
   ecc = 0;
   exp_ecc = 0;
   chksum = 16'hffff;
   cur_crc = 0;
   crc     = 0;
   exp_crc = 16'hffff;
   data_type = 0;
   word_count = 0;
   data_mod = 0;
   data_cycle = -1;
   short_pkt = 0;
   header0 = 0;
   header1 = 0;
   dvalid = 0;
   data_out = 0;
   pkt_end = 0;
   start_check = 1;

   fork
      begin
        detect_sync;
      end
      begin
        collect_data;
      end
   join
end

task detect_sync;
begin
   forever begin
      @ (clk_p_i);
      #1;
      data0_r = data0_r >> 1;
      data0_r[7:7] = do_p_i[0];
      data1_r = data1_r >> 1;
      data1_r[7:7] = do_p_i[1];
      data2_r = data2_r >> 1;
      data2_r[7:7] = do_p_i[2];
      data3_r = data3_r >> 1;
      data3_r[7:7] = do_p_i[3];
      
      if (data0_r == 8'hb8 && start_check == 1) begin
        sync_det = 1;
        active_data = 1;
      end else
      begin
        sync_det = 0;
      end
   end
end 
endtask

task collect_data;
begin
   forever begin
      if (active_data == 1) begin
          if (bus_width == 1) begin
              if (data_ctr == 0) begin // B8
                  data_ctr = data_ctr + 1;
                  repeat (8) @ (clk_p_i);
              end else
              if (data_ctr == 1) begin // DT
                 data_ctr   = data_ctr + 1;
                 data_type  = data0_r;
                 data0_out  = data0_r;
                 write_str("#####Header#####");

				 if (data_type[5:0] >= 6'h00 && data_type[5:0] <= 6'h0F) begin //short packet
                    $display ("[%0t][%0s] Short Packet detected : Data type = %0x", $realtime, name, data_type[5:0]);
                    short_pkt  = 1;
                    data_cycle = 5;
                    write_str("Short Packet");
                 end else
                 if (data_type[5:0] >= 6'h10 && data_type[5:0] <= 6'h2F) begin //long packet
                    $display ("[%0t][%0s] Long Packet detected : Data type = %0x", $realtime, name, data_type[5:0]);
                    short_pkt = 0;
                    write_str("Long Packet");
                 end

                 write_to_file(data0_out);

                 repeat (8) @ (clk_p_i);
              end else
              if (data_ctr == 2 ) begin // WC[7:0]
                 data_ctr = data_ctr + 1;
                 if (short_pkt == 0) begin // get WC for long packet
                    word_count[ 7:0] = data0_r;
                    $display ("[%0t][%0s] Word Count [7:0] = %0x", $realtime, name, word_count[7:0]);
                 end else
                 begin                       // get header 0 
                    header0 = data0_r;
                    $display ("[%0t][%0s] Header0 = %0x", $realtime, name, header0);
                 end
                 data0_out  = data0_r;
                 write_to_file(data0_out);
                 repeat (8) @ (clk_p_i);
              end else
              if (data_ctr == 3 ) begin // WC[15:8]
                 data_ctr = data_ctr + 1;
                 if (short_pkt == 0) begin // get WC for long packet
                    word_count[15:8] = data0_r;
                    $display ("[%0t][%0s] Word Count [15:8] = %0x", $realtime, name, word_count[15:8]);
                 end else
                 begin                       // get header 1
                    header1 = data0_r;
                    $display ("[%0t][%0s] Header1 = %0x", $realtime, name, header1);
                 end
                 data0_out  = data0_r;
                 write_to_file(data0_out);
                 repeat (8) @ (clk_p_i);
              end else
              if (data_ctr == 4) begin
                 data_ctr = data_ctr + 1;
                 ecc = data0_r;
                 data0_out  = data0_r;
                 write_to_file(data0_out);
                 if (short_pkt == 0) begin // update WC if long packet
                    get_data_ctr (word_count, data_cycle);
                    get_ecc({word_count, data_type}, exp_ecc);
                    write_str("#####DATA######"); // 
                 end else
                 begin // get ecc for short packet
                    get_ecc({header1, header0, data_type}, exp_ecc);
                 end
                  if (ecc != exp_ecc) begin
                    $display ("[%0t][%0s] UVM_ERROR Incorrect ECC: Actual = %0x; Expected = %0x", $realtime, name, ecc, exp_ecc);
                    err_cnt = err_cnt + 1;
                  end else
                  begin
                    $display ("[%0t][%0s]ECC = %0x", $realtime, name, ecc);
                  end

                 // resetting checksum
                 chksum = 16'hFFFF;
                  repeat (8) @ (clk_p_i);
                 // reset ecc
                 ecc     = 8'h00;
                 exp_ecc = 8'h00;
              end else
              if (data_ctr == 5 && short_pkt == 1) begin
                 active_data = 0;
              end else
              if (data_ctr == data_cycle - 2) begin // get computed crc
                  data_ctr  = data_ctr + 1;
                  exp_crc   = chksum;

                  data0_out = data0_r;

                  repeat (8) @ (clk_p_i);
              end else
              if (data_ctr == data_cycle - 1) begin // get actual crc
                  data_ctr  = data_ctr + 1;
                  crc[7:0] = data0_out;
                  write_str("#####CRC######");
                  write_to_file(data0_out);

                  data0_out = data0_r;

                  repeat (8) @ (clk_p_i);
              end else
              if (data_ctr == data_cycle) begin
                  active_data = 0;
                  pkt_end = 1;
                  crc[15:8] = data0_out;
                  write_to_file(data0_out);
                  data0_out = data0_r;

                  if (crc != exp_crc) begin
                    $display ("[%0t][%0s]UVM_ERROR Incorrect CRC: Actual = %0x; Expected = %0x", $realtime, name, crc, exp_crc);
                    err_cnt = err_cnt + 1;
                  end else
                  begin
                    $display ("[%0t][%0s]CRC = %0x", $realtime, name, crc);
                  end
              end else
              begin
                  data_ctr  = data_ctr + 1;
                  $display ("[%0t][%0s]byte data = %0x", $realtime, name, data0_r);
                  data0_out = data0_r;
                  write_to_file(data0_out);
                  compute_crc16(data0_r);

                  data_out [7:0] = data0_out;
                  dvalid = 1;

                  repeat (2) @ (clk_p_i);
                  dvalid = 0;
                  repeat (6) @ (clk_p_i);
              end
          end else 
          if (bus_width == 2) begin
              if (data_ctr == 0) begin // B8
                  data_ctr = data_ctr + 1;
                  write_str("");
                  repeat (8) @ (clk_p_i);
              end else
              if (data_ctr == 1) begin // DT
                 data_ctr   = data_ctr + 1;
                 data_type  = data0_r;
                 data0_out  = data0_r;
                 data1_out  = data1_r;
                 write_str("#####Header#####");

                 if (data_type[5:0] >= 6'h00 && data_type[5:0] <= 6'h0F) begin //short packet
                    $display ("[%0t][%0s] Short Packet detected : Data type = %0x", $realtime, name, data_type[5:0]);
                    short_pkt  = 1;
                    data_cycle = 3;
                    header0    = data1_r;
                    write_str("Short Packet");
                 end else
                 if (data_type[5:0] >= 6'h10 && data_type[5:0] <= 6'h2F) begin //long packet
                    $display ("[%0t][%0s] Long Packet detected : Data type = %0x", $realtime, name, data_type[5:0]);
                    short_pkt = 0;
                    word_count[7:0] = data1_r;
                    write_str("Long Packet");
                 end

                 write_to_file(data0_out);
                 write_to_file(data1_out);

                 repeat (8) @ (clk_p_i);
              end else
              if (data_ctr == 2) begin
                 data_ctr   = data_ctr + 1;
                 data0_out  = data0_r;
                 data1_out  = data1_r;
                 write_to_file(data0_out);
                 write_to_file(data1_out);

                 if (short_pkt == 0) begin // get WC for long packet
                    word_count[15:8] = data0_r;
                    $display ("[%0t][%0s] Word Count [15:8] = %0x", $realtime, name, word_count[15:8]);
                    get_data_ctr (word_count, data_cycle);
                    get_ecc({word_count, data_type}, exp_ecc);
                    write_str("#####DATA######"); //
                 end else
                 begin                       // get header 1
                    header1 = data0_r;
                    $display ("[%0t][%0s] Header1 = %0x", $realtime, name, header1);
                    get_ecc({header1, header0, data_type}, exp_ecc);
                 end

                 ecc        = data1_r;

                 if (ecc != exp_ecc) begin
                   $display ("[%0t][%0s] UVM_ERROR Incorrect ECC: Actual = %0x; Expected = %0x", $realtime, name, ecc, exp_ecc);
                    err_cnt = err_cnt + 1;
                 end else
                 begin
                   $display ("[%0t][%0s]ECC = %0x", $realtime, name, ecc);
                 end

                 // reset checksum
                 chksum = 16'hFFFF;
                 repeat (8) @ (clk_p_i);
                 ecc     = 8'h00;
                 exp_ecc = 8'h00;

              end else
              if (data_ctr == 3 && short_pkt == 1) begin
                 active_data = 0;
              end else
              if (data_ctr == data_cycle - 1) begin // get computed crc
                  data_ctr  = data_ctr + 1;
                  exp_crc   = chksum;

                  data0_out = data0_r;
                  data1_out = data1_r;

                  repeat (8) @ (clk_p_i);
              end else
              if (data_ctr == data_cycle) begin
                 active_data = 0;
                 pkt_end = 1;
                 crc[ 7:0] = data0_out;
                 crc[15:8] = data1_out;

                 write_str("#####CRC######");
                 write_to_file(data0_out);
                 write_to_file(data1_out);

                 if (crc != exp_crc) begin
                   $display ("[%0t][%0s]UVM_ERROR Incorrect CRC: Actual = %0x; Expected = %0x", $realtime, name, crc, exp_crc);
                    err_cnt = err_cnt + 1;
                 end else
                 begin
                   $display ("[%0t][%0s]CRC = %0x", $realtime, name, crc);
                 end
              end else
              begin
                  data_ctr  = data_ctr + 1;
                  $display ("[%0t][%0s]byte data = %0x", $realtime, name, data0_r);
                  data0_out = data0_r;
                  data1_out = data1_r;
                  write_to_file(data0_out);
                  write_to_file(data1_out);
                  compute_crc16(data0_r);
                  compute_crc16(data1_r);

                  data_out[ 7:0] = data0_out;
                  data_out[15:8] = data1_out;

                  dvalid = 1;
                  repeat (2) @ (clk_p_i);
                  dvalid = 2;
                  repeat (6) @ (clk_p_i);
              end
          end else
          if (bus_width == 3) begin
               if (data_ctr == 0) begin // B8
                  data_ctr = data_ctr + 1;
                  repeat (8) @ (clk_p_i);
               end else
               if (data_ctr == 1) begin // data type
                  data_ctr  = data_ctr + 1;
                  data_type = data0_r;
                  data0_out = data0_r;
                  data1_out = data1_r;
                  data2_out = data2_r;
                  word_count[ 7:0] = data1_r;
                  word_count[15:8] = data2_r;
                  header0 = data1_r;
                  header1 = data2_r;
                  write_str("#####Header#####"); 

                 if (data_type[5:0] >= 6'h00 && data_type[5:0] <= 6'h0F) begin //short packet
                    $display ("[%0t][%0s] Short Packet detected : Data type = %0x", $realtime, name, data_type[5:0]);
                    short_pkt  = 1;
                    data_cycle = 3;
                    write_str("Short Packet");
                    write_to_file(data0_out);
                    write_to_file(data1_out);
                    write_to_file(data2_out);
                 end else
                 if (data_type[5:0] >= 6'h10 && data_type[5:0] <= 6'h2F) begin //long packet
                    $display ("[%0t][%0s] Long Packet detected : Data type = %0x", $realtime, name, data_type[5:0]);
                    short_pkt = 0;
                    get_data_ctr (word_count, data_cycle);
                    write_str("Long Packet");
                    write_to_file(data0_out);
                    write_to_file(data1_out);
                    write_to_file(data2_out);
                    //write_str("#####Data#####"); 
                 end
                 repeat (8) @ (clk_p_i);
              end else 
              if (data_ctr == 2) begin 
                  data_ctr = data_ctr + 1;
                  ecc = data0_r;
                  data0_out = data0_r;
                  data1_out = data1_r;
                  data2_out = data2_r;
                  write_to_file(data0_out);
                  //reset checksum
                  chksum = 16'hFFFF;
                  if(short_pkt == 0) begin // long packet
                    get_ecc({word_count, data_type}, exp_ecc);
                    write_str("#####Data#####"); 
                    write_to_file(data1_out);
                    write_to_file(data2_out);
                    compute_crc16(data1_r);
                    compute_crc16(data2_r);
                  end
                  else begin
                    get_ecc({header1, header0, data_type}, exp_ecc);
                  end 
                  if (ecc != exp_ecc) begin
                    $display ("[%0t][%0s] UVM_ERROR Incorrect ECC: Actual = %0x; Expected = %0x", $realtime, name, ecc, exp_ecc);
                    err_cnt = err_cnt + 1;
                  end else
                  begin
                    $display ("[%0t][%0s]ECC = %0x", $realtime, name, ecc);
                  end
                  //reset ecc 
                  repeat (8) @ (clk_p_i);
                  ecc     = 8'h00;
                  exp_ecc = 8'h00;
              end else
              if (data_ctr == 3 && short_pkt == 1) begin 
                  active_data = 0;
              end else
              if ((data_ctr == data_cycle - 1) && data_mod == 0) begin // get computed crc
                  data_ctr  = data_ctr + 1;
                  exp_crc   = chksum;

                  data0_out = data0_r;
                  data1_out = data1_r;
                  data2_out = data2_r;
            
                  repeat (8) @ (clk_p_i);
              end else
              if ((data_ctr == data_cycle) && data_mod == 0) begin 
                   active_data = 0;
                   crc[15:8] = data1_out;
                   crc[ 7:0] = data0_out;

                  write_str("#####CRC#####"); 
                  write_to_file(data0_out);
                  write_to_file(data1_out);

                   if (crc != exp_crc) begin
                     $display ("[%0t][%0s]UVM_ERROR Incorrect CRC: Actual = %0x; Expected = %0x", $realtime, name, crc, exp_crc);
                    err_cnt = err_cnt + 1;
                   end else
                   begin
                     $display ("[%0t][%0s]CRC = %0x", $realtime, name, crc);
                   end
              end else
              if ((data_ctr == data_cycle - 1) && data_mod != 0) begin 
                  if(data_mod == 1) begin
                    $display ("[%0t][%0s]byte data = %0x", $realtime, name, data0_r);
                    data0_out = data0_r;
                    data1_out = data1_r;
                    data2_out = data2_r;
                    compute_crc16(data0_r);
                    exp_crc   = chksum;
                    crc[15:8] = data1_out;
                    crc[ 7:0] = data2_out;
                    write_str("#####CRC#####"); 
                    write_to_file(data1_out);
                    write_to_file(data2_out);
                  end
                  else if (data_mod == 2) begin 
                    data0_out = data0_r;
                    crc[7:0] = data0_out;
                    write_to_file(data0_out);
                  end 
                  active_data = 0;

                  if (crc != exp_crc) begin
                     $display ("[%0t][%0s]UVM_ERROR Incorrect CRC: Actual = %0x; Expected = %0x", $realtime, name, crc, exp_crc);
                    err_cnt = err_cnt + 1;
                  end else
                  begin
                    $display ("[%0t][%0s]CRC = %0x", $realtime, name, crc);
                  end
              end else
              if ((data_ctr == data_cycle - 2) && data_mod == 2) begin 
                  $display ("[%0t][%0s]byte data = %0x", $realtime, name, data0_r);
                  $display ("[%0t][%0s]byte data = %0x", $realtime, name, data1_r);
                  data0_out = data0_r;
                  data1_out = data1_r;
                  data2_out = data2_r;
                  compute_crc16(data0_r);
                  compute_crc16(data1_r);
                  exp_crc = chksum;
                  crc[15:8] = data2_out;
                  data_ctr = data_ctr + 1;

                  write_to_file(data0_out);
                  write_to_file(data1_out);
                  write_str("#####CRC#####"); 
                  write_to_file(data2_out);
      
                  repeat (8) @ (clk_p_i);
               end
          end else
          if (bus_width == 4) begin
               if (data_ctr == 0) begin // B8
                  data_ctr = data_ctr + 1;
                  repeat (8) @ (clk_p_i);
               end else
               if (data_ctr == 1) begin // data type
                  data_ctr  = data_ctr + 1;
                  data_type = data0_r;
                  data0_out = data0_r;
                  data1_out = data1_r;
                  data2_out = data2_r;
                  data3_out = data3_r;
                  word_count[ 7:0] = data1_r;
                  word_count[15:8] = data2_r;
                  ecc              = data3_r;
                  get_ecc({data2_r, data1_r, data0_r}, exp_ecc);
                  write_str("#####Header#####"); 

                 if (data_type[5:0] >= 6'h00 && data_type[5:0] <= 6'h0F) begin //short packet
                    $display ("[%0t][%0s] Short Packet detected : Data type = %0x", $realtime, name, data_type[5:0]);
                    short_pkt  = 1;
                    data_cycle = 2;
                    write_str("Short Packet");
                    write_to_file(data0_out);
                    write_to_file(data1_out);
                    write_to_file(data2_out);
                    write_to_file(data3_out);
                 end else
                 if (data_type[5:0] >= 6'h10 && data_type[5:0] <= 6'h2F) begin //long packet
                    $display ("[%0t][%0s] Long Packet detected : Data type = %0x", $realtime, name, data_type[5:0]);
                    short_pkt = 0;
                    get_data_ctr (word_count, data_cycle);
                    write_str("Long Packet");
                    write_to_file(data0_out);
                    write_to_file(data1_out);
                    write_to_file(data2_out);
                    write_to_file(data3_out);
                    write_str("#####Data#####"); 
                 end 

                  if (ecc != exp_ecc) begin
                    $display ("[%0t][%0s] UVM_ERROR Incorrect ECC: Actual = %0x; Expected = %0x", $realtime, name, ecc, exp_ecc);
                    err_cnt = err_cnt + 1;
                  end else
                  begin
                    $display ("[%0t][%0s]ECC = %0x", $realtime, name, ecc);
                  end
                  repeat (8) @ (clk_p_i);
                  chksum = 16'hFFFF;
               end else
               if (data_ctr == 2 && short_pkt == 1) begin 
                  active_data = 0;
               end else
               if (data_ctr == data_cycle - 1) begin // get computed crc
                  data_ctr  = data_ctr + 1;
                  exp_crc   = chksum;

                  data0_out = data0_r;
                  data1_out = data1_r;
                  data2_out = data2_r;
                  data3_out = data3_r;
               end else
               if (data_ctr == data_cycle) begin 
                   active_data = 0;
                   pkt_end = 1;
                   crc[15:8] = data1_out;
                   crc[ 7:0] = data0_out;

                  write_str("#####CRC#####"); 
                  write_to_file(data0_out);
                  write_to_file(data1_out);

                   if (crc != exp_crc) begin
                     $display ("[%0t][%0s]UVM_ERROR Incorrect CRC: Actual = %0x; Expected = %0x", $realtime, name, crc, exp_crc);
                    err_cnt = err_cnt + 1;
                   end else
                   begin
                     $display ("[%0t][%0s]CRC = %0x", $realtime, name, crc);
                   end
               end
               else begin
                  $display ("[%0t][%0s]byte data = %0x", $realtime, name, data0_r);
                  $display ("[%0t][%0s]byte data = %0x", $realtime, name, data1_r);
                  $display ("[%0t][%0s]byte data = %0x", $realtime, name, data2_r);
                  $display ("[%0t][%0s]byte data = %0x", $realtime, name, data3_r);
                  data0_out = data0_r;
                  data1_out = data1_r;
                  data2_out = data2_r;
                  data3_out = data3_r;
                  compute_crc16(data0_r);
                  compute_crc16(data1_r);
                  compute_crc16(data2_r);
                  compute_crc16(data3_r);
                  data_ctr = data_ctr + 1;

                  write_to_file(data0_out);
                  write_to_file(data1_out);
                  write_to_file(data2_out);
                  write_to_file(data3_out);

      
                  data_out[  7:0] = data0_out;
                  data_out[ 15:8] = data1_out;
                  data_out[23:16] = data2_out;
                  data_out[31:24] = data3_out;
//                  data_out = data_out_w;
                  dvalid = 1;
                  repeat (2) @ (clk_p_i);
                  dvalid = 0;
                  repeat (6) @ (clk_p_i);
               end
          end
      end else
      begin
         data_ctr = 0;
         @ (clk_p_i);
         pkt_end = 0;
      end
      
//      if (err_cnt != 0) begin
//          $display ("[%0t][%0s] %0d errors detected in ECC/CRC", $realtime, name, err_cnt);
//      end
   end
end
endtask

task get_ecc (input [23:0] d, output [5:0] ecc_val);
begin
  ecc_val[0] = d[0]^d[1]^d[2]^d[4]^d[5]^d[7]^d[10]^d[11]^d[13]^d[16]^d[20]^d[21]^d[22]^d[23];
  ecc_val[1] = d[0]^d[1]^d[3]^d[4]^d[6]^d[8]^d[10]^d[12]^d[14]^d[17]^d[20]^d[21]^d[22]^d[23];
  ecc_val[2] = d[0]^d[2]^d[3]^d[5]^d[6]^d[9]^d[11]^d[12]^d[15]^d[18]^d[20]^d[21]^d[22];
  ecc_val[3] = d[1]^d[2]^d[3]^d[7]^d[8]^d[9]^d[13]^d[14]^d[15]^d[19]^d[20]^d[21]^d[23];
  ecc_val[4] = d[4]^d[5]^d[6]^d[7]^d[8]^d[9]^d[16]^d[17]^d[18]^d[19]^d[20]^d[22]^d[23];
  ecc_val[5] = d[10]^d[11]^d[12]^d[13]^d[14]^d[15]^d[16]^d[17]^d[18]^d[19]^d[21]^d[22]^d[23];
end
endtask

task compute_crc16(input [7:0] data);
begin
   for (n = 0; n < 8; n = n + 1) begin
     cur_crc = chksum;
     cur_crc[15] = data[n]^cur_crc[0];
     cur_crc[10] = cur_crc[11]^cur_crc[15];
     cur_crc[3]  = cur_crc[4]^cur_crc[15];
     chksum = chksum >> 1;
     chksum[15] = cur_crc[15];
     chksum[10] = cur_crc[10];
     chksum[3] = cur_crc[3];
   end
end
endtask

task get_data_ctr(input [15:0] wc, output [15:0] data_cnt);
begin
     if (bus_width == 1) begin
        data_cnt = 7 + wc; // 1 : sync, 4 : header, 2 : CRC
     end else
     if (bus_width == 2) begin
        data_cnt = wc/bus_width;
        if (wc%bus_width > 0) begin
           data_cnt = data_cnt + 1;
        end
        data_cnt = data_cnt + 4; // 1 : sync, 2 : header, 1 : CRC
     end else
     if (bus_width == 3) begin
        data_cnt = ((wc-2)/bus_width) + 1 + 2 + 1; // 1 : sync, 2 : header, 1 : CRC
        data_mod = (wc-2)%bus_width;
        if(data_mod == 2) begin
          data_cnt = ((wc-2)/bus_width) + 1 + 1 + 2 + 1; // 1: last 2 data, 1 : sync, 2 : header, 1 : CRC
        end
     end else
     if (bus_width == 4) begin
        data_cnt = wc/bus_width;
        if (wc%bus_width < 3) begin
           data_cnt = data_cnt + 1; // CRC included
        end else
        if (wc%bus_width > 2) begin
           data_cnt = data_cnt + 2; // additional for CRC
        end
        data_cnt = data_cnt + 2; // 1 : sync, 1 : header
     end
end
endtask

task write_to_file (input [7:0] data);
  integer filedesc;
begin
  filedesc = $fopen(name,"a");
  $fwrite(filedesc, "%0x\n", data);
  $fclose(filedesc);
end
endtask

task write_str (input [20*8-1:0] str);
  integer filedesc;
begin
  filedesc = $fopen(name,"a");
  $fwrite(filedesc, "%0s\n", str);
  $fclose(filedesc);
end
endtask

always @(negedge active_data) begin
  start_check = 0;
  repeat (8) @(clk_p_i);
  start_check = 1;

  if (err_cnt != 0) begin
      $display ("[%0t][%0s] %0d errors detected in ECC/CRC", $realtime, name, err_cnt);
  end
end
endmodule
