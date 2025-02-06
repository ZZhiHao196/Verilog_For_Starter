`timescale 1ns / 1ps


module Encode(
    input clk,    //����ʱ��
    input rst_p,
    input [7:0] din,
    input c0,    //�����ź�
    input c1,
    input de,  //����ʹ��
    output reg [9:0] dout   //�������
);

//�����źŶ�Ӧ����
 parameter  
        CTL0  = 10'b11_01010100,
        CTL1  = 10'b00_10101011,
        CTL2  = 10'b01_01010100,
        CTL3  = 10'b10_10101011;
        

reg [3:0] n1d;  //����ͳ��8bit������1�ĸ���
reg [7:0] din_q;  //ͬ���Ĵ��������8bit����Ҫһ��ʱ�䣩

//ͳ������0��1����
 always @(posedge clk)begin
    din_q<=din;
    n1d<=din[0]+din[1]+din[2]+din[3]+din[4]+din[5]+din[6]+din[7];
 end//always
 
 //8bit -->9bit
 wire use_Xnor;
 assign use_Xnor=(n1d>4'h4)|(n1d==4'h4&&din_q[0]==1'b0);
 
 wire [8:0]q_m;
 assign q_m[0]=din_q[0];
 
 generate
 genvar i;
 for (i=1;i<8;i=i+1)begin : gen_q_m
    assign q_m[i]=(use_Xnor)? ~(q_m[i-1]^din_q[i]):(q_m[i-1]^din_q[i]);
 end
 endgenerate
assign q_m[8]=(use_Xnor)? 1'b0:1'b1;    // Xnor ����Ϊ0�� nor����Ϊ1


//9bit -->10bit
reg [3:0] n1q_m, n0q_m;   //�ֱ�����ͳ��1��0

always @(posedge clk)begin
    n1q_m<=q_m[0]+q_m[1]+q_m[2]+q_m[3]+q_m[4]+q_m[5]+q_m[6]+q_m[7];     
    n0q_m<=4'h8-(q_m[0]+q_m[1]+q_m[2]+q_m[3]+q_m[4]+q_m[5]+q_m[6]+q_m[7]);        
end//always

reg signed  [4:0] cnt;  //1��0���ͳ��,  ʹ�õ�ʱ 1-0 �ĸ���,���λΪ����λ

wire is_equal,is_worse;
assign is_equal = (cnt==5'h0)|(n1q_m==n0q_m);   // 0��1����Ŀƽ��
assign is_worse = (~cnt[4]&&(n1q_m>n0q_m))|(cnt[4]&&(n1q_m<n0q_m));  // ԭ��1��0�࣬����1Ҳ��0�ࣻ ����ԭ��0��1�࣬����0��1��

//��ˮ�߶��루2�ģ�
    reg [1:0]de_reg;
    reg [1:0]c0_reg;
    reg [1:0]c1_reg;
    reg [8:0]q_m_reg;
    
 always @(posedge clk)begin
    de_reg<={de_reg[0],de};
    c0_reg<={c0_reg[0],c0};
    c1_reg<={c1_reg[0],c1};
    q_m_reg<=q_m;
 end//always
//10bit ���

always @(posedge clk or posedge rst_p)begin
    if(rst_p)begin
        dout<=0;
        cnt<=0;
    end else begin
        if(de_reg[1])begin  //�������ڣ����Ͷ�Ӧ��������
            if(is_equal) begin // 0,1��Ŀ��ȣ�����Ҫ��ת
                dout[9]<=~q_m_reg[8];
                dout[8]<=q_m_reg[8];
                dout[7:0]<=(q_m_reg[8])?q_m_reg[7:0]:~q_m_reg[7:0];
                cnt <= (q_m_reg[8]) ? (cnt + n1q_m - n0q_m) : (cnt + n0q_m - n1q_m);
            end else if(is_worse)begin   //0��1��Ŀ���ȣ�ƫ��ƽ��״̬
                dout[9]<=1'b1;
                dout[8]<=q_m_reg[8];
                dout[7:0]<=~q_m_reg[7:0];
                cnt <= cnt + {{3{q_m_reg[8]}}, q_m_reg[8], 1'b0} + (n0q_m - n1q_m);
                
                end else begin
                    dout[9]<=0;
                    dout[8]<=q_m_reg[8];
                    dout[7:0]<=q_m_reg[7:0];
                    cnt <= cnt - {{3{~q_m_reg[8]}}, ~q_m_reg[8], 1'b0} + (n1q_m - n0q_m);
                end
            end
         else begin //�������ڣ����Ϳ����ź�
            cnt<=0;
            case({c1_reg[1],c0_reg[1]})
                2'b00: dout<=CTL0;
                2'b01: dout<=CTL1;
                2'b10: dout<=CTL2;
                default:dout<=CTL3;
             endcase
        end
    end//else
end//always

endmodule
