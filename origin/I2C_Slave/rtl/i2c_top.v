/*================================================*\
		  Filename ﹕i2c_top.v
			Author ﹕Adolph
	  Description  ﹕i2c 从机模块 顶层调度文件
		 Called by ﹕
Revision History   ﹕ 2022-5-13 15:28:47
		  			  Revision 1.0
  			  Email﹕ 
			Company﹕ 
\*================================================*/
module 	i2c_top(
	input  wire			Clk		, //system clock 50MHz
	input  wire 		Rst_n	, //reset ，low valid

	input  wire 		Sclk 	, //串行时钟总线
	inout  wire  		Sdat	, //
	
	output wire  [7:0]	sen_duan,
	output wire  [5:0]	sen_wei	
);

	

//Interrnal wire/reg declarations
	wire 			Sda_in ;
	wire 			Sda_oe ;
	wire 			Sda_o  ; 
	wire 			rw_flag; //读写状态标志信号 0：写；1：读
	wire 			Wr_vld ; //写数据有效标志
	wire  [07:00]	Wr_data; //写入数据
	wire 			Rd_vld ; //读数据有效标志
	wire  [07:00]	Rd_data; //读出数据
	
//Module instantiations ， self-build module
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
	
	smg_ctrl	Segment(
	/*input   wire            */.clk		(Clk		),
	/*input   wire            */.rst_n		(Rst_n		), 
    /*input   wire  [19:0]    */.data_in	(Rd_data	),

	/*output  wire  [7:0]     */.sen_duan	(sen_duan	),
	/*output  wire  [5:0]     */.sen_wei	(sen_wei	)	
	);


//Logic Description
	assign Sdat = Sda_oe ? Sda_o : 1'bz;
	
	assign Sda_in = ~Sda_oe ? Sdat : 1'b0;

endmodule 
