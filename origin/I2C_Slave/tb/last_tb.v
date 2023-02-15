/*================================================*\
		  Filename ﹕ 
			Author ﹕ 
	  Description  ﹕ 
		 Called by ﹕ 
Revision History   ﹕ mm/dd/202x
		  			  Revision 1.0
  			  Email﹕ 
			Company﹕ 
			  _ _
			_|   |_ 数据传输阶段，per bit的时钟
\*================================================*/

`timescale 1ns/1ns 		//仿真系统时间尺度定义

`define clk_period 20  	//时钟周期参数定义	

`define sclk_period 125 //125 个系统时钟周期，先高后低

module last_tb(); 
//激励信号定义  
	reg				Clk		; 
	reg				Rst_n	; 
	reg				Sclk	; //
	reg				Sda_in	; //
	
//响应信号定义	  
	wire 			Sda_oe	; //
	wire 			Sda_o	; //
	
	wire 			rw_flag	; //读写状态标志信号 0：写；1：读
	wire 			Wr_vld	; //写数据有效标志
	wire [07:00]	Wr_data	; //写入数据
	wire 			Rd_vld	; //读数据有效标志
	wire [07:00]	Rd_data	; //读出数据
	
	reg  [07:00]	RX_data	; //接收到的数据
	integer			i , j	;
	reg		[55:00]	State_Machine; //
	
	localparam IDLE		= 7'b000_0001, //空闲状态
			   START	= 7'b000_0010, //接收起始位状态
			   JUG_RW 	= 7'b000_0100, //接收读写写指令状态
			   RW_ADDR	= 7'b000_1000, //接收读 or 写地址状态
			   WR_DAT	= 7'b001_0000, //接收写数据状态
			   RD_DAT	= 7'b010_0000, //发送读数据状态
			   STOP		= 7'b100_0000; //接收停止位状态
	always@(*)begin
		case(i2c_slave.state_c)
			IDLE	: State_Machine = "IDLE";	
			START	: State_Machine = "START";
			JUG_RW 	: State_Machine = "JUG_RW";
			RW_ADDR	: State_Machine = "RW_ADDR";
			WR_DAT	: State_Machine = "WR_DAT";
			RD_DAT	: State_Machine = "RD_DAT";
			STOP	: State_Machine = "STOP";	
			default:State_Machine = "IDLE";	
		endcase	
	end 
	
//实例化
	// i2c_slave	i2c_slave(
	// /*input  wire 			*/.Clk		(Clk	), //system clock 50MHz
	// /*input  wire 			*/.Rst_n	(Rst_n	), //reset ，low valid
	
	// /*input  wire 			*/.Sclk 	(Sclk 	), //串行时钟总线
	// /*input  wire 			*/.Sda_in	(Sda_in	), //三态门的写法
	// /*output reg  			*/.Sda_oe	(Sda_oe	), //
	// /*output reg  			*/.Sda_o	(Sda_o	), //
	
	// /*output reg  			*/.rw_flag	(rw_flag), //读写状态标志信号 0：写；1：读
	// /*output reg  			*/.Wr_vld	(Wr_vld	), //写数据有效标志
	// /*output reg   [07:00]	*/.Wr_data	(Wr_data), //写入数据
	// /*output reg  			*/.Rd_vld	(Rd_vld	), //读数据有效标志
	// /*output reg   [07:00]	*/.Rd_data	(Rd_data)  //读出数据
// );
		// defparam i2c_slave.DLY_STA = 30;
	// i2c_slave_new	i2c_slave(
	// /*input  wire 			*/.Clk		(Clk	), //system clock 50MHz
	// /*input  wire 			*/.Rst_n	(Rst_n	), //reset ，low valid
	
	// /*input  wire 			*/.Sclk 	(Sclk 	), //串行时钟总线
	// /*input  wire 			*/.Sda_in	(Sda_in	), //三态门的写法
	// /*output reg  			*/.Sda_oe	(Sda_oe	), //
	// /*output reg  			*/.Sda_o	(Sda_o	), //
	
	// /*output reg  			*/.rw_flag	(rw_flag), //读写状态标志信号 0：写；1：读
	// /*output reg  			*/.Wr_vld	(Wr_vld	), //写数据有效标志
	// /*output reg   [07:00]	*/.Wr_data	(Wr_data), //写入数据
	// /*output reg  			*/.Rd_vld	(Rd_vld	), //读数据有效标志
	// /*output reg   [07:00]	*/.Rd_data	(Rd_data)  //读出数据
// );

	slave_2		i2c_slave(
	/*input  wire 			*/.Clk		(Clk	), //system clock 50MHz
	/*input  wire 			*/.Rst_n	(Rst_n	), //reset ，low valid
	
	/*input  wire 			*/.Sclk 	(Sclk 	), //串行时钟总线
	/*input  wire 			*/.Sda_in	(Sda_in	), //三态门的写法
	/*output reg  			*/.Sda_oe	(Sda_oe	), //
	/*output reg  			*/.Sda_o	(Sda_o	), //
	
	/*output reg  			*/.rw_flag	(rw_flag), //读写状态标志信号 0：写；1：读
	/*output reg  			*/.Wr_vld	(Wr_vld	), //写数据有效标志
	/*output reg   [07:00]	*/.Wr_data	(Wr_data), //写入数据
	/*output reg  			*/.Rd_vld	(Rd_vld	), //读数据有效标志
	/*output reg   [07:00]	*/.Rd_data	(Rd_data)  //读出数据
);

//产生时钟							       		 
	initial Clk = 1'b0;		       		 
	always #(`clk_period / 2) Clk = ~Clk;  		 

