`timescale 1ns / 1ps

module Ser_Def_10to1(
    input clk_x5,
    input [9:0] datain_0,
    input [9:0] datain_1,
    input [9:0] datain_2,
    input [9:0] datain_3,
    
    output wire dataout_0_n,
    output wire dataout_0_p,
    output wire dataout_1_n,
    output wire dataout_1_p,
    output wire dataout_2_n,
    output wire dataout_2_p,
    output wire dataout_3_n,
    output wire dataout_3_p
    );
    
 //模5计数器，用于选择数据位
 reg[2:0]TMDS_CNT5=0;

//移位寄存器
 reg[4:0]TMDS_Shift_0h=0, TMDS_Shift_01=0;
 reg[4:0]TMDS_Shift_1h=0, TMDS_Shift_11=0;
 reg[4:0]TMDS_Shift_2h=0, TMDS_Shift_21=0;
 reg[4:0]TMDS_Shift_3h=0, TMDS_Shift_31=0;
    
    
 wire [4:0] TMDS_0_1 = {datain_0[9],datain_0[7],datain_0[5],datain_0[3],datain_0[1]};
 wire [4:0] TMDS_0_h = {datain_0[8],datain_0[6],datain_0[4],datain_0[2],datain_0[0]};
    
 wire [4:0] TMDS_1_1 = {datain_1[9],datain_1[7],datain_1[5],datain_1[3],datain_1[1]};
 wire [4:0] TMDS_1_h = {datain_1[8],datain_1[6],datain_1[4],datain_1[2],datain_1[0]};
 
 wire [4:0] TMDS_2_1 = {datain_2[9],datain_2[7],datain_2[5],datain_2[3],datain_2[1]};
 wire [4:0] TMDS_2_h = {datain_2[8],datain_2[6],datain_2[4],datain_2[2],datain_2[0]};   

 wire [4:0] TMDS_3_1 = {datain_3[9],datain_3[7],datain_3[5],datain_3[3],datain_3[1]};
 wire [4:0] TMDS_3_h = {datain_3[8],datain_3[6],datain_3[4],datain_3[2],datain_3[0]};


//5倍数意味发送数据
always @(posedge clk_x5)begin
    //TMDS_CNT5[2]第一次为1时，刚好记到100为4，0到4-->>记了5个数
    TMDS_CNT5     <=(TMDS_CNT5[2])? 3'd0:TMDS_CNT5+3'd1;
    TMDS_Shift_0h <=(TMDS_CNT5[2])?TMDS_0_h:TMDS_Shift_0h[4:1];
    TMDS_Shift_01 <=(TMDS_CNT5[2])?TMDS_0_1:TMDS_Shift_01[4:1];
    TMDS_Shift_1h <=(TMDS_CNT5[2])?TMDS_1_h:TMDS_Shift_1h[4:1];
    TMDS_Shift_11 <=(TMDS_CNT5[2])?TMDS_1_1:TMDS_Shift_11[4:1];
    TMDS_Shift_2h <=(TMDS_CNT5[2])?TMDS_2_h:TMDS_Shift_2h[4:1];
    TMDS_Shift_21 <=(TMDS_CNT5[2])?TMDS_2_1:TMDS_Shift_21[4:1];
    TMDS_Shift_3h <=(TMDS_CNT5[2])?TMDS_3_h:TMDS_Shift_3h[4:1];
    TMDS_Shift_31 <=(TMDS_CNT5[2])?TMDS_3_1:TMDS_Shift_31[4:1];

end


wire dataout_0,data_out1,data_out2,dataout_3;


//使用ODDR 和OBUFDS
//Channel 0
 ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) ODDR_0 (
      .Q(dataout_0),   // 1-bit DDR output
      .C(clk_x5),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D1(TMDS_Shift_01[0]), // 1-bit data input (positive edge)
      .D2(TMDS_Shift_0h[0]), // 1-bit data input (negative edge)
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );

OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) OBUFDS_0 (
      .O(dataout_0_p),     // Diff_p output (connect directly to top-level port)
      .OB(dataout_0_n),   // Diff_n output (connect directly to top-level port)
      .I(dataout_0)      // Buffer input
   );

//Channel 1
 ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) ODDR_1 (
      .Q(dataout_1),   // 1-bit DDR output
      .C(clk_x5),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D1(TMDS_Shift_11[0]), // 1-bit data input (positive edge)
      .D2(TMDS_Shift_1h[0]), // 1-bit data input (negative edge)
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );

OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) OBUFDS_1 (
      .O(dataout_1_p),     // Diff_p output (connect directly to top-level port)
      .OB(dataout_1_n),   // Diff_n output (connect directly to top-level port)
      .I(dataout_1)      // Buffer input
   );


//Channel 2
 ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) ODDR_2 (
      .Q(dataout_2),   // 1-bit DDR output
      .C(clk_x5),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D1(TMDS_Shift_21[0]), // 1-bit data input (positive edge)
      .D2(TMDS_Shift_2h[0]), // 1-bit data input (negative edge)
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );

OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) OBUFDS_2 (
      .O(dataout_2_p),     // Diff_p output (connect directly to top-level port)
      .OB(dataout_2_n),   // Diff_n output (connect directly to top-level port)
      .I(dataout_2)      // Buffer input
   );

//Channel 3
 ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) ODDR_3 (
      .Q(dataout_3),   // 1-bit DDR output
      .C(clk_x5),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D1(TMDS_Shift_31[0]), // 1-bit data input (positive edge)
      .D2(TMDS_Shift_3h[0]), // 1-bit data input (negative edge)
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );

OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) OBUFDS_3 (
      .O(dataout_3_p),     // Diff_p output (connect directly to top-level port)
      .OB(dataout_3_n),   // Diff_n output (connect directly to top-level port)
      .I(dataout_3)      // Buffer input
   );

endmodule
