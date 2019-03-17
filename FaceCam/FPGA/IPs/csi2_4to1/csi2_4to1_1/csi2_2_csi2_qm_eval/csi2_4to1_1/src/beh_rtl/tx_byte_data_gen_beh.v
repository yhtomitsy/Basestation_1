// tx_byte_data_gen_beh.v generated by Lattice IP Model Creator version 1
// created on Sat, Feb 04, 2017  2:23:50 PM
// Copyright(c) 2007 Lattice Semiconductor Corporation. All rights reserved
// obfuscator_exe version 1.mar0807

// top

`timescale 1 ns / 100 ps
module tx_byte_data_gen # (
			parameter TX_GEAR=16,	parameter RX_GEAR=8,	parameter NO_LANE=4	)
		(		
			input rst_n_i,
			input tx_clk,


input lbf_lastwd_ch0,
input [TX_GEAR*NO_LANE-1:0] byte_bufout_ch0, 
input [TX_GEAR*NO_LANE-1:0] byte_bufout_ch1,
input lbfr_wdvalid_ch0,
input lbfr_wdvalid_ch1,
input [15:0] rd_counter_ch0, 


			output reg [63:0] gen_word_o,
			output reg gen_data_valid_o	);
parameter DATA_WIDTH = TX_GEAR*NO_LANE;
reg [DATA_WIDTH-1:0]   czc9a1f;
reg   zk4d0fd;
reg   ww687ea;
reg   su43f51;
reg [DATA_WIDTH-1:0]   alfd441;
reg [DATA_WIDTH-1:0]   mr51060;
reg ec88305;
reg mr41828;
wire [7:0] zzc145;
wire [7:0] yx60a2e;
wire [7:0] aa5174;
wire [7:0] db28ba0;
wire [7:0] vv45d06;
wire [7:0] qi2e837;
wire [7:0] zx741b9;
wire [7:0] tja0dce;
wire [7:0] ph6e76;
wire [7:0] tj373b6;
wire [7:0] ymb9db7;
wire [7:0] qgcedb9;
wire [7:0] dm76dc8;
wire [7:0] wyb6e42;
wire [7:0] twb7210;
wire [7:0] ymb9083;

`ifdef TX_GEAR_16

`ifdef NO_OF_LANE_2

`endif

`ifdef NO_OF_LANE_4

`endif

`ifdef NO_OF_LANE_2

`endif

`ifdef NO_OF_LANE_4

`endif

`endif

`ifdef LR //....................................................................

`ifdef NO_OF_LANE_4 //------------------------------------------

`ifdef TX_GEAR_16 ////// 

`else //`elsif TX_GEAR_8 //////

`endif //TX_GEAR //////

`endif //NO_OF_LANE_4

`ifdef NO_OF_LANE_2 //------------------------------------------

`ifdef TX_GEAR_16 //////      

`else //`elsif TX_GEAR_8 //////

`endif

`endif //NO_OF_LANE_2

`ifdef NO_OF_LANE_1 //------------------------------------------

`endif //-------------------------------------------------------

`ifdef NO_OF_LANE_4 //------------------------------------------

`ifdef TX_GEAR_16 ////// 

`else //`elsif TX_GEAR_8 //////

`endif //TX_GEAR //////

`endif //NO_OF_LANE_4

`ifdef NO_OF_LANE_2 //------------------------------------------

`ifdef TX_GEAR_16 //////     

`else //`elsif TX_GEAR_8 //////

`endif //TX_GEAR /////

`endif

`ifdef NO_OF_LANE_1 //------------------------------------------

`endif //-------------------------------------------------------

`else //`elsif VC //....................................................................

