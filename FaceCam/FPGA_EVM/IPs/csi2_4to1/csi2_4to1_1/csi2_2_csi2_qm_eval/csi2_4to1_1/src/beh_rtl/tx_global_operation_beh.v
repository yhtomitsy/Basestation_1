// tx_global_operation_beh.v generated by Lattice IP Model Creator version 1
// created on Thu, Dec  7, 2017  2:21:02 PM
// Copyright(c) 2007 Lattice Semiconductor Corporation. All rights reserved
// obfuscator_exe version 1.mar0807

// top














































`timescale 1 ns / 100 ps
module do1bb9a #(

  parameter CLK_MODE        = "HS_ONLY",  parameter LANE_WIDTH      = 4,  parameter DATA_WIDTH      = 16,  parameter GEAR_16         = 0,  parameter TX_FREQ_TGT     = 38,  parameter nt9e4e5 = 6,  parameter LPHS_FIFO_IMPL  = "LUT",  parameter T_DATPREP       = 2,  parameter T_DAT_HSZERO    = 3,  parameter T_CLKPOST       = 14,  parameter T_CLKPRE        = 1
)
(
  input                        reset_n,
  input                        core_clk,
  input                        nr5a064,


  input                        clk_hs_en_i,
  input                        d_hs_en_i,
  output wire                  d_hs_rdy_o,

 
  input [15:0]       nr64cff,
  input [15:0]       sj267fe,
  input [15:0]       gd33ff4,
  input [15:0]       wl9ffa4,
  
  output reg                   kqffd25,
  output reg                   fafe928,
  output reg                   rgf4942,
  output reg [1:0]             kfa4a13,
  output reg [1:0]             tw2509c,

  output reg                   c2d_ready_o, 


  output reg [15:0]  vi4271f,
  output reg [15:0]  tj138fb,
  output reg [15:0]  je9c7df,
  output reg [15:0]  nre3efb
);
localparam  TX_GEAR      = (GEAR_16==1) ? 16 : 8;
localparam UI4           = 4000/(TX_FREQ_TGT*TX_GEAR);
localparam UI12          = 12000/(TX_FREQ_TGT*TX_GEAR);
localparam UI10          = 10000/(TX_FREQ_TGT*TX_GEAR);
localparam UI52          = 52000/(TX_FREQ_TGT*TX_GEAR);
localparam  BYTECLK_NS   = 1000/TX_FREQ_TGT;
localparam  zk7385b = ((60+UI4)/BYTECLK_NS) + 1;
localparam  xyb69b = TX_FREQ_TGT < 60 ? zk7385b :                                              (105 + UI12)*TX_FREQ_TGT/1000;
parameter [5:0] uidb8a6        = (50/BYTECLK_NS) + 1;
parameter [5:0] mre298d    = TX_FREQ_TGT < 22 ? 1  : (50/BYTECLK_NS) + 1;
parameter [5:0]	co31b50 = (250/BYTECLK_NS) +1;
parameter [5:0]	ww6d409   = 60/BYTECLK_NS +2 ;
parameter [5:0] bl5024c    = 100/BYTECLK_NS +1;
parameter [5:0]	fp933e     = (50/BYTECLK_NS) + 1;

`ifdef DSI2DSI
parameter [5:0]	ww4cfb1   = 1;

