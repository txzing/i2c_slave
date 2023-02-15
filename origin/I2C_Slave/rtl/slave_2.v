/*=============================================================================================================*\
		  Filename ﹕i2c_slave.v
			Author ﹕Adolph
	  Description  ﹕i2c reloop
		 Called by ﹕
Revision History   ﹕ 2022-5-7  V1.0  指令+地址+数据  仅支持2字节的读写《写时序存在问题》
						
					  2022-5-17 V2.0 优化读写时序
  			  Email﹕  
	Tips：同样是需要接收SCL、SDA，以及系统时钟，然后选定边界进行数据接收2022-5-7 11:14:01
	Sclk:400KHz
	Device Id: 0b1010000
	Memery Size: 16Byte
	
	从机只能发送ACK
	每接收完1byte数据后都发送一次ACK
	
	将SCLK的下降沿作为计数的开始/清零标志，低电平中间变化，高电平中间采样
	
					2022-5-17 12:56:17
				从机严格来说是没有时钟的，除了Sclk，上升沿来了就采数据，下降沿来了就发数据发数据
				高电平期间一直采数据，并计数个数，统计1的个数大于计数值一半，即认为采集高电平，否则为低电平
			2022-5-18 15:16:39 调试完毕	
\*=============================================================================================================*/
// `define Sclk_100KHz

// `define Sclk_3_4MHz

// `define Sclk_20KHz
module 	slave_2(
	input  wire			Clk		, //system clock 50MHz
	input  wire 		Rst_n	, //reset ，low valid
	
	input  wire 		Sclk 	, //串行时钟总线
	input  wire 		Sda_in	, //三态门的写法
	output reg  		Sda_oe	, //
	output reg  		Sda_o	, //
	
	output reg 			rw_flag	, //读写状态标志信号 0：写；1：读
	output reg 			Wr_vld	, //写数据有效标志
	output reg   [07:00]Wr_data	, //写入数据
	output reg 			Rd_vld	, //读数据有效标志
	output reg   [07:00]Rd_data	  //读出数据
);
//Parameter Declarations
	// `ifdef Sclk_20KHz
		// parameter SCLK_FRE = 32'd20_000;	//20KHz
	// `elsif Sclk_100KHz
		// parameter SCLK_FRE = 32'd100_000;	//100KHz 
	// `elsif Sclk_3_4MHz
		// parameter SCLK_FRE = 32'd3_400_000; //3.4MHZ
	// `else
		// parameter SCLK_FRE = 32'd400_000;	//400KHz
	// `endif
	
	parameter WR_CTRL_WORD = 8'hA0,
			  RD_CTRL_WORD = 8'hA1;	
   
	localparam IDLE		= 7'b000_0001, //空闲状态
			   START	= 7'b000_0010, //接收起始位状态
			   JUG_RW 	= 7'b000_0100, //接收读写写指令状态
			   RW_ADDR	= 7'b000_1000, //接收读 or 写地址状态
			   WR_DAT	= 7'b001_0000, //接收写数据状态
			   RD_DAT	= 7'b010_0000, //发送读数据状态
			   STOP		= 7'b100_0000; //接收停止位状态
			   
//Interrnal wire/reg declarations
	reg	[07:00]	state_c, state_n; //状态机信号	
	reg	[10:00]	cnt_sclk		; //sclk 高电平采集数据计数器
	reg	[10:00]	cnt_sdai_h	; //slck Sda_in 同为高电平计数器
	
	reg			bit_buf			; //高电平计数
	reg	[02:00]	samp_flag		; //低电平，且两个计数器都不为零，开始计数，记到3，保持，上升沿清零
	
	reg	[03:00]	cnt_bit 		; //位计数器
	reg	[07:00]	cnt_byte		; //读写字节数计数器	
	reg	[03:00]	RW_Addr			; //读写地址信号	
	
	reg [07:00]	data_buf		; //数据暂存	
	reg [07:00]	memery [15:00]	; //16Byte 数据存储空间
	
	reg	[01:00]	r_scl,r_sda		; //寄存打拍，用于边沿检测
	
	wire		scl_neg,scl_pos	; //Sclk 双边沿
	wire		sda_neg,sda_pos	; //Sdat 双边沿
	
	//状态跳转条件定义
	wire 		idle2start		;
	wire 		start2jug_rw	;
	wire 		jug_rw2rw_addr	;
	wire 		jug_rw2rd_dat	;
	wire 		jug_rw2idle		;
	wire 		rw_addr2wr_dat  ;
	wire		wr_dat2start	; //
	wire 		wr_dat2stop     ;
	wire 		rd_dat2stop     ;
	wire 		stop2idle		;
	
