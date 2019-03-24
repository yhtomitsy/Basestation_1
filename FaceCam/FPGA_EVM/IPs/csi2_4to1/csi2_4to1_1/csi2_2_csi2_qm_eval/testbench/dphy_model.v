`include "bus_driver.v"
`include "clk_driver.v"

module dphy_model#(
   parameter num_frames           = 2,
   parameter num_lines            = 2,
   parameter num_pixels           = 200,
   parameter active_dphy_lanes    = 4,
   parameter data_type            = 6'h2b,

   parameter dphy_clk_period      = 1683, 
   parameter t_lpx                = 68000,
   parameter t_clk_prepare        = 51000,
   parameter t_clk_zero           = 252503, 
   parameter t_clk_trail          = 62000,
   parameter t_clk_pre            = 30000,
   parameter t_clk_post           = 131000, //based from waveform

   parameter t_hs_prepare         = 55000,
   parameter t_hs_zero            = 103543, 
   parameter t_hs_trail           = 80000,
   parameter lps_gap              = 100000,
   parameter frame_gap            = 100000,
   parameter init_drive_delay     = 1000,
   parameter dphy_ch              = 0,
   parameter dphy_vc              = 0,
   parameter long_even_line_en    = 0,
   parameter ls_le_en             = 0,
   parameter debug                = 0
)(
   input refclk_i,
   input resetn,
   input pll_lock,

   output clk_p_i,
   output clk_n_i,
   output cont_clk_p_i,
   output cont_clk_n_i,
   output [3:0] do_p_i,
   output [3:0] do_n_i
);

wire clk_p_w, clk_n_w;
reg cont_clk_p_r, cont_clk_n_r;

reg clk_en, cont_clk_en;
reg [1:0]  vc;
reg [5:0]  dt;
reg [15:0] wc;
reg [7:0]  ecc;
reg [15:0] chksum;
reg [15:0] cur_crc;
reg odd_even_line; 
reg long_even_line;
reg ls_le;
reg [15:0] lnum;

reg [1:0] fnum;

reg dphy_start;
reg dphy_active;

integer i,j,k,l,m,n;
reg [7:0] data [3:0];


wire [7:0] data0;
wire [7:0] data1;
wire [7:0] data2;
wire [7:0] data3;

clk_driver clk_drv();
bus_driver#(.ch(0))bus_drv0(.clk_p_i(clk_p_w));
bus_driver#(.ch(1))bus_drv1(.clk_p_i(clk_p_w));
bus_driver#(.ch(2))bus_drv2(.clk_p_i(clk_p_w));
bus_driver#(.ch(3))bus_drv3(.clk_p_i(clk_p_w));

assign clk_p_i = clk_p_w; 
assign clk_n_i = clk_n_w;
assign cont_clk_p_i = cont_clk_p_r;
assign cont_clk_n_i = cont_clk_n_r;
assign clk_p_w = clk_drv.clk_p_i;
assign clk_n_w = clk_drv.clk_n_i;
assign do_p_i[0] = bus_drv0.do_p_i;
assign do_n_i[0] = bus_drv0.do_n_i;
assign do_p_i[1] = bus_drv1.do_p_i;
assign do_n_i[1] = bus_drv1.do_n_i;
assign do_p_i[2] = bus_drv2.do_p_i;
assign do_n_i[2] = bus_drv2.do_n_i;
assign do_p_i[3] = bus_drv3.do_p_i;
assign do_n_i[3] = bus_drv3.do_n_i;

assign data0 = data[0];
assign data1 = data[1];
assign data2 = data[2];
assign data3 = data[3];

initial begin
      vc = dphy_vc;
      dt = data_type;
      wc = num_pixels;
      fnum = 1;
      chksum = 16'hffff;
      dphy_active = 0;
      cont_clk_p_r = 1;
      cont_clk_n_r = 1;
      long_even_line = long_even_line_en;
      ls_le = ls_le_en;
      data[0]  = 0;
      data[1]  = 0;
      data[2]  = 0;
      data[3]  = 0;

      `ifndef RX_CLK_MODE_HS_ONLY
      @(posedge dphy_active);
      $display("%0t DPHY [%0d] model activated\n", $time, dphy_ch);

      #(init_drive_delay);
      `endif

      fork
         begin
            #100000;
            drive_cont_clk;
         end
         begin

            `ifdef RX_CLK_MODE_HS_ONLY
               @(posedge dphy_active);
               $display("%0t DPHY [%0d] model activated\n", $time, dphy_ch);

               #(init_drive_delay);
            `endif 

            repeat (num_frames) begin
            // FS
