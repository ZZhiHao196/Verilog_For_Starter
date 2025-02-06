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
    output reg Frame_Begin, //一帧图像开始的标志符号
    output reg Disp_De,
    output Disp_Pclk
    );
   //连线
    wire hcount_ov;     // 行计数器溢出信号
    wire vcount_ov;     // 列计数器溢出信号
    
    
    reg [11:0]hcount_r;  // 行计数寄存器
    reg [11:0]vcount_r;  // 列计数寄存器
     
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
    
    
      // 行计数器溢出信号
    assign hcount_ov = (hcount_r >= Hpixel_End);  // 行计数器达到最大值时，溢出信号有效
    
    
    // 行计数器
    always @(posedge clk_disp or posedge rst_p) begin
        if(rst_p)          // 复位时，行计数器清零
            hcount_r <= 0;
        else if (hcount_ov)  // 达到行扫描结束位置时，行计数器清零
            hcount_r <= 0;
        else                // 否则，行计数器加1
            hcount_r <= hcount_r +1;
    end
    
    
      // 列计数器溢出信号
    assign vcount_ov = (vcount_r >= Vline_End);  // 列计数器达到最大值且行计数器溢出时，溢出信号有效
  
    // 列计数器
    always @(posedge clk_disp or posedge rst_p) begin
        if(rst_p)          // 复位时，列计数器清零
            vcount_r <= 0;
        else if(hcount_ov) begin  // 行计数器溢出时，列计数器递增
            if(vcount_ov)  // 达到列扫描结束位置时，列计数器清零
                vcount_r <= 0;
            else                // 否则，列计数器加1
                vcount_r <= vcount_r + 1;
        end
        else vcount_r<=vcount_r;
    end
    
  // 数据有效区标志
    always @(posedge clk_disp)begin
        Disp_De <= ((hcount_r >= Hdata_Begin) && (hcount_r < Hdata_End)) && 
                   ((vcount_r >= Vdata_Begin) && (vcount_r < Vdata_End));  // 当行计数和列计数都位于有效数据区域时，数据有效区标志有效
    end
    
  
    assign H_Addr = Disp_De?(hcount_r - Hdata_Begin):12'd0;
    assign V_Addr = Disp_De?(vcount_r - Vdata_Begin):12'd0;
       
    
    always @(posedge clk_disp)begin
        Disp_Hs <= (hcount_r >= VGA_HS_End);  // 行计数器大于等于 VGS_HS_End 时，行同步信号有效
        Disp_Vs <= (vcount_r >= VGA_VS_End);  // 列计数器大于等于 VGS_VS_End 时，场同步信号有效
       {Disp_Red,Disp_Green,Disp_Blue} <=(Disp_De) ? Data_In :0;  // 在数据有效区输出RGB数据，否则输出黑色
    end
    
   
  reg Disp_Vs_Dly1; //用于提取上升沿
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