`else
parameter [5:0]	ww4cfb1   = zk7385b +1;

`endif
parameter [5:0] hbf6248    = 100/BYTECLK_NS +1;
parameter [3:0] ls8923c   = 4'd0;
parameter [3:0] os491e2   = 4'd1;
parameter [3:0] ne48f10   = 4'd2;
parameter [3:0] jc47883 = 4'd3;
parameter [3:0] wl3c41a    = 4'd4;
parameter [3:0] yxe20d4   = 4'd5;
parameter [3:0] aa106a4   = 4'd6;
parameter [3:0] ng83521  = 4'd7;
parameter [3:0] ec1a90b   = 4'd8;
parameter [3:0] wwd4859   = 4'd0;
parameter [3:0] epa42c8   = 4'd1;
parameter [3:0] aa21645   = 4'd2;
parameter [3:0] vkb229 = 4'd3;
parameter [3:0] ui5914b  = 4'd4;
parameter [3:0] xjc8a59  = 4'd7;
parameter [3:0] nr452cf   = 4'd8;
parameter [3:0] cb2967e  = 4'd9;
reg  [63:0] qt4b3f5;
wire [63:0] go59fad;
reg  [15:0] jccfd68, bl7eb42,kqf5a16;
reg         fcad0b1;
wire    me6858b;
wire    rg42c59;
wire    jr162ca;
wire    epb1656;
wire [63:0] hd8b2b4;
wire [63:0] me595a7	= {nr64cff,sj267fe,gd33ff4,wl9ffa4};
wire [63:0] sj3946a;
reg     rgca354;
reg     qt51aa3;
reg     gq8d51c;
reg     cz6a8e0;
reg     qt54705;
reg     ksa382d;
reg     zz1c169;
reg     ice0b4f;
reg     co5a78;
reg     xl2d3c1;
reg     by69e0f;
reg     fn4f07a;
reg     ww783d7;
reg     wwc1eb8;
reg     ymf5c1;
reg     uv7ae09;
reg     jpd704c;
reg [1:0]     dob8266;
reg     ayc1332;
reg [3:0]     db9990;
reg [3:0]     go4cc87;
reg [5:0]     fa66439;
reg                  hd321ca;
reg     ir90e57;
reg     uk872bc;
reg     kf395e1;
reg     facaf0c;
reg     tu57862;
reg [1:0]     iebc313;
reg     pse1898;
reg     jrc4c2;
reg     yk62616;
reg     db130b0;
reg     gq98586;
reg     pfc2c31;
reg     tj1618e;
reg     hdb0c76;
reg     hq863b7;
reg             ie31dbb;
reg             rv8edd9;
reg [3:0]     lq76ece;
reg [3:0]     jeb7672;
reg [5:0]     yzbb393;
reg     shd9c9d;
reg     ayce4ec;
wire                 ic72761;
reg                  pu93b09;
reg                  co9d84b;
reg                  fnec258;
reg                  pf612c7;
reg [16:0] nt963f,gb4b1fe,fa58ff5,dzc7faa;
reg zm3fd56;
reg vifeab2;
reg osf5592;
reg [15 : 0] jraac90;
reg [15 : 0] su56487;
reg [15 : 0] xyb2438;
reg [15 : 0] ec921c3;
reg [63 : 0] qv90e18;
reg [63 : 0] gq870c4;
reg [15 : 0] db38621;
reg [15 : 0] czc310e;
reg [15 : 0] wl18875;
reg goc43ac;
reg wy21d60;
reg lseb00;
reg qt75802;
reg aaac015;
reg [63 : 0] al600a9;
reg [63 : 0] uk54d;
reg [63 : 0] gd2a68;
reg wy15344;
reg gqa9a21;
reg rg4d108;
reg kq68842;
reg yx44210;
reg ks21084;
reg yz8421;
reg ps4210c;
reg uk10863;
reg ph84318;
reg qi218c6;
reg rvc630;
reg lq63186;
reg cb18c32;
reg enc6194;
reg ls30ca5;
reg ng8652b;
reg [1 : 0] hd3295b;
reg fp94ade;
reg [3 : 0] zza56f6;
reg [3 : 0] mg2b7b7;
reg [5 : 0] of5bdb8;
reg ykdedc5;
reg dzf6e29;
reg xyb714e;
reg fcb8a73;
reg vic539b;
reg oh29cda;
reg [1 : 0] en4e6d4;
reg ps736a5;
reg vx9b52b;
reg zkda95e;
reg icd4af3;
reg xla5798;
reg wy2bcc7;
reg uv5e639;
reg thf31cc;
reg ym98e67;
reg zxc7338;
reg yz399c7;
reg [3 : 0] shcce3d;
reg [3 : 0] ww671ed;
reg [5 : 0] nt38f68;
reg jpc7b47;
reg xl3da3e;
reg kded1f7;
reg ay68fbd;
reg vi47de8;
reg mg3ef42;
reg wjf7a10;
reg [16 : 0] twbd084;
reg [16 : 0] ale8422;
reg [16 : 0] zk42115;
reg [16 : 0] wy108ab;
reg [2047:0] fp84558;
wire [73:0] rv22ac6;

`ifdef DSI2DSI

`else

`endif

localparam aa15637 = 74,ohab1b9 = 32'hfdffc68b;
localparam [31:0] dm58dcc = ohab1b9;
localparam vx37314 = ohab1b9 & 4'hf;
localparam [11:0] qtcc539 = 'h7ff;
wire [(1 << vx37314) -1:0] ls14e61;
reg [aa15637-1:0] oh39852;
reg [vx37314-1:0] fn614ac [0:1];
reg [vx37314-1:0] vi52b39;
reg an959cb;
integer ieace5c;
integer go672e0;


`ifdef DSI2DSI


`else


`endif



































`ifdef DSI2DSI



`else



