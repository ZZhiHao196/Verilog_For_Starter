
module Image_Extract
#(
  parameter H_Visible_area = 800, //������Ļ��ʾ����Ŀ��
  parameter V_Visible_area = 480, //������Ļ��ʾ����ĸ߶�
  parameter IMG_WIDTH      = 160, //ͼƬ���
  parameter IMG_HEIGHT     = 120, //ͼƬ�߶�
  parameter IMG_DATA_WIDTH = 16,  //ͼƬ����λ��
  parameter ROM_ADDR_WIDTH = 16   //�洢ͼƬROM��ַλ��
)
(
  input                       clk_ctrl       ,   //����ʱ�ӣ���TFT��ʱ�ӱ���һ��
  input                       reset_n        ,   //��λ�źţ��͵�ƽ��Ч
                                           
  input  [15:0]               img_disp_hbegin,   //����ʾ���������Ͻǵ�һ�����ص���TFT����������
  input  [15:0]               img_disp_vbegin,   //����ʾ���������Ͻǵ�һ�����ص���TFT���ĳ�����
  input  [IMG_DATA_WIDTH-1:0] disp_back_color,   //����ɫ                                
  input                       frame_begin    ,   //һ֡ͼ����ʼ�ı�־�źţ�clk_ctrlʱ����
  input                       disp_data_req  ,   //������Ч����
  input  [11:0]               visible_hcount ,   // TFT�ɼ�������ɨ�������
  input  [11:0]               visible_vcount ,   // TFT�ɼ�����ɨ�輼����
  input  [IMG_DATA_WIDTH-1:0] rom_data       ,     //��ȡ��ͼƬ����
  output reg [ROM_ADDR_WIDTH-1:0] rom_addra  ,    //��ȡͼƬ���ݵ�ROM��ַ
  output [IMG_DATA_WIDTH-1:0] disp_data           //TFT����ʾ������
  
);
 
  wire       h_exceed;
  wire       v_exceed;
  wire       img_h_disp;
  wire       img_v_disp;
  wire       img_disp;
  wire [15:0]hcount_max;
 
 //�ж�ͼƬ�Ƿ�ᳬ����ʾ����Χ���Ӷ�������ʾ����ʾ��ȫ
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