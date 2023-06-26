
/*=============================================================================================================*\
		  Filename ﹕i2c_slave.v
			Author ﹕Adolph
	  Description  ﹕i2c reloop
		 Called by ﹕
Revision History   ﹕ 2022-5-7  V1.0  指令+地址+数据  仅支持2字节的读写《写时序存在问题》
						
					  2022-5-17 V2.0 优化读写时序
  			  Email﹕  
	Tips：同样是需要接收SCL、SDA，以及系统时钟，然后选定边界进行数据接收2022-5-7 11:14:01
	scl:400KHz
	Device Id: 0b1010000
	Memery Size: 16Byte
	
	从机只能发送ACK
	每接收完1byte数据后都发送一次ACK
	
	将scl的下降沿作为计数的开始/清零标志，低电平中间变化，高电平中间采样
	
					2022-5-17 12:56:17
				从机严格来说是没有时钟的，除了scl，上升沿来了就采数据，下降沿来了就发数据发数据
				高电平期间一直采数据，并计数个数，统计1的个数大于计数值一半，即认为采集高电平，否则为低电平
			2022-5-18 15:16:39 调试完毕	
			
			
	2023.2.9		
		Modified by TX:			
    目前只做支持 2byte reg_addr寻址 , 读写1byte data 的类型,支持连续读与连续写	
    后续可扩展寻址空间与读写的数据空间	
    
注意：对于Xilinx的FPGA的三态门中，T为0代表输出，T为1代表输入
经过测试，在100KHz和在400KHz下可正常同学
    
    2023.2.15
        Modified by TX:
    经过测试功能均无误
    对于地址0X78-0x7B,在7位地址中被限制,具体可看IIC地址定义
    
    2023.2.20
        Modified by TX:
    出现bug,当设备地址不对时，接管总线给出非应答，造成总线上其他地址不能正常访问
    将其修改为当设备地址不对时，释放总线控制权，不操作。只有当设备地址正确时，才对总线操作
    
    2023.3.8
        Modified by TX:
        将这个模块改为fake iic,不涉及设备地址的寄存器地址等操作

vivado下用ila调试：
(* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)
\*=============================================================================================================*/
module 	fake_eeprom_ar0233
#(
    parameter   I2C_SLAVE_ADDR      = 7'b1010000,   //7bit i2c slave addr
//    parameter   REG_DEVICE_ADDR     = 16'h0000  ,   //设备地址的寄存器地址
//    parameter   DEVICE_ADDR_BIT     = 1'b0      ,   //写入REG_DEVICE_ADDR的7位device_addr值，存放在低7位还是高7位,0代表低7位
    parameter   I2C_SLAVE_REG_MODE  = 1'b1      ,   // i2c reg width,1-16bit, 0-8bit
    parameter   I2C_SLAVE_DAT_MODE  = 1'b0      ,   // i2c reg width, 2-32bit, 1-16bit, 0-8bit  //预留
    parameter   SDA_T_POLARITY      = 1'b0          // sda的输出极性，高电平作为输出，还是低电平作为输出

)

(
	input wire  		sys_clk		/* synthesis syn_keep = 1 */, //system clock 50MHz
	input wire   		sys_rst_n	/* synthesis syn_keep = 1 */, //reset ，low valid 
	input wire   		scl         /* synthesis syn_keep = 1 */, //串行时钟总线
	input wire   		sda_in	, //三态门的写法
	output wire  		sda_t	, //
	output reg  		sda_o	,
    input               fake_eeprom_addr_vld,
    input [6:0]         fake_eeprom_addr
);	
   
	localparam IDLE		  = 8'b0000_0001, //空闲状态
			   START	  = 8'b0000_0010, //接收起始位状态
			   JUG_RW 	  = 8'b0000_0100, //判断接收读写指令状态
			   RW_ADDR_16 = 8'b0000_1000, //接收读写地址状态 2byte
			   RW_ADDR	  = 8'b0001_0000, //接收读写地址状态
			   WR_DAT	  = 8'b0010_0000, //接收写数据状态
			   RD_DAT	  = 8'b0100_0000, //发送读数据状态
			   STOP		  = 8'b1000_0000; //接收停止位状态
			   