`endif



















generate  if (CLK_MODE == "HS_ONLY") begin: kqcb804    assign ic72761 = ww783d7 & fnec258;  end  else begin: xy4049    assign ic72761 = lq63186;  end
endgenerate


always @(posedge core_clk or negedge reset_n) begin  if (!reset_n) begin    fnec258 <= 1'b0;  end    else if (ay68fbd) begin    fnec258 <= 1'b0;  end  else if (osf5592) begin    fnec258 <= 1'b1;  end  
end 

always @(posedge core_clk or negedge reset_n) begin  if (!reset_n) begin    pf612c7 <= 1'b0;  end  else begin  if (vifeab2)    pf612c7 <= 1'b1;  else if (lq63186)     pf612c7 <= 1'b0;  end
end






assign d_hs_rdy_o = ay68fbd;











































       


always @* begin  vi4271f = yz399c7 ? 16'h0000: vi47de8 ? twbd084 : uk54d[63:48];  tj138fb = yz399c7 ? 16'h0000: vi47de8 ? ale8422 : uk54d[47:32];  je9c7df = yz399c7 ? 16'h0000: vi47de8 ? zk42115 : uk54d[31:16];  nre3efb = yz399c7 ? 16'h0000: vi47de8 ? wy108ab : uk54d[15:0] ;
end
always @(posedge core_clk or negedge reset_n) begin  if (!reset_n) begin    nt963f <= 16'h0000;	gb4b1fe <= 16'h0000;	fa58ff5 <= 16'h0000;	dzc7faa <= 16'h0000;  end  else begin    nt963f <= vi4271f;	gb4b1fe <= tj138fb;	fa58ff5 <= je9c7df;	dzc7faa <= nre3efb;  end
end

always @* begin  kqffd25  = fp94ade;  kfa4a13  = hd3295b;  tw2509c  = en4e6d4;
end


always @* begin  rgca354   = 1'b0;  qt51aa3   = 1'b0;  gq8d51c   = 1'b0;  cz6a8e0   = 1'b0;  qt54705   = 1'b0;  ksa382d   = 1'b0;  zz1c169   = 1'b0;
  ice0b4f   = 1'b0;  co5a78   = 1'b0;
  xl2d3c1    = 1'b0;  by69e0f   = 1'b0;  fn4f07a    = 1'b0;  ww783d7    = 1'b0;  wwc1eb8   = 1'b0;  ymf5c1    = 1'b0;  uv7ae09    = 1'b0;  jpd704c    = 1'b0;
  dob8266      = 2'b11;  fafe928   = 1'b0;  ayc1332      = 1'b1;  db9990   = mg2b7b7;
case (mg2b7b7)
  ls8923c: begin    dob8266 = 2'b11;    if (wjf7a10) begin      ksa382d   = 1'b1;      ice0b4f = 1'b1;      db9990 = os491e2;    end  end    os491e2: begin    dob8266   = 2'b01;    ice0b4f  = 1'b1;    if (ykdedc5) begin      qt54705   = 1'b1;      db9990 = ne48f10;    end  end    ne48f10: begin    dob8266   = 2'b00;    ice0b4f  = 1'b1;    if (dzf6e29) begin      cz6a8e0     = 1'b1;      db9990  = jc47883;    end  end    jc47883: begin    dob8266   = 2'b01;    ice0b4f  = 1'b1;    fafe928  = 1'b1;    ayc1332   = 1'b1;    if (xyb714e) begin      co5a78   = 1'b1;      zz1c169     = 1'b1;      db9990  = wl3c41a;    end  end    wl3c41a : begin    dob8266   = 2'b01;    ice0b4f  = 1'b1;    fafe928  = 1'b1;    ayc1332   = 1'b0;    if (of5bdb8 == 6'h00) begin      db9990  = yxe20d4;    end  end
      yxe20d4 : begin    dob8266   = 2'b01;    ice0b4f  = 1'b1;    fafe928  = 1'b1;    ayc1332   = 1'b0;    ww783d7 = 1'b1;
    if (CLK_MODE=="HS_ONLY") begin      db9990 = yxe20d4;    end    else if (icd4af3) begin       gq8d51c   = 1'b1;      db9990  = aa106a4;    end  end          aa106a4 : begin    dob8266    = 2'b01;    fn4f07a  = 1'b1;    ice0b4f   = 1'b1;    fafe928   = 1'b1;    ayc1332    = 1'b0;
    if (vifeab2 || mg3ef42)        db9990 = yxe20d4;    else if (fcb8a73) begin      qt51aa3  = 1'b1;      db9990 = ng83521;    end  end          ng83521: begin    dob8266     = 2'b01;    fafe928    = 1'b1;    ayc1332     = 1'b1;    by69e0f  = 1'b1;    ice0b4f    = 1'b1;    if (vic539b) begin      rgca354    = 1'b1;      db9990  = ec1a90b;    end  end
      ec1a90b: begin    dob8266     = 2'b11;    xl2d3c1   = 1'b1;    ice0b4f    = 1'b1;    if (oh29cda) begin      db9990     = ls8923c;    end  end  default: begin    db9990  = ls8923c;  end
endcase 
end 

always @(posedge core_clk or negedge reset_n) begin  if (!reset_n) begin    go4cc87 <= ls8923c;  end  else begin    go4cc87 <= zza56f6;  end
end


always @(posedge core_clk or negedge reset_n) begin  if (!reset_n) begin    fa66439 <= 6'h00;  end  else begin    if (ps4210c) begin      case(1'b1)        ks21084 : fa66439 <= uidb8a6;        yx44210 : fa66439 <= mre298d;        kq68842  : fa66439 <= co31b50;        yz8421  : fa66439 <= T_CLKPRE;        rg4d108 : fa66439 <= T_CLKPOST;        gqa9a21: fa66439 <= ww6d409;        wy15344 : fa66439 <= bl5024c;        default    : fa66439 <= of5bdb8 - 1;      endcase     end     else begin      fa66439 <= 6'h00;    end  end
end 
always @* begin  hd321ca  = of5bdb8 == 6'h01;  ir90e57  = of5bdb8 == 6'h01;  uk872bc   = of5bdb8 == 6'h01;  kf395e1  = of5bdb8 == 6'h01;  facaf0c = of5bdb8 == 6'h01;  tu57862  = of5bdb8 == 6'h01;
end


always @* begin  c2d_ready_o  = 1'b1;  iebc313  = 2'b11;  pse1898  = 1'b0;  rgf4942  = 1'b0;  jrc4c2  = 1'b0;  yk62616  = 1'b0;
  gq98586  = 1'b0;  pfc2c31  = 1'b0;  tj1618e  = 1'b0;  hdb0c76  = 1'b0;  hq863b7  = 1'b0;  rv8edd9      = 1'b0;  ie31dbb   = 1'b0;  ayce4ec      = 1'b0;
  lq76ece  = ww671ed;
  pu93b09    = 1'b0;  co9d84b      = 1'b0;  case (ww671ed)  wwd4859: begin    c2d_ready_o   = 1'b1;    iebc313   = 2'b11;    if (kded1f7) begin      gq98586  = 1'b1;      pse1898= 1'b1;      lq76ece= epa42c8;    end  end  epa42c8: begin    iebc313   = 2'b01;    pse1898  = 1'b1;    rv8edd9    = 1'b1;    if (jpc7b47) begin      pfc2c31    = 1'b1;      lq76ece  = aa21645;    end  end  aa21645: begin    iebc313   = 2'b00;    pse1898  = 1'b1;    rv8edd9    = 1'b1;    if (jpc7b47) begin      tj1618e     = 1'b1;      lq76ece  = vkb229;    end  end
    vkb229: begin    iebc313   = 2'b01;    rv8edd9    = 1'b1;    rgf4942  = 1'b1;    pse1898  = 1'b1;    c2d_ready_o   = 1'b0;    if (jpc7b47) begin

      lq76ece  =  cb2967e;    end  end
  cb2967e: begin    iebc313   = 2'b01;    rv8edd9    = 1'b1;    rgf4942  = 1'b1;    pse1898  = 1'b1;    c2d_ready_o   = 1'b0;
    pu93b09    = 1'b1;    if (zm3fd56) begin      lq76ece  =  ui5914b;    end  end  ui5914b: begin    iebc313     = 2'b01;    rgf4942    = 1'b1;    c2d_ready_o     = 1'b0;
    pu93b09      = 1'b1;

    if (!zm3fd56) begin      pse1898  = 1'b1;      hdb0c76   = 1'b1;      lq76ece  = xjc8a59;    end  end
  xjc8a59: begin    iebc313   = 2'b01;    rgf4942  = 1'b1;    pse1898  = 1'b1;    c2d_ready_o   = 1'b0;
    co9d84b      = 1'b1;    if (jpc7b47) begin      yk62616  = 1'b1;      hq863b7    = 1'b1;
      lq76ece  = nr452cf;      co9d84b      = 1'b0;    end  end  nr452cf: begin    iebc313    = 2'b11;    ie31dbb  = 1'b1;    pse1898   = 1'b1;    c2d_ready_o    = 1'b0;     if (jpc7b47) begin       lq76ece  = wwd4859;    end  end  default: begin    lq76ece = wwd4859;  end  endcase 
end 

always @(posedge core_clk or negedge reset_n) begin  if (!reset_n) begin    jeb7672 <= wwd4859;  end  else begin    jeb7672 <= shcce3d;  end
end

always @(posedge core_clk or negedge reset_n) begin  if (!reset_n) begin    db130b0 <= 1'b0;  end  else begin    db130b0 <= zkda95e;  end
end

always @(posedge core_clk or negedge reset_n) begin  if (!reset_n) begin    yzbb393 <= 6'h00;  end  else begin    if (ps736a5) begin      case(1'b1)        xla5798 : yzbb393 <= uidb8a6;        wy2bcc7 : yzbb393 <= T_DATPREP;        uv5e639  : yzbb393 <= T_DAT_HSZERO;              thf31cc: yzbb393 <= ww4cfb1;        ym98e67 : yzbb393 <= hbf6248;        default    : yzbb393 <= nt38f68 - 1;      endcase     end     else begin      yzbb393 <= 6'h00;    end  end
end



always @* begin  shd9c9d = (nt38f68 == 6'h01);
end




always@* begin zm3fd56<=rv22ac6[0];vifeab2<=rv22ac6[1];osf5592<=rv22ac6[2];jraac90<={nr64cff>>1,rv22ac6[3]};su56487<={sj267fe>>1,rv22ac6[4]};xyb2438<={gd33ff4>>1,rv22ac6[5]};ec921c3<={wl9ffa4>>1,rv22ac6[6]};qv90e18<={qt4b3f5>>1,rv22ac6[7]};gq870c4<={go59fad>>1,rv22ac6[8]};db38621<={jccfd68>>1,rv22ac6[9]};czc310e<={bl7eb42>>1,rv22ac6[10]};wl18875<={kqf5a16>>1,rv22ac6[11]};goc43ac<=rv22ac6[12];wy21d60<=rv22ac6[13];lseb00<=rv22ac6[14];qt75802<=rv22ac6[15];aaac015<=rv22ac6[16];al600a9<={hd8b2b4>>1,rv22ac6[17]};uk54d<={me595a7>>1,rv22ac6[18]};gd2a68<={sj3946a>>1,rv22ac6[19]};wy15344<=rv22ac6[20];gqa9a21<=rv22ac6[21];rg4d108<=rv22ac6[22];kq68842<=rv22ac6[23];yx44210<=rv22ac6[24];ks21084<=rv22ac6[25];yz8421<=rv22ac6[26];ps4210c<=rv22ac6[27];uk10863<=rv22ac6[28];ph84318<=rv22ac6[29];qi218c6<=rv22ac6[30];rvc630<=rv22ac6[31];lq63186<=rv22ac6[32];cb18c32<=rv22ac6[33];enc6194<=rv22ac6[34];ls30ca5<=rv22ac6[35];ng8652b<=rv22ac6[36];hd3295b<={dob8266>>1,rv22ac6[37]};fp94ade<=rv22ac6[38];zza56f6<={db9990>>1,rv22ac6[39]};mg2b7b7<={go4cc87>>1,rv22ac6[40]};of5bdb8<={fa66439>>1,rv22ac6[41]};ykdedc5<=rv22ac6[42];dzf6e29<=rv22ac6[43];xyb714e<=rv22ac6[44];fcb8a73<=rv22ac6[45];vic539b<=rv22ac6[46];oh29cda<=rv22ac6[47];en4e6d4<={iebc313>>1,rv22ac6[48]};ps736a5<=rv22ac6[49];vx9b52b<=rv22ac6[50];zkda95e<=rv22ac6[51];icd4af3<=rv22ac6[52];xla5798<=rv22ac6[53];wy2bcc7<=rv22ac6[54];uv5e639<=rv22ac6[55];thf31cc<=rv22ac6[56];ym98e67<=rv22ac6[57];zxc7338<=rv22ac6[58];yz399c7<=rv22ac6[59];shcce3d<={lq76ece>>1,rv22ac6[60]};ww671ed<={jeb7672>>1,rv22ac6[61]};nt38f68<={yzbb393>>1,rv22ac6[62]};jpc7b47<=rv22ac6[63];xl3da3e<=rv22ac6[64];kded1f7<=rv22ac6[65];ay68fbd<=rv22ac6[66];vi47de8<=rv22ac6[67];mg3ef42<=rv22ac6[68];wjf7a10<=rv22ac6[69];twbd084<={nt963f>>1,rv22ac6[70]};ale8422<={gb4b1fe>>1,rv22ac6[71]};zk42115<={fa58ff5>>1,rv22ac6[72]};wy108ab<={dzc7faa>>1,rv22ac6[73]};end
always@* begin fp84558[2047]<=clk_hs_en_i;fp84558[2046]<=d_hs_en_i;fp84558[2044]<=nr64cff[0];fp84558[2040]<=sj267fe[0];fp84558[2032]<=gd33ff4[0];fp84558[2017]<=wl9ffa4[0];fp84558[1987]<=qt4b3f5[0];fp84558[1980]<=pse1898;fp84558[1963]<=wwc1eb8;fp84558[1942]<=pfc2c31;fp84558[1926]<=go59fad[0];fp84558[1921]<=cz6a8e0;fp84558[1913]<=jrc4c2;fp84558[1903]<=hd321ca;fp84558[1879]<=ymf5c1;fp84558[1872]<=ic72761;fp84558[1837]<=tj1618e;fp84558[1805]<=jccfd68[0];fp84558[1795]<=qt54705;fp84558[1783]<=facaf0c;fp84558[1778]<=yk62616;fp84558[1770]<=yzbb393[0];fp84558[1758]<=ir90e57;fp84558[1710]<=uv7ae09;fp84558[1696]<=pu93b09;fp84558[1679]<=epb1656;fp84558[1627]<=hdb0c76;fp84558[1562]<=bl7eb42[0];fp84558[1543]<=ksa382d;fp84558[1519]<=tu57862;fp84558[1509]<=db130b0;fp84558[1499]<=go4cc87[0];fp84558[1492]<=shd9c9d;fp84558[1469]<=uk872bc;fp84558[1466]<=lq76ece[0];fp84558[1398]<=ayc1332;fp84558[1373]<=jpd704c;fp84558[1344]<=co9d84b;fp84558[1310]<=hd8b2b4[0];fp84558[1280]<=pf612c7;fp84558[1207]<=hq863b7;fp84558[1144]<=sj3946a[0];fp84558[1076]<=kqf5a16[0];fp84558[1039]<=zz1c169;fp84558[1026]<=gb4b1fe[0];fp84558[1023]<=nr5a064;fp84558[990]<=iebc313[0];fp84558[981]<=ww783d7;fp84558[971]<=gq98586;fp84558[960]<=gq8d51c;fp84558[951]<=fa66439[0];fp84558[936]<=ayce4ec;fp84558[891]<=kf395e1;fp84558[885]<=jeb7672[0];fp84558[839]<=jr162ca;fp84558[749]<=db9990[0];fp84558[733]<=rv8edd9;fp84558[699]<=dob8266[0];fp84558[640]<=fnec258;fp84558[572]<=me595a7[0];fp84558[513]<=nt963f[0];fp84558[490]<=fn4f07a;fp84558[480]<=qt51aa3;fp84558[419]<=rg42c59;fp84558[366]<=ie31dbb;fp84558[245]<=by69e0f;fp84558[240]<=rgca354;fp84558[209]<=me6858b;fp84558[122]<=xl2d3c1;fp84558[104]<=fcad0b1;fp84558[61]<=co5a78;fp84558[30]<=ice0b4f;fp84558[10]<=dzc7faa[0];fp84558[5]<=fa58ff5[0];end         assign ls14e61 = fp84558,rv22ac6 = oh39852; initial begin ieace5c = $fopen(".fred"); $fdisplay( ieace5c, "%3h\n%3h", (dm58dcc >> 4) & qtcc539, (dm58dcc >> (vx37314+4)) & qtcc539 ); $fclose(ieace5c); $readmemh(".fred", fn614ac); end always @ (ls14e61) begin vi52b39 = fn614ac[1]; for (go672e0=0; go672e0<aa15637; go672e0=go672e0+1) begin oh39852[go672e0] = ls14e61[vi52b39]; an959cb = ^(vi52b39 & fn614ac[0]); vi52b39 = {vi52b39, an959cb}; end end 
endmodule















































`timescale 1 ns / 100 ps
module tx_global_operation #(

