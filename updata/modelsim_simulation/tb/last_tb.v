/*================================================*\
			  _ _
			_|   |_ ���ݴ���׶Σ�per bit��ʱ��
\*================================================*/

`timescale 1ns/1ns 		//����ϵͳʱ��߶ȶ���

`define clk_period 20  	//ʱ�����ڲ�������	

`define sclk_period 500 //125 ��ϵͳʱ�����ڣ��ȸߺ��,400KHz��Ƶ����

module last_tb(); 


parameter           DEVICE_ADDR = 7'h36;
parameter           WR_CTRL     = {DEVICE_ADDR,1'b0};
parameter           RD_CTRL     = {DEVICE_ADDR,1'b1};
//�����źŶ���  
	reg				sys_clk		; 
	reg				rst_n	; 
	reg				scl	; //
	reg				sda_in	; //
	
//��Ӧ�źŶ���	  
	wire 			sda_oe	; //
	wire 			sda_o	; //

	integer			i       ;
	reg		[127:0]	State_Machine; //string
	
	localparam IDLE		  = 8'b0000_0001, //����״̬
			   START	  = 8'b0000_0010, //������ʼλ״̬
			   JUG_RW 	  = 8'b0000_0100, //�жϽ��ն�дָ��״̬
			   RW_ADDR_16 = 8'b0000_1000, //���ն�д��ַ״̬ 2byte
			   RW_ADDR	  = 8'b0001_0000, //���ն�д��ַ״̬
			   WR_DAT	  = 8'b0010_0000, //����д����״̬
			   RD_DAT	  = 8'b0100_0000, //���Ͷ�����״̬
			   STOP		  = 8'b1000_0000; //����ֹͣλ״̬
               
               
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
//   .I2C_SLAVE_DAT_MODE(1'b0 ) // i2c reg width, 2-32bit, 1-16bit, 0-8bit  //Ԥ��,��δ���ù���
)
u_i2c_slave
(
	/*input   	   */.sys_clk	(sys_clk), //system clock 50MHz
	/*input    	   */.sys_rst_n	    (rst_n)  , //reset ��low valid 
	/*input    	   */.scl 	    (scl)    , //����ʱ������
	/*input    	   */.sda_in	(sda_in) , //��̬�ŵ�д��

	/*output reg   */.sda_t	    (sda_t) , //1'b1��ʹ�������Ҳ������Ӧ��״̬
	/*output reg   */.sda_o	    (sda_o) 
);

//����ʱ��							       		 
	initial sys_clk = 1'b0;		       		 
	always #(`clk_period / 2) sys_clk = ~sys_clk;  		 

//��������	 
	initial  begin	 
		rst_n = 1'b0;	 
		scl  = 1'b1;
		sda_in= 1'b1;
		#(`clk_period * 10 + 3);//��λ	 
		rst_n = 1'b1;	 
		#(`clk_period * 10); //��λ����
        
	//д����		
        start;
		Send_data(WR_CTRL); //дָ��
			
		Send_data(8'h00); //д��ַ
        Send_data(8'h05); //д��ַ	
		Send_data(8'h19); //д����
        Send_data(8'h20); //д����
        Send_data(8'h33); //д����
        Send_data(8'h25); //д����
        Send_data(8'h04); //д����

        stop;
		
		#(`sclk_period * `clk_period * 10);		
		
		
		
	//������
        start;
		Send_data(WR_CTRL); //дָ��		
		Send_data(8'h00); //д��ַ
        Send_data(8'h05); //д��ַ
        read_start;
		Send_data(RD_CTRL); //��ָ��		
		Rx_data; //������
		send_ack;
        Rx_data; //������
		send_ack;
        Rx_data; //������
		send_ack;
        Rx_data; //������
		send_ack;
        Rx_data; //������
		send_ack;
        Rx_data; //������
		send_ack;
		Rx_data;
		send_Nack;	
        
        stop;//ֹͣλ
        
        
        start;
        //���豸��ַ
        Send_data(WR_CTRL); //дָ��
		Send_data(8'h00); //д��ַ
        Send_data(8'h00); //д��ַ	
		Send_data({1'b0,7'h78}); //д����
        stop;
        
        start;
        //���Դ����豸��ַ
        Send_data(WR_CTRL); //дָ��
		Send_data(8'h00); //д��ַ
        Send_data(8'h05); //д��ַ	
		Send_data(8'haa); //д����
        stop;
        
        start;
        //��ȷ�豸��ַд
        Send_data({7'h78,1'b0}); //дָ��
		Send_data(8'h00); //д��ַ
        Send_data(8'h05); //д��ַ	
		Send_data(8'haa); //д����
        stop;
        
        
        start;
        //��ȷ�豸��ַ��
        Send_data({7'h78,1'b0}); //дָ��
		Send_data(8'h00); //д��ַ
        Send_data(8'h05); //д��ַ	
        read_start;
		Send_data({7'h78,1'b1}); //��ָ��	
		Rx_data; //������
		send_Nack;
        stop;

		$stop(2); 
	end	 
	



    
    task  start; 
		// input	;
		begin //��ʼλ
			#(`sclk_period * `clk_period / 2) sda_in = 1'b0;
			#(`sclk_period * `clk_period / 4) scl   = 1'b0;
			#(`sclk_period * `clk_period / 4);
		end
	endtask
    
    task  read_start; 
		// input	;
		begin 
    		fork //��ʼλ
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
		begin //ֹͣλ			
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
	
	
	
	task  Rx_data; //Ҫ����ACK �� NACK 
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