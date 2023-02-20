
/*=============================================================================================================*\
		  Filename �si2c_slave.v
			Author �sAdolph
	  Description  �si2c reloop
		 Called by �s
Revision History   �s 2022-5-7  V1.0  ָ��+��ַ+����  ��֧��2�ֽڵĶ�д��дʱ��������⡷
						
					  2022-5-17 V2.0 �Ż���дʱ��
  			  Email�s  
	Tips��ͬ������Ҫ����SCL��SDA���Լ�ϵͳʱ�ӣ�Ȼ��ѡ���߽�������ݽ���2022-5-7 11:14:01
	scl:400KHz
	Device Id: 0b1010000
	Memery Size: 16Byte
	
	�ӻ�ֻ�ܷ���ACK
	ÿ������1byte���ݺ󶼷���һ��ACK
	
	��scl���½�����Ϊ�����Ŀ�ʼ/�����־���͵�ƽ�м�仯���ߵ�ƽ�м����
	
					2022-5-17 12:56:17
				�ӻ��ϸ���˵��û��ʱ�ӵģ�����scl�����������˾Ͳ����ݣ��½������˾ͷ����ݷ�����
				�ߵ�ƽ�ڼ�һֱ�����ݣ�������������ͳ��1�ĸ������ڼ���ֵһ�룬����Ϊ�ɼ��ߵ�ƽ������Ϊ�͵�ƽ
			2022-5-18 15:16:39 �������	
			
			
	2023.2.9		
		Modified by TX:			
    Ŀǰֻ��֧�� 2byte reg_addrѰַ , ��д1byte data ������,֧��������������д	
    ��������չѰַ�ռ����д�����ݿռ�	
    
ע�⣺����Xilinx��FPGA����̬���У�TΪ0���������TΪ1��������
�������ԣ���100KHz����400KHz�¿�����ͬѧ
    
    2023.2.15
        Modified by TX:
    �������Թ��ܾ�����
    ���ڵ�ַ0X78-0x7B,��7λ��ַ�б�����,����ɿ�IIC��ַ����

vivado����ila���ԣ�
(* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)
\*=============================================================================================================*/
module 	i2c_slave
#(
    parameter   I2C_SLAVE_ADDR      = 7'b0110110,   //7bit i2c slave addr
    parameter   REG_DEVICE_ADDR     = 16'h0000  ,   //�豸��ַ�ļĴ�����ַ
    parameter   DEVICE_ADDR_BIT     = 1'b0      ,   //д��REG_DEVICE_ADDR��7λdevice_addrֵ������ڵ�7λ���Ǹ�7λ,0�����7λ
    parameter   I2C_SLAVE_REG_MODE  = 1'b0      ,   // i2c reg width,1-16bit, 0-8bit
    parameter   I2C_SLAVE_DAT_MODE  = 1'b0      ,   // i2c reg width, 2-32bit, 1-16bit, 0-8bit  //Ԥ��
    parameter   SDA_T_POLARITY      = 1'b0          // sda��������ԣ��ߵ�ƽ��Ϊ��������ǵ͵�ƽ��Ϊ���

)

(
	input wire  		sys_clk		/* synthesis syn_keep = 1 */, //system clock 50MHz
	input wire   		sys_rst_n	/* synthesis syn_keep = 1 */, //reset ��low valid 
	input wire   		scl         /* synthesis syn_keep = 1 */, //����ʱ������
	input wire   		sda_in	, //��̬�ŵ�д��
	output wire  		sda_t	, //
	output reg  		sda_o	
);	
   
	localparam IDLE		  = 8'b0000_0001, //����״̬
			   START	  = 8'b0000_0010, //������ʼλ״̬
			   JUG_RW 	  = 8'b0000_0100, //�жϽ��ն�дָ��״̬
			   RW_ADDR_16 = 8'b0000_1000, //���ն�д��ַ״̬ 2byte
			   RW_ADDR	  = 8'b0001_0000, //���ն�д��ַ״̬
			   WR_DAT	  = 8'b0010_0000, //����д����״̬
			   RD_DAT	  = 8'b0100_0000, //���Ͷ�����״̬
			   STOP		  = 8'b1000_0000; //����ֹͣλ״̬
			   