parameter CLK_MODE = "HS_ONLY",
parameter  LANE_WIDTH   = 4,	
parameter  DATA_WIDTH   = 16,
parameter  GEAR_16      = 0,
parameter  TX_FREQ_TGT  = 8'd112,
parameter  TX_GEAR      = (GEAR_16==1) ? 16 : 8,

parameter  BYTECLK_NS   = 1000/TX_FREQ_TGT, 

parameter UI4   = 4000/(TX_FREQ_TGT*TX_GEAR),
parameter UI12  = 12000/(TX_FREQ_TGT*TX_GEAR),
parameter UI10  = 10000/(TX_FREQ_TGT*TX_GEAR),
parameter UI52  = 52000/(TX_FREQ_TGT*TX_GEAR),



`ifdef T_DATPREP
parameter T_DATPREP        = `T_DATPREP,

`else
parameter T_DATPREP  = ((41+UI4)/BYTECLK_NS) + 2, 
`endif



`ifdef T_DAT_HSZERO
parameter T_DAT_HSZERO = `T_DAT_HSZERO,

`else
parameter T_DAT_HSZERO = ((145+UI10)/BYTECLK_NS)- ((41+UI4)/BYTECLK_NS),
`endif




`ifdef T_CLKPOST
parameter T_CLKPOST          = `T_CLKPOST,

