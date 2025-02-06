
module Rom_Image_Tft(

    input         clk50M,   //系统时钟输入＿50M
	input         reset_n,  //复位信号输入，低有效
  
	output [15:0] TFT_rgb,  //TFT数据输出
	output        TFT_hs,   //TFT行同步信叿
	output        TFT_vs,   //TFT场同步信叿
	output        TFT_clk,  //TFT像素时钟
	output        TFT_de,   //TFT数据使能
	output        TFT_pwm   //TFT背光控制
);


//设置待显示图片尺寸，和存储图片ROM的地址位宽，显示背景颜色
  parameter DISP_IMAGE_W    = 169;
  parameter DISP_IMAGE_H    = 267;
  parameter ROM_ADDR_WIDTH  = 16; //根据图片存储承霿ROM深度决定ROM的地坿位宽
  parameter DISP_BACK_COLOR = 16'hFFFF; //白色


  parameter TFT_WIDTH  = 800;
  parameter TFT_HEIGHT = 480;

//图片显示在屏幕中间位罿
  parameter DISP_HBEGIN = (TFT_WIDTH  - DISP_IMAGE_W)/2;
  parameter DISP_VBEGIN = (TFT_HEIGHT - DISP_IMAGE_H)/2;

  wire                      pll_locked;
  wire                      clk_ctrl;
  wire                      tft_reset_n;
  wire [ROM_ADDR_WIDTH-1:0] rom_addra;
  wire [15:0]               disp_data;
  wire [15:0]               rom_data;
  wire                      disp_data_req;
  wire [11:0]               visible_hcount;
  wire [11:0]               visible_vcount;
  wire                      frame_begin;
  wire                      tft_reset_p;
  wire [4:0]                Disp_red;
  wire [5:0]                Disp_green;
  wire [4:0]                Disp_blue;
  wire                      clk33M;
  wire                      clk165M;

  
  assign tft_reset_n = pll_locked;
  assign tft_reset_p = ~pll_locked;
  assign clk_ctrl = clk33M;


  pll pll
  (
    // Clock out ports
    .clk_out1(clk33M      ), // output clk_out1
    .clk_out2(clk165M     ),
    // Status and control signals
    .resetn  (reset_n     ), // input reset,active low
    .locked  (pll_locked  ), // output locked
    // Clock in ports
    .clk_in1 (clk50M      )  // input clk_in1
  );  

  rom_image rom_image (
    .clka  (clk_ctrl  ),   // input wire clka
    .addra (rom_addra ),   // input wire [16 : 0] addra
    .douta (rom_data  )    // output wire [15 : 0] douta
  );  


  Image_Extract
  #(
    .H_Visible_area (TFT_WIDTH      ), //屏幕显示区域宽度
    .V_Visible_area (TFT_HEIGHT     ), //屏幕显示区域高度
    .IMG_WIDTH      (DISP_IMAGE_W   ), //图片宽度
    .IMG_HEIGHT     (DISP_IMAGE_H   ), //图片高度
    .IMG_DATA_WIDTH (16             ), //图片像素点位宽
    .ROM_ADDR_WIDTH (ROM_ADDR_WIDTH )  //存储图片ROM的地址位宽
  )image_extract
  (
    .clk_ctrl       (clk_ctrl       ),
    .reset_n        (tft_reset_n    ),
    .img_disp_hbegin(DISP_HBEGIN    ),
    .img_disp_vbegin(DISP_VBEGIN    ),
    .disp_back_color(DISP_BACK_COLOR),
    .rom_addra      (rom_addra      ),
    .rom_data       (rom_data       ),
    .frame_begin    (frame_begin    ),
    .disp_data_req  (disp_data_req  ),
    .visible_hcount (visible_hcount ),
    .visible_vcount (visible_vcount ),
    .disp_data      (disp_data      )
  );

  Disp_Driver disp_driver
  (
   .clk_disp(clk_ctrl),
   .rst_p(tft_reset_p),
  
   .Data_In(disp_data),
   .DataReq(disp_data_req),
   
   .H_Addr(visible_hcount),
   .V_Addr(visible_vcount),
  
   .Disp_Hs(TFT_hs),
   .Disp_Vs(TFT_vs),
   .Disp_Red( Disp_red),
   .Disp_Green( Disp_green),
   .Disp_Blue(Disp_blue),
   .Frame_Begin(frame_begin), //一帧图像开始的标志符号
   .Disp_De(TFT_de),
   .Disp_Pclk(TFT_clk)
  );
  assign TFT_rgb={Disp_red,Disp_green,Disp_blue};
  assign TFT_pwm=1'b1;
  
endmodule