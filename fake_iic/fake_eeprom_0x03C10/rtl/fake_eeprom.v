
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
module 	fake_eeprom
#(
    parameter   I2C_SLAVE_ADDR      = 7'b1010000,   //7bit i2c slave addr
//    parameter   REG_DEVICE_ADDR     = 16'h0000  ,   //设备地址的寄存器地址
//    parameter   DEVICE_ADDR_BIT     = 1'b0      ,   //写入REG_DEVICE_ADDR的7位device_addr值，存放在低7位还是高7位,0代表低7位
    parameter   I2C_SLAVE_REG_MODE  = 1'b0      ,   // i2c reg width,1-16bit, 0-8bit
    parameter   I2C_SLAVE_DAT_MODE  = 1'b0      ,   // i2c reg width, 2-32bit, 1-16bit, 0-8bit  //预留
    parameter   SDA_T_POLARITY      = 1'b0          // sda的输出极性，高电平作为输出，还是低电平作为输出

)

(
	input wire  		sys_clk		/* synthesis syn_keep = 1 */, //system clock 50MHz
	input wire   		sys_rst_n	/* synthesis syn_keep = 1 */, //reset ，low valid 
	input wire   		scl         /* synthesis syn_keep = 1 */, //串行时钟总线
	input wire   		sda_in	, //三态门的写法
	output wire  		sda_t	, //
	output reg  		sda_o	
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
        memory[9'h000] <= 8'h01;
        memory[9'h001] <= 8'h02;
        memory[9'h002] <= 8'h38;
        memory[9'h003] <= 8'h36;
        memory[9'h004] <= 8'h35;
        memory[9'h005] <= 8'h37;
        memory[9'h006] <= 8'h2e;
        memory[9'h007] <= 8'h33;
        memory[9'h008] <= 8'h35;
        memory[9'h009] <= 8'h31;
        memory[9'h00a] <= 8'h2e;
        memory[9'h00b] <= 8'h30;
        memory[9'h00c] <= 8'h30;
        memory[9'h00d] <= 8'h33;
        memory[9'h00e] <= 8'h20;
        memory[9'h00f] <= 8'h20;
        memory[9'h010] <= 8'h20;
        memory[9'h011] <= 8'h20;
        memory[9'h012] <= 8'h4f;
        memory[9'h013] <= 8'h58;
        memory[9'h014] <= 8'h30;
        memory[9'h015] <= 8'h33;
        memory[9'h016] <= 8'h43;
        memory[9'h017] <= 8'h31;
        memory[9'h018] <= 8'h30;
        memory[9'h019] <= 8'h20;
        memory[9'h01a] <= 8'h20;
        memory[9'h01b] <= 8'h20;
        memory[9'h01c] <= 8'h20;
        memory[9'h01d] <= 8'h20;
        memory[9'h01e] <= 8'h20;
        memory[9'h01f] <= 8'h20; // 1837
        memory[9'h020] <= 8'h20;
        memory[9'h021] <= 8'h20;
        memory[9'h022] <= 8'h4d;
        memory[9'h023] <= 8'h41;
        memory[9'h024] <= 8'h58;
        memory[9'h025] <= 8'h39;
        memory[9'h026] <= 8'h36;
        memory[9'h027] <= 8'h37;
        memory[9'h028] <= 8'h31;
        memory[9'h029] <= 8'h37;
        memory[9'h02a] <= 8'h46;
        memory[9'h02b] <= 8'h20;
        memory[9'h02c] <= 8'h20;
        memory[9'h02d] <= 8'h20;
        memory[9'h02e] <= 8'h20;
        memory[9'h02f] <= 8'h20; // 2077
        memory[9'h030] <= 8'h20;
        memory[9'h031] <= 8'h20;
        memory[9'h032] <= 8'h4f;
        memory[9'h033] <= 8'h46;
        memory[9'h034] <= 8'h2d;
        memory[9'h035] <= 8'h54;
        memory[9'h036] <= 8'h31;
        memory[9'h037] <= 8'h39;
        memory[9'h038] <= 8'h32;
        memory[9'h039] <= 8'h46;
        memory[9'h03a] <= 8'h31;
        memory[9'h03b] <= 8'h20;
        memory[9'h03c] <= 8'h20;
        memory[9'h03d] <= 8'h20;
        memory[9'h03e] <= 8'h20;
        memory[9'h03f] <= 8'h20; // 2317
        memory[9'h040] <= 8'h20;
        memory[9'h041] <= 8'h20;
        memory[9'h042] <= 8'h42;
        memory[9'h043] <= 8'h4f;
        memory[9'h044] <= 8'h53;
        memory[9'h045] <= 8'h43;
        memory[9'h046] <= 8'h48;
        memory[9'h047] <= 8'h20;
        memory[9'h048] <= 8'h57;
        memory[9'h049] <= 8'h33;
        memory[9'h04a] <= 8'h01;
        memory[9'h04b] <= 8'h02;
        memory[9'h04c] <= 8'h1c;
        memory[9'h04d] <= 8'hde;
        memory[9'h04e] <= 8'h00;
        memory[9'h04f] <= 8'h00; // 2557
        memory[9'h050] <= 8'h00;
        memory[9'h051] <= 8'h5a;
        memory[9'h052] <= 8'h43;
        memory[9'h053] <= 8'h30;
        memory[9'h054] <= 8'h30;
        memory[9'h055] <= 8'h30;
        memory[9'h056] <= 8'h30;
        memory[9'h057] <= 8'h34;
        memory[9'h058] <= 8'h30;
        memory[9'h059] <= 8'h34;
        memory[9'h05a] <= 8'h37;
        memory[9'h05b] <= 8'h33;
        memory[9'h05c] <= 8'h39;
        memory[9'h05d] <= 8'h16;
        memory[9'h05e] <= 8'h0b;
        memory[9'h05f] <= 8'h10; // 2797
        memory[9'h060] <= 8'h12;
        memory[9'h061] <= 8'h17;
        memory[9'h062] <= 8'h1c;
        memory[9'h063] <= 8'h53;
        memory[9'h064] <= 8'h53;
        memory[9'h065] <= 8'h32;
        memory[9'h066] <= 8'h56;
        memory[9'h067] <= 8'h30;
        memory[9'h068] <= 8'h30;
        memory[9'h069] <= 8'h35;
        memory[9'h06a] <= 8'h41;
        memory[9'h06b] <= 8'h31;
        memory[9'h06c] <= 8'h30;
        memory[9'h06d] <= 8'h30;
        memory[9'h06e] <= 8'h30;
        memory[9'h06f] <= 8'h31; // 3037
        memory[9'h070] <= 8'h32;
        memory[9'h071] <= 8'h32;
        memory[9'h072] <= 8'h34;
        memory[9'h073] <= 8'h35;
        memory[9'h074] <= 8'h30;
        memory[9'h075] <= 8'h30;
        memory[9'h076] <= 8'h36;
        memory[9'h077] <= 8'h36;
        memory[9'h078] <= 8'h20;
        memory[9'h079] <= 8'h20;
        memory[9'h07a] <= 8'h20;
        memory[9'h07b] <= 8'h20;
        memory[9'h07c] <= 8'h20;
        memory[9'h07d] <= 8'h20;
        memory[9'h07e] <= 8'h20;
        memory[9'h07f] <= 8'h20; // 3277
        memory[9'h080] <= 8'h20;
        memory[9'h081] <= 8'h20;
        memory[9'h082] <= 8'h20;
        memory[9'h083] <= 8'h20;
        memory[9'h084] <= 8'h20;
        memory[9'h085] <= 8'h00;
        memory[9'h086] <= 8'h00;
        memory[9'h087] <= 8'h00;
        memory[9'h088] <= 8'h00;
        memory[9'h089] <= 8'h00;
        memory[9'h08a] <= 8'h00;
        memory[9'h08b] <= 8'h00;
        memory[9'h08c] <= 8'h00;
        memory[9'h08d] <= 8'h01;
        memory[9'h08e] <= 8'h01;
        memory[9'h08f] <= 8'h05; // 3517
        memory[9'h090] <= 8'h2c;
        memory[9'h091] <= 8'hbb;
        memory[9'h092] <= 8'hc3;
        memory[9'h093] <= 8'hbb;
        memory[9'h094] <= 8'h7a;
        memory[9'h095] <= 8'hdf;
        memory[9'h096] <= 8'h8d;
        memory[9'h097] <= 8'h40;
        memory[9'h098] <= 8'h21;
        memory[9'h099] <= 8'he5;
        memory[9'h09a] <= 8'hac;
        memory[9'h09b] <= 8'h6f;
        memory[9'h09c] <= 8'hd8;
        memory[9'h09d] <= 8'h33;
        memory[9'h09e] <= 8'h84;
        memory[9'h09f] <= 8'h40; // 3757
        memory[9'h0a0] <= 8'h2c;
        memory[9'h0a1] <= 8'hbb;
        memory[9'h0a2] <= 8'hc3;
        memory[9'h0a3] <= 8'hbb;
        memory[9'h0a4] <= 8'h7a;
        memory[9'h0a5] <= 8'hdf;
        memory[9'h0a6] <= 8'h8d;
        memory[9'h0a7] <= 8'h40;
        memory[9'h0a8] <= 8'h21;
        memory[9'h0a9] <= 8'he5;
        memory[9'h0aa] <= 8'hac;
        memory[9'h0ab] <= 8'h6f;
        memory[9'h0ac] <= 8'hd8;
        memory[9'h0ad] <= 8'h33;
        memory[9'h0ae] <= 8'h84;
        memory[9'h0af] <= 8'h40; // 3997
        memory[9'h0b0] <= 8'h94;
        memory[9'h0b1] <= 8'h89;
        memory[9'h0b2] <= 8'h11;
        memory[9'h0b3] <= 8'ha3;
        memory[9'h0b4] <= 8'hfc;
        memory[9'h0b5] <= 8'h96;
        memory[9'h0b6] <= 8'h9e;
        memory[9'h0b7] <= 8'h40;
        memory[9'h0b8] <= 8'h94;
        memory[9'h0b9] <= 8'h89;
        memory[9'h0ba] <= 8'h11;
        memory[9'h0bb] <= 8'ha3;
        memory[9'h0bc] <= 8'hfc;
        memory[9'h0bd] <= 8'h96;
        memory[9'h0be] <= 8'h9e;
        memory[9'h0bf] <= 8'h40; // 4237
        memory[9'h0c0] <= 8'h00;
        memory[9'h0c1] <= 8'h00;
        memory[9'h0c2] <= 8'h00;
        memory[9'h0c3] <= 8'h00;
        memory[9'h0c4] <= 8'h00;
        memory[9'h0c5] <= 8'h00;
        memory[9'h0c6] <= 8'h00;
        memory[9'h0c7] <= 8'h00;
        memory[9'h0c8] <= 8'h00;
        memory[9'h0c9] <= 8'h00;
        memory[9'h0ca] <= 8'h00;
        memory[9'h0cb] <= 8'h00;
        memory[9'h0cc] <= 8'h00;
        memory[9'h0cd] <= 8'h00;
        memory[9'h0ce] <= 8'h00;
        memory[9'h0cf] <= 8'h00; // 4477
        memory[9'h0d0] <= 8'hf8;
        memory[9'h0d1] <= 8'h20;
        memory[9'h0d2] <= 8'h71;
        memory[9'h0d3] <= 8'hf8;
        memory[9'h0d4] <= 8'he4;
        memory[9'h0d5] <= 8'hf7;
        memory[9'h0d6] <= 8'hdf;
        memory[9'h0d7] <= 8'hbf;
        memory[9'h0d8] <= 8'h70;
        memory[9'h0d9] <= 8'hec;
        memory[9'h0da] <= 8'h86;
        memory[9'h0db] <= 8'h9a;
        memory[9'h0dc] <= 8'h7c;
        memory[9'h0dd] <= 8'hc9;
        memory[9'h0de] <= 8'hcd;
        memory[9'h0df] <= 8'h3f; // 4717
        memory[9'h0e0] <= 8'h4f;
        memory[9'h0e1] <= 8'h17;
        memory[9'h0e2] <= 8'h62;
        memory[9'h0e3] <= 8'h75;
        memory[9'h0e4] <= 8'h9b;
        memory[9'h0e5] <= 8'h47;
        memory[9'h0e6] <= 8'h5d;
        memory[9'h0e7] <= 8'hbf;
        memory[9'h0e8] <= 8'h95;
        memory[9'h0e9] <= 8'h90;
        memory[9'h0ea] <= 8'h28;
        memory[9'h0eb] <= 8'h08;
        memory[9'h0ec] <= 8'he5;
        memory[9'h0ed] <= 8'h32;
        memory[9'h0ee] <= 8'h28;
        memory[9'h0ef] <= 8'h3f; // 4957
        memory[9'h0f0] <= 8'h74;
        memory[9'h0f1] <= 8'ha3;
        memory[9'h0f2] <= 8'h08;
        memory[9'h0f3] <= 8'haf;
        memory[9'h0f4] <= 8'h01;
        memory[9'h0f5] <= 8'h5c;
        memory[9'h0f6] <= 8'h8d;
        memory[9'h0f7] <= 8'hbf;
        memory[9'h0f8] <= 8'h00;
        memory[9'h0f9] <= 8'h00;
        memory[9'h0fa] <= 8'h00;
        memory[9'h0fb] <= 8'h00;
        memory[9'h0fc] <= 8'h00;
        memory[9'h0fd] <= 8'h00;
        memory[9'h0fe] <= 8'h00;
        memory[9'h0ff] <= 8'h00; // 5197
        memory[9'h100] <= 8'h00;
        memory[9'h101] <= 8'h00;
        memory[9'h102] <= 8'h00;
        memory[9'h103] <= 8'h00;
        memory[9'h104] <= 8'h00;
        memory[9'h105] <= 8'h00;
        memory[9'h106] <= 8'h00;
        memory[9'h107] <= 8'h00;
        memory[9'h108] <= 8'h00;
        memory[9'h109] <= 8'h00;
        memory[9'h10a] <= 8'h00;
        memory[9'h10b] <= 8'h00;
        memory[9'h10c] <= 8'h00;
        memory[9'h10d] <= 8'h00;
        memory[9'h10e] <= 8'h00;
        memory[9'h10f] <= 8'h00; // 5437
        memory[9'h110] <= 8'h00;
        memory[9'h111] <= 8'h00;
        memory[9'h112] <= 8'h00;
        memory[9'h113] <= 8'h00;
        memory[9'h114] <= 8'h00;
        memory[9'h115] <= 8'h00;
        memory[9'h116] <= 8'h00;
        memory[9'h117] <= 8'h00;
        memory[9'h118] <= 8'h00;
        memory[9'h119] <= 8'h00;
        memory[9'h11a] <= 8'h00;
        memory[9'h11b] <= 8'h00;
        memory[9'h11c] <= 8'h00;
        memory[9'h11d] <= 8'h00;
        memory[9'h11e] <= 8'h00;
        memory[9'h11f] <= 8'h00; // 5677
        memory[9'h120] <= 8'h00;
        memory[9'h121] <= 8'h00;
        memory[9'h122] <= 8'h00;
        memory[9'h123] <= 8'h00;
        memory[9'h124] <= 8'h00;
        memory[9'h125] <= 8'h00;
        memory[9'h126] <= 8'h00;
        memory[9'h127] <= 8'h00;
        memory[9'h128] <= 8'h00;
        memory[9'h129] <= 8'h00;
        memory[9'h12a] <= 8'h00;
        memory[9'h12b] <= 8'h00;
        memory[9'h12c] <= 8'h00;
        memory[9'h12d] <= 8'h00;
        memory[9'h12e] <= 8'h00;
        memory[9'h12f] <= 8'h00; // 5917
        memory[9'h130] <= 8'h00;
        memory[9'h131] <= 8'h00;
        memory[9'h132] <= 8'h00;
        memory[9'h133] <= 8'h00;
        memory[9'h134] <= 8'h00;
        memory[9'h135] <= 8'h00;
        memory[9'h136] <= 8'h00;
        memory[9'h137] <= 8'h00;
        memory[9'h138] <= 8'h00;
        memory[9'h139] <= 8'h00;
        memory[9'h13a] <= 8'h00;
        memory[9'h13b] <= 8'h00;
        memory[9'h13c] <= 8'h00;
        memory[9'h13d] <= 8'h00;
        memory[9'h13e] <= 8'h00;
        memory[9'h13f] <= 8'h00; // 6157
        memory[9'h140] <= 8'h20;
        memory[9'h141] <= 8'h20;
        memory[9'h142] <= 8'h20;
        memory[9'h143] <= 8'h20;
        memory[9'h144] <= 8'h20;
        memory[9'h145] <= 8'h20;
        memory[9'h146] <= 8'h20;
        memory[9'h147] <= 8'h20;
        memory[9'h148] <= 8'h20;
        memory[9'h149] <= 8'h20;
        memory[9'h14a] <= 8'h20;
        memory[9'h14b] <= 8'h20;
        memory[9'h14c] <= 8'h20;
        memory[9'h14d] <= 8'h20;
        memory[9'h14e] <= 8'h20;
        memory[9'h14f] <= 8'h20; // 6397
        memory[9'h150] <= 8'hba;
        memory[9'h151] <= 8'h19;
        memory[9'h152] <= 8'h2b;
        memory[9'h153] <= 8'h39;
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
                16'h001f: rd_data <= memory[9'h01f][7:0]; // 1837
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
                16'h002f: rd_data <= memory[9'h02f][7:0]; // 2077
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
                16'h003f: rd_data <= memory[9'h03f][7:0]; // 2317
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
                16'h004f: rd_data <= memory[9'h04f][7:0]; // 2557
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
                16'h005f: rd_data <= memory[9'h05f][7:0]; // 2797
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
                16'h006f: rd_data <= memory[9'h06f][7:0]; // 3037
                16'h0070: rd_data <= memory[9'h070][7:0];
                16'h0071: rd_data <= memory[9'h071][7:0];
                16'h0072: rd_data <= memory[9'h072][7:0];
                16'h0073: rd_data <= memory[9'h073][7:0];
                16'h0074: rd_data <= memory[9'h074][7:0];
                16'h0075: rd_data <= memory[9'h075][7:0];
                16'h0076: rd_data <= memory[9'h076][7:0];
                16'h0077: rd_data <= memory[9'h077][7:0];
                16'h0078: rd_data <= memory[9'h078][7:0];
                16'h0079: rd_data <= memory[9'h079][7:0];
                16'h007a: rd_data <= memory[9'h07a][7:0];
                16'h007b: rd_data <= memory[9'h07b][7:0];
                16'h007c: rd_data <= memory[9'h07c][7:0];
                16'h007d: rd_data <= memory[9'h07d][7:0];
                16'h007e: rd_data <= memory[9'h07e][7:0];
                16'h007f: rd_data <= memory[9'h07f][7:0]; // 3277
                16'h0080: rd_data <= memory[9'h080][7:0];
                16'h0081: rd_data <= memory[9'h081][7:0];
                16'h0082: rd_data <= memory[9'h082][7:0];
                16'h0083: rd_data <= memory[9'h083][7:0];
                16'h0084: rd_data <= memory[9'h084][7:0];
                16'h0085: rd_data <= memory[9'h085][7:0];
                16'h0086: rd_data <= memory[9'h086][7:0];
                16'h0087: rd_data <= memory[9'h087][7:0];
                16'h0088: rd_data <= memory[9'h088][7:0];
                16'h0089: rd_data <= memory[9'h089][7:0];
                16'h008a: rd_data <= memory[9'h08a][7:0];
                16'h008b: rd_data <= memory[9'h08b][7:0];
                16'h008c: rd_data <= memory[9'h08c][7:0];
                16'h008d: rd_data <= memory[9'h08d][7:0];
                16'h008e: rd_data <= memory[9'h08e][7:0];
                16'h008f: rd_data <= memory[9'h08f][7:0]; // 3517
                16'h0090: rd_data <= memory[9'h090][7:0];
                16'h0091: rd_data <= memory[9'h091][7:0];
                16'h0092: rd_data <= memory[9'h092][7:0];
                16'h0093: rd_data <= memory[9'h093][7:0];
                16'h0094: rd_data <= memory[9'h094][7:0];
                16'h0095: rd_data <= memory[9'h095][7:0];
                16'h0096: rd_data <= memory[9'h096][7:0];
                16'h0097: rd_data <= memory[9'h097][7:0];
                16'h0098: rd_data <= memory[9'h098][7:0];
                16'h0099: rd_data <= memory[9'h099][7:0];
                16'h009a: rd_data <= memory[9'h09a][7:0];
                16'h009b: rd_data <= memory[9'h09b][7:0];
                16'h009c: rd_data <= memory[9'h09c][7:0];
                16'h009d: rd_data <= memory[9'h09d][7:0];
                16'h009e: rd_data <= memory[9'h09e][7:0];
                16'h009f: rd_data <= memory[9'h09f][7:0]; // 3757
                16'h00a0: rd_data <= memory[9'h0a0][7:0];
                16'h00a1: rd_data <= memory[9'h0a1][7:0];
                16'h00a2: rd_data <= memory[9'h0a2][7:0];
                16'h00a3: rd_data <= memory[9'h0a3][7:0];
                16'h00a4: rd_data <= memory[9'h0a4][7:0];
                16'h00a5: rd_data <= memory[9'h0a5][7:0];
                16'h00a6: rd_data <= memory[9'h0a6][7:0];
                16'h00a7: rd_data <= memory[9'h0a7][7:0];
                16'h00a8: rd_data <= memory[9'h0a8][7:0];
                16'h00a9: rd_data <= memory[9'h0a9][7:0];
                16'h00aa: rd_data <= memory[9'h0aa][7:0];
                16'h00ab: rd_data <= memory[9'h0ab][7:0];
                16'h00ac: rd_data <= memory[9'h0ac][7:0];
                16'h00ad: rd_data <= memory[9'h0ad][7:0];
                16'h00ae: rd_data <= memory[9'h0ae][7:0];
                16'h00af: rd_data <= memory[9'h0af][7:0]; // 3997
                16'h00b0: rd_data <= memory[9'h0b0][7:0];
                16'h00b1: rd_data <= memory[9'h0b1][7:0];
                16'h00b2: rd_data <= memory[9'h0b2][7:0];
                16'h00b3: rd_data <= memory[9'h0b3][7:0];
                16'h00b4: rd_data <= memory[9'h0b4][7:0];
                16'h00b5: rd_data <= memory[9'h0b5][7:0];
                16'h00b6: rd_data <= memory[9'h0b6][7:0];
                16'h00b7: rd_data <= memory[9'h0b7][7:0];
                16'h00b8: rd_data <= memory[9'h0b8][7:0];
                16'h00b9: rd_data <= memory[9'h0b9][7:0];
                16'h00ba: rd_data <= memory[9'h0ba][7:0];
                16'h00bb: rd_data <= memory[9'h0bb][7:0];
                16'h00bc: rd_data <= memory[9'h0bc][7:0];
                16'h00bd: rd_data <= memory[9'h0bd][7:0];
                16'h00be: rd_data <= memory[9'h0be][7:0];
                16'h00bf: rd_data <= memory[9'h0bf][7:0]; // 4237
                16'h00c0: rd_data <= memory[9'h0c0][7:0];
                16'h00c1: rd_data <= memory[9'h0c1][7:0];
                16'h00c2: rd_data <= memory[9'h0c2][7:0];
                16'h00c3: rd_data <= memory[9'h0c3][7:0];
                16'h00c4: rd_data <= memory[9'h0c4][7:0];
                16'h00c5: rd_data <= memory[9'h0c5][7:0];
                16'h00c6: rd_data <= memory[9'h0c6][7:0];
                16'h00c7: rd_data <= memory[9'h0c7][7:0];
                16'h00c8: rd_data <= memory[9'h0c8][7:0];
                16'h00c9: rd_data <= memory[9'h0c9][7:0];
                16'h00ca: rd_data <= memory[9'h0ca][7:0];
                16'h00cb: rd_data <= memory[9'h0cb][7:0];
                16'h00cc: rd_data <= memory[9'h0cc][7:0];
                16'h00cd: rd_data <= memory[9'h0cd][7:0];
                16'h00ce: rd_data <= memory[9'h0ce][7:0];
                16'h00cf: rd_data <= memory[9'h0cf][7:0]; // 4477
                16'h00d0: rd_data <= memory[9'h0d0][7:0];
                16'h00d1: rd_data <= memory[9'h0d1][7:0];
                16'h00d2: rd_data <= memory[9'h0d2][7:0];
                16'h00d3: rd_data <= memory[9'h0d3][7:0];
                16'h00d4: rd_data <= memory[9'h0d4][7:0];
                16'h00d5: rd_data <= memory[9'h0d5][7:0];
                16'h00d6: rd_data <= memory[9'h0d6][7:0];
                16'h00d7: rd_data <= memory[9'h0d7][7:0];
                16'h00d8: rd_data <= memory[9'h0d8][7:0];
                16'h00d9: rd_data <= memory[9'h0d9][7:0];
                16'h00da: rd_data <= memory[9'h0da][7:0];
                16'h00db: rd_data <= memory[9'h0db][7:0];
                16'h00dc: rd_data <= memory[9'h0dc][7:0];
                16'h00dd: rd_data <= memory[9'h0dd][7:0];
                16'h00de: rd_data <= memory[9'h0de][7:0];
                16'h00df: rd_data <= memory[9'h0df][7:0]; // 4717
                16'h00e0: rd_data <= memory[9'h0e0][7:0];
                16'h00e1: rd_data <= memory[9'h0e1][7:0];
                16'h00e2: rd_data <= memory[9'h0e2][7:0];
                16'h00e3: rd_data <= memory[9'h0e3][7:0];
                16'h00e4: rd_data <= memory[9'h0e4][7:0];
                16'h00e5: rd_data <= memory[9'h0e5][7:0];
                16'h00e6: rd_data <= memory[9'h0e6][7:0];
                16'h00e7: rd_data <= memory[9'h0e7][7:0];
                16'h00e8: rd_data <= memory[9'h0e8][7:0];
                16'h00e9: rd_data <= memory[9'h0e9][7:0];
                16'h00ea: rd_data <= memory[9'h0ea][7:0];
                16'h00eb: rd_data <= memory[9'h0eb][7:0];
                16'h00ec: rd_data <= memory[9'h0ec][7:0];
                16'h00ed: rd_data <= memory[9'h0ed][7:0];
                16'h00ee: rd_data <= memory[9'h0ee][7:0];
                16'h00ef: rd_data <= memory[9'h0ef][7:0]; // 4957
                16'h00f0: rd_data <= memory[9'h0f0][7:0];
                16'h00f1: rd_data <= memory[9'h0f1][7:0];
                16'h00f2: rd_data <= memory[9'h0f2][7:0];
                16'h00f3: rd_data <= memory[9'h0f3][7:0];
                16'h00f4: rd_data <= memory[9'h0f4][7:0];
                16'h00f5: rd_data <= memory[9'h0f5][7:0];
                16'h00f6: rd_data <= memory[9'h0f6][7:0];
                16'h00f7: rd_data <= memory[9'h0f7][7:0];
                16'h00f8: rd_data <= memory[9'h0f8][7:0];
                16'h00f9: rd_data <= memory[9'h0f9][7:0];
                16'h00fa: rd_data <= memory[9'h0fa][7:0];
                16'h00fb: rd_data <= memory[9'h0fb][7:0];
                16'h00fc: rd_data <= memory[9'h0fc][7:0];
                16'h00fd: rd_data <= memory[9'h0fd][7:0];
                16'h00fe: rd_data <= memory[9'h0fe][7:0];
                16'h00ff: rd_data <= memory[9'h0ff][7:0]; // 5197
                16'h0100: rd_data <= memory[9'h100][7:0];
                16'h0101: rd_data <= memory[9'h101][7:0];
                16'h0102: rd_data <= memory[9'h102][7:0];
                16'h0103: rd_data <= memory[9'h103][7:0];
                16'h0104: rd_data <= memory[9'h104][7:0];
                16'h0105: rd_data <= memory[9'h105][7:0];
                16'h0106: rd_data <= memory[9'h106][7:0];
                16'h0107: rd_data <= memory[9'h107][7:0];
                16'h0108: rd_data <= memory[9'h108][7:0];
                16'h0109: rd_data <= memory[9'h109][7:0];
                16'h010a: rd_data <= memory[9'h10a][7:0];
                16'h010b: rd_data <= memory[9'h10b][7:0];
                16'h010c: rd_data <= memory[9'h10c][7:0];
                16'h010d: rd_data <= memory[9'h10d][7:0];
                16'h010e: rd_data <= memory[9'h10e][7:0];
                16'h010f: rd_data <= memory[9'h10f][7:0]; // 5437
                16'h0110: rd_data <= memory[9'h110][7:0];
                16'h0111: rd_data <= memory[9'h111][7:0];
                16'h0112: rd_data <= memory[9'h112][7:0];
                16'h0113: rd_data <= memory[9'h113][7:0];
                16'h0114: rd_data <= memory[9'h114][7:0];
                16'h0115: rd_data <= memory[9'h115][7:0];
                16'h0116: rd_data <= memory[9'h116][7:0];
                16'h0117: rd_data <= memory[9'h117][7:0];
                16'h0118: rd_data <= memory[9'h118][7:0];
                16'h0119: rd_data <= memory[9'h119][7:0];
                16'h011a: rd_data <= memory[9'h11a][7:0];
                16'h011b: rd_data <= memory[9'h11b][7:0];
                16'h011c: rd_data <= memory[9'h11c][7:0];
                16'h011d: rd_data <= memory[9'h11d][7:0];
                16'h011e: rd_data <= memory[9'h11e][7:0];
                16'h011f: rd_data <= memory[9'h11f][7:0]; // 5677
                16'h0120: rd_data <= memory[9'h120][7:0];
                16'h0121: rd_data <= memory[9'h121][7:0];
                16'h0122: rd_data <= memory[9'h122][7:0];
                16'h0123: rd_data <= memory[9'h123][7:0];
                16'h0124: rd_data <= memory[9'h124][7:0];
                16'h0125: rd_data <= memory[9'h125][7:0];
                16'h0126: rd_data <= memory[9'h126][7:0];
                16'h0127: rd_data <= memory[9'h127][7:0];
                16'h0128: rd_data <= memory[9'h128][7:0];
                16'h0129: rd_data <= memory[9'h129][7:0];
                16'h012a: rd_data <= memory[9'h12a][7:0];
                16'h012b: rd_data <= memory[9'h12b][7:0];
                16'h012c: rd_data <= memory[9'h12c][7:0];
                16'h012d: rd_data <= memory[9'h12d][7:0];
                16'h012e: rd_data <= memory[9'h12e][7:0];
                16'h012f: rd_data <= memory[9'h12f][7:0]; // 5917
                16'h0130: rd_data <= memory[9'h130][7:0];
                16'h0131: rd_data <= memory[9'h131][7:0];
                16'h0132: rd_data <= memory[9'h132][7:0];
                16'h0133: rd_data <= memory[9'h133][7:0];
                16'h0134: rd_data <= memory[9'h134][7:0];
                16'h0135: rd_data <= memory[9'h135][7:0];
                16'h0136: rd_data <= memory[9'h136][7:0];
                16'h0137: rd_data <= memory[9'h137][7:0];
                16'h0138: rd_data <= memory[9'h138][7:0];
                16'h0139: rd_data <= memory[9'h139][7:0];
                16'h013a: rd_data <= memory[9'h13a][7:0];
                16'h013b: rd_data <= memory[9'h13b][7:0];
                16'h013c: rd_data <= memory[9'h13c][7:0];
                16'h013d: rd_data <= memory[9'h13d][7:0];
                16'h013e: rd_data <= memory[9'h13e][7:0];
                16'h013f: rd_data <= memory[9'h13f][7:0]; // 6157
                16'h0140: rd_data <= memory[9'h140][7:0];
                16'h0141: rd_data <= memory[9'h141][7:0];
                16'h0142: rd_data <= memory[9'h142][7:0];
                16'h0143: rd_data <= memory[9'h143][7:0];
                16'h0144: rd_data <= memory[9'h144][7:0];
                16'h0145: rd_data <= memory[9'h145][7:0];
                16'h0146: rd_data <= memory[9'h146][7:0];
                16'h0147: rd_data <= memory[9'h147][7:0];
                16'h0148: rd_data <= memory[9'h148][7:0];
                16'h0149: rd_data <= memory[9'h149][7:0];
                16'h014a: rd_data <= memory[9'h14a][7:0];
                16'h014b: rd_data <= memory[9'h14b][7:0];
                16'h014c: rd_data <= memory[9'h14c][7:0];
                16'h014d: rd_data <= memory[9'h14d][7:0];
                16'h014e: rd_data <= memory[9'h14e][7:0];
                16'h014f: rd_data <= memory[9'h14f][7:0]; // 6397
                16'h0150: rd_data <= memory[9'h150][7:0];
                16'h0151: rd_data <= memory[9'h151][7:0];
                16'h0152: rd_data <= memory[9'h152][7:0];
                16'h0153: rd_data <= memory[9'h153][7:0];

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