//Interrnal wire/reg declarations
    reg [6:0]   device_addr     ;
	reg [7:0]   WR_CTRL_WORD    ;
	reg [7:0]   RD_CTRL_WORD    ;
	reg	[7:0]	state_c         ; 
    reg [7:0]   state_n         ; //状态机信号	
	reg	[9:0]	scl_cnt  		; //scl 高电平采集数据计数器
    reg [7:0 ]  sda_cnt         ; //在scl高电平期间，基于sysclk,对sda的高电平进行计数
	
	
	reg	[3:0]	cnt_bit 		; //比特位计数器
	
	reg	[15:0]	reg_addr		; //读写寄存器地址
	reg [7:0]	memory [339:0]	; //暂定数据存储空间	
	
	reg [7:0]	data_r		    ; //缓存接收到的数据
    reg [7:0]	rd_data         ; //暂存待发送数据
	reg	[1:0]	scl_r,sda_r		; //寄存打拍，用于边沿检测
    reg         end_9b          ;//9bit数据处理完，包含应答位
    reg         rev_H_flag      ;//接收高电平信号标志
    reg         rev_L_flag      ;//接收高电平信号标志
    reg         send_ack_flag   ;//发送应答标志位，脉冲信号
    reg         wr_vld          ;//数据写入寄存器有效信号
    reg         rd_vld          ;//数据从寄存器读出有效信号
	
	wire		scl_neg,scl_pos	; //scl 双边沿
	wire		sda_neg,sda_pos	; //sdat 双边沿   
   
    wire        add_scl_cnt         ; //计数器累加条件
	wire        end_scl_cnt         ; //计数器结束计数条件
	//状态跳转条件定义
	wire 		idle2start		    ;
	wire 		start2jug_rw	    ;
    wire        jug_rw2rw_addr_16   ;
	wire 		jug_rw2rw_addr	    ;
	wire 		jug_rw2rd_dat	    ;
	wire 		jug_rw2idle		    ;
    wire        rw_addr_162rw_addr  ;
    wire        rw_addr_162idel     ;
	wire 		rw_addr2wr_dat      ;
    wire        rw_addr2idel        ;
	wire		wr_dat2start	    ; //
	wire 		wr_dat2stop         ;
	wire 		rd_dat2stop         ;
    wire        rd_dat2idle         ;
	wire 		stop2idle		    ;
    
//  reg [7:0]    ROReg0 ;//定义四个只读寄存器
//	reg [7:0]    ROReg1 ;
//  reg [7:0]    ROReg2 ;	
//	reg [7:0]    ROReg3 ;
  
    wire         rst_n;
reset_sync  u_reset_sync  //异步复位同步释放
(
/*input  	*/.sys_clk		(sys_clk),
/*input  	*/.sys_rst_n  	(sys_rst_n),
/*output 	*/.rst_sync_n   (rst_n)

);

