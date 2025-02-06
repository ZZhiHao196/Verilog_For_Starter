
module Rom_Image_Tft(

    input         clk50M,   //ϵͳʱ�������50M
	input         reset_n,  //��λ�ź����룬����Ч
  
	output [15:0] TFT_rgb,  //TFT�������
	output        TFT_hs,   //TFT��ͬ���Ņ�
	output        TFT_vs,   //TFT��ͬ���Ņ�
	output        TFT_clk,  //TFT����ʱ��
	output        TFT_de,   //TFT����ʹ��
	output        TFT_pwm   //TFT�������
);


//���ô���ʾͼƬ�ߴ磬�ʹ洢ͼƬROM�ĵ�ַλ����ʾ������ɫ
  parameter DISP_IMAGE_W    = 169;
  parameter DISP_IMAGE_H    = 267;
  parameter ROM_ADDR_WIDTH  = 16; //����ͼƬ�洢���WROM��Ⱦ���ROM�ĵ؈}λ��
  parameter DISP_BACK_COLOR = 16'hFFFF; //��ɫ


  parameter TFT_WIDTH  = 800;
  parameter TFT_HEIGHT = 480;

//ͼƬ��ʾ����Ļ�м�λ�Z
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
    .H_Visible_area (TFT_WIDTH      ), //��Ļ��ʾ������
    .V_Visible_area (TFT_HEIGHT     ), //��Ļ��ʾ����߶�
    .IMG_WIDTH      (DISP_IMAGE_W   ), //ͼƬ���
    .IMG_HEIGHT     (DISP_IMAGE_H   ), //ͼƬ�߶�
    .IMG_DATA_WIDTH (16             ), //ͼƬ���ص�λ��
    .ROM_ADDR_WIDTH (ROM_ADDR_WIDTH )  //�洢ͼƬROM�ĵ�ַλ��
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
   .Frame_Begin(frame_begin), //һ֡ͼ��ʼ�ı�־����
   .Disp_De(TFT_de),
   .Disp_Pclk(TFT_clk)
  );
  assign TFT_rgb={Disp_red,Disp_green,Disp_blue};
  assign TFT_pwm=1'b1;
  
endmodule