`else

`ifdef CSI2CSI //---------
parameter T_CLKPOST    = ((60 + UI52)/BYTECLK_NS) > 13 ? 
                                        ((60 + UI52)/BYTECLK_NS) + 1 : 14 ,
   `else  //-----------------
parameter T_CLKPOST    = ((60 + UI52)/BYTECLK_NS) + 1,
   `endif //-----------------
`endif



`ifdef T_CLKPRE
parameter T_CLKPRE        = `T_CLKPRE,

`else
parameter T_CLKPRE        = 1,

`endif

parameter LPHS_FIFO_IMPL = "LUT"
) (


  input clk_hs_en_i,
  input d_hs_en_i,
  output d_hs_rdy_o,

    
  input      reset_n,
  input      core_clk,
  
  
  input                    dphy_pkten_i,
  input [4*DATA_WIDTH-1:0] dphy_pkt_i,
  
  
  
  output                   hs_clk_gate_en_o,
  output                   hs_clk_en_o,
  output                   hs_data_en_o,
`ifdef NUM_TX_LANE_4
  output  [DATA_WIDTH-1:0] hs_data_d3_o,
  output  [DATA_WIDTH-1:0] hs_data_d2_o,
  output  [DATA_WIDTH-1:0] hs_data_d1_o,
  output  [DATA_WIDTH-1:0] hs_data_d0_o,
