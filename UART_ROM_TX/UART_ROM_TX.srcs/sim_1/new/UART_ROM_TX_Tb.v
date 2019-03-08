`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2019 00:00:15
// Design Name: 
// Module Name: UART_ROM_TX_Tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_ROM_TX_Tb();

reg clk;
reg rst = 1'b0;
reg sync = 1'b0;
wire FPGA_Tx;
wire [2:0] state;
wire [7:0] data;
wire wr_en_Push;
wire tx_busy;
wire clken;
parameter clkper = 20; // 20ns = 50MHz

initial
begin
  clk = 1;
end

always
begin
   # (clkper / 2) clk = ~clk;
end

initial
begin
  #10000 rst = 1'b1;
  #10000 rst = 1'b0;
  #10 rst = 1'b1; sync = 1'b1;
  #10000 rst = 1'b1; sync = 1'b0;   
  #1000000 rst = 1'b1; sync = 1'b1; 
  #10000 rst = 1'b1; sync = 1'b0;   
end
/*
        -- combined data layout:
        -- bit 31        lighthouse_id
        -- bit 30        axis
        -- bit 29        valid
        -- bits 28:19  sensor_id
        -- bits 18:0    duration (divide by 50 to get microseconds)
*/

// 01100000000001100110011001110101

One_Sensor_UART_TX One_Sensor_UART_TX(
	.FPGA_MCLK(clk), // 50MHz
	.FPGA_nRESET(rst),
	.sync(sync),
	.state(state),
	.data(data),
	.tx_busy(tx_busy),
	.wr_en_Push(wr_en_Push),
	.FPGA_Tx(FPGA_Tx)
	);  
	
baud_rate_gen baud_rate_gen(
	.clk_50m(clk),
	.txclk_en(clken)
	); 
	
endmodule
