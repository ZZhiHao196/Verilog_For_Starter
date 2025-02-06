// TFT 显示控制器模块
module Tft_Disp
(
    input            clk_ctrl,       // 控制时钟
    input            reset_n,        // 异步复位，低电平有效

    input     [15:0] disp_data,      // 16 位显示数据输入
    output           disp_data_req,  // 显示数据请求信号
    output reg[11:0] visible_hcount, // 可视区域水平像素计数器
    output reg[11:0] visible_vcount, // 可视区域垂直像素计数器
    output reg       frame_begin,    // 帧开始标志

    output    [15:0] TFT_rgb,        // 16 位 RGB 输出到 TFT 显示器
    output reg       TFT_hs,         // TFT 水平同步信号
    output reg       TFT_vs,         // TFT 垂直同步信号
    output           TFT_clk,        // TFT 时钟信号 (同 clk_ctrl)
    output           TFT_de,         // TFT 数据使能信号
    output           TFT_pwm         // PWM 信号 (此处连接到 reset_n)
);

`include "disp_param.vh" // 包含显示参数的头文件 (时序、分辨率等)

// 定义可视区域边界的局部参数
localparam H_DATA_BEGIN = H_Sync_Pulse + H_Back_Porch + H_Left_Border - 1'b1; // 水平可视区域起始位置
localparam H_DATA_END   = H_Visible_Area + H_Sync_Pulse + H_Back_Porch + H_Left_Border - 1'b1; // 水平可视区域结束位置
localparam V_DATA_BEGIN	= V_Sync_Pulse + V_Back_Porch + V_Top_Border - 1'b1; // 垂直可视区域起始位置
localparam V_DATA_END   = V_Visible_Area + V_Sync_Pulse + V_Back_Porch + V_Top_Border - 1'b1; // 垂直可视区域结束位置

reg       visible_flag;   // 当前像素是否在可视区域内的标志
reg [11:0]hcount;         // 水平像素计数器
reg [11:0]vcount;	        // 垂直行计数器
wire      hcount_ov;      // 水平计数器溢出标志 (行结束)
wire      vcount_ov;      // 垂直计数器溢出标志 (帧结束)
reg       TFT_vs_dly1;    // 延迟后的 TFT_vs 信号，用于检测帧起始

assign TFT_clk  = clk_ctrl; // TFT 时钟与控制时钟相同
assign TFT_de   = visible_flag; // 数据使能信号，在可视区域内为高电平
assign TFT_pwm  = reset_n; // PWM 信号 (连接到 reset_n，可能用于背光控制等)
assign TFT_rgb  = visible_flag ? disp_data : 16'h0000; // 可视区域输出显示数据，否则输出黑色
assign disp_data_req = visible_flag; // 在可视区域内请求新的显示数据

// 水平计数器溢出检测
assign hcount_ov = (hcount == H_Whole_Line - 1'b1)?1'b1:1'b0;

// 水平计数器
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
        hcount <= 12'd0; // 复位时清零
    else if(hcount_ov)
        hcount <= 12'd0; // 行结束时清零
    else 
        hcount <= hcount + 1'b1; // 时钟上升沿递增
end

// 垂直计数器溢出检测
assign vcount_ov = (vcount == V_Whole_Frame - 1'b1)?1'b1:1'b0;

// 垂直计数器
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
        vcount <= 12'd0; // 复位时清零
    else if(hcount_ov)begin // 行结束时，垂直计数器才可能递增
        if(vcount_ov)
            vcount <= 12'd0; // 帧结束时清零
        else 
            vcount <= vcount + 1'b1;		
    end else
        vcount <= vcount; // 否则保持不变
end

// 水平同步信号生成
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
        TFT_hs <= 1'b0; // 复位时拉低
    else if(hcount == H_Sync_Pulse - 1'b1)
        TFT_hs <= 1'b1; // 同步脉冲起始
    else if(hcount == H_Whole_Line - 1'b1)
        TFT_hs <= 1'b0; // 同步脉冲结束
    else
      TFT_hs <= TFT_hs; // 否则保持不变
end

// 垂直同步信号生成
always@(posedge clk_ctrl or negedge reset_n)
begin
    if(!reset_n)
        TFT_vs <= 1'b0; // 复位时拉低
    else if(hcount_ov && vcount == V_Sync_Pulse - 1'b1)
        TFT_vs <= 1'b1; // 同步脉冲起始
    else if(hcount_ov && vcount == V_Whole_Frame - 1'b1)
        TFT_vs <= 1'b0; // 同步脉冲结束
    else
      TFT_vs <= TFT_vs; // 否则保持不变
end

// 可视区域标志生成
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
        visible_flag <= 1'b0; // 复位时清零
    else if((vcount >= V_DATA_BEGIN) && (vcount < V_DATA_END)) // 判断是否在垂直可视区域内
        if((hcount >= H_DATA_BEGIN) && (hcount < H_DATA_END)) // 判断是否在水平可视区域内
        visible_flag <= 1'b1; //  在可视区域内
    else
        visible_flag <= 1'b0; // 不在可视区域内
    else
        visible_flag <= 1'b0; // 不在可视区域内
end

// 可视区域水平计数器
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
        visible_hcount <= 1'b0; // 复位时清零
    else if((hcount >= H_DATA_BEGIN) && (hcount < H_DATA_END)) // 在水平可视区域内
        visible_hcount <= hcount - H_DATA_BEGIN; // 计算在可视区域内的水平位置
    else
        visible_hcount <= 1'b0; // 否则清零
end

// 可视区域垂直计数器
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
        visible_vcount <= 1'b0; // 复位时清零
    else if((vcount >= V_DATA_BEGIN) && (vcount < V_DATA_END)) // 在垂直可视区域内
      visible_vcount <= vcount - V_DATA_BEGIN; // 计算在可视区域内的垂直位置
    else
        visible_vcount <= 1'b0; // 否则清零
end

// 延迟垂直同步信号
always@(posedge clk_ctrl)begin
    TFT_vs_dly1 <= TFT_vs; // 存储上一个垂直同步信号
end

// 帧开始检测
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
        frame_begin <= 1'b0; // 复位时清零
    else if(!TFT_vs_dly1 && TFT_vs) // 检测到垂直同步信号上升沿，即新的一帧开始
        frame_begin <= 1'b1; // 帧开始标志置高
    else
        frame_begin <= 1'b0; // 否则保持为低
end

endmodule