`endif
`ifdef NUM_TX_LANE_3
  output  [DATA_WIDTH-1:0] hs_data_d2_o,
  output  [DATA_WIDTH-1:0] hs_data_d1_o,
  output  [DATA_WIDTH-1:0] hs_data_d0_o,
`endif
`ifdef NUM_TX_LANE_2
  output  [DATA_WIDTH-1:0] hs_data_d1_o,
  output  [DATA_WIDTH-1:0] hs_data_d0_o,
`endif
`ifdef NUM_TX_LANE_1
  output  [DATA_WIDTH-1:0] hs_data_d0_o,
`endif	

  output                   c2d_ready_o,
 
  
  output                   lp_clk_en_o,
  output                   lp_clk_p_o,
  output                   lp_clk_n_o,
  output                   lp_data_en_o,
  output                   lp_data_p_o,
  output                   lp_data_n_o
)  ;
localparam DELAY = (TX_FREQ_TGT > 0 && TX_FREQ_TGT < 34)     ? 2 :                   (TX_FREQ_TGT >= 34 && TX_FREQ_TGT < 45)   ? 3 :                   (TX_FREQ_TGT >= 45 && TX_FREQ_TGT < 60)   ? 4 :                   (TX_FREQ_TGT >= 60 && TX_FREQ_TGT < 75)   ? 5 :                   (TX_FREQ_TGT >= 75 && TX_FREQ_TGT < 90)   ? 6 :                   (TX_FREQ_TGT >= 90 && TX_FREQ_TGT < 105)  ? 7 :                   (TX_FREQ_TGT >= 105 && TX_FREQ_TGT < 120) ? 8 : 9;

`ifdef NUM_TX_LANE_4

