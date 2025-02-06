
module Image_Extract
#(
  parameter H_Visible_area = 800, //整个屏幕显示区域的宽度
  parameter V_Visible_area = 480, //整个屏幕显示区域的高度
  parameter IMG_WIDTH      = 160, //图片宽度
  parameter IMG_HEIGHT     = 120, //图片高度
  parameter IMG_DATA_WIDTH = 16,  //图片像素位宽
  parameter ROM_ADDR_WIDTH = 16   //存储图片ROM地址位宽
)
(
  input                       clk_ctrl       ,   //输入时钟，与TFT屏时钟保持一致
  input                       reset_n        ,   //复位信号，低电平有效
                                           
  input  [15:0]               img_disp_hbegin,   //待显示土拍你左上角第一个像素点在TFT屏的行坐标
  input  [15:0]               img_disp_vbegin,   //待显示土拍你左上角第一个像素点在TFT屏的场坐标
  input  [IMG_DATA_WIDTH-1:0] disp_back_color,   //背景色                                
  input                       frame_begin    ,   //一帧图像起始的标志信号，clk_ctrl时钟域
  input                       disp_data_req  ,   //数据有效区域
  input  [11:0]               visible_hcount ,   // TFT可见区域行扫描计数器
  input  [11:0]               visible_vcount ,   // TFT可见区域场扫描技术器
  input  [IMG_DATA_WIDTH-1:0] rom_data       ,     //读取的图片数据
  output reg [ROM_ADDR_WIDTH-1:0] rom_addra  ,    //读取图片数据的ROM地址
  output [IMG_DATA_WIDTH-1:0] disp_data           //TFT屏显示的数据
  
);
 
  wire       h_exceed;
  wire       v_exceed;
  wire       img_h_disp;
  wire       img_v_disp;
  wire       img_disp;
  wire [15:0]hcount_max;
 
 //判断图片是否会超过显示屏范围，从而导致显示屏显示不全
  assign h_exceed = img_disp_hbegin + IMG_WIDTH  > H_Visible_area - 1'b1;
  assign v_exceed = img_disp_vbegin + IMG_HEIGHT > V_Visible_area - 1'b1;

  assign img_h_disp = h_exceed ? (visible_hcount >= img_disp_hbegin && visible_hcount < H_Visible_area):
                                 (visible_hcount >= img_disp_hbegin && visible_hcount < img_disp_hbegin + IMG_WIDTH);  
  
  assign img_v_disp = v_exceed ? (visible_vcount >= img_disp_vbegin && visible_vcount < V_Visible_area):
                                 (visible_vcount >= img_disp_vbegin && visible_vcount < img_disp_vbegin + IMG_HEIGHT);
     
  assign img_disp = disp_data_req && img_h_disp && img_v_disp;
  
  assign hcount_max = h_exceed ? (H_Visible_area - 1'b1):(img_disp_hbegin + IMG_WIDTH - 1'b1);
     
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
      rom_addra <= 'd0;
    else if(frame_begin)
      rom_addra <= 'd0; 
    else if(img_disp) begin
      if(visible_hcount == hcount_max)
        rom_addra <= rom_addra + (img_disp_hbegin + IMG_WIDTH - hcount_max);
      else
        rom_addra <= rom_addra + 1'b1;
    end else
      rom_addra <= rom_addra;
end

  assign disp_data = img_disp ? rom_data : disp_back_color;

 endmodule