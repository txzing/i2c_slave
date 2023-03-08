/*================================================*\
	  Description  �si2c �ӻ�ģ�� ��������ļ� 
\*================================================*/
module 	i2c_slave_top
#(
    parameter   I2C_SLAVE_ADDR      = 7'h36,   //7bit i2c slave addr
    parameter   I2C_SLAVE_REG_MODE  = 1'b0    // i2c reg width,1-16bit, 0-8bit
)
(
	input   			sys_clk	    , //system clock 50MHz
	input    		    sys_rst_n	, //reset ��low valid 
    
	input    		    scl 	, //����ʱ������
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
//   .I2C_SLAVE_DAT_MODE(1'b0 ) // i2c reg width, 2-32bit, 1-16bit, 0-8bit  //Ԥ��,��δ���ù���
)
u_i2c_slave
(
	/*input   			*/.sys_clk	(sys_clk), //system clock 50MHz
	/*input    		    */.sys_rst_n(sys_rst_n), //reset ��low valid 
	/*input    		    */.scl 	    (scl), //����ʱ������
	/*input    		    */.sda_in	(sda_in), //��̬�ŵ�д��

	/*output reg  		*/.sda_oe	(sda_oe), //1'b1��ʹ�������Ҳ������Ӧ��״̬
	/*output reg  		*/.sda_o	(sda_o)
);


//Logic Description
	assign sdat = sda_oe ? sda_o : 1'bz;
	assign sda_in = ~sda_oe ? sdat : 1'b0;

endmodule 
