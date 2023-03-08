/*================================================*\
	  Description  ﹕i2c 从机模块 顶层调度文件 
\*================================================*/
module 	i2c_slave_top
#(
    parameter   I2C_SLAVE_ADDR      = 7'h36,   //7bit i2c slave addr
    parameter   I2C_SLAVE_REG_MODE  = 1'b0    // i2c reg width,1-16bit, 0-8bit
)
(
	input   			sys_clk	    , //system clock 50MHz
	input    		    sys_rst_n	, //reset ，low valid 
    
	input    		    scl 	, //串行时钟总线
	inout        		sdat	 //
	
);

	

//Interrnal wire/reg declarations
    wire			rst_sync_n  ;
    wire 			sda_in      ;
    wire 			sda_oe      ;
    wire 			sda_o       ; 
	
i2c_slave 
#(
   .I2C_SLAVE_ADDR    (7'h36),//7bit i2c slave addr
   .I2C_SLAVE_REG_MODE(1'b0 )// i2c reg width,1-16bit, 0-8bit
//   .I2C_SLAVE_DAT_MODE(1'b0 ) // i2c reg width, 2-32bit, 1-16bit, 0-8bit  //预留,暂未做该功能
)
u_i2c_slave
(
	/*input   			*/.sys_clk	(sys_clk), //system clock 50MHz
	/*input    		    */.sys_rst_n(sys_rst_n), //reset ，low valid 
	/*input    		    */.scl 	    (scl), //串行时钟总线
	/*input    		    */.sda_in	(sda_in), //三态门的写法

	/*output reg  		*/.sda_oe	(sda_oe), //1'b1，使能输出，也即给出应答状态
	/*output reg  		*/.sda_o	(sda_o)
);


//Logic Description
	assign sdat = sda_oe ? sda_o : 1'bz;
	assign sda_in = ~sda_oe ? sdat : 1'b0;

endmodule 