//Interrnal wire/reg declarations
    reg [6:0]   device_addr     ;
	reg [7:0]   WR_CTRL_WORD    ;
	reg [7:0]   RD_CTRL_WORD    ;
	reg	[7:0]	state_c         ; 
    reg [7:0]   state_n         ; //״̬���ź�	
	reg	[9:0]	scl_cnt  		; //scl �ߵ�ƽ�ɼ����ݼ�����
    reg [7:0 ]  sda_cnt         ; //��scl�ߵ�ƽ�ڼ䣬����sysclk,��sda�ĸߵ�ƽ���м���
	
	
	reg	[3:0]	cnt_bit 		; //����λ������
	
	reg	[15:0]	reg_addr		; //��д�Ĵ�����ַ
	reg [7:0]	memory [35:0]	; //�ݶ� 36 Byte ���ݴ洢�ռ�	
	
	reg [7:0]	data_r		    ; //������յ�������
    reg [7:0]	rd_data         ; //�ݴ����������
	reg	[1:0]	scl_r,sda_r		; //�Ĵ���ģ����ڱ��ؼ��
    reg         end_9b          ;//9bit���ݴ����꣬����Ӧ��λ
    reg         rev_H_flag      ;//���ոߵ�ƽ�źű�־
    reg         rev_L_flag      ;//���ոߵ�ƽ�źű�־
    reg         send_ack_flag   ;//����Ӧ���־λ�������ź�
    reg         wr_vld          ;//����д��Ĵ�����Ч�ź�
    reg         rd_vld          ;//���ݴӼĴ���������Ч�ź�
	
	wire		scl_neg,scl_pos	; //scl ˫����
	wire		sda_neg,sda_pos	; //sdat ˫����   
   
    wire        add_scl_cnt         ; //�������ۼ�����
	wire        end_scl_cnt         ; //������������������
	//״̬��ת��������
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
    
    reg [7:0]    ROReg0 ;//�����ĸ�ֻ���Ĵ���
	reg [7:0]    ROReg1 ;
    reg [7:0]    ROReg2 ;	
	reg [7:0]    ROReg3 ;
  
    wire         rst_n;
reset_sync  u_reset_sync  //�첽��λͬ���ͷ�
(
/*input  	*/.sys_clk		(sys_clk),
/*input  	*/.sys_rst_n  	(sys_rst_n),
/*output 	*/.rst_sync_n   (rst_n)

);