`endif

`ifdef NUM_TX_LANE_3

`endif

`ifdef NUM_TX_LANE_2

`endif

`ifdef NUM_TX_LANE_1

`endif

`ifdef NUM_TX_LANE_4

`endif

`ifdef NUM_TX_LANE_3

`endif	

`ifdef NUM_TX_LANE_2

`endif	

`ifdef NUM_TX_LANE_1

`endif
reg vifeab2;
reg osf5592;
reg aa21d3a;
reg rie9d0;
reg nr74e82;
reg [4 * DATA_WIDTH - 1 : 0] pu3a0ba;
reg [2047:0] fp84558;
wire [5:0] rv22ac6;


`ifdef NUM_TX_LANE_4

`endif

`ifdef NUM_TX_LANE_3

`endif

`ifdef NUM_TX_LANE_2

`endif

`ifdef NUM_TX_LANE_1

`endif

`ifdef NUM_TX_LANE_4

`endif

`ifdef NUM_TX_LANE_3

`endif	

`ifdef NUM_TX_LANE_2

`endif	

`ifdef NUM_TX_LANE_1

`endif

localparam aa15637 = 6,ohab1b9 = 32'hfdffc68b;
localparam [31:0] dm58dcc = ohab1b9;
localparam vx37314 = ohab1b9 & 4'hf;
localparam [11:0] qtcc539 = 'h7ff;
wire [(1 << vx37314) -1:0] ls14e61;
reg [aa15637-1:0] oh39852;
reg [vx37314-1:0] fn614ac [0:1];
reg [vx37314-1:0] vi52b39;
reg an959cb;
integer ieace5c;
integer go672e0;


`ifdef NUM_TX_LANE_4


`endif


`ifdef NUM_TX_LANE_3


`endif


`ifdef NUM_TX_LANE_2


