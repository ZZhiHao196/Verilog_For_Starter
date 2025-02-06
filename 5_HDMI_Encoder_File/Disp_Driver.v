`include "disp_para.vh"


module Disp_Driver(
    input clk_disp,
    input rst_p,
    
    input [`Red_Bits +`Green_Bits + `Blue_Bits -1:0]Data_In,
    output DataReq,
    
    output [11:0]H_Addr,
    output [11:0]V_Addr,
    
    output reg Disp_Hs,
    output reg Disp_Vs,
    output reg [`Red_Bits-1:0]Disp_Red,
    output reg [`Green_Bits-1:0]Disp_Green,
    output reg [`Blue_Bits-1:0]Disp_Blue,
    output reg Frame_Begin, //һ֡ͼ��ʼ�ı�־����
    output reg Disp_De,
    output Disp_Pclk
    );
   //����
    wire hcount_ov;     // �м���������ź�
    wire vcount_ov;     // �м���������ź�
    
    
    reg [11:0]hcount_r;  // �м����Ĵ���
    reg [11:0]vcount_r;  // �м����Ĵ���
     
    `ifdef HW_VGA
        assign Disp_Pclk=~clk_disp;
    `else 
        assign Disp_Pclk= clk_disp;
    `endif
    
    assign DataReq =Disp_De; 
    
parameter   Hdata_Begin = `H_Sync_Time + `H_Back_Porch + `H_Left_Border - 1'b1,
            Hdata_End   =  `H_Total_Time - `H_Right_Border - `H_Front_Porch-1'b1,
            Vdata_Begin = `V_Sync_Time + `V_Back_Porch + `V_Top_Border-1'b1,
            Vdata_End   = `V_Total_Time - `V_Bottom_Border - `V_Front_Porch-1'b1,
            VGA_HS_End  = `H_Sync_Time - 1'b1,
            VGA_VS_End  = `V_Sync_Time - 1'b1,
            Hpixel_End  = `H_Total_Time - 1'b1,
            Vline_End   = `V_Total_Time - 1'b1;
    
    
      // �м���������ź�
    assign hcount_ov = (hcount_r >= Hpixel_End);  // �м������ﵽ���ֵʱ������ź���Ч
    
    
    // �м�����
    always @(posedge clk_disp or posedge rst_p) begin
        if(rst_p)          // ��λʱ���м���������
            hcount_r <= 0;
        else if (hcount_ov)  // �ﵽ��ɨ�����λ��ʱ���м���������
            hcount_r <= 0;
        else                // �����м�������1
            hcount_r <= hcount_r +1;
    end
    
    
      // �м���������ź�
    assign vcount_ov = (vcount_r >= Vline_End);  // �м������ﵽ���ֵ���м��������ʱ������ź���Ч
  
    // �м�����
    always @(posedge clk_disp or posedge rst_p) begin
        if(rst_p)          // ��λʱ���м���������
            vcount_r <= 0;
        else if(hcount_ov) begin  // �м��������ʱ���м���������
            if(vcount_ov)  // �ﵽ��ɨ�����λ��ʱ���м���������
                vcount_r <= 0;
            else                // �����м�������1
                vcount_r <= vcount_r + 1;
        end
        else vcount_r<=vcount_r;
    end
    
  // ������Ч����־
    always @(posedge clk_disp)begin
        Disp_De <= ((hcount_r >= Hdata_Begin) && (hcount_r < Hdata_End)) && 
                   ((vcount_r >= Vdata_Begin) && (vcount_r < Vdata_End));  // ���м������м�����λ����Ч��������ʱ��������Ч����־��Ч
    end
    
  
    assign H_Addr = Disp_De?(hcount_r - Hdata_Begin):12'd0;
    assign V_Addr = Disp_De?(vcount_r - Vdata_Begin):12'd0;
       
    
    always @(posedge clk_disp)begin
        Disp_Hs <= (hcount_r >= VGA_HS_End);  // �м��������ڵ��� VGS_HS_End ʱ����ͬ���ź���Ч
        Disp_Vs <= (vcount_r >= VGA_VS_End);  // �м��������ڵ��� VGS_VS_End ʱ����ͬ���ź���Ч
       {Disp_Red,Disp_Green,Disp_Blue} <=(Disp_De) ? Data_In :0;  // ��������Ч�����RGB���ݣ����������ɫ
    end
    
   
  reg Disp_Vs_Dly1; //������ȡ������
  always@(posedge clk_disp)
  begin
    Disp_Vs_Dly1 <= Disp_Vs;
  end
  
  always @(posedge clk_disp or posedge rst_p)begin
    if(rst_p)begin
        Frame_Begin<=0;
    end else if(!Disp_Vs_Dly1&&Disp_Vs)begin
        Frame_Begin<=1;
    end else begin
        Frame_Begin<=0;
    end//else 
  end
    
endmodule
