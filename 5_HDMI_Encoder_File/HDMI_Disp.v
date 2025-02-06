`timescale 1ns / 1ps


module HDMI_Disp(
    input clk_50M,
    input rst_n,
    
    // HDMI1 interface
    output hdmi1_clk_p,
    output hdmi1_clk_n,
    output [2:0]hdmi1_dat_p,
    output [2:0]hdmi1_dat_n,
    output [2:0]hdmi1_oe,
    
    // HDMI2 interface
    output hdmi2_clk_p,
    output hdmi2_clk_n,
    output [2:0]hdmi2_dat_p,
    output [2:0]hdmi2_dat_n,
    output [2:0]hdmi2_oe,
    
    // HDMI3 interface
    output hdmi3_clk_p,
    output hdmi3_clk_n,
    output [2:0]hdmi3_dat_p,
    output [2:0]hdmi3_dat_n,
    output [2:0]hdmi3_oe,
    
    //TFT interface
    output [15:0]TFT_rgb,
    output TFT_hs,
    output TFT_vs,
    output TFT_clk,
    output TFT_de,
    output TFT_pwn
    );
 //Resolution_800x480    //时钟为33MHz
 parameter 
       Disp_Width =800,
       Disp_Height=480; 
       
  wire pixelclk;
  wire pixelclk_x5;
  wire pll_locked;

  wire rst_p;
  wire [11:0] disp_h_addr;
  wire [11:0] disp_v_addr;
  wire disp_data_req;
  wire [23:0]disp_data;
  wire disp_hs;
  wire disp_vs;
  wire [7:0]disp_red;
  wire [7:0]disp_green;
  wire [7:0]disp_blue;
  wire disp_de;
  wire disp_pclk;

  assign rst_p = ~pll_locked;

  
  pll pll
(
    .clk_out1(pixelclk),     // output   33M
    .clk_out2(pixelclk_x5),     // output 165M
    .resetn(rst_n), // input resetn
    .locked(pll_locked),       // output locked
    .clk_in1(clk_50M)      // input clk_in1
);

 Color_Bar #(
 .Disp_Width(  Disp_Width),
 .Disp_Height( Disp_Height)
 ) color_bar (
    .disp_h_addr(disp_h_addr),
    .disp_v_addr(disp_v_addr),
    .disp_data_req(disp_data_req),
    .disp_data(disp_data)
);

Disp_Driver disp_driver(
    .clk_disp    (  pixelclk      ),
    .rst_p       (  rst_p         ),
    .Data_In     (  disp_data     ),
    .DataReq     (  disp_data_req ),
    .H_Addr      (  disp_h_addr   ),
    .V_Addr      (  disp_v_addr   ),
    . Disp_Hs    (  disp_hs    ),
    . Disp_Vs    (  disp_vs     ),
    . Disp_Red   (  disp_red    ),
    . Disp_Green (  disp_green  ),
    . Disp_Blue  (  disp_blue   ),
    . Frame_Begin(             ), //一帧图像开始的标志符号
    . Disp_De    ( disp_de    ),
    . Disp_Pclk  ( disp_pclk  )
    );      
             
  //TFT
  assign TFT_rgb = {disp_red[7:3],disp_green[7:2],disp_blue[7:3]};
  assign TFT_hs  = disp_hs;
  assign TFT_vs  = disp_vs;
  assign TFT_clk = disp_pclk;
  assign TFT_de  = disp_de;
  assign TFT_pwm = 1'b1;
 
 
 HDMI_Encoder  encoder1(
    //输入全局控制信号
  .pixelclk    (pixelclk   ) ,
  .pixelclk_x5 (pixelclk5x ) ,
  .rst_p       (reset_p    ) ,
  .blue_din    (disp_blue  ) ,
  .green_din   (disp_green ) ,
  .red_din     (disp_red   ) ,
  .hsync       (disp_hs    ) ,
  .vsync       (disp_vs    ) ,
  .de          (disp_de    ) ,
  .tdms_clk_p  (hdmi1_clk_p) ,
  .tdms_clk_n  (hdmi1_clk_n) ,
  .tmds_data_p (hdmi1_dat_p) ,
  .tmds_data_n (hdmi1_dat_n)
    );                    
       
 assign hdmi1_oe = 1'b1;   

 HDMI_Encoder  encoder2(
    //输入全局控制信号
  .pixelclk    (pixelclk   ) ,
  .pixelclk_x5 (pixelclk5x ) ,
  .rst_p       (reset_p    ) ,
  .blue_din    (disp_blue  ) ,
  .green_din   (disp_green ) ,
  .red_din     (disp_red   ) ,
  .hsync       (disp_hs    ) ,
  .vsync       (disp_vs    ) ,
  .de          (disp_de    ) ,
  .tdms_clk_p  (hdmi2_clk_p) ,
  .tdms_clk_n  (hdmi2_clk_n) ,
  .tmds_data_p (hdmi2_dat_p) ,
  .tmds_data_n (hdmi2_dat_n)
    );                    

assign hdmi2_oe = 1'b1;      
                            
endmodule