`endif


`ifdef NUM_TX_LANE_1


`endif


`ifdef NUM_TX_LANE_4


`endif


`ifdef NUM_TX_LANE_3


`endif	


`ifdef NUM_TX_LANE_2


`endif	


`ifdef NUM_TX_LANE_1


`endif



assign lp_clk_en_o = ~hs_clk_en_o;
assign lp_data_en_o = ~hs_data_en_o;


  do1bb9a #(
    .CLK_MODE        (CLK_MODE),    .LANE_WIDTH      (LANE_WIDTH),    .DATA_WIDTH      (DATA_WIDTH),    .GEAR_16         (GEAR_16),    .TX_FREQ_TGT     (TX_FREQ_TGT),    .nt9e4e5 (DELAY),    .LPHS_FIFO_IMPL  (LPHS_FIFO_IMPL),    .T_DATPREP       (T_DATPREP),    .T_DAT_HSZERO    (T_DAT_HSZERO),    .T_CLKPOST       (T_CLKPOST),    .T_CLKPRE        (T_CLKPRE)  )  bl4a802  (    .reset_n           (aa21d3a),    .core_clk          (rie9d0),
    .nr5a064             (nr74e82),
    .clk_hs_en_i       (vifeab2),    .d_hs_en_i         (osf5592),    .d_hs_rdy_o        (d_hs_rdy_o),


`ifdef NUM_TX_LANE_4
    .nr64cff        (pu3a0ba[63:48]),    .sj267fe        (pu3a0ba[47:32]),    .gd33ff4        (pu3a0ba[31:16]),    .wl9ffa4        (pu3a0ba[15:0]),


`endif



`ifdef NUM_TX_LANE_3
    .nr64cff        (16'h0),    .sj267fe        (pu3a0ba[47:32]),    .gd33ff4        (pu3a0ba[31:16]),    .wl9ffa4        (pu3a0ba[15:0]),


`endif



`ifdef NUM_TX_LANE_2
    .nr64cff        (16'h0),    .sj267fe        (16'h0),    .gd33ff4        (pu3a0ba[31:16]),    .wl9ffa4        (pu3a0ba[15:0]),


`endif



`ifdef NUM_TX_LANE_1
    .nr64cff        (16'h0),    .sj267fe        (16'h0),    .gd33ff4        (16'h0),    .wl9ffa4        (pu3a0ba[15:0]),


`endif
    .kqffd25    (hs_clk_gate_en_o),    .fafe928         (hs_clk_en_o),    .rgf4942        (hs_data_en_o),    .kfa4a13            ({lp_clk_p_o,lp_clk_n_o}),    .tw2509c           ({lp_data_p_o,lp_data_n_o}),    .c2d_ready_o       (c2d_ready_o),


`ifdef NUM_TX_LANE_4
    .vi4271f       (hs_data_d3_o),    .tj138fb       (hs_data_d2_o),    .je9c7df       (hs_data_d1_o),


`endif



`ifdef NUM_TX_LANE_3
    .vi4271f       (),    .tj138fb       (hs_data_d2_o),    .je9c7df       (hs_data_d1_o),


`endif	



`ifdef NUM_TX_LANE_2
    .vi4271f       (),    .tj138fb       (),    .je9c7df       (hs_data_d1_o),


`endif	



`ifdef NUM_TX_LANE_1
    .vi4271f       (),    .tj138fb       (),    .je9c7df       (),


`endif
    .nre3efb       (hs_data_d0_o)  );









always@* begin vifeab2<=rv22ac6[0];osf5592<=rv22ac6[1];aa21d3a<=rv22ac6[2];rie9d0<=rv22ac6[3];nr74e82<=rv22ac6[4];pu3a0ba<={dphy_pkt_i>>1,rv22ac6[5]};end
always@* begin fp84558[2047]<=d_hs_en_i;fp84558[2046]<=reset_n;fp84558[2044]<=core_clk;fp84558[2040]<=dphy_pkten_i;fp84558[2032]<=dphy_pkt_i[0];fp84558[1023]<=clk_hs_en_i;end         assign ls14e61 = fp84558,rv22ac6 = oh39852; initial begin ieace5c = $fopen(".fred"); $fdisplay( ieace5c, "%3h\n%3h", (dm58dcc >> 4) & qtcc539, (dm58dcc >> (vx37314+4)) & qtcc539 ); $fclose(ieace5c); $readmemh(".fred", fn614ac); end always @ (ls14e61) begin vi52b39 = fn614ac[1]; for (go672e0=0; go672e0<aa15637; go672e0=go672e0+1) begin oh39852[go672e0] = ls14e61[vi52b39]; an959cb = ^(vi52b39 & fn614ac[0]); vi52b39 = {vi52b39, an959cb}; end end 
endmodule