//产生激励	 
	initial  begin	 
		Rst_n = 1'b0;	 
		Sclk  = 1'b1;
		Sda_in= 1'b1;
		j = 43;
		#(`clk_period * 10 + 3);	 
		Rst_n = 1'b1;	 
		#(`clk_period * 10); 
	//写数据		
		begin //起始位
			#(`sclk_period * `clk_period / 2) Sda_in = 1'b0;
			#(`sclk_period * `clk_period / 4) Sclk   = 1'b0;
			#(`sclk_period * `clk_period / 4);
		end
		Send_data(8'hA0); //写指令
			
		Send_data(8'hc6); //写地址
			
		repeat(1)begin
			j = j + 3;
			Send_data(25); //写数据
			
		end 		
		Sda_in = Sda_o;
		begin //停止位			
			#(`sclk_period * `clk_period / 4) Sclk = 1'b1;
			#(`sclk_period * `clk_period / 2) Sda_in = 1'b1;
			#(`sclk_period * `clk_period / 4);
		end
		
		
		#(`sclk_period * `clk_period * 10);		
		
		
		
	//读数据
		begin //起始位
			#(`sclk_period * `clk_period / 2) Sda_in = 1'b0;
			#(`sclk_period * `clk_period / 4) Sclk   = 1'b0;
			#(`sclk_period * `clk_period / 4);
		end
		Send_data(8'hA0); //写指令
			
		Send_data(8'hc6); //写地址
		
		fork //起始位
			Sda_in = 1'b1;
			Sclk   = 1'b0;
			#(`sclk_period * `clk_period / 4) Sclk   = 1'b1;
			#(`sclk_period * `clk_period / 2) Sda_in = 1'b0;
			#(`sclk_period * `clk_period / 4 * 3) Sclk   = 1'b0;
			#(`sclk_period * `clk_period );
		join
		Send_data(8'hA1); //读指令
			
		repeat(1)begin
			Rx_data; //读数据
			send_ack;
		end 
		Rx_data;
		send_Nack;
		
		Sda_in = Sda_o;
		begin //停止位			
			#(`sclk_period * `clk_period / 4) Sclk = 1'b1;
			#(`sclk_period * `clk_period / 2) Sda_in = 1'b1;
			#(`sclk_period * `clk_period / 4);
		end
		$stop(2); 
	end	 
	
	task  Send_data; 
		input  [07:00]	data_in;
		begin
			i = 0;
			repeat(8)begin
			Sclk = 1'b0;
			Sda_in = data_in[7 - i];
			#(`sclk_period * `clk_period / 4) Sclk = 1'b1;
			#(`sclk_period * `clk_period / 2) Sclk = 1'b0;
			#(`sclk_period * `clk_period / 4);
			i = i + 1;
			end 
			Sclk = 1'b0;
			#(`sclk_period * `clk_period / 4) Sclk = 1'b1;
			#(`sclk_period * `clk_period / 2) Sclk = 1'b0;
			#(`sclk_period * `clk_period / 4) ;
		end 
	endtask 
	task  send_ack; 
		// input	;
		begin
			Sclk = 1'b0;
			Sda_in = 1'b0;
			#(`sclk_period * `clk_period / 4) Sclk = 1'b1;
			#(`sclk_period * `clk_period / 2) Sclk = 1'b0;
			#(`sclk_period * `clk_period / 4) ;
		end 
	endtask 
	
	task  send_Nack; 
		// input	;
		begin
			Sclk = 1'b0;
			Sda_in = 1'b1;
			#(`sclk_period * `clk_period / 4) Sclk = 1'b1;
			#(`sclk_period * `clk_period / 2) Sclk = 1'b0;
			#(`sclk_period * `clk_period / 4) ;
		end 
	endtask 
	
	
	
	task  Rx_data; //要发送ACK 和 NACK 
		// input	;
		begin
			i = 0;
			repeat(8)begin
			Sclk = 1'b0;
			#(`sclk_period * `clk_period / 4) Sclk = 1'b1;
			#(`sclk_period * `clk_period / 2) Sclk = 1'b0;
			#(`sclk_period * `clk_period / 4);
			i = i + 1;
			end 
		end  
	endtask 
	
	

endmodule 