`timescale 1ns / 1ps

module HDMI_Encoder(
    //����ȫ�ֿ����ź�
    input pixelclk,
    input pixelclk_x5,
    input rst_p,
    
    //������ʾ����
    input [7:0]blue_din,
    input [7:0]green_din,
    input [7:0]red_din,
    
    //������ʾ�����ź�
    input hsync,
    input vsync,
    input de,
    
    //���
    output tdms_clk_p,
    output tdms_clk_n,
    output [2:0] tmds_data_p,
    output [2:0] tmds_data_n
    );
    
wire [9:0]red;
wire [9:0]green;
wire [9:0]blue;

//����ģ��
Encode  encb(
   .clk(pixel_clk),    //����ʱ��
   .rst_p(rst_p),
   .din(blue_din),
   .c0(hsync),    //�����ź�
   .c1(vsync),
   .de(de),  //����ʹ��
   .dout(blue)   //�������
);    
  
Encode  encg(
   .clk(pixel_clk),    //����ʱ��
   .rst_p(rst_p),
   .din(green_din),
   .c0(1'b0),    //�����ź�
   .c1(1'b0),
   .de(de),  //����ʹ��
   .dout(green)   //�������
);    
Encode  encr(
   .clk(pixel_clk),    //����ʱ��
   .rst_p(rst_p),
   .din(red_din),
   .c0(1'b0),    //�����ź�
   .c1(1'b0),
   .de(de),  //����ʹ��
   .dout(red)   //�������
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