//Logic Description		
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			r_scl <= 2'b0;
			r_sda <= 2'b0;
		end   
		else begin  
			r_scl <= {r_scl[0],Sclk};
			r_sda <= {r_sda[0],Sda_in};
		end  
	end //always end
	
	assign scl_neg	 = r_scl == 2'b10;
	assign scl_pos	 = r_scl == 2'b01;
	assign sda_neg	 = r_sda == 2'b10;
	assign sda_pos	 = r_sda == 2'b01;
		
	//第一段设置状态转移空间
	always @(posedge Clk or negedge Rst_n)begin
		if(!Rst_n)begin
			state_c <= IDLE;
		end
		else begin 
			state_c <= state_n;
		end
	end
	//第二段、组合逻辑定义状态转移
	always@(*)begin
		case(state_c)
			IDLE:begin
				if(idle2start)begin
					state_n = START;
				end
				else begin
					state_n = IDLE;
				end
			end
			
			START:begin
				if(start2jug_rw)begin //Sclk 拉低后即跳转
					state_n = JUG_RW;
				end 
				else begin
					state_n = START;	
				end 
			end
			
			JUG_RW :begin
				if(jug_rw2rw_addr)begin
					state_n = RW_ADDR;
				end 	
				else if(jug_rw2rd_dat)begin
					state_n = RD_DAT;
				end 
				else if(jug_rw2idle)begin //未接收到正确指令
					state_n = IDLE; 
				end 
				else begin
					state_n = JUG_RW;	
				end 
			end 
			
			RW_ADDR:begin
				if(rw_addr2wr_dat)begin
					state_n = WR_DAT;
				end 
				else begin
					state_n = RW_ADDR;	
				end 
			end 
			
			WR_DAT:begin
				if(wr_dat2start)begin //接收到起始位
					state_n = START;
				end 
				else if(wr_dat2stop)begin
					state_n = STOP;
				end 
				else begin
					state_n = WR_DAT;
				end 
			end 
			
			RD_DAT:begin
				if(rd_dat2stop)begin
					state_n = STOP;
				end 
				else begin
					state_n = RD_DAT;
				end 
			end 
			STOP:begin
				if(stop2idle)begin
					state_n = IDLE;
				end 	
				else begin
					state_n = STOP;
				end 
			end 
			default: begin
				state_n = IDLE;
			end
		endcase
	end
	
	assign	idle2start		= state_c == IDLE	 && (sda_neg && Sclk);//起始位，Sdat 在 Sclk 高电平期间出现下降沿
	assign	start2jug_rw	= state_c == START	 && (scl_pos);//上升沿跳状态
	assign	jug_rw2rw_addr	= state_c == JUG_RW	 && (cnt_bit == 4'd8 && samp_flag == 3'd1 && data_buf == WR_CTRL_WORD);
	assign	jug_rw2rd_dat	= state_c == JUG_RW	 && (cnt_bit == 4'd8 && samp_flag == 3'd1 && data_buf == RD_CTRL_WORD);
	assign	jug_rw2idle		= state_c == JUG_RW	 && (cnt_bit == 4'd8 && samp_flag == 3'd1 && data_buf != WR_CTRL_WORD && data_buf != RD_CTRL_WORD);
	assign	rw_addr2wr_dat  = state_c == RW_ADDR && (cnt_bit == 4'd8 && scl_neg);
	assign	wr_dat2start   	= state_c == WR_DAT  && (Sclk && sda_neg);//起始位，Sdat 在 Sclk 高电平期间出现下降沿
	assign	wr_dat2stop     = state_c == WR_DAT  && (Sclk && sda_pos);
	assign	rd_dat2stop     = state_c == RD_DAT  && (cnt_bit == 4'd8 && Sclk && Sda_in);//检测到NACK
	assign 	stop2idle		= state_c == STOP	 && (Sclk && Sda_in && cnt_sclk >= 11'd50);//等待1 us
	
	//第三段，定义状态机输出情况，可以时序逻辑，也可以组合逻辑
		//rw_flag
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			rw_flag <= 1'b0;
		end  
		else if(state_c == RD_DAT)begin  
			rw_flag <= 1'b1;
		end  
		else begin  
			rw_flag <= 1'b0;
		end  
	end //always end
		//cnt_sclk		
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			cnt_sclk <= 'd0;
			cnt_sdai_h <= 'd0;
		end  
		else if(state_c == IDLE || state_c == START)begin  
			cnt_sclk <= 'd0;
			cnt_sdai_h <= 'd0;
		end  
		else if(state_c == JUG_RW || state_c == RW_ADDR 
		   || state_c == WR_DAT/*  || state_c == RD_DAT */)begin
			if(scl_pos)begin //上升沿清零
				cnt_sclk <= 'd0;
				cnt_sdai_h <= 'd0;
			end 
			else if(Sclk)begin //高电平计数
				cnt_sclk <= cnt_sclk + 11'd1;
				if(Sda_in)begin
					cnt_sdai_h <= cnt_sdai_h + 11'd1;
				end 
			end 
			else begin
				cnt_sclk <= cnt_sclk;
				cnt_sdai_h <= cnt_sdai_h;
			end 
		end 
		else if(state_c == STOP)begin
			cnt_sclk <= cnt_sclk + 11'd1;
		end 
		else begin  
			cnt_sclk <= 'd0;
		end  
	end //always end
	
	//samp_flag
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			samp_flag <= 3'd0;
		end  
		else if(scl_pos)begin  
			samp_flag <= 3'd0;
		end  
		else if(samp_flag == 3'd7)begin
			samp_flag <= 3'd7;
		end 
		else if(cnt_sclk != 0 && ~Sclk)begin
			samp_flag <= samp_flag + 3'd1;
		end 
		else begin  
			samp_flag <= samp_flag;
		end  
	end //always end
	
	
		//cnt_bit
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			cnt_bit <= 4'd0;
		end  
		else if(state_c == IDLE || state_c == START || state_c == STOP)begin
			cnt_bit <= 4'd0;
		end 
		else if(state_c != IDLE && state_c != START && state_c != STOP)begin  
			if(cnt_bit == 4'd8 && scl_neg)begin
				cnt_bit <= 4'd0;
			end 
			else if(scl_neg)begin
				cnt_bit <= cnt_bit + 4'd1;
			end 
		end  
		else begin  
			cnt_bit <= cnt_bit;
		end  
	end //always end
		
		//cnt_byte
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			cnt_byte <= 5'd0;
		end  
		else if(state_c == IDLE || state_c == START || state_c == STOP)begin
			cnt_byte <= 5'd0;
		end 
		else if((state_c == WR_DAT || state_c == RD_DAT)
			  &&(cnt_bit == 4'd8 && scl_neg))begin  
			cnt_byte <= cnt_byte + 5'd1;
		end  
		else begin  
			cnt_byte <= cnt_byte;
		end  
	end //always end
	
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			Sda_o 	 <= 1'b0;
			Sda_oe 	 <= 1'b0;		
			Wr_vld	 <= 1'b0;
			Wr_data	 <= 8'd0;
			Rd_vld	 <= 1'b0;
			Rd_data	 <= 8'd0;	
			data_buf <= 8'd0;	
			RW_Addr  <= 4'd0;
			bit_buf  <= 1'b0;
		end   
		else begin  
			case(state_c)
				IDLE:begin
					Sda_o 	 <= 1'b0;
					Sda_oe 	 <= 1'b0;		
					Wr_vld	 <= 1'b0;
					Wr_data	 <= 8'd0;
					Rd_vld	 <= 1'b0;
					data_buf <= 8'd0;
					bit_buf  <= 1'b0;
				end 
				// START:
				JUG_RW:begin
					if(cnt_bit == 4'd7 && scl_neg)begin
						Sda_o 	 <= 1'b0;
						Sda_oe 	 <= 1'b1;//接收总线控制权，发送应答位
					end 
					else if(cnt_bit == 4'd8 && scl_neg)begin
						if(data_buf == RD_CTRL_WORD)begin
							Sda_o 	 <= 1'b0;
							Sda_oe 	 <= 1'b1;//如果接受的是读指令，则不必释放总线，从机准备发数据
						end 
						else begin
							Sda_o 	 <= 1'b0;
							Sda_oe 	 <= 1'b0;//应答位发送完成，释放总线控制权
						end 
					end 
					else if(cnt_bit <= 4'd8)begin //接收数据
						if(cnt_sdai_h != cnt_sclk)begin
							bit_buf <= 1'b0;
						end 
						else begin
							bit_buf <= 1'b1;
						end 						
					end 
					if (scl_neg && cnt_bit < 4'd8)begin
						data_buf <= {data_buf[6:0],bit_buf};
					end 
					else begin
						data_buf <= data_buf;
					end 
				end 
				RW_ADDR:begin
					if(cnt_bit == 4'd7 && scl_neg)begin
						Sda_oe <= 1'b1; //接收总线控制权，发送应答位
						Sda_o  <= 1'b0;						
					end 
					else if(cnt_bit == 4'd8 && scl_neg)begin
						Sda_oe <= 1'b0; //应答位发送完成，释放总线控制权
						Sda_o  <= 1'b0;
						RW_Addr<= data_buf[3:0]; //地址赋值
					end 						
					else if(cnt_bit <= 4'd8)begin //接收数据
						if(cnt_sdai_h == cnt_sclk)begin
							bit_buf <= 1'b1;
						end 
						else begin
							bit_buf <= 1'b0;
						end 						
					end 
					if (scl_neg && cnt_bit < 4'd8)begin
						data_buf <= {data_buf[6:0],bit_buf};
					end 
					else begin
						data_buf <= data_buf;
					end 
				end 
				WR_DAT	:begin
					if(cnt_bit == 4'd7 && scl_neg)begin
						Sda_oe <= 1'b1; //接收总线控制权，发送应答位
						Sda_o  <= 1'b0;						
					end 
					else if(cnt_bit == 4'd8 && scl_neg)begin
						Sda_oe <= 1'b0; //应答位发送完成，释放总线控制权
						Sda_o  <= 1'b0;
						RW_Addr<= RW_Addr + 4'd1; //每写完 1byte data 写地址自增 1
						Wr_vld <= 1'b1;
						memery[RW_Addr]<= data_buf; //数据写入
						Wr_data<= data_buf;
					end 						
					else if(cnt_bit <= 4'd8)begin //接收数据
						if(cnt_sdai_h == cnt_sclk)begin
							bit_buf <= 1'b1;
						end 
						else begin
							bit_buf <= 1'b0;
						end 						
					end 
					if (scl_neg && cnt_bit < 4'd8)begin
						data_buf <= {data_buf[6:0],bit_buf};
					end 
					else begin
						Wr_vld <= 1'b0;
						data_buf <= data_buf;
					end 
				end
				RD_DAT	:begin	
					data_buf <= memery[RW_Addr]; 
					Rd_data	 <= data_buf;//传出读的数据
					if(cnt_bit == 4'd7 && scl_neg)begin
						Sda_oe   <= 1'b0; //释放总线控制权
						Sda_o    <= 1'b0;						
					end
					else if(cnt_bit == 4'd8 && scl_neg)begin
						Sda_oe <= 1'b1; //接管总线控制权
						RW_Addr<= RW_Addr + 4'd1; //每写完 1byte data 写地址自增 1
						cnt_byte <= cnt_byte + 5'd1;
						Rd_vld <= 1'b1;						
					end 				
					else if(~Sclk && cnt_bit < 4'd8)begin //发送数据
						Sda_oe<= 1'b1;
						Sda_o <= data_buf[7 - cnt_bit]; 
					end 
					else begin							
						Rd_vld 	 <= 1'b0;						
					end 
				end
				// STOP:
				default: ;
			endcase
		end  
	end //always end
	
endmodule 
