/*** 默认可显示1天的时间 **///-->被注释的部分
/////////////////////////////////////////////////////
////                                             ////
////    Author ：Adolph Wang                     ////
////    Time   ：2020年11月19日 22:21:12         ////
////    Version：1.0                             ////
////                                             ////
/////////////////////////////////////////////////////
module smg_ctrl(
	input   wire            clk		,
	input   wire            rst_n	, 
    input   wire  [19:0]    data_in	,

	output  wire  [7:0]     sen_duan,
	output  wire  [5:0]     sen_wei	
);

parameter TIMER_20us_cnt = 11'd2_000;//20us
/* parameter TIMER_1S_cnt = 26'd50_000_000;//1秒
parameter TIMER_1day_cnt = 17'd86399;//一天
reg [25:0]  cnt_1s;         //1s计数器
reg         cnt_1s_flag;    //1秒完成的标志
reg [16:0]  cnt_1day;       //一天的总秒数 */
reg [7:0]   sen_duan_r;
reg [5:0]   sen_wei_r;

reg [10:0]  time_20us_cnt_r;//20us的计数
reg         flag_20us_r;    //20us完成的标志
reg [3:0]   temp_r;         //记录位选的数字
reg         dot;            //小数点位
//20us计数器
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		time_20us_cnt_r <= 'd0;
	end
	else if(time_20us_cnt_r==TIMER_20us_cnt - 11'd1)begin
		time_20us_cnt_r <= 'd0;
	end
	else begin
		time_20us_cnt_r <= time_20us_cnt_r + 11'd1;
	end
end
//20us满标志
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		flag_20us_r <= 1'b0;
	end
	else if(time_20us_cnt_r==TIMER_20us_cnt - 11'd1)begin
		flag_20us_r <= 1'b1;
	end
	else begin
		flag_20us_r <= 1'b0;
	end
end
/* //1s计数器
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnt_1s  <= 0;
	end
	else if(cnt_1s==TIMER_1S_cnt - 1)begin
		cnt_1s  <= 0;
	end
	else
        cnt_1s  <=  cnt_1s  +  1;
end
//1s计数满标志
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnt_1s_flag <= 0;
	end
	else if (cnt_1s==TIMER_1S_cnt - 1)begin
		cnt_1s_flag <= 1;
	end
	else
		cnt_1s_flag <= 0;
end */
//位选切换
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		sen_wei_r <= 6'b011_111;//默认为最右边的位选
	end
	else if(flag_20us_r)begin
		sen_wei_r<={sen_wei_r[4:0],sen_wei_r[5]};//这里控制位选
//		sen_wei_r<={sen_wei_r[5:2],sen_wei_r[0],sen_wei_r[1]};
	end
	else begin
		sen_wei_r <= sen_wei_r;
	end
end
/* //数码管显示的数字_1天的时间
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnt_1day  <=  0;//初始值
	end
	else if(cnt_1s_flag)begin
		if(cnt_1day == TIMER_1day_cnt)begin
			cnt_1day <= 0;
		end
		else begin
			cnt_1day = cnt_1day + 1;
		end
	end
    else
        cnt_1day = cnt_1day;
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		temp_r <= 0;
        dot  <=  1;
	end
	else begin
		case(sen_wei_r)                             
			6'b011_111:begin    
                    temp_r <= cnt_1day % 60 % 10;//秒个位
                    dot  <=  1;//小数点无效
                end
			6'b101_111:begin    
                    temp_r <= cnt_1day % 60 / 10;//秒十位
                    dot  <=  1;//小数点无效
                end
            6'b110_111:begin
                    temp_r <= cnt_1day % 3600 / 60 % 10;//分钟个位
                    dot  <=  0;//小数点有效
                end
            6'b111_011:begin    
                    temp_r <= cnt_1day % 3600 / 60 / 10;//分钟十位
                    dot  <=  1;//小数点无效
                end
            6'b111_101:begin    
                    temp_r <= cnt_1day / 3600 % 10;     //小时个位
                    dot  <=  0;//小数点有效
                end
			6'b111_110:begin    
                    temp_r <= cnt_1day / 3600 / 10;     //小时十位
                    dot  <=  1;//小数点无效
                end
			default:begin
                    temp_r <= 0;
                    dot  <=  1'b1;
                end
		endcase
	end
end */	
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		temp_r <= 0;
        dot  <=  1;
	end
	else begin
        case(sen_wei_r)                             
            6'b011_111:begin    
                    temp_r  <=  data_in[3:0];//第一位，最低位
                    dot  <=  1;//小数点无效
                end
            6'b101_111:begin    
                    temp_r  <=  data_in[7:4];//第二位
                    dot  <=  1;//小数点无效
                end
            /* 6'b110_111:begin
                    temp_r  <=  data_in % 1000 / 100;//第三位
                    dot  <=  1;//小数点无效
                end
            6'b111_011:begin    
                    temp_r  <=  data_in % 10000 / 1000;//第四位
                    dot  <=  1;//小数点无效
                end
            6'b111_101:begin    
                    temp_r  <=  data_in % 10_0000 / 10000;     //第五位
                    dot  <=  1;//小数点无效
                end
            6'b111_110:begin    
                    temp_r  <=  data_in / 10_0000;     //第六位
                    dot  <=  1;//小数点无效
                end */
            default:begin
                    temp_r <= 0;
                    dot  <=  1'b1;
                end
        endcase
	end
end 
//各个数码管段选
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		sen_duan_r <= 8'b0;
	end
	else if(sen_wei_r != 6'b011_111 && sen_wei_r != 6'b101_111)begin
		sen_duan_r  <=  8'hff;
	end 
	else begin
		case(temp_r)            //point gfe_dcba
			4'h0:  sen_duan_r  <=  8'b1100_0000;
			4'h1:  sen_duan_r  <=  8'b1111_1001;
			4'h2:  sen_duan_r  <=  8'b1010_0100;
			4'h3:  sen_duan_r  <=  8'b1011_0000;
			4'h4:  sen_duan_r  <=  8'b1001_1001;
			4'h5:  sen_duan_r  <=  8'b1001_0010;
			4'h6:  sen_duan_r  <=  8'b1000_0010;
			4'h7:  sen_duan_r  <=  8'b1111_1000;
			4'h8:  sen_duan_r  <=  8'b1000_0000;
			4'h9:  sen_duan_r  <=  8'b1001_0000;
            4'ha:  sen_duan_r  <=  8'b1000_1000;
            4'hb:  sen_duan_r  <=  8'b1000_0011;
            4'hc:  sen_duan_r  <=  8'b1100_0110;
            4'hd:  sen_duan_r  <=  8'b1010_0001;
            4'he:  sen_duan_r  <=  8'b1000_0110;
            4'hf:  sen_duan_r  <=  8'b1000_1110;
/* 			'd:sen_duan_r  <=  8'b1100_0001;//U
			'd:sen_duan_r  <=  8'b1100_0111;//L */
			default:sen_duan_r  <=  8'b0000_0000;
		endcase
	end
end

assign sen_duan = {dot,sen_duan_r[6:0]};
assign sen_wei = sen_wei_r;

endmodule
