`timescale 1ns / 1ps

module Color_Bar #(
     parameter Disp_Width = 800,
     parameter Disp_Height= 480
)(
    input [11:0]disp_h_addr,
    input [11:0]disp_v_addr,
    input disp_data_req,
    output reg [23:0] disp_data
);

 localparam 
    BLACK    = 24'h000000, //黑色
    BLUE     = 24'h0000FF, //蓝色
    RED      = 24'hFF0000, //红色
    PURPPLE  = 24'hFF00FF, //紫色
    GREEN    = 24'h00FF00, //绿色
    CYAN     = 24'h00FFFF, //青色
    YELLOW   = 24'hFFFF00, //黄色
    WHITE    = 24'hFFFFFF; //白色
    
  //定义每个像素块的默认显示颜色值
  localparam 
    R0_C0 = BLACK,   //第0行0列像素块
    R0_C1 = BLUE,    //第0行1列像素块
    R1_C0 = RED,     //第1行0列像素块
    R1_C1 = PURPPLE, //第1行1列像素块
    R2_C0 = GREEN,   //第2行0列像素块
    R2_C1 = CYAN,    //第2行1列像素块
    R3_C0 = YELLOW,  //第3行0列像素块
    R3_C1 = WHITE;   //第3行1列像素块

	wire [3:0]row_act;
	wire [1:0]col_act;
	
genvar i ,j;
	localparam  row_height= Disp_Height/4,
	            col_width=  Disp_Width/2; 
  for (i=0;i<4;i=i+1)begin
    assign row_act[i]=(disp_v_addr>=i*row_height)&&(disp_v_addr<(1+i)*row_height); 
  end
  for (j=0;j<2;j=j+1)begin
    assign col_act[j]=(disp_h_addr>=j*col_width)&&(disp_h_addr<(1+j)*col_width); 
  end

always@(*)
		case({row_act,col_act,disp_data_req})
			7'b0001_01_1:disp_data = R0_C0;
			7'b0001_10_1:disp_data = R0_C1;
			7'b0010_01_1:disp_data = R1_C0;
			7'b0010_10_1:disp_data = R1_C1;
			7'b0100_01_1:disp_data = R2_C0;
			7'b0100_10_1:disp_data = R2_C1;
			7'b1000_01_1:disp_data = R3_C0;
			7'b1000_10_1:disp_data = R3_C1;
			default:disp_data = R0_C0;
		endcase
	
endmodule