`endif //.......................................................................
reg pfc8418;
reg [TX_GEAR * NO_LANE - 1 : 0] ls83199;
reg [TX_GEAR * NO_LANE - 1 : 0] yz332e5;
reg ng9972d;
reg qgcb96b;
reg [15 : 0] cm5cb58;
reg [DATA_WIDTH - 1 : 0] jr2d600;
reg vv6b007;
reg ho5803e;
reg vic01f3;
reg [DATA_WIDTH - 1 : 0] yz7cd1;
reg [DATA_WIDTH - 1 : 0] ldf3461;
reg oh9a30f;
reg uid187c;
reg [7 : 0] ng8c3e0;
reg [7 : 0] hb61f02;
reg [7 : 0] ukf816;
reg [7 : 0] jc7c0b0;
reg [7 : 0] wwe0582;
reg [7 : 0] qv2c11;
reg [7 : 0] bn1608c;
reg [7 : 0] tjb0466;
reg [7 : 0] uk82336;
reg [7 : 0] je119b1;
reg [7 : 0] do8cd8a;
reg [7 : 0] ho66c53;
reg [7 : 0] an3629b;
reg [7 : 0] epb14dd;
reg [7 : 0] gd8a6ec;
reg [7 : 0] ea53765;
reg [2047:0] rv9bb28;
wire [29:0] zxdd947;

`ifdef TX_GEAR_16

`ifdef NO_OF_LANE_2

`endif

`ifdef NO_OF_LANE_4

`endif

`ifdef NO_OF_LANE_2

`endif

`ifdef NO_OF_LANE_4

`endif

`endif

`ifdef LR //....................................................................

`ifdef NO_OF_LANE_4 //------------------------------------------

`ifdef TX_GEAR_16 ////// 

`else //`elsif TX_GEAR_8 //////

`endif //TX_GEAR //////

`endif //NO_OF_LANE_4

`ifdef NO_OF_LANE_2 //------------------------------------------

`ifdef TX_GEAR_16 //////      

`else //`elsif TX_GEAR_8 //////

`endif

`endif //NO_OF_LANE_2

`ifdef NO_OF_LANE_1 //------------------------------------------

`endif //-------------------------------------------------------

`ifdef NO_OF_LANE_4 //------------------------------------------

`ifdef TX_GEAR_16 ////// 

`else //`elsif TX_GEAR_8 //////

`endif //TX_GEAR //////

`endif //NO_OF_LANE_4

`ifdef NO_OF_LANE_2 //------------------------------------------

`ifdef TX_GEAR_16 //////     

`else //`elsif TX_GEAR_8 //////

`endif //TX_GEAR /////

`endif

`ifdef NO_OF_LANE_1 //------------------------------------------

`endif //-------------------------------------------------------

`else //`elsif VC //....................................................................

`endif //.......................................................................

localparam hbeca3e = 30,al651f6 = 32'hfdffc68b;
localparam [31:0] xl28fb5 = al651f6;
localparam co3ed72 = al651f6 & 4'hf;
localparam [11:0] ntb5c86 = 'h7ff;
wire [(1 << co3ed72) -1:0] ay721bc;
reg [hbeca3e-1:0] pu86f0c;
reg [co3ed72-1:0] ukbc316 [0:1];
reg [co3ed72-1:0] xlc582;
reg go62c16;
integer tj160b1;
integer hdb058e;


`ifdef TX_GEAR_16


`ifdef NO_OF_LANE_2


`endif


`ifdef NO_OF_LANE_4


`endif


`ifdef NO_OF_LANE_2


`endif


`ifdef NO_OF_LANE_4


`endif


`endif


`ifdef LR //....................................................................


`ifdef NO_OF_LANE_4 //------------------------------------------


`ifdef TX_GEAR_16 ////// 


`else //`elsif TX_GEAR_8 //////


`endif //TX_GEAR //////


`endif //NO_OF_LANE_4


`ifdef NO_OF_LANE_2 //------------------------------------------


`ifdef TX_GEAR_16 //////      


`else //`elsif TX_GEAR_8 //////


`endif


`endif //NO_OF_LANE_2


`ifdef NO_OF_LANE_1 //------------------------------------------


`endif //-------------------------------------------------------


`ifdef NO_OF_LANE_4 //------------------------------------------


`ifdef TX_GEAR_16 ////// 


`else //`elsif TX_GEAR_8 //////


`endif //TX_GEAR //////


`endif //NO_OF_LANE_4


`ifdef NO_OF_LANE_2 //------------------------------------------


`ifdef TX_GEAR_16 //////     


`else //`elsif TX_GEAR_8 //////


`endif //TX_GEAR /////


`endif


`ifdef NO_OF_LANE_1 //------------------------------------------


`endif //-------------------------------------------------------


