// TFT ��ʾ������ģ��
module Tft_Disp
(
    input            clk_ctrl,       // ����ʱ��
    input            reset_n,        // �첽��λ���͵�ƽ��Ч

    input     [15:0] disp_data,      // 16 λ��ʾ��������
    output           disp_data_req,  // ��ʾ���������ź�
    output reg[11:0] visible_hcount, // ��������ˮƽ���ؼ�����
    output reg[11:0] visible_vcount, // ��������ֱ���ؼ�����
    output reg       frame_begin,    // ֡��ʼ��־

    output    [15:0] TFT_rgb,        // 16 λ RGB ����� TFT ��ʾ��
    output reg       TFT_hs,         // TFT ˮƽͬ���ź�
    output reg       TFT_vs,         // TFT ��ֱͬ���ź�
    output           TFT_clk,        // TFT ʱ���ź� (ͬ clk_ctrl)
    output           TFT_de,         // TFT ����ʹ���ź�
    output           TFT_pwm         // PWM �ź� (�˴����ӵ� reset_n)
);

`include "disp_param.vh" // ������ʾ������ͷ�ļ� (ʱ�򡢷ֱ��ʵ�)

// �����������߽�ľֲ�����
localparam H_DATA_BEGIN = H_Sync_Pulse + H_Back_Porch + H_Left_Border - 1'b1; // ˮƽ����������ʼλ��
localparam H_DATA_END   = H_Visible_Area + H_Sync_Pulse + H_Back_Porch + H_Left_Border - 1'b1; // ˮƽ�����������λ��
localparam V_DATA_BEGIN	= V_Sync_Pulse + V_Back_Porch + V_Top_Border - 1'b1; // ��ֱ����������ʼλ��
localparam V_DATA_END   = V_Visible_Area + V_Sync_Pulse + V_Back_Porch + V_Top_Border - 1'b1; // ��ֱ�����������λ��

reg       visible_flag;   // ��ǰ�����Ƿ��ڿ��������ڵı�־
reg [11:0]hcount;         // ˮƽ���ؼ�����
reg [11:0]vcount;	        // ��ֱ�м�����
wire      hcount_ov;      // ˮƽ�����������־ (�н���)
wire      vcount_ov;      // ��ֱ�����������־ (֡����)
reg       TFT_vs_dly1;    // �ӳٺ�� TFT_vs �źţ����ڼ��֡��ʼ

assign TFT_clk  = clk_ctrl; // TFT ʱ�������ʱ����ͬ
assign TFT_de   = visible_flag; // ����ʹ���źţ��ڿ���������Ϊ�ߵ�ƽ
assign TFT_pwm  = reset_n; // PWM �ź� (���ӵ� reset_n���������ڱ�����Ƶ�)
assign TFT_rgb  = visible_flag ? disp_data : 16'h0000; // �������������ʾ���ݣ����������ɫ
assign disp_data_req = visible_flag; // �ڿ��������������µ���ʾ����

// ˮƽ������������
assign hcount_ov = (hcount == H_Whole_Line - 1'b1)?1'b1:1'b0;

// ˮƽ������
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
        hcount <= 12'd0; // ��λʱ����
    else if(hcount_ov)
        hcount <= 12'd0; // �н���ʱ����
    else 
        hcount <= hcount + 1'b1; // ʱ�������ص���
end

// ��ֱ������������
assign vcount_ov = (vcount == V_Whole_Frame - 1'b1)?1'b1:1'b0;

// ��ֱ������
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
        vcount <= 12'd0; // ��λʱ����
    else if(hcount_ov)begin // �н���ʱ����ֱ�������ſ��ܵ���
        if(vcount_ov)
            vcount <= 12'd0; // ֡����ʱ����
        else 
            vcount <= vcount + 1'b1;		
    end else
        vcount <= vcount; // ���򱣳ֲ���
end

// ˮƽͬ���ź�����
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
        TFT_hs <= 1'b0; // ��λʱ����
    else if(hcount == H_Sync_Pulse - 1'b1)
        TFT_hs <= 1'b1; // ͬ��������ʼ
    else if(hcount == H_Whole_Line - 1'b1)
        TFT_hs <= 1'b0; // ͬ���������
    else
      TFT_hs <= TFT_hs; // ���򱣳ֲ���
end

// ��ֱͬ���ź�����
always@(posedge clk_ctrl or negedge reset_n)
begin
    if(!reset_n)
        TFT_vs <= 1'b0; // ��λʱ����
    else if(hcount_ov && vcount == V_Sync_Pulse - 1'b1)
        TFT_vs <= 1'b1; // ͬ��������ʼ
    else if(hcount_ov && vcount == V_Whole_Frame - 1'b1)
        TFT_vs <= 1'b0; // ͬ���������
    else
      TFT_vs <= TFT_vs; // ���򱣳ֲ���
end

// ���������־����
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
        visible_flag <= 1'b0; // ��λʱ����
    else if((vcount >= V_DATA_BEGIN) && (vcount < V_DATA_END)) // �ж��Ƿ��ڴ�ֱ����������
        if((hcount >= H_DATA_BEGIN) && (hcount < H_DATA_END)) // �ж��Ƿ���ˮƽ����������
        visible_flag <= 1'b1; //  �ڿ���������
    else
        visible_flag <= 1'b0; // ���ڿ���������
    else
        visible_flag <= 1'b0; // ���ڿ���������
end

// ��������ˮƽ������
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
        visible_hcount <= 1'b0; // ��λʱ����
    else if((hcount >= H_DATA_BEGIN) && (hcount < H_DATA_END)) // ��ˮƽ����������
        visible_hcount <= hcount - H_DATA_BEGIN; // �����ڿ��������ڵ�ˮƽλ��
    else
        visible_hcount <= 1'b0; // ��������
end

// ��������ֱ������
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
        visible_vcount <= 1'b0; // ��λʱ����
    else if((vcount >= V_DATA_BEGIN) && (vcount < V_DATA_END)) // �ڴ�ֱ����������
      visible_vcount <= vcount - V_DATA_BEGIN; // �����ڿ��������ڵĴ�ֱλ��
    else
        visible_vcount <= 1'b0; // ��������
end

// �ӳٴ�ֱͬ���ź�
always@(posedge clk_ctrl)begin
    TFT_vs_dly1 <= TFT_vs; // �洢��һ����ֱͬ���ź�
end

// ֡��ʼ���
always@(posedge clk_ctrl or negedge reset_n)begin
    if(!reset_n)
        frame_begin <= 1'b0; // ��λʱ����
    else if(!TFT_vs_dly1 && TFT_vs) // ��⵽��ֱͬ���ź������أ����µ�һ֡��ʼ
        frame_begin <= 1'b1; // ֡��ʼ��־�ø�
    else
        frame_begin <= 1'b0; // ���򱣳�Ϊ��
end

endmodule