

module four_sensor (
	input clock,  // 50MHz
	input reset_n, // Active LOW
	// those are the sensor data lines
	inout [NUMBER_OF_SENSORS-1:0]D_io,
	// those are the sensor envelope lines
	inout [NUMBER_OF_SENSORS-1:0]E_io,
	output [NUMBER_OF_SENSORS-1:0]sync_o,
	output [31:0]sensor_data_o_0, 
	output [31:0]sensor_data_o_1,
	output [31:0]sensor_data_o_2,
	output [31:0]sensor_data_o_3
  );
/* sensor_data_o_0 - sensor_data_o_3
		-- bit 31    	lighthouse_id
		-- bit 30    	axis
		-- bit 29    	valid
		-- bits 28:19  sensor_id
		-- bits 18:0	duration (divide by 50 to get microseconds)
*/
	
parameter NUMBER_OF_SENSORS = 4 ; // 4 sensor
parameter CLK_SPEED = 50_000_000 ;
localparam NUMBER_OF_SPI_FRAMES = (NUMBER_OF_SENSORS+4-1)/4; // ceil division to get eg 2 frames when using 15 sensors
reg [255:0]sensor_data[NUMBER_OF_SPI_FRAMES-1:0] ; 
reg [NUMBER_OF_SENSORS-1:0] sync;
wire [2:0] sensor_state[NUMBER_OF_SENSORS-1:0];
assign sync_o = sync;
assign sensor_data_o_0 = sensor_data[0][31:0];
assign sensor_data_o_1 = sensor_data[0][63:32];
assign sensor_data_o_2 = sensor_data[0][95:64];
assign sensor_data_o_3 = sensor_data[0][127:96];

genvar i,sensor_frame,sensor_counter;
generate 
	for(i=0; i<NUMBER_OF_SENSORS; i = i+1) begin : instantiate_lighthouse_sensors
		localparam integer sensor_frame = i/4;
		localparam integer sensor_counter = i%4;
		localparam unsigned [9:0]sensor_id = i;
		lighthouse_sensor #(sensor_id) lighthouse_sensors(
			.clk(clock),
			.sensor((~E_io[i]) && sensor_state[i]==3'b001), // activate envelope line when sensor is in watch state
			.combined_data(sensor_data[sensor_frame][32*(sensor_counter+1)-1:32*sensor_counter]),
			.sync(sync[i])
		);
		ts4231 #(CLK_SPEED) sensor(
			.clk(clock),
			.rst(~reset_n),
			.D(D_io[i]),
			.E(E_io[i]),
			.sensor_STATE(sensor_state[i])
		);
	end
endgenerate 
  
  
 
 
 
endmodule