`else //`elsif VC //....................................................................


`endif //.......................................................................










`ifdef TX_GEAR_16

assign zzc145 = yz332e5[7:0];
assign yx60a2e = yz332e5[15:8];


`ifdef NO_OF_LANE_2

assign aa5174 = yz332e5[23:16];
assign db28ba0 = yz332e5[31:24];


`endif



`ifdef NO_OF_LANE_4

assign aa5174 = yz332e5[23:16];
assign db28ba0 = yz332e5[31:24];
assign vv45d06 = yz332e5[39:32];
assign qi2e837 = yz332e5[47:40];
assign zx741b9 = yz332e5[55:48];
assign tja0dce = yz332e5[63:56];


`endif


assign ph6e76 = yz7cd1[7:0];
assign tj373b6 = yz7cd1[15:8];


`ifdef NO_OF_LANE_2

assign ymb9db7 = yz7cd1[23:16];
assign qgcedb9 = yz7cd1[31:24];


`endif



`ifdef NO_OF_LANE_4

assign ymb9db7 = yz7cd1[23:16];
assign qgcedb9 = yz7cd1[31:24];
assign dm76dc8 = yz7cd1[39:32];
assign wyb6e42 = yz7cd1[47:40];
assign twb7210 = yz7cd1[55:48];
assign ymb9083 = yz7cd1[63:56];


`endif



`endif





always @* begin    ec88305 = qgcb96b || ng9972d;
end


always @* begin    gen_data_valid_o = oh9a30f || uid187c;
end


always @ (posedge tx_clk or negedge rst_n_i) begin  if (!rst_n_i) begin    mr41828  <= 1'b0;  end  else begin    mr41828 <= oh9a30f;  end
end 



`ifdef LR //....................................................................




