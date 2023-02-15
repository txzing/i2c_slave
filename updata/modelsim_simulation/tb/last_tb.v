/*================================================*\
			  _ _
			_|   |_ 数据传输阶段，per bit的时钟
\*================================================*/

`timescale 1ns/1ns 		//仿真系统时间尺度定义

`define clk_period 20  	//时钟周期参数定义	

`define sclk_period 500 //125 个系统时钟周期，先高后低,400KHz的频率下

module last_tb(); 


parameter           DEVICE_ADDR = 7'h36;
parameter           WR_CTRL     = {DEVICE_ADDR,1'b0};
parameter           RD_CTRL     = {DEVICE_ADDR,1'b1};
//激励信号定义  
	reg				sys_clk		; 
	reg				rst_n	; 
	reg				scl	; //
	reg				sda_in	; //
	
//响应信号定义	  
	wire 			sda_oe	; //
	wire 			sda_o	; //

	integer			i       ;
	reg		[127:0]	State_Machine; //string
	
	localparam IDLE		  = 8'b0000_0001, //空闲状态
			   START	  = 8'b0000_0010, //接收起始位状态
			   JUG_RW 	  = 8'b0000_0100, //判断接收读写指令状态
			   RW_ADDR_16 = 8'b0000_1000, //接收读写地址状态 2byte
			   RW_ADDR	  = 8'b0001_0000, //接收读写地址状态
			   WR_DAT	  = 8'b0010_0000, //接收写数据状态
			   RD_DAT	  = 8'b0100_0000, //发送读数据状态
			   STOP		  = 8'b1000_0000; //接收停止位状态
               
               
	always@(*)begin
		case(u_i2c_slave.state_c)
			IDLE	    : State_Machine = "IDLE";	
			START	    : State_Machine = "START";
			JUG_RW 	    : State_Machine = "JUG_RW";
            RW_ADDR_16	: State_Machine = "RW_ADDR_16";
			RW_ADDR	    : State_Machine = "RW_ADDR";
			WR_DAT	    : State_Machine = "WR_DAT";
			RD_DAT	    : State_Machine = "RD_DAT";
			STOP	    : State_Machine = "STOP";	
			default:State_Machine = "IDLE";	
		endcase	
	end 


i2c_slave 
#(
    .I2C_SLAVE_ADDR    (DEVICE_ADDR),//7bit i2c slave addr
    .I2C_SLAVE_REG_MODE(1'b1 )       // i2c reg width,1-16bit, 0-8bit
//   .I2C_SLAVE_DAT_MODE(1'b0 ) // i2c reg width, 2-32bit, 1-16bit, 0-8bit  //预留,暂未做该功能
)
u_i2c_slave
(
	/*input   	   */.sys_clk	(sys_clk), //system clock 50MHz
	/*input    	   */.sys_rst_n	    (rst_n)  , //reset ，low valid 
	/*input    	   */.scl 	    (scl)    , //串行时钟总线
	/*input    	   */.sda_in	(sda_in) , //三态门的写法

	/*output reg   */.sda_t	    (sda_t) , //1'b1，使能输出，也即给出应答状态
	/*output reg   */.sda_o	    (sda_o) 
);

//产生时钟							       		 
	initial sys_clk = 1'b0;		       		 
	always #(`clk_period / 2) sys_clk = ~sys_clk;  		 