//            #lps_gap;
            drive_fs;
      
            odd_even_line = 0; 
               //Drive data
               repeat (num_lines) begin
                  if (ls_le == 1) begin
                     #lps_gap;
                     drive_ls;
                  end
                  #lps_gap;
                  if (long_even_line == 1) begin
                     if (odd_even_line == 0) begin
                        wc = num_pixels;
                     end else
                     if (odd_even_line == 1) begin
                        wc = num_pixels*2;
                     end
                  end
                  drive_data;

                  if (ls_le == 1) begin
                     #lps_gap;
                     drive_le;
                  end
                  odd_even_line = ~odd_even_line;
               end
      
            //FE
            #lps_gap;
            drive_fe;
            #frame_gap;
            end
      
            #lps_gap;
            dphy_active = 0;
            cont_clk_en = 0;
         end
      join
end

initial begin
   clk_en = 0;
   cont_clk_en = 0;
end

task drive_cont_clk;
begin
   #1000;
   // HS-RQST
   $display("%0t DPHY [%0d] CLK CONT : Driving HS-CLK-RQST", $time, dphy_ch);
   cont_clk_p_r = 0;
   cont_clk_n_r = 1;
   #t_lpx;

   // HS-Prpr
   $display("%0t DPHY [%0d] CLK CONT : Driving HS-Prpr", $time, dphy_ch);
   cont_clk_p_r = 0;
   cont_clk_n_r = 0;
   #t_clk_prepare;

   // HS-Go
   $display("%0t DPHY [%0d] CLK CONT : Driving HS-Go", $time, dphy_ch);
   cont_clk_p_r = 0;
   cont_clk_n_r = 1;
   #t_clk_zero;

   cont_clk_en = 1;
   $display("%0t DPHY [%0d] CLK CONT : Driving HS-0/HS-1", $time, dphy_ch);
   while (cont_clk_en) begin
      @(refclk_i);
      cont_clk_p_r = refclk_i;
      cont_clk_n_r = ~refclk_i;
   end

   // Trail HS-0
   $display("%0t DPHY [%0d] CLK CONT : Driving CLK-Trail", $time, dphy_ch);
   #t_clk_trail;

   // TX-Stop
   $display("%0t DPHY [%0d] CLK CONT : Driving CLK-Stop", $time, dphy_ch);
   clk_drv.drv_clk_st(1, 1);
end
endtask

task drive_clk;
begin 

   #1000;
   // HS-RQST
   $display("%0t DPHY [%0d] CLK : Driving HS-CLK-RQST", $time, dphy_ch);
   clk_drv.drv_clk_st(0, 1);
   #t_lpx;

   // HS-Prpr
   $display("%0t DPHY [%0d] CLK : Driving HS-Prpr", $time, dphy_ch);
   clk_drv.drv_clk_st(0, 0);
   #t_clk_prepare;

   // HS-Go
   $display("%0t DPHY [%0d] CLK : Driving HS-Go", $time, dphy_ch);
   clk_drv.drv_clk_st(0, 1);
   #t_clk_zero;

   clk_en = 1;
   $display("%0t DPHY [%0d] CLK : Driving HS-0/HS-1", $time, dphy_ch);
   while (clk_en) begin
      @(refclk_i);
      clk_drv.drv_clk_st(refclk_i, ~refclk_i);
   end

   // Trail HS-0
   $display("%0t DPHY [%0d] CLK : Driving CLK-Trail", $time, dphy_ch);
   #t_clk_trail;

   // TX-Stop
   $display("%0t DPHY [%0d] CLK : Driving CLK-Stop", $time, dphy_ch);
   clk_drv.drv_clk_st(1, 1);

end
endtask

