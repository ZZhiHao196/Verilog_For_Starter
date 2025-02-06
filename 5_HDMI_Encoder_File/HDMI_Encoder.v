`timescale 1ns / 1ps

module HDMI_Encoder(
    //输入全局控制信号
    input pixelclk,
    input pixelclk_x5,
    input rst_p,
    
    //输入显示数据
    input [7:0]blue_din,
    input [7:0]green_din,
    input [7:0]red_din,
    
    //输入显示控制信号
    input hsync,
    input vsync,
    input de,
    
    //输出
    output tdms_clk_p,
    output tdms_clk_n,
    output [2:0] tmds_data_p,
    output [2:0] tmds_data_n
    );
    
wire [9:0]red;
wire [9:0]green;
wire [9:0]blue;

//调用模块
Encode  encb(
   .clk(pixel_clk),    //像素时钟
   .rst_p(rst_p),
   .din(blue_din),
   .c0(hsync),    //控制信号
   .c1(vsync),
   .de(de),  //数据使能
   .dout(blue)   //数据输出
);    
  
Encode  encg(
   .clk(pixel_clk),    //像素时钟
   .rst_p(rst_p),
   .din(green_din),
   .c0(1'b0),    //控制信号
   .c1(1'b0),
   .de(de),  //数据使能
   .dout(green)   //数据输出
);    
Encode  encr(
   .clk(pixel_clk),    //像素时钟
   .rst_p(rst_p),
   .din(red_din),
   .c0(1'b0),    //控制信号
   .c1(1'b0),
   .de(de),  //数据使能
   .dout(red)   //数据输出
);      
Ser_Def_10to1  HDMI_Sender(
  .clk_x5(pixelclk_x5),              
  .datain_0(blue),      
  .datain_1(green),      
  .datain_2(red),      
  .datain_3(10'b11111_00000),      
  .dataout_0_n(tmds_data_p[0]),   
  .dataout_0_p(tmds_data_n[0]),   
  .dataout_1_n(tmds_data_p[1]),   
  .dataout_1_p(tmds_data_n[1]),   
  .dataout_2_n(tmds_data_p[2]),   
  .dataout_2_p(tmds_data_n[2]),   
  .dataout_3_n(tmds_clk_n),   
  .dataout_3_p(tmds_clk_p)       
);  

endmodule