//产生激励	 
	initial  begin	 
		rst_n = 1'b0;	 
		scl  = 1'b1;
		sda_in= 1'b1;
		#(`clk_period * 10 + 3);//复位	 
		rst_n = 1'b1;	 
		#(`clk_period * 10); //复位结束
        
	//写数据		
        start;
		Send_data(WR_CTRL); //写指令
			
		Send_data(8'h00); //写地址
        Send_data(8'h05); //写地址	
		Send_data(8'h19); //写数据
        Send_data(8'h20); //写数据
        Send_data(8'h33); //写数据
        Send_data(8'h25); //写数据
        Send_data(8'h04); //写数据

        stop;
		
		#(`sclk_period * `clk_period * 10);		
		
		
		
	//读数据
        start;
		Send_data(WR_CTRL); //写指令		
		Send_data(8'h00); //写地址
        Send_data(8'h05); //写地址
        read_start;
		Send_data(RD_CTRL); //读指令		
		Rx_data; //读数据
		send_ack;
        Rx_data; //读数据
		send_ack;
        Rx_data; //读数据
		send_ack;
        Rx_data; //读数据
		send_ack;
        Rx_data; //读数据
		send_ack;
        Rx_data; //读数据
		send_ack;
		Rx_data;
		send_Nack;	
        
        stop;//停止位
        
        
        start;
        //改设备地址
        Send_data(WR_CTRL); //写指令
		Send_data(8'h00); //写地址
        Send_data(8'h00); //写地址	
		Send_data({1'b0,7'h78}); //写数据
        stop;
        
        start;
        //尝试错误设备地址
        Send_data(WR_CTRL); //写指令
		Send_data(8'h00); //写地址
        Send_data(8'h05); //写地址	
		Send_data(8'haa); //写数据
        stop;
        
        start;
        //正确设备地址写
        Send_data({7'h78,1'b0}); //写指令
		Send_data(8'h00); //写地址
        Send_data(8'h05); //写地址	
		Send_data(8'haa); //写数据
        stop;
        
        
        start;
        //正确设备地址读
        Send_data({7'h78,1'b0}); //写指令
		Send_data(8'h00); //写地址
        Send_data(8'h05); //写地址	
        read_start;
		Send_data({7'h78,1'b1}); //读指令	
		Rx_data; //读数据
		send_Nack;
        stop;

		$stop(2); 
	end	 
	



    
    task  start; 
		// input	;
		begin //起始位
			#(`sclk_period * `clk_period / 2) sda_in = 1'b0;
			#(`sclk_period * `clk_period / 4) scl   = 1'b0;
			#(`sclk_period * `clk_period / 4);
		end
	endtask
    
    task  read_start; 
		// input	;
		begin 
    		fork //起始位
			sda_in = 1'b1;
			scl   = 1'b0;
			#(`sclk_period * `clk_period / 4) scl   = 1'b1;
			#(`sclk_period * `clk_period / 2) sda_in = 1'b0;
			#(`sclk_period * `clk_period / 4 * 3) scl   = 1'b0;
			#(`sclk_period * `clk_period );
            join
		end
	endtask

    
    task  stop; 
		// input	;
		begin //停止位			
			#(`sclk_period * `clk_period / 4) scl = 1'b1;
			#(`sclk_period * `clk_period / 2) sda_in = 1'b1;
			#(`sclk_period * `clk_period / 4);
		end
	endtask
    
    
	task  Send_data; 
		input  [07:00]	data_in;
		begin
			i = 0;
			repeat(8)begin
			scl = 1'b0;
			sda_in = data_in[7 - i];
			#(`sclk_period * `clk_period / 4) scl = 1'b1;
			#(`sclk_period * `clk_period / 2) scl = 1'b0;
			#(`sclk_period * `clk_period / 4);
			i = i + 1;
			end 
			scl = 1'b0;
			#(`sclk_period * `clk_period / 4) scl = 1'b1;
			#(`sclk_period * `clk_period / 2) scl = 1'b0;
			#(`sclk_period * `clk_period / 4) ;
		end 
	endtask 
	task  send_ack; 
		// input	;
		begin
			scl = 1'b0;
			sda_in = 1'b0;
			#(`sclk_period * `clk_period / 4) scl = 1'b1;
			#(`sclk_period * `clk_period / 2) scl = 1'b0;
			#(`sclk_period * `clk_period / 4) ;
		end 
	endtask 
	
	task  send_Nack; 
		// input	;
		begin
			scl = 1'b0;
			sda_in = 1'b1;
			#(`sclk_period * `clk_period / 4) scl = 1'b1;
			#(`sclk_period * `clk_period / 2) scl = 1'b0;
			#(`sclk_period * `clk_period / 4) ;
		end 
	endtask 
	
	
	
	task  Rx_data; //要发送ACK 和 NACK 
		// input	;
		begin
			i = 0;
			repeat(8)begin
			scl = 1'b0;
			#(`sclk_period * `clk_period / 4) scl = 1'b1;
			#(`sclk_period * `clk_period / 2) scl = 1'b0;
			#(`sclk_period * `clk_period / 4);
			i = i + 1;
			end 
		end  
	endtask 
	
	

endmodule 