task drive_fs;
begin
   fork
      begin
         drive_clk;
      end
      begin
         pre_data;

         // FS packet
         data[0] = {vc, 6'h00};
         data[1] = fnum;
         data[2] = 8'h00;
         get_ecc({data[2], data[1], data[0]}, data[3]);
         //data[3] = 8'h15;

         $display("%0t DPHY [%0d] DATA : Driving FS", $time, dphy_ch);
         if (active_dphy_lanes == 1) begin
            for (i = 0 ; i < 4 ; i = i + 1) begin
               bus_drv0.drive_datax(data[i]);
            end
         end else 
         if (active_dphy_lanes == 2) begin
            for (i = 0 ; i < 4 ; i = i + 2) begin
            $display("%0t DPHY [%0d] DATA : Driving data[%0d] = %0x", $time, dphy_ch, i, data[i]);
            $display("%0t DPHY [%0d] DATA : Driving data[%0d] = %0x", $time, dphy_ch, i+1, data[i+1]);
               fork
                  bus_drv0.drive_datax(data[i]);
                  bus_drv1.drive_datax(data[i+1]);
               join
            end
         end else
         if (active_dphy_lanes == 4) begin
            fork
               bus_drv0.drive_datax(data[0]);
               bus_drv1.drive_datax(data[1]);
               bus_drv2.drive_datax(data[2]);
               bus_drv3.drive_datax(data[3]);
            join
         end
         post_data;

         // reset line number
         lnum = 1;
      end
   join
end
endtask

task drive_ls;
begin
   fork
      begin
         drive_clk;
      end
      begin
         pre_data;

         // FS packet
         data[0] = {vc, 6'h02};
         data[1] = lnum[7:0];
         data[2] = lnum[15:8];
         get_ecc({data[2], data[1], data[0]}, data[3]);

         $display("%0t DPHY [%0d] DATA : Driving LS", $time, dphy_ch);
         if (active_dphy_lanes == 1) begin
            for (i = 0 ; i < 4 ; i = i + 1) begin
               bus_drv0.drive_datax(data[i]);
            end
         end else
         if (active_dphy_lanes == 2) begin
            for (i = 0 ; i < 4 ; i = i + 2) begin
            $display("%0t DPHY [%0d] DATA : Driving data[%0d] = %0x", $time, dphy_ch, i, data[i]);
            $display("%0t DPHY [%0d] DATA : Driving data[%0d] = %0x", $time, dphy_ch, i+1, data[i+1]);
               fork
                  bus_drv0.drive_datax(data[i]);
                  bus_drv1.drive_datax(data[i+1]);
               join
            end
         end else
         if (active_dphy_lanes == 4) begin
            fork
               bus_drv0.drive_datax(data[0]);
               bus_drv1.drive_datax(data[1]);
               bus_drv2.drive_datax(data[2]);
               bus_drv3.drive_datax(data[3]);
            join
         end
         post_data;
      end
   join
end
endtask

task drive_fe;
begin
   fork
      begin
         drive_clk;
      end
      begin
         pre_data;

         // FE packet
         data[0] = {vc, 6'h01};
         data[1] = fnum;
         data[2] = 8'h00;
         get_ecc({data[2], data[1], data[0]}, data[3]);

         $display("%0t DPHY [%0d] DATA : Driving FE", $time, dphy_ch);
         if (active_dphy_lanes == 1) begin
            for (i = 0 ; i < 4 ; i = i + 1) begin
               bus_drv0.drive_datax(data[i]);
            end
         end else
         if (active_dphy_lanes == 2) begin
            for (i = 0 ; i < 4 ; i = i + 2) begin
               fork
                  bus_drv0.drive_datax(data[i]);
                  bus_drv1.drive_datax(data[i+1]);
               join
            end
         end else
         if (active_dphy_lanes == 4) begin
            fork
               bus_drv0.drive_datax(data[0]);
               bus_drv1.drive_datax(data[1]);
               bus_drv2.drive_datax(data[2]);
               bus_drv3.drive_datax(data[3]);
            join
         end

         post_data;
         fnum = ~fnum;
      end
   join

end
endtask

task drive_le;
begin
   fork
      begin
         drive_clk;
      end
      begin
         pre_data;

         // LE packet
         data[0] = {vc, 6'h03};
         data[1] = lnum[7:0];
         data[2] = lnum[15:0];
         get_ecc({data[2], data[1], data[0]}, data[3]);

         $display("%0t DPHY [%0d] DATA : Driving LE", $time, dphy_ch);
         if (active_dphy_lanes == 1) begin
            for (i = 0 ; i < 4 ; i = i + 1) begin
               bus_drv0.drive_datax(data[i]);
            end
         end else
         if (active_dphy_lanes == 2) begin
            for (i = 0 ; i < 4 ; i = i + 2) begin
               fork
                  bus_drv0.drive_datax(data[i]);
                  bus_drv1.drive_datax(data[i+1]);
               join
            end
         end else
         if (active_dphy_lanes == 4) begin
            fork
               bus_drv0.drive_datax(data[0]);
               bus_drv1.drive_datax(data[1]);
               bus_drv2.drive_datax(data[2]);
               bus_drv3.drive_datax(data[3]);
            join
         end

         post_data;
         lnum = lnum + 1;
      end
   join

end
endtask

task drive_data;
begin
   fork
      begin
         drive_clk;
      end
      begin
         pre_data;

         //drive header
         data[0] = {vc, dt};
         data[1] = {wc[7:0]};
         data[2] = {wc[15:8]};
         get_ecc({data[2], data[1], data[0]}, data[3]);

         $display("%0t DPHY [%0d] Driving Data header", $time, dphy_ch);
         if (active_dphy_lanes == 1) begin
            for (i = 0 ; i < 4 ; i = i + 1) begin
               bus_drv0.drive_datax(data[i]);
            end
         end else
         if (active_dphy_lanes == 2) begin
            for (i = 0 ; i < 4 ; i = i + 2) begin
         $display("%0t DPHY [%0d] Driving Data header for data[%0d] = %x", $time, dphy_ch, i, data[i]);
         $display("%0t DPHY [%0d] Driving Data header for data[%0d] = %x", $time, dphy_ch, i+1, data[i+1]);
               fork
                  bus_drv0.drive_datax(data[i]);
                  bus_drv1.drive_datax(data[i+1]);
               join
            end
         end else
         if (active_dphy_lanes == 4) begin
            fork
               bus_drv0.drive_datax(data[0]);
               bus_drv1.drive_datax(data[1]);
               bus_drv2.drive_datax(data[2]);
               bus_drv3.drive_datax(data[3]);
            join
         end

         // reset crc value
         chksum = 16'hffff;

         // temporary alternating data 8'h0 and 8'hFF
         data[0] = 0;
         data[1] = 0;
         data[2] = 0;
         data[3] = 0;
         // random data packet
         repeat (wc/active_dphy_lanes) begin // use variable later
            
            for (i = 0; i < active_dphy_lanes; i = i + 1) begin
                if (debug == 0) begin
                  data[i] = $random;
                end else
                begin
                  data[i] = ~data[i];
                end
                compute_crc16(data[i]);
            end

            $display("%0t DPHY [%0d] Driving Data", $time, dphy_ch);
            if (active_dphy_lanes == 1) begin
               for (i = 0 ; i < active_dphy_lanes ; i = i + 1) begin
                  bus_drv0.drive_datax(data[i]);
               end
            end else
            if (active_dphy_lanes == 2) begin
               for (i = 0 ; i < active_dphy_lanes ; i = i + 2) begin
                  fork
                     bus_drv0.drive_datax(data[i]);
                     bus_drv1.drive_datax(data[i+1]);
                  join
               end
            end else
            if (active_dphy_lanes == 4) begin
               fork
                  bus_drv0.drive_datax(data[0]);
                  bus_drv1.drive_datax(data[1]);
                  bus_drv2.drive_datax(data[2]);
                  bus_drv3.drive_datax(data[3]);
               join
            end
         end

         // drive crc data until end of packet
         $display("%0t DPHY [%0d] Driving CRC[15:8] = %0x; CRC[7:0] = %0x", $time, dphy_ch, chksum[15:8], chksum[7:0]);
         if (active_dphy_lanes == 1) begin
            bus_drv0.drive_datax(chksum[7:0]);
            bus_drv0.drive_datax(chksum[15:8]);
         end else
         if (active_dphy_lanes == 2) begin
            fork
               bus_drv0.drive_datax(chksum[7:0]);
               bus_drv1.drive_datax(chksum[15:8]);
            join 
         end else
         if (active_dphy_lanes == 4) begin
            fork
               bus_drv0.drive_datax(chksum[7:0]);
               bus_drv1.drive_datax(chksum[15:8]);
               bus_drv2.drv_trail;
               bus_drv3.drv_trail;
            join
         end 

         //Start HS-trail
         fork
            bus_drv0.drv_trail;
            begin
               if (active_dphy_lanes == 2 || active_dphy_lanes == 4) begin
                  bus_drv1.drv_trail;
               end
            end
         join

         #t_hs_trail;

         // HS-Stop
         //@(clk_p_i);
         fork
            bus_drv0.drv_stop;
            begin
               if (active_dphy_lanes == 2) begin
                  bus_drv1.drv_stop;
               end
            end
            begin
               if (active_dphy_lanes == 4) begin
                  fork
                     bus_drv1.drv_stop;
                     bus_drv2.drv_stop;
                     bus_drv3.drv_stop;
                  join
               end
            end
         join

         #t_clk_post;
         clk_en = 0;

      end
   join
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

task pre_data;
begin
   @(posedge clk_en);

//   repeat (5) begin
//     @(posedge clk_p_i);
//   end

   #t_clk_pre;

   // HS-RQST
   $display("%0t DPHY [%0d] DATA : Driving HS-RQST", $time, dphy_ch);
    bus_drv0.drv_dat_st(0,1);
    if (active_dphy_lanes == 2) begin
    bus_drv1.drv_dat_st(0,1);
    end else
    if (active_dphy_lanes == 4) begin
    bus_drv1.drv_dat_st(0,1);
    bus_drv2.drv_dat_st(0,1);
    bus_drv3.drv_dat_st(0,1);
    end
   #t_lpx;

   // HS-Prpr
   $display("%0t DPHY [%0d] DATA : Driving HS-Prpr", $time, dphy_ch);
    bus_drv0.drv_dat_st(0,0);
    if (active_dphy_lanes == 2) begin
    bus_drv1.drv_dat_st(0,0);
    end else
    if (active_dphy_lanes == 4) begin
    bus_drv1.drv_dat_st(0,0);
    bus_drv2.drv_dat_st(0,0);
    bus_drv3.drv_dat_st(0,0);
    end
   #t_hs_prepare;

   // HS-Go
   $display("%0t DPHY [%0d] CLK : Driving HS-Go", $time, dphy_ch);
    bus_drv0.drv_dat_st(0,1);
    if (active_dphy_lanes == 2) begin
    bus_drv1.drv_dat_st(0,1);
    end else
    if (active_dphy_lanes == 4) begin
    bus_drv1.drv_dat_st(0,1);
    bus_drv2.drv_dat_st(0,1);
    bus_drv3.drv_dat_st(0,1);
    end
   #t_hs_zero;

   //sync with clock
   @(clk_p_i);

   // HS-Sync
   // generate data
   for (i = 0; i < active_dphy_lanes; i = i + 1) begin
       data[i] = 8'hB8;
   end

   $display("%0t DPHY [%0d] CLK : Driving SYNC Data", $time, dphy_ch);
   if (active_dphy_lanes == 1) begin
       bus_drv0.drive_datax(data[0]);
   end else
   if (active_dphy_lanes == 2) begin
   fork
       bus_drv0.drive_datax(data[0]);
       bus_drv1.drive_datax(data[1]);
   join
   end else
   if (active_dphy_lanes == 4) begin
   fork
       bus_drv0.drive_datax(data[0]);
       bus_drv1.drive_datax(data[1]);
       bus_drv2.drive_datax(data[2]);
       bus_drv3.drive_datax(data[3]);
   join
   end
end
endtask

task post_data;
begin
   // HS-Trail
   $display("%0t DPHY [%0d] DATA : Driving HS-Trail", $time, dphy_ch);
   fork
         bus_drv0.drv_trail;
         begin
            if (active_dphy_lanes == 2) begin
               bus_drv1.drv_trail;
            end
         end
         begin
            if (active_dphy_lanes == 4) begin
               fork
                   bus_drv1.drv_trail;
                   bus_drv2.drv_trail;
                   bus_drv3.drv_trail;
               join
            end
         end
   join
   #t_hs_trail;

   // HS-Stop
   $display("%0t DPHY [%0d] DATA : Driving HS-Stop", $time, dphy_ch);
   fork
         bus_drv0.drv_stop;
         begin
             if (active_dphy_lanes == 2) begin
                 bus_drv1.drv_stop;
             end 
         end
         begin
             if (active_dphy_lanes == 4) begin
                fork
                    bus_drv1.drv_stop;
                    bus_drv2.drv_stop;
                    bus_drv3.drv_stop;
                join
             end
         end
   join

         #131000; // based from waveform
         clk_en = 0;
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
endmodule