//��vivado��̬���У�TΪ0�������
    reg     sda_oe;//���ʹ���źţ�1�������
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
		
	//��һ������״̬ת��
	always @(posedge sys_clk)begin
		if(!rst_n)begin
			state_c <= IDLE;
		end
		else begin 
			state_c <= state_n;
		end
	end
    
	//�ڶ��Ρ�����߼�����״̬ת��
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
				if(start2jug_rw)begin //scl ���ͺ���ת
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
            begin      //����2byte�Ĵ�����ַ�ĸ�byte
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
				if(wr_dat2start)begin //���յ���ʼλ
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

	assign	idle2start			= state_c == IDLE	 && sda_neg && scl_r[1];//��ʼλ��sdat �� scl �ߵ�ƽ�ڼ�����½���
	assign	start2jug_rw		= state_c == START	 && scl_pos;//��������״̬
	assign	jug_rw2rw_addr_16	= state_c == JUG_RW	 && end_9b && (data_r == WR_CTRL_WORD && I2C_SLAVE_REG_MODE );
	assign	jug_rw2rw_addr	  	= state_c == JUG_RW	 && end_9b && (data_r == WR_CTRL_WORD && !I2C_SLAVE_REG_MODE);
	assign	jug_rw2rd_dat	  	= state_c == JUG_RW	 && end_9b && data_r == RD_CTRL_WORD;
	assign	jug_rw2idle		  	= ((state_c == JUG_RW) && end_9b && (data_r != WR_CTRL_WORD && data_r != RD_CTRL_WORD)) || (scl_r[1] && sda_pos);	
	assign	rw_addr_162rw_addr	= state_c == RW_ADDR_16	 && end_9b;
    assign  rw_addr_162idel     = state_c == RW_ADDR_16 && ((scl_r[1] && sda_neg) || (scl_r[1] && sda_pos));
	assign	rw_addr2wr_dat    	= state_c == RW_ADDR && end_9b;//�Ĵ�����ַΪ2byte�Ļ���cnt_bitҪ��
    assign  rw_addr2idel        = state_c == RW_ADDR && ((scl_r[1] && sda_neg) || (scl_r[1] && sda_pos));
	assign	wr_dat2start   	  	= state_c == WR_DAT  && (scl_r[1] && sda_neg);//��ʼλ��sdat �� scl �ߵ�ƽ�ڼ�����½���
	assign	wr_dat2stop       	= state_c == WR_DAT  && (scl_r[1] && sda_pos);//����ֹͣλ
	assign	rd_dat2stop       	= state_c == RD_DAT && (cnt_bit == 4'd8 && scl_r[1] && sda_r[1]);//��⵽NACK
    assign  rd_dat2idle         = state_c == RD_DAT && ((scl_r[1] && sda_neg) || (scl_r[1] && sda_pos));
	assign 	stop2idle		  	= state_c == STOP && (scl_r[1] && sda_r[1] && scl_cnt >= 11'd50);//�ȴ�1 us
	
    
//end_9b    �����ź�,8bit���ݽ�����,�ҷ�����Ӧ��λ(8bit���ݣ�1bitӦ��)
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
   
  
//��scl�ߵ�ƽ������ͳ�Ƶ�ƽ
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
        else if(state_c == STOP)begin //����ʱ������ʹ��
			scl_cnt <= scl_cnt + 1'b1;
		end 
		else begin  
			scl_cnt <= 'd0;
            sda_cnt <= 0;
		end  
    end 
               
    assign add_scl_cnt = (state_c != IDLE && state_c != START);
    assign end_scl_cnt = add_scl_cnt && (scl_pos || scl_neg); //����64 32 16 8 4 2 1 


//send_ack_flag    �����ź�
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
					if(send_ack_flag && (data_r[7:1]==device_addr)begin
                        sda_oe 	 <= 1'b1;//�������߿���Ȩ������Ӧ��λ
						sda_o 	 <= 1'b0;				
					end                 
					else if(end_9b)
                    begin
                        if(data_r == RD_CTRL_WORD))begin
                            sda_oe 	 <= 1'b1;//������ܵ��Ƕ�ָ��򲻱��ͷ����ߣ��ӻ�׼��������
                            sda_o 	 <= 1'b0;  
                        end 
                        else if((data_r == WR_CTRL_WORD))begin //Ӧ��λ�������
                        sda_oe 	 <= 1'b0;//Ӧ��λ������ɣ��ͷ����߿���Ȩ
                        sda_o 	 <= 1'b1;  
                        end    
                        else begin	//������ַ�Ĳ��������ͷ�����				
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
						sda_oe <= 1'b1; //�������߿���Ȩ������Ӧ��λ
						sda_o  <= 1'b0;	//�����͵�ƽ,ack					
					end 
					else if(end_9b)begin
						sda_oe <= 1'b0; //Ӧ��λ������ɣ��ͷ����߿���Ȩ
						sda_o  <= 1'b1;
					end
                    else begin
                        sda_oe 	 <= sda_oe;
                        sda_o 	 <= sda_o;  
                    end                     
				end 
				RW_ADDR:begin
					if(send_ack_flag)begin
						sda_oe <= 1'b1; //�������߿���Ȩ������Ӧ��λ
						sda_o  <= 1'b0;						
					end 
					else if(end_9b)begin
						sda_oe <= 1'b0; //Ӧ��λ������ɣ��ͷ����߿���Ȩ
						sda_o  <= 1'b1;
					end 
                    else begin
                        sda_oe 	 <= sda_oe;
                        sda_o 	 <= sda_o;  
                    end                     
				end 
				WR_DAT	:begin
					if(send_ack_flag)begin
						sda_oe <= 1'b1; //�������߿���Ȩ������Ӧ��λ
						sda_o  <= 1'b0;						
					end 
					else if(end_9b)begin
						sda_oe <= 1'b0; //Ӧ��λ������ɣ��ͷ����߿���Ȩ
						sda_o  <= 1'b1;
					end 
                    else begin
                        sda_oe 	 <= sda_oe;
                        sda_o 	 <= sda_o;  
                    end                     
				end
				RD_DAT	:begin	
					if(send_ack_flag)begin //����������Ӧ��
						sda_oe   <= 1'b0; 
						sda_o    <= 1'b1;						
					end
					else if(end_9b)begin
						sda_oe <= 1'b1; //�ӹ����߿���Ȩ,�������					
					end 				
					else if(~scl_r[1] && cnt_bit < 4'd8 && scl_cnt[5])begin //scld��������
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
    
//����Э�飬scl�ߵ�ƽ�ڼ䣬sda���ᷭת    
    always @(posedge sys_clk)begin  
		if(!rst_n)begin  
			rev_H_flag <= 1'b0;
            rev_L_flag <= 1'b0;
		end   
		else if(scl_neg && (cnt_bit < 4'd8) && (|sda_cnt[7:5])) begin  //scl�ߵ�ƽ�ڼ䣬sda�ߵ�ƽ���ٳ�������32��sys_clk 
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
						data_r <= {data_r[6:0],1'b1};//�����400KHz,������
					end 
                    else if(rev_L_flag)begin
                        data_r <= {data_r[6:0],1'b0};//�����400KHz,������
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
						reg_addr[15:8] <= data_r; //��ַ��ֵ
					end 						
					else if(rev_H_flag)begin
						data_r <= {data_r[6:0],1'b1};//�����400KHz,������
					end 
                    else if(rev_L_flag)begin
                        data_r <= {data_r[6:0],1'b0};//�����400KHz,������
                    end
					else begin
						data_r <= data_r;
					end 
				end 
				RW_ADDR:begin
                    if(end_9b)begin
						data_r <= 8'd0; //��ַ��ֵ
					end
                    else 
                    if(cnt_bit == 4'd8 && scl_pos)begin
						reg_addr[7:0] <= data_r; //��ַ��ֵ
					end 						
					else if(rev_H_flag)begin //����32
						data_r <= {data_r[6:0],1'b1};//�����400KHz,������
					end 
                    else if(rev_L_flag)begin
                        data_r <= {data_r[6:0],1'b0};//�����400KHz,������
                    end
					else begin
						data_r <= data_r;
					end 
				end 
				WR_DAT	:begin
                        if(end_9b)begin
                            data_r <= 8'd0;
                            reg_addr<= reg_addr + 1'd1; //ÿд�� 1byte data д��ַ���� 1                         
                        end 
                        else if(cnt_bit == 4'd8 && scl_pos)begin
                            wr_vld <= 1'b1;
                        end
                        else if(rev_H_flag)begin //ͳ����scl�ߵ�ƽ�ڼ䣬sda��������32��sys_clk�ߵ�ƽ,����Ϊ�ǲɵ��ߵ�ƽ
                            data_r <= {data_r[6:0],1'b1};//�����400KHz������,���62��sys_clk,100KHz,���250��sys_clk
                        end 
                        else if(rev_L_flag)begin
                            data_r <= {data_r[6:0],1'b0};//�����400KHz,������
                        end
                        else begin
                            wr_vld <= 1'b0;
                            data_r <= data_r;
                        end 
				end
				RD_DAT	:begin	
					if(cnt_bit == 4'd8 && scl_pos)begin 
						reg_addr<= reg_addr + 4'd1; //ÿд�� 1byte data д��ַ���� 1
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
    

//�Ĵ�����ַ0Ϊ�豸��ַ
    always @(posedge sys_clk)begin  
        if(!rst_n)begin 
            device_addr <= I2C_SLAVE_ADDR;//7λ��ַ
        end
        else if(state_c == WR_DAT && wr_vld && (reg_addr == REG_DEVICE_ADDR))begin
            if(DEVICE_ADDR_BIT)begin
                device_addr <= data_r[7:1];//ȡ��7λ
            end
            else begin
                device_addr <= data_r[6:0];//ȡ��7λ
            end   
        end
        else begin
            device_addr <= device_addr;
        end
    end
     
    always @(*)begin 
        WR_CTRL_WORD = {device_addr,1'b0};
        RD_CTRL_WORD = {device_addr,1'b1};
    end

/*
�˴����ö�д��ֵ��ɶ�д�ļĴ���
*/    
    always @(posedge sys_clk)begin  
    if(!rst_n)begin 
        ROReg0         <=   8'hA0;// ֻ���Ĵ���
        ROReg1         <=   8'hA1;// �����ǳ�ʼֵ
        ROReg2         <=   8'hA2;// �����ǳ�ʼֵ
        ROReg3         <=   8'hA3;// �����ǳ�ʼֵ
        memory[0]      <=   8'hB0;// �����ǳ�ʼֵ 
        memory[1]      <=   8'hB1;// �����ǳ�ʼֵ 
        memory[2]      <=   8'hB2;// �����ǳ�ʼֵ 
        memory[3]      <=   8'hB3;// �����ǳ�ʼֵ 
        memory[4]      <=   8'hB4; 
        memory[5]      <=   8'hB5; 
        memory[6]      <=   8'hB6; 
        memory[7]      <=   8'hB7; 	
        memory[8]      <=   8'h58;
        memory[9]      <=   8'h03;
        memory[10]     <=   8'h43;
        memory[11]     <=   8'h01;
        memory[12]     <=   8'h03;
        memory[13]     <=   8'h5E;
        memory[14]     <=   8'h06;
        memory[15]     <=   8'hD8;
        memory[16]     <=   8'h03;
        memory[17]     <=   8'h78;
        memory[18]     <=   8'h03;
        memory[19]     <=   8'h48;
        memory[20]     <=   8'h21;
        memory[21]     <=   8'h03;
        memory[22]     <=   8'h0C;
        memory[23]     <=   8'h01;
        memory[24]     <=   8'h00;
        memory[25]     <=   8'h19;
        memory[26]     <=   8'hF4;
        memory[27]     <=   8'h11;
        memory[28]     <=   8'h87;
        memory[29]     <=   8'h00;
        memory[30]     <=   8'h28;
        memory[31]     <=   8'h23;
        memory[32]     <=   8'h19;
        memory[33]     <=   8'h0F;
        memory[34]     <=   8'h83;
        memory[35]     <=   8'h07;
    end
    else begin
        if (jug_rw2rd_dat || rd_vld) // --- I2C Read
        begin
            case (reg_addr)
                16'h0000: rd_data <= DEVICE_ADDR_BIT?{device_addr,1'b0}:{1'b0,device_addr};//�ɶ��豸��ַ
                16'h0001: rd_data <= ROReg0        ;  
                16'h0002: rd_data <= ROReg1        ;  
                16'h0003: rd_data <= ROReg2        ;  
                16'h0004: rd_data <= ROReg3        ;  
                16'h0005: rd_data <= memory[0][7:0];  
                16'h0006: rd_data <= memory[1][7:0];  
                16'h0007: rd_data <= memory[2][7:0];  
                16'h0008: rd_data <= memory[3][7:0];  
                16'h0009: rd_data <= memory[4][7:0];  
                16'h000A: rd_data <= memory[5][7:0]; 
                16'h000B: rd_data <= memory[6][7:0]; 
                16'h000C: rd_data <= memory[7][7:0];
/*                        
��ģ����Ҫ�ļĴ�����ַ
*/               
                16'h300A: rd_data <= memory[8 ][7:0];
                16'h300B: rd_data <= memory[9 ][7:0];
                16'h300C: rd_data <= memory[10][7:0];
                16'h302A: rd_data <= memory[11][7:0];
                16'h380E: rd_data <= memory[12][7:0];
                16'h380F: rd_data <= memory[13][7:0];
                16'h380C: rd_data <= memory[14][7:0];
                16'h380D: rd_data <= memory[15][7:0];			
                16'h388C: rd_data <= memory[16][7:0];
                16'h388D: rd_data <= memory[17][7:0];		
                16'h384C: rd_data <= memory[18][7:0];
                16'h384D: rd_data <= memory[19][7:0];
                16'h7000: rd_data <= memory[20][7:0];
                16'h7001: rd_data <= memory[21][7:0];
                16'h7002: rd_data <= memory[22][7:0];
                16'h7003: rd_data <= memory[23][7:0];
                16'h7004: rd_data <= memory[24][7:0];
                16'h7005: rd_data <= memory[25][7:0];
                16'h7006: rd_data <= memory[26][7:0];
                16'h7007: rd_data <= memory[27][7:0];
                16'h7008: rd_data <= memory[28][7:0];
                16'h7009: rd_data <= memory[29][7:0];
                16'h700A: rd_data <= memory[30][7:0];
                16'h700B: rd_data <= memory[31][7:0];
                16'h700C: rd_data <= memory[32][7:0];
                16'h700D: rd_data <= memory[33][7:0];
                16'h700E: rd_data <= memory[34][7:0];
                16'h700F: rd_data <= memory[35][7:0]; 
                REG_DEVICE_ADDR : rd_data <= DEVICE_ADDR_BIT?{device_addr,1'b0}:{1'b0,device_addr};//�ɶ��豸��ַ              
                
            default: rd_data <= 8'hFF; // i2c���Ƿ��ڲ���ַ, ����0xff
            endcase
        end
        else if (wr_vld) // --- I2C Write
        begin
            case (reg_addr)//��ģ����ʵд��ļĴ���  
            16'h0005: memory[0][7:0] <= data_r;   
            16'h0006: memory[1][7:0] <= data_r;     
            16'h0007: memory[2][7:0] <= data_r;
            16'h0008: memory[3][7:0] <= data_r;
            16'h0009: memory[4][7:0] <= data_r;
            16'h000a: memory[5][7:0] <= data_r;
            16'h000b: memory[6][7:0] <= data_r;
            16'h000c: memory[7][7:0] <= data_r;
            endcase
        end
    end
end
    
endmodule 