always @ (posedge tx_clk or negedge rst_n_i) begin  if (!rst_n_i) begin    alfd441          <= {DATA_WIDTH{1'b0}};  end  else begin    if (qgcb96b)      alfd441 <= yz332e5;    else if (ng9972d)      alfd441 <= ls83199;    else      alfd441 <= yz7cd1;  end
end 



always @  (posedge tx_clk or negedge rst_n_i) begin  if (!rst_n_i) begin    ww687ea <= 1'b0;  end  else begin    ww687ea <= ng9972d;  end
end

always @* begin  su43f51 = ho5803e && !ng9972d;
end





always @* begin  mr51060 = {DATA_WIDTH{1'b0}};  if (ng9972d)    mr51060 = yz7cd1;  else if (uid187c) begin    if (vic01f3) begin 

`ifdef NO_OF_LANE_4 //------------------------------------------



`ifdef TX_GEAR_16 ////// 
    case (cm5cb58)          15'd8: mr51060  = yz7cd1[DATA_WIDTH-1:0];               15'd4: mr51060  = {bn1608c,                          gd8a6ec,                          wwe0582,                          an3629b,                          ukf816,                          do8cd8a,                          ng8c3e0,                          uk82336};                      default:mr51060  = yz7cd1[DATA_WIDTH-1:0];    endcase 


`else //`elsif TX_GEAR_8 //////
    case (cm5cb58)      15'd4: mr51060   = yz7cd1[DATA_WIDTH-1:0];      15'd3: mr51060   = {yz332e5[8*1-1:0],yz7cd1[3*8-1:0]};      15'd2: mr51060   = {yz332e5[8*2-1:0],yz7cd1[2*8-1:0]};      15'd1: mr51060   = {yz332e5[8*3-1:0],yz7cd1[1*8-1:0]};      default:mr51060  = yz7cd1[DATA_WIDTH-1:0];    endcase 


`endif //TX_GEAR //////



`endif //NO_OF_LANE_4



`ifdef NO_OF_LANE_2 //------------------------------------------



`ifdef TX_GEAR_16 //////      
    case (cm5cb58)      15'd4: mr51060   = yz7cd1[DATA_WIDTH-1:0];      15'd3: mr51060   = {yz332e5[8*1-1:0],yz7cd1[3*8-1:0]};      15'd2: mr51060   = {yz332e5[23:16],yz7cd1[23:16],yz332e5[7:0],yz7cd1[7:0]};       15'd1: mr51060   = {yz332e5[8*3-1:0],yz7cd1[1*8-1:0]};      default:mr51060  = yz7cd1[DATA_WIDTH-1:0];    endcase 


`else //`elsif TX_GEAR_8 //////
    case (cm5cb58)      15'd2: mr51060   = yz7cd1[DATA_WIDTH-1:0];      15'd1: mr51060   = {yz332e5[8*1-1:0],yz7cd1[1*8-1:0]};      default:mr51060  = yz7cd1[DATA_WIDTH-1:0];    endcase 


`endif



`endif //NO_OF_LANE_2





`ifdef NO_OF_LANE_1 //------------------------------------------
    mr51060   = yz7cd1[TX_GEAR*NO_LANE-1:0];

`endif //-------------------------------------------------------

    end     else begin 

`ifdef NO_OF_LANE_4 //------------------------------------------



`ifdef TX_GEAR_16 ////// 
    case (cm5cb58)          15'd8: mr51060   = yz7cd1[DATA_WIDTH-1:0];               15'd4: mr51060   =                           {yz332e5 [55:48],                           yz7cd1[63:56],                           yz332e5 [39:32],                           yz7cd1[47:40],                           yz332e5[23:16],                           yz7cd1[31:24],                           yz332e5[7:0],                           yz7cd1[15:8]};
               default:mr51060  = yz7cd1[DATA_WIDTH-1:0];    endcase 


`else //`elsif TX_GEAR_8 //////
    case (cm5cb58)      15'd4: mr51060   = yz7cd1[DATA_WIDTH-1:0];      15'd3: mr51060   = {yz332e5[8*1-1:0],yz7cd1[DATA_WIDTH-1:1*8]};      15'd2: mr51060   = {yz332e5[8*2-1:0],yz7cd1[DATA_WIDTH-1:2*8]};      15'd1: mr51060   = {yz332e5[8*3-1:0],yz7cd1[DATA_WIDTH-1:3*8]};      default:mr51060  = yz7cd1[DATA_WIDTH-1:0];    endcase 


`endif //TX_GEAR //////



`endif //NO_OF_LANE_4



`ifdef NO_OF_LANE_2 //------------------------------------------



`ifdef TX_GEAR_16 //////     
    case (cm5cb58)      15'd4: mr51060   = yz7cd1[DATA_WIDTH-1:0];      15'd3: mr51060   = {yz332e5[8*1-1:0],yz7cd1[DATA_WIDTH-1:1*8]};      15'd2: mr51060   = {yz332e5[23:16],yz7cd1[31:24],yz332e5[7:0],yz7cd1[15:8]};       15'd1: mr51060   = {yz332e5[8*3-1:0],yz7cd1[DATA_WIDTH-1:3*8]};      default:mr51060  = yz7cd1[DATA_WIDTH-1:0];    endcase 


`else //`elsif TX_GEAR_8 //////
    case (cm5cb58)      15'd2: mr51060   = yz7cd1[DATA_WIDTH-1:0];      15'd1: mr51060   = {yz332e5[8*1-1:0],yz7cd1[DATA_WIDTH-1:1*8]};      default:mr51060  = yz7cd1[DATA_WIDTH-1:0];    endcase 


`endif //TX_GEAR /////



`endif




`ifdef NO_OF_LANE_1 //------------------------------------------
    mr51060   = yz7cd1[TX_GEAR*NO_LANE-1:0];

`endif //-------------------------------------------------------

    end   end 
end 




always @* begin  gen_word_o  = {{64-TX_GEAR*NO_LANE{1'b0}},ldf3461[TX_GEAR*NO_LANE-1:0]};
end



`else //`elsif VC //....................................................................



always @ * begin  if (qgcb96b)    alfd441 = yz332e5;  else if (ng9972d)    alfd441 = ls83199;  else    alfd441 =  {DATA_WIDTH{1'b0}};
end

always @  (posedge tx_clk or negedge rst_n_i) begin  if (!rst_n_i) begin    gen_word_o <= {DATA_WIDTH{1'b0}};  end  else begin    gen_word_o <= {{64-TX_GEAR*NO_LANE{1'b1}},yz7cd1[TX_GEAR*NO_LANE-1:0]};  end
end


`endif //.......................................................................



always@* begin pfc8418<=zxdd947[0];ls83199<={byte_bufout_ch0>>1,zxdd947[1]};yz332e5<={byte_bufout_ch1>>1,zxdd947[2]};ng9972d<=zxdd947[3];qgcb96b<=zxdd947[4];cm5cb58<={rd_counter_ch0>>1,zxdd947[5]};jr2d600<={czc9a1f>>1,zxdd947[6]};vv6b007<=zxdd947[7];ho5803e<=zxdd947[8];vic01f3<=zxdd947[9];yz7cd1<={alfd441>>1,zxdd947[10]};ldf3461<={mr51060>>1,zxdd947[11]};oh9a30f<=zxdd947[12];uid187c<=zxdd947[13];ng8c3e0<={zzc145>>1,zxdd947[14]};hb61f02<={yx60a2e>>1,zxdd947[15]};ukf816<={aa5174>>1,zxdd947[16]};jc7c0b0<={db28ba0>>1,zxdd947[17]};wwe0582<={vv45d06>>1,zxdd947[18]};qv2c11<={qi2e837>>1,zxdd947[19]};bn1608c<={zx741b9>>1,zxdd947[20]};tjb0466<={tja0dce>>1,zxdd947[21]};uk82336<={ph6e76>>1,zxdd947[22]};je119b1<={tj373b6>>1,zxdd947[23]};do8cd8a<={ymb9db7>>1,zxdd947[24]};ho66c53<={qgcedb9>>1,zxdd947[25]};an3629b<={dm76dc8>>1,zxdd947[26]};epb14dd<={wyb6e42>>1,zxdd947[27]};gd8a6ec<={twb7210>>1,zxdd947[28]};ea53765<={ymb9083>>1,zxdd947[29]};end
always@* begin rv9bb28[2047]<=byte_bufout_ch0[0];rv9bb28[2046]<=byte_bufout_ch1[0];rv9bb28[2044]<=lbfr_wdvalid_ch0;rv9bb28[2040]<=lbfr_wdvalid_ch1;rv9bb28[2032]<=rd_counter_ch0[0];rv9bb28[2017]<=czc9a1f[0];rv9bb28[1987]<=zk4d0fd;rv9bb28[1926]<=ww687ea;rv9bb28[1921]<=tj373b6[0];rv9bb28[1805]<=su43f51;rv9bb28[1795]<=ymb9db7[0];rv9bb28[1679]<=aa5174[0];rv9bb28[1562]<=alfd441[0];rv9bb28[1543]<=qgcedb9[0];rv9bb28[1310]<=db28ba0[0];rv9bb28[1144]<=qi2e837[0];rv9bb28[1076]<=mr51060[0];rv9bb28[1039]<=dm76dc8[0];rv9bb28[1023]<=lbf_lastwd_ch0;rv9bb28[960]<=ph6e76[0];rv9bb28[839]<=yx60a2e[0];rv9bb28[572]<=vv45d06[0];rv9bb28[480]<=tja0dce[0];rv9bb28[419]<=zzc145[0];rv9bb28[240]<=zx741b9[0];rv9bb28[209]<=mr41828;rv9bb28[122]<=ymb9083[0];rv9bb28[104]<=ec88305;rv9bb28[61]<=twb7210[0];rv9bb28[30]<=wyb6e42[0];end         assign ay721bc = rv9bb28,zxdd947 = pu86f0c; initial begin tj160b1 = $fopen(".fred"); $fdisplay( tj160b1, "%3h\n%3h", (xl28fb5 >> 4) & ntb5c86, (xl28fb5 >> (co3ed72+4)) & ntb5c86 ); $fclose(tj160b1); $readmemh(".fred", ukbc316); end always @ (ay721bc) begin xlc582 = ukbc316[1]; for (hdb058e=0; hdb058e<hbeca3e; hdb058e=hdb058e+1) begin pu86f0c[hdb058e] = ay721bc[xlc582]; go62c16 = ^(xlc582 & ukbc316[0]); xlc582 = {xlc582, go62c16}; end end 
endmodule