//在vivado三态门中，T为0代表输出
    reg     sda_oe;//输出使能信号，1代表输出
    assign  sda_t = SDA_T_POLARITY? (sda_oe):(!sda_oe);
 
    always @(posedge sys_clk)begin  
		if(!rst_n)begin  
			scl_r <= 2'd0;
			sda_r <= 2'd0;
		end   
		else begin  
			scl_r <= {scl_r[0],scl};
			sda_r <= {sda_r[0],sda_in};
		end  
	end //always end
	
	assign scl_neg	 = scl_r == 2'b10;
	assign scl_pos	 = scl_r == 2'b01;
	assign sda_neg	 = sda_r == 2'b10;
	assign sda_pos	 = sda_r == 2'b01;
		
	//第一段设置状态转移
	always @(posedge sys_clk)begin
		if(!rst_n)begin
			state_c <= IDLE;
		end
		else begin 
			state_c <= state_n;
		end
	end
    
	//第二段、组合逻辑定义状态转移
	always@(*)begin
		case(state_c)
			IDLE :
            begin
				if(idle2start)begin
					state_n = START;
				end
				else begin
					state_n = IDLE;
				end
			end
			
			START :
            begin
				if(start2jug_rw)begin //scl 拉低后即跳转
					state_n = JUG_RW;
				end 
				else begin
					state_n = START;	
				end 
			end
			
			JUG_RW :
            begin
                if(jug_rw2idle)begin
                    state_n = IDLE;
                end               
				else if(jug_rw2rw_addr_16)begin
					state_n = RW_ADDR_16;
				end 
                else if(jug_rw2rw_addr)begin
					state_n = RW_ADDR;
				end                 
				else if(jug_rw2rd_dat)begin
					state_n = RD_DAT;
				end 
				else begin
					state_n = JUG_RW;	
				end 
			end 
			
			RW_ADDR_16 :
            begin      //接收2byte寄存器地址的高byte
                if(rw_addr_162idel)begin
                    state_n = IDLE;
                end   
				else if(rw_addr_162rw_addr)begin
					state_n = RW_ADDR;
				end 
				else begin
					state_n = RW_ADDR_16;	
				end 
			end 
			
			RW_ADDR :
            begin
                if(rw_addr2idel)begin
                    state_n = IDLE;
                end   
				else if(rw_addr2wr_dat)begin
					state_n = WR_DAT;
				end 
				else begin
					state_n = RW_ADDR;	
				end 
			end 
			
			WR_DAT :
            begin
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
			
			RD_DAT :
            begin
                if(rd_dat2idle)begin
                    state_n = IDLE;
                end   
				else if(rd_dat2stop)begin
					state_n = STOP;
				end 
				else begin
					state_n = RD_DAT;
				end 
			end 
			STOP :
            begin
				if(stop2idle)begin
					state_n = IDLE;
				end 	
				else begin
					state_n = STOP;
				end 
			end 
			default: 
            begin
				state_n = IDLE;
			end
		endcase
	end

	assign	idle2start			= state_c == IDLE	 && sda_neg && scl_r[1];//起始位，sdat 在 scl 高电平期间出现下降沿
	assign	start2jug_rw		= state_c == START	 && scl_pos;//上升沿跳状态
	assign	jug_rw2rw_addr_16	= state_c == JUG_RW	 && end_9b && (data_r == WR_CTRL_WORD && I2C_SLAVE_REG_MODE );
	assign	jug_rw2rw_addr	  	= state_c == JUG_RW	 && end_9b && (data_r == WR_CTRL_WORD && !I2C_SLAVE_REG_MODE);
	assign	jug_rw2rd_dat	  	= state_c == JUG_RW	 && end_9b && data_r == RD_CTRL_WORD;
	assign	jug_rw2idle		  	= ((state_c == JUG_RW) && end_9b && (data_r != WR_CTRL_WORD && data_r != RD_CTRL_WORD)) || (scl_r[1] && sda_pos);	
	assign	rw_addr_162rw_addr	= state_c == RW_ADDR_16	 && end_9b;
    assign  rw_addr_162idel     = state_c == RW_ADDR_16 && ((scl_r[1] && sda_neg) || (scl_r[1] && sda_pos));
	assign	rw_addr2wr_dat    	= state_c == RW_ADDR && end_9b;//寄存器地址为2byte的话，cnt_bit要变
    assign  rw_addr2idel        = state_c == RW_ADDR && ((scl_r[1] && sda_neg) || (scl_r[1] && sda_pos));
	assign	wr_dat2start   	  	= state_c == WR_DAT  && (scl_r[1] && sda_neg);//起始位，sdat 在 scl 高电平期间出现下降沿
	assign	wr_dat2stop       	= state_c == WR_DAT  && (scl_r[1] && sda_pos);//出现停止位
	assign	rd_dat2stop       	= state_c == RD_DAT && (cnt_bit == 4'd8 && scl_r[1] && sda_r[1]);//检测到NACK
    assign  rd_dat2idle         = state_c == RD_DAT && ((scl_r[1] && sda_neg) || (scl_r[1] && sda_pos));
	assign 	stop2idle		  	= state_c == STOP && (scl_r[1] && sda_r[1] && scl_cnt >= 11'd50);//等待1 us
	
    
//end_9b    脉冲信号,8bit数据接受完,且发送完应答位(8bit数据，1bit应答)
	always @(posedge sys_clk)begin  
		if(!rst_n)begin  
			end_9b <= 1'b0;
		end  
		else if(!end_9b && (cnt_bit == 4'd8) && scl_neg)begin
			end_9b <= 1'b1;
		end 
        else if(end_9b)begin
			end_9b <= 1'b0;
		end 
		else begin  
			end_9b <= end_9b;
		end  
	end //always end
    
//cnt_bit
	always @(posedge sys_clk)begin  
		if(!rst_n)begin  
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
   
  
//对scl高电平计数，统计电平
    always @(posedge sys_clk)begin 
        if(!rst_n)begin 
            scl_cnt <= 0;
            sda_cnt <= 0;
        end    
        else if(add_scl_cnt)begin 
                if(end_scl_cnt)begin 
                    scl_cnt <= 0;
                    sda_cnt <= 0;
                end 
                else begin
                    scl_cnt <= scl_cnt + 1'b1;
                    if(sda_r[1] && scl_r[1])begin
                        sda_cnt <= sda_cnt + 1'b1;
                    end
                end 
        end 
        else if(state_c == STOP)begin //做延时计数器使用
			scl_cnt <= scl_cnt + 1'b1;
		end 
		else begin  
			scl_cnt <= 'd0;
            sda_cnt <= 0;
		end  
    end 
               
    assign add_scl_cnt = (state_c != IDLE && state_c != START);
    assign end_scl_cnt = add_scl_cnt && (scl_pos || scl_neg); //根据64 32 16 8 4 2 1 


//send_ack_flag    脉冲信号
	always @(posedge sys_clk)begin  
		if(!rst_n)begin  
			send_ack_flag <= 1'b0;
		end  
		else if(!send_ack_flag && cnt_bit == 4'd8 && (scl_cnt == 10'd52) && !scl_r[1])begin
			send_ack_flag <= 1'b1;
		end 
        else if(send_ack_flag)begin
			send_ack_flag <= 1'b0;
		end 
		else begin  
			send_ack_flag <= send_ack_flag;
		end  
	end //always end

	
	always @(posedge sys_clk)begin  
		if(!rst_n)begin  
			sda_oe 	 <= 1'b0;
            sda_o 	 <= 1'b1;
		end   
		else begin  
			case(state_c)
				IDLE:begin					
					sda_oe 	 <= 1'b0;	
                    sda_o 	 <= 1'b1;                    
				end 
				// START:
				JUG_RW:begin 
					if(send_ack_flag && (data_r[7:1]==device_addr))begin
                        sda_oe 	 <= 1'b1;//接收总线控制权，发送应答位
						sda_o 	 <= 1'b0;				
					end                 
					else if(end_9b)
                    begin
                        if(data_r == RD_CTRL_WORD)begin
                            sda_oe 	 <= 1'b1;//如果接受的是读指令，则不必释放总线，从机准备发数据
                            sda_o 	 <= 1'b0;  
                        end 
                        else if(data_r == WR_CTRL_WORD)begin //应答位发送完成
                        sda_oe 	 <= 1'b0;//应答位发送完成，释放总线控制权
                        sda_o 	 <= 1'b1;  
                        end    
                        else begin	//其他地址的操作，则释放总线				
                            sda_oe 	 <= 1'b0;	
                            sda_o 	 <= 1'b1;                    
                        end 
                    end                    
                    else 
                    begin
                        sda_oe 	 <= sda_oe;
                        sda_o 	 <= sda_o;  
                    end             
				end 
				RW_ADDR_16:begin
					if(send_ack_flag)begin
						sda_oe <= 1'b1; //接收总线控制权，发送应答位
						sda_o  <= 1'b0;	//给出低电平,ack					
					end 
					else if(end_9b)begin
						sda_oe <= 1'b0; //应答位发送完成，释放总线控制权
						sda_o  <= 1'b1;
					end
                    else begin
                        sda_oe 	 <= sda_oe;
                        sda_o 	 <= sda_o;  
                    end                     
				end 
				RW_ADDR:begin
					if(send_ack_flag)begin
						sda_oe <= 1'b1; //接收总线控制权，发送应答位
						sda_o  <= 1'b0;						
					end 
					else if(end_9b)begin
						sda_oe <= 1'b0; //应答位发送完成，释放总线控制权
						sda_o  <= 1'b1;
					end 
                    else begin
                        sda_oe 	 <= sda_oe;
                        sda_o 	 <= sda_o;  
                    end                     
				end 
				WR_DAT	:begin
					if(send_ack_flag)begin
						sda_oe <= 1'b1; //接收总线控制权，发送应答位
						sda_o  <= 1'b0;						
					end 
					else if(end_9b)begin
						sda_oe <= 1'b0; //应答位发送完成，释放总线控制权
						sda_o  <= 1'b1;
					end 
                    else begin
                        sda_oe 	 <= sda_oe;
                        sda_o 	 <= sda_o;  
                    end                     
				end
				RD_DAT	:begin	
					if(send_ack_flag)begin //接受主机的应答
						sda_oe   <= 1'b0; 
						sda_o    <= 1'b1;						
					end
					else if(end_9b)begin
						sda_oe <= 1'b1; //接管总线控制权,继续输出					
					end 				
					else if(~scl_r[1] && cnt_bit < 4'd8 && scl_cnt[5])begin //scld发送数据
						sda_oe<= 1'b1;
						sda_o <= rd_data[7 - cnt_bit]; 
					end 
                    else begin
                        sda_oe 	 <= sda_oe;
                        sda_o 	 <= sda_o;  
                    end 
				end
                STOP  :begin
                    sda_oe   <= 1'b0;                
                    sda_o    <= 1'b1;					
				end
				default: ;
			endcase
		end  
	end //always end
    
//根据协议，scl高电平期间，sda不会翻转    
    always @(posedge sys_clk)begin  
		if(!rst_n)begin  
			rev_H_flag <= 1'b0;
            rev_L_flag <= 1'b0;
		end   
		else if(scl_neg && (cnt_bit < 4'd8) && (|sda_cnt[7:5])) begin  //scl高电平期间，sda高电平至少持续大于32个sys_clk 
            rev_H_flag <= 1'b1;
            rev_L_flag <= 1'b0;
		end
        else if(scl_neg && (cnt_bit < 4'd8) && !(|sda_cnt[7:5])) begin  
            rev_H_flag <= 1'b0;
            rev_L_flag <= 1'b1;
		end
        else begin
            rev_H_flag <= 1'b0;
            rev_L_flag <= 1'b0;
        end
    end 
    
    always @(posedge sys_clk)begin  
		if(!rst_n)begin  		
			wr_vld	 <= 1'b0;
			rd_vld	 <= 1'b0;
			data_r   <= 8'd0;	
			reg_addr <= 16'b00;
		end   
		else begin  
			case(state_c)
				IDLE:begin		
					wr_vld	 <= 1'b0;
					rd_vld	 <= 1'b0;
					data_r <= 8'd0;
				end 
				// START:
				JUG_RW:begin
                    if(end_9b)begin
						data_r <= 8'd0; 
					end
					else if(rev_H_flag)begin 
						data_r <= {data_r[6:0],1'b1};//如果在400KHz,速率下
					end 
                    else if(rev_L_flag)begin
                        data_r <= {data_r[6:0],1'b0};//如果在400KHz,速率下
                    end
					else begin
						data_r <= data_r;
					end 
				end 
				RW_ADDR_16:begin
                    if(end_9b)begin
						data_r <= 8'd0;
					end
                    else if(cnt_bit == 4'd8 && scl_pos)begin
						reg_addr[15:8] <= data_r; //地址赋值
					end 						
					else if(rev_H_flag)begin
						data_r <= {data_r[6:0],1'b1};//如果在400KHz,速率下
					end 
                    else if(rev_L_flag)begin
                        data_r <= {data_r[6:0],1'b0};//如果在400KHz,速率下
                    end
					else begin
						data_r <= data_r;
					end 
				end 
				RW_ADDR:begin
                    if(end_9b)begin
						data_r <= 8'd0; //地址赋值
					end
                    else 
                    if(cnt_bit == 4'd8 && scl_pos)begin
						reg_addr[7:0] <= data_r; //地址赋值
					end 						
					else if(rev_H_flag)begin //大于32
						data_r <= {data_r[6:0],1'b1};//如果在400KHz,速率下
					end 
                    else if(rev_L_flag)begin
                        data_r <= {data_r[6:0],1'b0};//如果在400KHz,速率下
                    end
					else begin
						data_r <= data_r;
					end 
				end 
				WR_DAT	:begin
                        if(end_9b)begin
                            data_r <= 8'd0;
                            reg_addr<= reg_addr + 1'd1; //每写完 1byte data 写地址自增 1                         
                        end 
                        else if(cnt_bit == 4'd8 && scl_pos)begin
                            wr_vld <= 1'b1;
                        end
                        else if(rev_H_flag)begin //统计在scl高电平期间，sda保持至少32个sys_clk高电平,就认为是采到高电平
                            data_r <= {data_r[6:0],1'b1};//如果在400KHz速率下,大概62个sys_clk,100KHz,大概250个sys_clk
                        end 
                        else if(rev_L_flag)begin
                            data_r <= {data_r[6:0],1'b0};//如果在400KHz,速率下
                        end
                        else begin
                            wr_vld <= 1'b0;
                            data_r <= data_r;
                        end 
				end
				RD_DAT	:begin	
					if(cnt_bit == 4'd8 && scl_pos)begin 
						reg_addr<= reg_addr + 4'd1; //每写完 1byte data 写地址自增 1
                        rd_vld 	 <= 1'b1;	                        
					end  
					else begin		
                        reg_addr<= reg_addr;					
						rd_vld 	 <= 1'b0;						
					end 
				end
				// STOP:
				default: ;
			endcase
		end  
	end //always end
    

//fake_iic中不涉及设备地址的读写
//寄存器地址0为设备地址
    always @(posedge sys_clk)begin  
        if(!rst_n)begin 
            device_addr <= I2C_SLAVE_ADDR;//7位地址
        end
        else if(fake_eeprom_addr_vld)begin  
            device_addr <= fake_eeprom_addr;
        end
//        else if(state_c == WR_DAT && wr_vld && (reg_addr == REG_DEVICE_ADDR))begin
//            if(DEVICE_ADDR_BIT)begin
//                device_addr <= data_r[7:1];//取高7位
//            end
//            else begin
//                device_addr <= data_r[6:0];//取低7位
//            end   
//        end
        else begin
            device_addr <= device_addr;
        end
    end
    

    
    always @(*)begin 
        WR_CTRL_WORD = {device_addr,1'b0};
        RD_CTRL_WORD = {device_addr,1'b1};
    end

/*
此处设置读写初值与可读写的寄存器
*/    
    always @(posedge sys_clk)begin  
    if(!rst_n)begin 
//        ROReg0         <=   8'hA0;// 只读寄存器
//        ROReg1         <=   8'hA1;// 这里是初始值
//        ROReg2         <=   8'hA2;// 这里是初始值
//        ROReg3         <=   8'hA3;// 这里是初始值
        memory[9'h000] <= 8'h16;
        memory[9'h001] <= 8'h09;
        memory[9'h002] <= 8'h18;
        memory[9'h003] <= 8'h01;
        memory[9'h004] <= 8'h01;
        memory[9'h005] <= 8'he2;
        memory[9'h006] <= 8'h59;
        memory[9'h007] <= 8'h37;
        memory[9'h008] <= 8'h18;
        memory[9'h009] <= 8'he6;
        memory[9'h00a] <= 8'hf9;
        memory[9'h00b] <= 8'hab;
        memory[9'h00c] <= 8'h40;
        memory[9'h00d] <= 8'he2;
        memory[9'h00e] <= 8'h59;
        memory[9'h00f] <= 8'h37;
        memory[9'h010] <= 8'h18;
        memory[9'h011] <= 8'he6;
        memory[9'h012] <= 8'hf9;
        memory[9'h013] <= 8'hab;
        memory[9'h014] <= 8'h40;
        memory[9'h015] <= 8'h9c;
        memory[9'h016] <= 8'ha2;
        memory[9'h017] <= 8'hea;
        memory[9'h018] <= 8'h0c;
        memory[9'h019] <= 8'hff;
        memory[9'h01a] <= 8'hf9;
        memory[9'h01b] <= 8'h8d;
        memory[9'h01c] <= 8'h40;
        memory[9'h01d] <= 8'h5d;
        memory[9'h01e] <= 8'h08;
        memory[9'h01f] <= 8'h1f;
        memory[9'h020] <= 8'h63;
        memory[9'h021] <= 8'ha7;
        memory[9'h022] <= 8'hfd;
        memory[9'h023] <= 8'h83;
        memory[9'h024] <= 8'h40;
        memory[9'h025] <= 8'he7;
        memory[9'h026] <= 8'h37;
        memory[9'h027] <= 8'h42;
        memory[9'h028] <= 8'hb4;
        memory[9'h029] <= 8'h16;
        memory[9'h02a] <= 8'h20;
        memory[9'h02b] <= 8'h32;
        memory[9'h02c] <= 8'h40;
        memory[9'h02d] <= 8'h97;
        memory[9'h02e] <= 8'h7a;
        memory[9'h02f] <= 8'h6d;
        memory[9'h030] <= 8'h4a;
        memory[9'h031] <= 8'h2a;
        memory[9'h032] <= 8'h3b;
        memory[9'h033] <= 8'h96;
        memory[9'h034] <= 8'h40;
        memory[9'h035] <= 8'h8c;
        memory[9'h036] <= 8'hc1;
        memory[9'h037] <= 8'h55;
        memory[9'h038] <= 8'hb4;
        memory[9'h039] <= 8'hb4;
        memory[9'h03a] <= 8'h90;
        memory[9'h03b] <= 8'hba;
        memory[9'h03c] <= 8'h40;
        memory[9'h03d] <= 8'hd2;
        memory[9'h03e] <= 8'h8f;
        memory[9'h03f] <= 8'hcc;
        memory[9'h040] <= 8'hee;
        memory[9'h041] <= 8'h6b;
        memory[9'h042] <= 8'h39;
        memory[9'h043] <= 8'h32;
        memory[9'h044] <= 8'h40;
        memory[9'h045] <= 8'h63;
        memory[9'h046] <= 8'h42;
        memory[9'h047] <= 8'h73;
        memory[9'h048] <= 8'h41;
        memory[9'h049] <= 8'h8c;
        memory[9'h04a] <= 8'h31;
        memory[9'h04b] <= 8'h96;
        memory[9'h04c] <= 8'h40;
        memory[9'h04d] <= 8'hdc;
        memory[9'h04e] <= 8'h6a;
        memory[9'h04f] <= 8'h20;
        memory[9'h050] <= 8'h3f;
        memory[9'h051] <= 8'hf8;
        memory[9'h052] <= 8'h1f;
        memory[9'h053] <= 8'hbb;
        memory[9'h054] <= 8'h40;
        memory[9'h055] <= 8'h49;
        memory[9'h056] <= 8'h5c;
        memory[9'h057] <= 8'h83;
        memory[9'h058] <= 8'hce;
        memory[9'h059] <= 8'hc3;
        memory[9'h05a] <= 8'hd7;
        memory[9'h05b] <= 8'h6a;
        memory[9'h05c] <= 8'h3f;
        memory[9'h05d] <= 8'h44;
        memory[9'h05e] <= 8'h43;
        memory[9'h05f] <= 8'h24;
        memory[9'h060] <= 8'h26;
        memory[9'h061] <= 8'hc0;
        memory[9'h062] <= 8'h56;
        memory[9'h063] <= 8'h44;
        memory[9'h064] <= 8'h3f;
        memory[9'h065] <= 8'h04;
        memory[9'h066] <= 8'hfa;
        memory[9'h067] <= 8'h73;
        memory[9'h068] <= 8'h61;
        memory[9'h069] <= 8'hfa;
        memory[9'h06a] <= 8'hf8;
        memory[9'h06b] <= 8'hae;
        memory[9'h06c] <= 8'h3f;
        memory[9'h06d] <= 8'h2b;
        memory[9'h06e] <= 8'hcc;
        memory[9'h06f] <= 8'he8;
        memory[9'h070] <= 8'h78;
        memory[9'h071] <= 8'h99;
        memory[9'h072] <= 8'h68;
        memory[9'h073] <= 8'hbe;
        memory[9'h074] <= 8'h3f;
    end
    else begin
        if (jug_rw2rd_dat || rd_vld) // --- I2C Read
        begin
            case (reg_addr)
//                16'h0000: rd_data <= DEVICE_ADDR_BIT?{device_addr,1'b0}:{1'b0,device_addr};//可读设备地址
//                16'h0001: rd_data <= ROReg0        ;  
//                16'h0002: rd_data <= ROReg1        ;  
//                16'h0003: rd_data <= ROReg2        ;  
//                16'h0004: rd_data <= ROReg3        ;  
                16'h0000: rd_data <= memory[9'h000][7:0];
                16'h0001: rd_data <= memory[9'h001][7:0];
                16'h0002: rd_data <= memory[9'h002][7:0];
                16'h0003: rd_data <= memory[9'h003][7:0];
                16'h0004: rd_data <= memory[9'h004][7:0];
                16'h0005: rd_data <= memory[9'h005][7:0];
                16'h0006: rd_data <= memory[9'h006][7:0];
                16'h0007: rd_data <= memory[9'h007][7:0];
                16'h0008: rd_data <= memory[9'h008][7:0];
                16'h0009: rd_data <= memory[9'h009][7:0];
                16'h000a: rd_data <= memory[9'h00a][7:0];
                16'h000b: rd_data <= memory[9'h00b][7:0];
                16'h000c: rd_data <= memory[9'h00c][7:0];
                16'h000d: rd_data <= memory[9'h00d][7:0];
                16'h000e: rd_data <= memory[9'h00e][7:0];
                16'h000f: rd_data <= memory[9'h00f][7:0];
                16'h0010: rd_data <= memory[9'h010][7:0];
                16'h0011: rd_data <= memory[9'h011][7:0];
                16'h0012: rd_data <= memory[9'h012][7:0];
                16'h0013: rd_data <= memory[9'h013][7:0];
                16'h0014: rd_data <= memory[9'h014][7:0];
                16'h0015: rd_data <= memory[9'h015][7:0];
                16'h0016: rd_data <= memory[9'h016][7:0];
                16'h0017: rd_data <= memory[9'h017][7:0];
                16'h0018: rd_data <= memory[9'h018][7:0];
                16'h0019: rd_data <= memory[9'h019][7:0];
                16'h001a: rd_data <= memory[9'h01a][7:0];
                16'h001b: rd_data <= memory[9'h01b][7:0];
                16'h001c: rd_data <= memory[9'h01c][7:0];
                16'h001d: rd_data <= memory[9'h01d][7:0];
                16'h001e: rd_data <= memory[9'h01e][7:0];
                16'h001f: rd_data <= memory[9'h01f][7:0];
                16'h0020: rd_data <= memory[9'h020][7:0];
                16'h0021: rd_data <= memory[9'h021][7:0];
                16'h0022: rd_data <= memory[9'h022][7:0];
                16'h0023: rd_data <= memory[9'h023][7:0];
                16'h0024: rd_data <= memory[9'h024][7:0];
                16'h0025: rd_data <= memory[9'h025][7:0];
                16'h0026: rd_data <= memory[9'h026][7:0];
                16'h0027: rd_data <= memory[9'h027][7:0];
                16'h0028: rd_data <= memory[9'h028][7:0];
                16'h0029: rd_data <= memory[9'h029][7:0];
                16'h002a: rd_data <= memory[9'h02a][7:0];
                16'h002b: rd_data <= memory[9'h02b][7:0];
                16'h002c: rd_data <= memory[9'h02c][7:0];
                16'h002d: rd_data <= memory[9'h02d][7:0];
                16'h002e: rd_data <= memory[9'h02e][7:0];
                16'h002f: rd_data <= memory[9'h02f][7:0]; 
                16'h0030: rd_data <= memory[9'h030][7:0];
                16'h0031: rd_data <= memory[9'h031][7:0];
                16'h0032: rd_data <= memory[9'h032][7:0];
                16'h0033: rd_data <= memory[9'h033][7:0];
                16'h0034: rd_data <= memory[9'h034][7:0];
                16'h0035: rd_data <= memory[9'h035][7:0];
                16'h0036: rd_data <= memory[9'h036][7:0];
                16'h0037: rd_data <= memory[9'h037][7:0];
                16'h0038: rd_data <= memory[9'h038][7:0];
                16'h0039: rd_data <= memory[9'h039][7:0];
                16'h003a: rd_data <= memory[9'h03a][7:0];
                16'h003b: rd_data <= memory[9'h03b][7:0];
                16'h003c: rd_data <= memory[9'h03c][7:0];
                16'h003d: rd_data <= memory[9'h03d][7:0];
                16'h003e: rd_data <= memory[9'h03e][7:0];
                16'h003f: rd_data <= memory[9'h03f][7:0]; 
                16'h0040: rd_data <= memory[9'h040][7:0];
                16'h0041: rd_data <= memory[9'h041][7:0];
                16'h0042: rd_data <= memory[9'h042][7:0];
                16'h0043: rd_data <= memory[9'h043][7:0];
                16'h0044: rd_data <= memory[9'h044][7:0];
                16'h0045: rd_data <= memory[9'h045][7:0];
                16'h0046: rd_data <= memory[9'h046][7:0];
                16'h0047: rd_data <= memory[9'h047][7:0];
                16'h0048: rd_data <= memory[9'h048][7:0];
                16'h0049: rd_data <= memory[9'h049][7:0];
                16'h004a: rd_data <= memory[9'h04a][7:0];
                16'h004b: rd_data <= memory[9'h04b][7:0];
                16'h004c: rd_data <= memory[9'h04c][7:0];
                16'h004d: rd_data <= memory[9'h04d][7:0];
                16'h004e: rd_data <= memory[9'h04e][7:0];
                16'h004f: rd_data <= memory[9'h04f][7:0];
                16'h0050: rd_data <= memory[9'h050][7:0];
                16'h0051: rd_data <= memory[9'h051][7:0];
                16'h0052: rd_data <= memory[9'h052][7:0];
                16'h0053: rd_data <= memory[9'h053][7:0];
                16'h0054: rd_data <= memory[9'h054][7:0];
                16'h0055: rd_data <= memory[9'h055][7:0];
                16'h0056: rd_data <= memory[9'h056][7:0];
                16'h0057: rd_data <= memory[9'h057][7:0];
                16'h0058: rd_data <= memory[9'h058][7:0];
                16'h0059: rd_data <= memory[9'h059][7:0];
                16'h005a: rd_data <= memory[9'h05a][7:0];
                16'h005b: rd_data <= memory[9'h05b][7:0];
                16'h005c: rd_data <= memory[9'h05c][7:0];
                16'h005d: rd_data <= memory[9'h05d][7:0];
                16'h005e: rd_data <= memory[9'h05e][7:0];
                16'h005f: rd_data <= memory[9'h05f][7:0];
                16'h0060: rd_data <= memory[9'h060][7:0];
                16'h0061: rd_data <= memory[9'h061][7:0];
                16'h0062: rd_data <= memory[9'h062][7:0];
                16'h0063: rd_data <= memory[9'h063][7:0];
                16'h0064: rd_data <= memory[9'h064][7:0];
                16'h0065: rd_data <= memory[9'h065][7:0];
                16'h0066: rd_data <= memory[9'h066][7:0];
                16'h0067: rd_data <= memory[9'h067][7:0];
                16'h0068: rd_data <= memory[9'h068][7:0];
                16'h0069: rd_data <= memory[9'h069][7:0];
                16'h006a: rd_data <= memory[9'h06a][7:0];
                16'h006b: rd_data <= memory[9'h06b][7:0];
                16'h006c: rd_data <= memory[9'h06c][7:0];
                16'h006d: rd_data <= memory[9'h06d][7:0];
                16'h006e: rd_data <= memory[9'h06e][7:0];
                16'h006f: rd_data <= memory[9'h06f][7:0]; 
                16'h0070: rd_data <= memory[9'h070][7:0];
                16'h0071: rd_data <= memory[9'h071][7:0];
                16'h0072: rd_data <= memory[9'h072][7:0];
                16'h0073: rd_data <= memory[9'h073][7:0];
                16'h0074: rd_data <= memory[9'h074][7:0];


//                REG_DEVICE_ADDR : rd_data <= DEVICE_ADDR_BIT?{device_addr,1'b0}:{1'b0,device_addr};//可读设备地址              
                
            default: rd_data <= 8'hFF; // i2c读非法内部地址, 返回0xff
            endcase
        end
        else if (wr_vld) // --- I2C Write
        begin
            case (reg_addr)//可模拟真实写入的寄存器  
//            16'h0005: memory[0][7:0] <= data_r;   
//            16'h0006: memory[1][7:0] <= data_r;     
//            16'h0007: memory[2][7:0] <= data_r;
//            16'h0008: memory[3][7:0] <= data_r;
//            16'h0009: memory[4][7:0] <= data_r;
//            16'h000a: memory[5][7:0] <= data_r;
//            16'h000b: memory[6][7:0] <= data_r;
//            16'h000c: memory[7][7:0] <= data_r;
            endcase
        end
    end
end
    
endmodule 
