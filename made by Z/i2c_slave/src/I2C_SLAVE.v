//`default_nettype none 
module I2C_SLAVE # 
( 
    parameter   I2C_SLAVE_ADDR  = 8'b01010000,   // i2c bus addr
    parameter   I2C_SLAVE_REG_MODE  = 2'b1,   // i2c reg width, 2-32bit, 1-16bit, 0-8bit
    parameter   I2C_SLAVE_DAT_MODE  = 2'b0,   // i2c reg width, 2-32bit, 1-16bit, 0-8bit
    parameter   DEBOUNCE_LEN    = 10            // 10 ticks = 208nS @ 48MHz
    // TODO: implement sample delay
) 
(      
    CLOCK,                                      // 48MHz system clock
    RESET,                                      // reset active high
    SCL,
    SDA_I,
    SDA_O,
    SDA_T,

//    RD_EN,                                      //
//    ADD_IN,                                     // 
//    DAT_OUT,                                    //
    
//    SW0_0,                                      //
//    SW0_1,
//    SW0_2,
//    SW0_3,
//    SW0_4,
//    SW0_5,
//    SW0_6,
//    SW0_7,
	
//    I_SDA_DEB,
//    I_SCL_DEB,
//    I_SDA_DEB_1,
//    I_SCL_DEB_1,
//    I_SDA_OUT_OE,

    IDLE_S,
    READCTRL_S,
    READREGH_S,
    READREGHH_S,
    READREGHHH_S,
    READREG_S,
    READ_S,
    READH_S,
    READHH_S,
    READHHH_S,
    WRITE_S,
    WRITEHHH_S,
    WRITEHH_S,
    WRITEH_S,
    STOP_S,

    debug
)/* synthesis syn_preserve=1 */;

input                       CLOCK;
input                       RESET;
input                       SCL;
input                       SDA_I;
output                      SDA_O;
output                      SDA_T;
wire                        CLOCK  /* synthesis syn_keep = 1 */;
wire                        RESET  /* synthesis syn_keep = 1 */;
wire                        SCL  /* synthesis syn_keep = 1 */;

//input                       RD_EN;
//wire                        RD_EN /* synthesis syn_keep = 1 */;
//input   [2:0]               ADD_IN;
//wire    [2:0]               ADD_IN /* synthesis syn_keep = 1 */;
//output  [7:0]              DAT_OUT;
//reg     [7:0]              DAT_OUT /* synthesis syn_keep = 1 */;

//output                      SW0_0;
//output                      SW0_1;
//output                      SW0_2;
//output                      SW0_3;
//output                      SW0_4;
//output                      SW0_5;
//output                      SW0_6;
//output                      SW0_7;

output                      debug;
reg                         debug = 1'b1;

//output    I_SDA_DEB;
//output    I_SCL_DEB;
//output    I_SDA_DEB_1;
//output    I_SCL_DEB_1;
//output    I_SDA_OUT_OE;

output    IDLE_S;
output    READCTRL_S;
output    READREGH_S;
output    READREGHH_S;
output    READREGHHH_S;
output    READREG_S;
output    READ_S;
output    READH_S;
output    READHH_S;
output    READHHH_S;
output    WRITE_S;
output    WRITEHHH_S;
output    WRITEHH_S;
output    WRITEH_S;
output    STOP_S;

reg    IDLE_S;
reg    READCTRL_S;
reg    READREGH_S;
reg    READREGHH_S;
reg    READREGHHH_S;
reg    READREG_S;
reg    READ_S;
reg    READH_S;
reg    READHH_S;
reg    READHHH_S;
reg    WRITE_S;
reg    WRITEHHH_S;
reg    WRITEHH_S;
reg    WRITEH_S;
reg    STOP_S;

reg                         I_SDA_ACK_OUT /* synthesis syn_keep = 1 */;
wire                        I_SDA_IN /* synthesis syn_keep = 1 */;

reg                         I_SDA_DEB /* synthesis syn_keep = 1 */;
reg                         I_SCL_DEB /* synthesis syn_keep = 1 */;
reg                         I_SDA_DEB_1 /* synthesis syn_keep = 1 */;
reg                         I_SCL_DEB_1 /* synthesis syn_keep = 1 */;
reg [DEBOUNCE_LEN-1:0]      I_SDA_PIPE /* synthesis syn_keep = 1 */;
reg [DEBOUNCE_LEN-1:0]      I_SCL_PIPE /* synthesis syn_keep = 1 */;

reg     [7:0]               I_CTRL_BYTE /* synthesis syn_keep = 1 */;
reg     [7:0]               I_REG_ADDR /* synthesis syn_keep = 1 */;
reg     [7:0]               I_REG_ADDRH /* synthesis syn_keep = 1 */;
reg     [7:0]               I_REG_ADDRHH /* synthesis syn_keep = 1 */;
reg     [7:0]               I_REG_ADDRHHH /* synthesis syn_keep = 1 */;
//reg     [7:0]               I_REG_ADDR_1; // lotch I_REG_ADDR for output until next I_CTRL_BYTE update complete
reg     [7:0]               I_SDA_DATA /* synthesis syn_keep = 1 */; // 输入的
reg                         I_SDA_OUT_OE /* synthesis syn_keep = 1 */;


wire                        I_SCL_FALL /* synthesis syn_keep = 1 */; 
wire                        I_SCL_RISE /* synthesis syn_keep = 1 */; 
wire                        I_SCL_HIGH /* synthesis syn_keep = 1 */; 
wire                        I_SCL_LOW /* synthesis syn_keep = 1 */; 
wire                        I_SDA_FALL /* synthesis syn_keep = 1 */;
wire                        I_SDA_RISE /* synthesis syn_keep = 1 */;
wire                        I_SDA_HIGH /* synthesis syn_keep = 1 */;
wire                        I_SDA_LOW /* synthesis syn_keep = 1 */;
//reg     [7:0]               I_SREG_SDA_IN;
reg     [7:0]               I_SREG_SDA_OUT /* synthesis syn_keep = 1 */;
//reg     [3:0]               I_BIT_CNT;

reg                         I_WR_OP /* synthesis syn_keep = 1 */;
reg                         I_RD_OP /* synthesis syn_keep = 1 */;
//reg     [7:0]               I_WR_VAL; // for output
reg     [31:0]              I_RD_VAL /* synthesis syn_keep = 1 */;
reg                         I_RD_ACK /* synthesis syn_keep = 1 */;

reg                         I_START_FF /* synthesis syn_keep = 1 */;
reg                         I_START_FF_1 /* synthesis syn_keep = 1 */;
wire                        I_START_EDGE /* synthesis syn_keep = 1 */;
wire                        I_STOP_EDGE /* synthesis syn_keep = 1 */;
reg     [1:0]               I_START_EDGE_CNT /* synthesis syn_keep = 1 */;
//enum bit {RD_OP,WR_OP}      I_WR_OP;//1bit宽，2值数据类型

parameter HardWriteAddress = I2C_SLAVE_ADDR;
parameter HardReadAddress  = I2C_SLAVE_ADDR | 1'b1;


parameter    S_IDLE       =4'b0000;
parameter    S_READCTRL   =4'b0001;
parameter    S_READREGHHH =4'b0010;
parameter    S_READREGHH  =4'b0011;
parameter    S_READREGH   =4'b0100;
parameter    S_READREG    =4'b0101;
parameter    S_READ       =4'b0110;
parameter    S_READH      =4'b0111;
parameter    S_READHH     =4'b1000;
parameter    S_READHHH    =4'b1001;
parameter    S_WRITE      =4'b1010;
parameter    S_WRITEH     =4'b1011;
parameter    S_WRITEHH    =4'b1100;
parameter    S_WRITEHHH   =4'b1101;
parameter    S_STOP       =4'b1110;

reg [3:0]   ST_FSM_STATE /* synthesis syn_keep = 1 */;

reg [3:0]   sh8out_state /* synthesis syn_keep = 1 */;
reg [3:0]   sh8in_state /* synthesis syn_keep = 1 */;
reg [1:0]   ackout_state /* synthesis syn_keep = 1 */;

//-------------------------并行数据串行状态-----------------------------
// shift8_out从状态机的状态定义
parameter   sh8out_bit7 = 4'b0000;
parameter   sh8out_bit6 = 4'b0001;
parameter   sh8out_bit5 = 4'b0010;
parameter   sh8out_bit4 = 4'b0011;
parameter   sh8out_bit3 = 4'b0100;
parameter   sh8out_bit2 = 4'b0101;
parameter   sh8out_bit1 = 4'b0110;
parameter   sh8out_bit0 = 4'b0111;
parameter   sh8out_ack  = 4'b1000;
parameter   sh8out_end  = 4'b1001;
parameter   sh8out_repeat = 4'b1010;

//--------------------------串行数据并行状态----------------------------
// shift8in从状态机的状态定义
parameter   sh8in_begin    = 4'b0000;
parameter   sh8in_bit7     = 4'b0001;
parameter   sh8in_bit6     = 4'b0010;
parameter   sh8in_bit5     = 4'b0011;
parameter   sh8in_bit4     = 4'b0100;
parameter   sh8in_bit3     = 4'b0101;
parameter   sh8in_bit2     = 4'b0110;
parameter   sh8in_bit1     = 4'b0111;
parameter   sh8in_bit0     = 4'b1000;
parameter   sh8in_ack      = 4'b1001;
parameter   sh8in_end      = 4'b1010;

//--------------------------ACK输出状态----------------------------
parameter   ack_begin  = 2'b00;
parameter   ack_bit    = 2'b01;
parameter   ack_end    = 2'b10;


reg     I_ACK_OE /* synthesis syn_keep = 1 */;
reg     I_RD_OE /* synthesis syn_keep = 1 */;
wire    I_SDA_SOURCE_1 /* synthesis syn_keep = 1 */;
wire    I_SDA_SOURCE_2 /* synthesis syn_keep = 1 */;
wire    I_SDA_OUT /* synthesis syn_keep = 1 */;
assign  I_SDA_SOURCE_1      = (I_ACK_OE)     ? I_SDA_ACK_OUT : 1'b0; // 考虑直接I_SDA_ACK_OUT 换成0
assign  I_SDA_SOURCE_2      = (I_RD_OE)      ? I_SREG_SDA_OUT[7] : 1'b0;
assign  I_SDA_OUT           = (I_SDA_SOURCE_1 | I_SDA_SOURCE_2);
//assign  SDA                 = (I_SDA_OUT_OE) ? I_SDA_OUT : 1'bz;
//assign  I_SDA_IN            = SDA;
//assign  I_SDA_IN            = (~I_SDA_OUT_OE) ? SDA : 1'bz;
assign  SDA_O               = I_SDA_OUT;
assign  I_SDA_IN            = SDA_I;
assign  SDA_T               = ~I_SDA_OUT_OE;

assign  I_SCL_FALL          =   ~I_SCL_DEB & I_SCL_DEB_1; 
assign  I_SCL_RISE          =   I_SCL_DEB & ~I_SCL_DEB_1; 
assign  I_SCL_HIGH          =   I_SCL_DEB & I_SCL_DEB_1; 
assign  I_SCL_LOW           =   ~I_SCL_DEB & ~I_SCL_DEB_1; 
assign  I_SDA_FALL          =   ~I_SDA_DEB & I_SDA_DEB_1; 
assign  I_SDA_RISE          =   I_SDA_DEB & ~I_SDA_DEB_1; 
assign  I_SDA_HIGH          =   I_SDA_DEB & I_SDA_DEB_1; 
assign  I_SDA_LOW           =   ~I_SDA_DEB & ~I_SDA_DEB_1; 

// debounce sda and scl
// 去抖窗口 10 ticks
// 跳变之后稳定10个连续的电平才认为跳变完毕
always @(posedge CLOCK )
begin
    if (RESET == 1'b1) 
    begin
        I_SDA_PIPE <= {DEBOUNCE_LEN{1'b1}};
        I_SDA_DEB <= 1'b1;
        I_SDA_DEB_1 <= 1'b1;
        I_SCL_PIPE <= {DEBOUNCE_LEN{1'b1}};
        I_SCL_DEB <= 1'b1;
        I_SCL_DEB_1 <= 1'b1;
        //debug <= 1'b1;
    end
    else
    begin
        I_SDA_PIPE <= {I_SDA_PIPE[DEBOUNCE_LEN-2:0], I_SDA_IN}; // bit shift
        I_SCL_PIPE <= {I_SCL_PIPE[DEBOUNCE_LEN-2:0], SCL};      // bit shift
        //debug <= SDA;
        if (&I_SCL_PIPE[DEBOUNCE_LEN-1:1] == 1'b1)
        begin
            I_SCL_DEB <= 1'b1;
            I_SCL_DEB_1 <= I_SCL_DEB;
        end
        else if (|I_SCL_PIPE[DEBOUNCE_LEN-1:1] == 1'b0)
        begin
            I_SCL_DEB <= 1'b0;
            I_SCL_DEB_1 <= I_SCL_DEB;
        end
        if (&I_SDA_PIPE[DEBOUNCE_LEN-1:1] == 1'b1)
        begin
            I_SDA_DEB <= 1'b1;
            I_SDA_DEB_1 <= I_SDA_DEB;
        end
        else if (|I_SDA_PIPE[DEBOUNCE_LEN-1:1] == 1'b0)
        begin
            I_SDA_DEB <= 1'b0;
            I_SDA_DEB_1 <= I_SDA_DEB;
        end
    end
end

//-----------------------------检测start/stop----------------------------------
always @ (posedge CLOCK)
begin
    if(RESET == 1'b1)
        begin     
        I_START_FF      <= 1'b0;
        I_START_FF_1    <= 1'b0;
        I_START_EDGE_CNT <= 2'b0;
        //debug <= 1'b1;
    end
    else
    begin
        I_START_FF_1    <= I_START_FF;

//        if (I_START_EDGE)
//        begin
//            debug <= ~debug;
//        end
        
        if (I_SCL_HIGH & I_SDA_FALL)
        begin
            //debug <= 1'b0;
            I_START_FF  <= 1'b1;
            if(I_START_EDGE_CNT<2)
            begin
                I_START_EDGE_CNT <= I_START_EDGE_CNT+1'b1;
            end
        end
        else if (I_SCL_HIGH & I_SDA_RISE )
        begin
            //debug <= 1'b0;
            I_START_FF      <= 1'b0;
            I_START_EDGE_CNT <= 2'b0;
        end
    end
end
assign I_START_EDGE = I_START_FF & ~I_START_FF_1;
assign I_STOP_EDGE = ~I_START_FF & I_START_FF_1;



reg         FF /* synthesis syn_keep = 1 */;         //标志寄存器
reg         RFF /* synthesis syn_keep = 1 */;         //标志寄存器
//-----------------------------主状态机程序----------------------------------
always @ (posedge CLOCK)
begin
    if(RESET == 1'b1)
    begin
        I_REG_ADDR      <= 8'h00;
        I_REG_ADDRH     <= 8'h00;
        I_CTRL_BYTE     <= 8'h00;
        I_SDA_DATA      <= 8'h00;
        I_SDA_OUT_OE    <= 1'b0;
        I_ACK_OE        <= 1'b0;
        I_RD_OE         <= 1'b0;
        I_SDA_ACK_OUT   <= 1'b0;
        ST_FSM_STATE    <= S_IDLE;
        FF              <= 1'b0;
        RFF             <= 1'b1;
        sh8out_state    <= sh8out_bit7;
        sh8in_state     <= sh8in_begin;
        ackout_state    <= ack_begin;
        I_WR_OP         <= 1'b0;
        I_RD_OP         <= 1'b0;
        I_SREG_SDA_OUT  <= 8'b0;
        debug           <= 1'b1;
//        I_RD_NACK       <= 1'b0;
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b1;
        READREGHH_S<= 1'b1;
        READREGHHH_S<= 1'b1;
        READREG_S<= 1'b1;
        READ_S<= 1'b1;
        READH_S<= 1'b1;
        READHH_S<= 1'b1;
        READHHH_S<= 1'b1;
        WRITE_S<= 1'b1;
        STOP_S<= 1'b1;
    end
    else
    case(ST_FSM_STATE)
    S_IDLE:
    begin
        IDLE_S<= 1'b0;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b1;
        READREG_S<= 1'b1;
        READ_S<= 1'b1;
        WRITE_S<= 1'b1;
        STOP_S<= 1'b1;

        if(I_START_EDGE)
        begin
            ST_FSM_STATE    <= S_READCTRL;
            I_CTRL_BYTE     <= 8'h00;
            sh8in_state     <= sh8in_begin;
            FF              <= 1'b0;
            I_RD_ACK       <= 1'b0;
        end
        else
        begin
            ST_FSM_STATE    <= S_IDLE;
        end
    end
    S_READCTRL:
    begin
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b0;
        READREGH_S<= 1'b1;
        READREG_S<= 1'b1;
        READ_S<= 1'b1;
        WRITE_S<= 1'b1;
        STOP_S<= 1'b1;

        //debug <= 1'b0;

        if(FF == 1'b0) 
        begin
            //shift8in(I_CTRL_BYTE, 1'b1);

            case(sh8in_state)

            sh8in_begin:
            begin
                sh8in_state <= sh8in_bit7;
            end
            
            sh8in_bit7:
            begin
                if(I_SCL_RISE)   
                begin 
                    I_CTRL_BYTE[7] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit6;
                end
                else
                begin
                    sh8in_state <= sh8in_bit7;
                end
            end
            
            sh8in_bit6:
            begin
                if(I_SCL_RISE) 
                begin
                    I_CTRL_BYTE[6] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit5;
                end
                else
                begin
                    sh8in_state <= sh8in_bit6;
                end
            end

            sh8in_bit5:
            begin
                if(I_SCL_RISE) 
                begin
                    I_CTRL_BYTE[5] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit4;
                end
                else
                begin
                    sh8in_state <= sh8in_bit5;
                end
            end
                         
            sh8in_bit4:
            begin
                if(I_SCL_RISE) 
                begin
                    I_CTRL_BYTE[4] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit3;
                end
                else
                begin
                    sh8in_state <= sh8in_bit4;
                end
            end
                    
            sh8in_bit3:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_CTRL_BYTE[3] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit2;
                end
                else
                begin
                    sh8in_state <= sh8in_bit3; 
                end    
            end

            sh8in_bit2:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_CTRL_BYTE[2] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit1;
                end
                else
                begin
                    sh8in_state <= sh8in_bit2;  
                end
            end

            sh8in_bit1:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_CTRL_BYTE[1] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit0;
                end
                else
                begin
                    sh8in_state <= sh8in_bit1;  
                end
            end
          
            sh8in_bit0:
            begin
                //if ((ctrl) && ({I_CTRL_BYTE[7:1], 1'b0} !=HardWriteAddress))
                if ({I_CTRL_BYTE[7:1], 1'b0} !=HardWriteAddress)
                begin
                    sh8in_state  <= sh8in_begin;
                    FF              <= 1'b0;
                    ST_FSM_STATE    <= S_IDLE;
                    //debug <= 1'b0;
                    //debug <= I_START_EDGE_CNT[0];
                    //debug <= I_START_EDGE_CNT[0];
                end

                if(I_SCL_RISE) 
                begin
                    I_CTRL_BYTE[0] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_ack;
                    ackout_state   <= ack_begin;
                end
                else
                begin
                    sh8in_state <= sh8in_bit0;
                end
            end

            sh8in_ack:
            begin
                ack_out;
                if(ackout_state == ack_end)
                begin
                    sh8in_state <= sh8in_end;
                    ackout_state <= ack_begin;
                end
            end

            sh8in_end:
            begin
                //if(I_SCL_RISE)
                begin 
                    //link_read   <= YES;
                    FF          <=  1;                    
                    sh8in_state <= sh8in_bit7; 
                end 
                //else
                //begin
                    //sh8in_state  <= sh8in_end;
                //end
            end

            default:
            begin
                //link_read    <= NO;
                //sh8in_state  <= sh8in_bit7;
                sh8in_state  <= sh8in_begin;
            end
            
            endcase

        end
        else if(I_CTRL_BYTE==HardWriteAddress)
        begin
            debug <= 1'b0;
            if(I_START_EDGE_CNT==0)
            begin
                ST_FSM_STATE    <= S_IDLE;
            end
            else
            begin
                if(I2C_SLAVE_REG_MODE==2)
                begin
                   ST_FSM_STATE    <= S_READREGHHH;
                   I_REG_ADDRH     <= 8'h00;
                   I_REG_ADDR      <= 8'h00;
                end
                else if (I2C_SLAVE_REG_MODE==1)
                begin
                   ST_FSM_STATE    <= S_READREGH;
                   I_REG_ADDRH     <= 8'h00;
                   I_REG_ADDR      <= 8'h00;
                end
                else
                begin
                   ST_FSM_STATE    <= S_READREG;
                   I_REG_ADDRH     <= 8'h00;
                   I_REG_ADDR      <= 8'h00;
                end
                sh8in_state     <= sh8in_begin;
                FF              <= 0;
            end
        end
        else if(I_CTRL_BYTE==HardReadAddress)
        begin
            //debug <= 1'b0;
            if(I_START_EDGE_CNT==0)
            begin
                ST_FSM_STATE    <= S_IDLE;
            end
            else
            begin
                I_WR_OP         <= 0;
                I_RD_OP         <= 1;
                if(I_RD_OP)
                begin
                    I_RD_OP         <= 0;
                    RFF             <= 0;
                    
                    if(I2C_SLAVE_DAT_MODE==2)
                    begin
                        ST_FSM_STATE    <= S_READHHH;
                    end
                    else if (I2C_SLAVE_DAT_MODE==1)
                    begin
                        ST_FSM_STATE    <= S_READH;
                    end
                    else
                    begin
                        ST_FSM_STATE    <= S_READ;
                    end
                    
                    I_SREG_SDA_OUT  <= 8'b0;
                    sh8out_state    <= sh8out_bit7;
                    FF              <= 0;
                end
            end
        end
        else
        begin
            ST_FSM_STATE    <= S_IDLE;
        end
    end
    
    S_READREGHHH:
    begin
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b1;
        READREGHH_S<= 1'b1;
        READREGHHH_S<= 1'b0;
        READREG_S<= 1'b1;
        READ_S<= 1'b1;
        WRITE_S<= 1'b1;
        STOP_S<= 1'b1;

        if(FF == 0) 
        begin
            //shift8in(I_REG_ADDR, 1'b0);

            case(sh8in_state)
            
            sh8in_begin:
            begin
                sh8in_state <= sh8in_bit7;
            end
            
            sh8in_bit7:
            begin
                if(I_SCL_RISE)   
                begin 
                    I_REG_ADDRHHH[7] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit6;
                end
                else
                begin
                    sh8in_state <= sh8in_bit7;
                end
            end
            
            sh8in_bit6:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDRHHH[6] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit5;
                end
                else
                begin
                    sh8in_state <= sh8in_bit6;
                end
            end

            sh8in_bit5:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDRHHH[5] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit4;
                end
                else
                begin
                    sh8in_state <= sh8in_bit5;
                end
            end
                         
            sh8in_bit4:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDRHHH[4] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit3;
                end
                else
                begin
                    sh8in_state <= sh8in_bit4;
                end
            end
                    
            sh8in_bit3:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_REG_ADDRHHH[3] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit2;
                end
                else
                begin
                    sh8in_state <= sh8in_bit3; 
                end    
            end

            sh8in_bit2:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_REG_ADDRHHH[2] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit1;
                end
                else
                begin
                    sh8in_state <= sh8in_bit2;  
                end
            end

            sh8in_bit1:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_REG_ADDRHHH[1] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit0;
                end
                else
                begin
                    sh8in_state <= sh8in_bit1;  
                end
            end
          
            sh8in_bit0:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDRHHH[0] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_ack;
                    ackout_state   <= ack_begin;
                end
                else
                begin
                    sh8in_state <= sh8in_bit0;
                end
            end

            sh8in_ack:
            begin
                ack_out;
                if(ackout_state == ack_end)
                begin
                    sh8in_state <= sh8in_end;
                    ackout_state <= ack_begin;
                end
            end

            sh8in_end:
            begin
                //if(I_SCL_RISE)
                begin 
                    //link_read   <= YES;
                    FF          <=  1;                    
                    sh8in_state <= sh8in_bit7; 
                end 
                //else
                //begin
                    //sh8in_state  <= sh8in_end;
                //end
            end

            default:
            begin
                //link_read    <= NO;
                //sh8in_state  <= sh8in_bit7;
                sh8in_state  <= sh8in_begin;
            end
            
            endcase

        end
        else
        begin
            // TODO: 限制范围
            ST_FSM_STATE    <= S_READREGHH;
            I_SDA_DATA      <= 8'h00;
            sh8in_state     <= sh8in_begin;
            FF              <= 0;
        end
    end
    
    S_READREGHH:
    begin
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b1;
        READREGHH_S<= 1'b0;
        READREGHHH_S<= 1'b1;
        READREG_S<= 1'b1;
        READ_S<= 1'b1;
        WRITE_S<= 1'b1;
        STOP_S<= 1'b1;

        if(FF == 0) 
        begin
            //shift8in(I_REG_ADDR, 1'b0);

            case(sh8in_state)
            
            sh8in_begin:
            begin
                sh8in_state <= sh8in_bit7;
            end
            
            sh8in_bit7:
            begin
                if(I_SCL_RISE)   
                begin 
                    I_REG_ADDRHH[7] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit6;
                end
                else
                begin
                    sh8in_state <= sh8in_bit7;
                end
            end
            
            sh8in_bit6:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDRHH[6] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit5;
                end
                else
                begin
                    sh8in_state <= sh8in_bit6;
                end
            end

            sh8in_bit5:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDRHH[5] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit4;
                end
                else
                begin
                    sh8in_state <= sh8in_bit5;
                end
            end
                         
            sh8in_bit4:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDRHH[4] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit3;
                end
                else
                begin
                    sh8in_state <= sh8in_bit4;
                end
            end
                    
            sh8in_bit3:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_REG_ADDRHH[3] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit2;
                end
                else
                begin
                    sh8in_state <= sh8in_bit3; 
                end    
            end

            sh8in_bit2:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_REG_ADDRHH[2] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit1;
                end
                else
                begin
                    sh8in_state <= sh8in_bit2;  
                end
            end

            sh8in_bit1:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_REG_ADDRHH[1] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit0;
                end
                else
                begin
                    sh8in_state <= sh8in_bit1;  
                end
            end
          
            sh8in_bit0:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDRHH[0] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_ack;
                    ackout_state   <= ack_begin;
                end
                else
                begin
                    sh8in_state <= sh8in_bit0;
                end
            end

            sh8in_ack:
            begin
                ack_out;
                if(ackout_state == ack_end)
                begin
                    sh8in_state <= sh8in_end;
                    ackout_state <= ack_begin;
                end
            end

            sh8in_end:
            begin
                //if(I_SCL_RISE)
                begin 
                    //link_read   <= YES;
                    FF          <=  1;                    
                    sh8in_state <= sh8in_bit7; 
                end 
                //else
                //begin
                    //sh8in_state  <= sh8in_end;
                //end
            end

            default:
            begin
                //link_read    <= NO;
                //sh8in_state  <= sh8in_bit7;
                sh8in_state  <= sh8in_begin;
            end
            
            endcase

        end
        else
        begin
            // TODO: 限制范围
            ST_FSM_STATE    <= S_READREGH;
            I_SDA_DATA      <= 8'h00;
            sh8in_state     <= sh8in_begin;
            FF              <= 0;
        end
    end

    S_READREGH:
    begin
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b0;
        READREG_S<= 1'b1;
        READ_S<= 1'b1;
        WRITE_S<= 1'b1;
        STOP_S<= 1'b1;

        if(FF == 0) 
        begin
            //shift8in(I_REG_ADDR, 1'b0);

            case(sh8in_state)
            
            sh8in_begin:
            begin
                sh8in_state <= sh8in_bit7;
            end
            
            sh8in_bit7:
            begin
                if(I_SCL_RISE)   
                begin 
                    I_REG_ADDRH[7] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit6;
                end
                else
                begin
                    sh8in_state <= sh8in_bit7;
                end
            end
            
            sh8in_bit6:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDRH[6] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit5;
                end
                else
                begin
                    sh8in_state <= sh8in_bit6;
                end
            end

            sh8in_bit5:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDRH[5] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit4;
                end
                else
                begin
                    sh8in_state <= sh8in_bit5;
                end
            end
                         
            sh8in_bit4:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDRH[4] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit3;
                end
                else
                begin
                    sh8in_state <= sh8in_bit4;
                end
            end
                    
            sh8in_bit3:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_REG_ADDRH[3] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit2;
                end
                else
                begin
                    sh8in_state <= sh8in_bit3; 
                end    
            end

            sh8in_bit2:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_REG_ADDRH[2] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit1;
                end
                else
                begin
                    sh8in_state <= sh8in_bit2;  
                end
            end

            sh8in_bit1:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_REG_ADDRH[1] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit0;
                end
                else
                begin
                    sh8in_state <= sh8in_bit1;  
                end
            end
          
            sh8in_bit0:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDRH[0] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_ack;
                    ackout_state   <= ack_begin;
                end
                else
                begin
                    sh8in_state <= sh8in_bit0;
                end
            end

            sh8in_ack:
            begin
                ack_out;
                if(ackout_state == ack_end)
                begin
                    sh8in_state <= sh8in_end;
                    ackout_state <= ack_begin;
                end
            end

            sh8in_end:
            begin
                //if(I_SCL_RISE)
                begin 
                    //link_read   <= YES;
                    FF          <=  1;                    
                    sh8in_state <= sh8in_bit7; 
                end 
                //else
                //begin
                    //sh8in_state  <= sh8in_end;
                //end
            end

            default:
            begin
                //link_read    <= NO;
                //sh8in_state  <= sh8in_bit7;
                sh8in_state  <= sh8in_begin;
            end
            
            endcase

        end
        else
        begin
            // TODO: 限制范围
            ST_FSM_STATE    <= S_READREG;
            I_SDA_DATA      <= 8'h00;
            sh8in_state     <= sh8in_begin;
            FF              <= 0;
        end
    end

    S_READREG:
    begin
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b1;
        READREG_S<= 1'b0;
        READ_S<= 1'b1;
        WRITE_S<= 1'b1;
        STOP_S<= 1'b1;

        if(FF == 0) 
        begin
            //shift8in(I_REG_ADDR, 1'b0);

            case(sh8in_state)
            
            sh8in_begin:
            begin
                sh8in_state <= sh8in_bit7;
            end
            
            sh8in_bit7:
            begin
                if(I_SCL_RISE)   
                begin 
                    I_REG_ADDR[7] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit6;
                end
                else
                begin
                    sh8in_state <= sh8in_bit7;
                end
            end
            
            sh8in_bit6:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDR[6] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit5;
                end
                else
                begin
                    sh8in_state <= sh8in_bit6;
                end
            end

            sh8in_bit5:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDR[5] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit4;
                end
                else
                begin
                    sh8in_state <= sh8in_bit5;
                end
            end
                         
            sh8in_bit4:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDR[4] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit3;
                end
                else
                begin
                    sh8in_state <= sh8in_bit4;
                end
            end
                    
            sh8in_bit3:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_REG_ADDR[3] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit2;
                end
                else
                begin
                    sh8in_state <= sh8in_bit3; 
                end    
            end

            sh8in_bit2:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_REG_ADDR[2] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit1;
                end
                else
                begin
                    sh8in_state <= sh8in_bit2;  
                end
            end

            sh8in_bit1:
            begin
                if(I_SCL_RISE) 
                begin 
                    I_REG_ADDR[1] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_bit0;
                end
                else
                begin
                    sh8in_state <= sh8in_bit1;  
                end
            end
          
            sh8in_bit0:
            begin
                if(I_SCL_RISE) 
                begin
                    I_REG_ADDR[0] <= I_SDA_DEB;
                    sh8in_state     <= sh8in_ack;
                    ackout_state   <= ack_begin;
                end
                else
                begin
                    sh8in_state <= sh8in_bit0;
                end
            end

            sh8in_ack:
            begin
                ack_out;
                if(ackout_state == ack_end)
                begin
                    sh8in_state <= sh8in_end;
                    ackout_state <= ack_begin;
                end
            end

            sh8in_end:
            begin
                //if(I_SCL_RISE)
                begin 
                    //link_read   <= YES;
                    FF          <=  1;                    
                    sh8in_state <= sh8in_bit7; 
                end 
                //else
                //begin
                    //sh8in_state  <= sh8in_end;
                //end
            end

            default:
            begin
                //link_read    <= NO;
                //sh8in_state  <= sh8in_bit7;
                sh8in_state  <= sh8in_begin;
            end
            
            endcase

        end
        else
        begin
            // TODO: 限制范围
            if(I2C_SLAVE_DAT_MODE==2)
            begin
                ST_FSM_STATE    <= S_WRITEHHH;
            end
            else if (I2C_SLAVE_DAT_MODE==1)
            begin
                ST_FSM_STATE    <= S_WRITEH;
            end
            else
            begin
                ST_FSM_STATE    <= S_WRITE;
            end
            I_SDA_DATA      <= 8'h00;
            sh8in_state     <= sh8in_begin;
            FF              <= 0;
        end
    end

    S_WRITEHHH:
    begin
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b1;
        READREG_S<= 1'b1;
        READ_S<= 1'b1;
        WRITE_S<= 1'b1;
        WRITEHHH_S<= 1'b0;
        WRITEHH_S<= 1'b1;
        WRITEH_S<= 1'b1;
        STOP_S<= 1'b1;

        if(FF == 0) 
        begin
            if(I_START_EDGE_CNT==2)
            begin
                ST_FSM_STATE    <= S_READCTRL;
                sh8in_state     <= sh8in_begin;
            end
            else
            begin
                //shift8in(I_SDA_DATA, 1'b0);
                case(sh8in_state)
                
                sh8in_begin:
                begin
                    sh8in_state <= sh8in_bit7;
                end
                
                sh8in_bit7:
                begin
                    if(I_SCL_RISE)   
                    begin 
                        I_SDA_DATA[7] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit6;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit7;
                    end
                end
                
                sh8in_bit6:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[6] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit5;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit6;
                    end
                end

                sh8in_bit5:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[5] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit4;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit5;
                    end
                end
                             
                sh8in_bit4:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[4] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit3;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit4;
                    end
                end
                        
                sh8in_bit3:
                begin
                    if(I_SCL_RISE) 
                    begin 
                        I_SDA_DATA[3] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit2;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit3; 
                    end    
                end

                sh8in_bit2:
                begin
                    if(I_SCL_RISE) 
                    begin 
                        I_SDA_DATA[2] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit1;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit2;  
                    end
                end

                sh8in_bit1:
                begin
                    if(I_SCL_RISE) 
                    begin 
                        I_SDA_DATA[1] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit0;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit1;  
                    end
                end
              
                sh8in_bit0:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[0] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_ack;
                        ackout_state   <= ack_begin;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit0;
                    end
                end

                sh8in_ack:
                begin
                    ack_out;
                    if(ackout_state == ack_end)
                    begin
                        sh8in_state <= sh8in_end;
                        ackout_state <= ack_begin;
                    end
                end

                sh8in_end:
                begin
                    //if(I_SCL_RISE)
                    begin 
                        //link_read   <= YES;
                        FF          <=  1;                    
                        sh8in_state <= sh8in_bit7; 
                    end 
                    //else
                    //begin
                        //sh8in_state  <= sh8in_end;
                    //end
                end

                default:
                begin
                    //link_read    <= NO;
                    //sh8in_state  <= sh8in_bit7;
                    sh8in_state  <= sh8in_begin;
                end
                
                endcase

            end
        end
        else
        begin
            I_WR_OP         <= 1;
            I_RD_OP         <= 0;
            
            if(I_WR_OP)
            begin
                ST_FSM_STATE    <= S_WRITEHH;
                I_WR_OP         <= 0;
                FF              <= 0;
            end
        end
    end
    
    S_WRITEHH:
    begin
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b1;
        READREG_S<= 1'b1;
        READ_S<= 1'b1;
        WRITE_S<= 1'b1;
        WRITEHHH_S<= 1'b1;
        WRITEHH_S<= 1'b0;
        WRITEH_S<= 1'b1;
        STOP_S<= 1'b1;

        if(FF == 0) 
        begin
            if(I_START_EDGE_CNT==2)
            begin
                ST_FSM_STATE    <= S_READCTRL;
                sh8in_state     <= sh8in_begin;
            end
            else
            begin
                //shift8in(I_SDA_DATA, 1'b0);
                case(sh8in_state)
                
                sh8in_begin:
                begin
                    sh8in_state <= sh8in_bit7;
                end
                
                sh8in_bit7:
                begin
                    if(I_SCL_RISE)   
                    begin 
                        I_SDA_DATA[7] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit6;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit7;
                    end
                end
                
                sh8in_bit6:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[6] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit5;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit6;
                    end
                end

                sh8in_bit5:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[5] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit4;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit5;
                    end
                end
                             
                sh8in_bit4:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[4] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit3;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit4;
                    end
                end
                        
                sh8in_bit3:
                begin
                    if(I_SCL_RISE) 
                    begin 
                        I_SDA_DATA[3] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit2;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit3; 
                    end    
                end

                sh8in_bit2:
                begin
                    if(I_SCL_RISE) 
                    begin 
                        I_SDA_DATA[2] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit1;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit2;  
                    end
                end

                sh8in_bit1:
                begin
                    if(I_SCL_RISE) 
                    begin 
                        I_SDA_DATA[1] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit0;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit1;  
                    end
                end
              
                sh8in_bit0:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[0] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_ack;
                        ackout_state   <= ack_begin;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit0;
                    end
                end

                sh8in_ack:
                begin
                    ack_out;
                    if(ackout_state == ack_end)
                    begin
                        sh8in_state <= sh8in_end;
                        ackout_state <= ack_begin;
                    end
                end

                sh8in_end:
                begin
                    //if(I_SCL_RISE)
                    begin 
                        //link_read   <= YES;
                        FF          <=  1;                    
                        sh8in_state <= sh8in_bit7; 
                    end 
                    //else
                    //begin
                        //sh8in_state  <= sh8in_end;
                    //end
                end

                default:
                begin
                    //link_read    <= NO;
                    //sh8in_state  <= sh8in_bit7;
                    sh8in_state  <= sh8in_begin;
                end
                
                endcase

            end
        end
        else
        begin
            I_WR_OP         <= 1;
            I_RD_OP         <= 0;
            
            if(I_WR_OP)
            begin
                ST_FSM_STATE    <= S_WRITEH;
                I_WR_OP         <= 0;
                FF              <= 0;
            end
        end
    end

    S_WRITEH:
    begin
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b1;
        READREG_S<= 1'b1;
        READ_S<= 1'b1;
        WRITE_S<= 1'b1;
        WRITEHHH_S<= 1'b1;
        WRITEHH_S<= 1'b1;
        WRITEH_S<= 1'b0;
        STOP_S<= 1'b1;

        if(FF == 0) 
        begin
            if(I_START_EDGE_CNT==2)
            begin
                ST_FSM_STATE    <= S_READCTRL;
                sh8in_state     <= sh8in_begin;
            end
            else
            begin
                //shift8in(I_SDA_DATA, 1'b0);
                case(sh8in_state)
                
                sh8in_begin:
                begin
                    sh8in_state <= sh8in_bit7;
                end
                
                sh8in_bit7:
                begin
                    if(I_SCL_RISE)   
                    begin 
                        I_SDA_DATA[7] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit6;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit7;
                    end
                end
                
                sh8in_bit6:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[6] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit5;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit6;
                    end
                end

                sh8in_bit5:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[5] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit4;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit5;
                    end
                end
                             
                sh8in_bit4:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[4] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit3;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit4;
                    end
                end
                        
                sh8in_bit3:
                begin
                    if(I_SCL_RISE) 
                    begin 
                        I_SDA_DATA[3] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit2;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit3; 
                    end    
                end

                sh8in_bit2:
                begin
                    if(I_SCL_RISE) 
                    begin 
                        I_SDA_DATA[2] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit1;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit2;  
                    end
                end

                sh8in_bit1:
                begin
                    if(I_SCL_RISE) 
                    begin 
                        I_SDA_DATA[1] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit0;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit1;  
                    end
                end
              
                sh8in_bit0:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[0] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_ack;
                        ackout_state   <= ack_begin;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit0;
                    end
                end

                sh8in_ack:
                begin
                    ack_out;
                    if(ackout_state == ack_end)
                    begin
                        sh8in_state <= sh8in_end;
                        ackout_state <= ack_begin;
                    end
                end

                sh8in_end:
                begin
                    //if(I_SCL_RISE)
                    begin 
                        //link_read   <= YES;
                        FF          <=  1;                    
                        sh8in_state <= sh8in_bit7; 
                    end 
                    //else
                    //begin
                        //sh8in_state  <= sh8in_end;
                    //end
                end

                default:
                begin
                    //link_read    <= NO;
                    //sh8in_state  <= sh8in_bit7;
                    sh8in_state  <= sh8in_begin;
                end
                
                endcase

            end
        end
        else
        begin
            I_WR_OP         <= 1;
            I_RD_OP         <= 0;
            
            if(I_WR_OP)
            begin
                ST_FSM_STATE    <= S_WRITE;
                I_WR_OP         <= 0;
                FF              <= 0;
            end
        end
    end

    S_WRITE:
    begin
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b1;
        READREG_S<= 1'b1;
        READ_S<= 1'b1;
        WRITE_S<= 1'b0;
        STOP_S<= 1'b1;

        if(FF == 0) 
        begin
            if(I_START_EDGE_CNT==2)
            begin
                ST_FSM_STATE    <= S_READCTRL;
                sh8in_state     <= sh8in_begin;
            end
            else
            begin
                //shift8in(I_SDA_DATA, 1'b0);
                case(sh8in_state)
                
                sh8in_begin:
                begin
                    sh8in_state <= sh8in_bit7;
                end
                
                sh8in_bit7:
                begin
                    if(I_SCL_RISE)   
                    begin 
                        I_SDA_DATA[7] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit6;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit7;
                    end
                end
                
                sh8in_bit6:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[6] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit5;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit6;
                    end
                end

                sh8in_bit5:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[5] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit4;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit5;
                    end
                end
                             
                sh8in_bit4:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[4] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit3;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit4;
                    end
                end
                        
                sh8in_bit3:
                begin
                    if(I_SCL_RISE) 
                    begin 
                        I_SDA_DATA[3] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit2;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit3; 
                    end    
                end

                sh8in_bit2:
                begin
                    if(I_SCL_RISE) 
                    begin 
                        I_SDA_DATA[2] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit1;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit2;  
                    end
                end

                sh8in_bit1:
                begin
                    if(I_SCL_RISE) 
                    begin 
                        I_SDA_DATA[1] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_bit0;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit1;  
                    end
                end
              
                sh8in_bit0:
                begin
                    if(I_SCL_RISE) 
                    begin
                        I_SDA_DATA[0] <= I_SDA_DEB;
                        sh8in_state     <= sh8in_ack;
                        ackout_state   <= ack_begin;
                    end
                    else
                    begin
                        sh8in_state <= sh8in_bit0;
                    end
                end

                sh8in_ack:
                begin
                    ack_out;
                    if(ackout_state == ack_end)
                    begin
                        sh8in_state <= sh8in_end;
                        ackout_state <= ack_begin;
                    end
                end

                sh8in_end:
                begin
                    //if(I_SCL_RISE)
                    begin 
                        //link_read   <= YES;
                        FF          <=  1;                    
                        sh8in_state <= sh8in_bit7; 
                    end 
                    //else
                    //begin
                        //sh8in_state  <= sh8in_end;
                    //end
                end

                default:
                begin
                    //link_read    <= NO;
                    //sh8in_state  <= sh8in_bit7;
                    sh8in_state  <= sh8in_begin;
                end
                
                endcase

            end
        end
        else
        begin
            I_WR_OP         <= 1;
            I_RD_OP         <= 0;
            
            if(I_WR_OP)
            begin
                ST_FSM_STATE    <= S_WRITE;
                I_WR_OP         <= 0;
                FF              <= 0;
                {I_REG_ADDRH,I_REG_ADDR} <= {I_REG_ADDRH,I_REG_ADDR}+1'b1;
            end
        end
    end
    
    S_READHHH:
    begin
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b1;
        READREG_S<= 1'b1;
        READHHH_S<= 1'b0;
        READHH_S<= 1'b1;
        READH_S<= 1'b1;
        READ_S<= 1'b1;
        WRITE_S<= 1'b1;
        STOP_S<= 1'b1;

        if(FF == 0) 
        begin
            if(RFF == 0)
            begin
                I_SREG_SDA_OUT  <= I_RD_VAL[31:24];
                //debug <= I_RD_VAL[0];
                RFF <= 1;
            end
            else
            begin
//                if(I_RD_ACK)          
//                begin
//                    ST_FSM_STATE    <= S_STOP;
//                end
//                else
//                begin 
                    shift8_out;
//                end
            end
        end
        else
        begin      
            ST_FSM_STATE    <= S_READHH;
            RFF             <= 0;
            I_SREG_SDA_OUT  <= 8'b0;
            sh8out_state    <= sh8out_bit7;
            FF              <= 0;
        end
    end
    
    S_READHH:
    begin
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b1;
        READREG_S<= 1'b1;
        READHHH_S<= 1'b1;
        READHH_S<= 1'b0;
        READH_S<= 1'b1;
        READ_S<= 1'b1;
        WRITE_S<= 1'b1;
        STOP_S<= 1'b1;

        if(FF == 0) 
        begin
            if(RFF == 0)
            begin
                I_SREG_SDA_OUT  <= I_RD_VAL[23:16];
                //debug <= I_RD_VAL[0];
                RFF <= 1;
            end
            else
            begin           
                shift8_out;
            end
        end
        else
        begin      
            ST_FSM_STATE    <= S_READH;
            RFF             <= 0;
            I_SREG_SDA_OUT  <= 8'b0;
            sh8out_state    <= sh8out_bit7;
            FF              <= 0;
        end
    end

    S_READH:
    begin
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b1;
        READREG_S<= 1'b1;
        READHHH_S<= 1'b1;
        READHH_S<= 1'b1;
        READH_S<= 1'b0;
        READ_S<= 1'b1;
        WRITE_S<= 1'b1;
        STOP_S<= 1'b1;

        if(FF == 0) 
        begin
            if(RFF == 0)
            begin
                I_SREG_SDA_OUT  <= I_RD_VAL[15:8];
                //debug <= I_RD_VAL[0];
                RFF <= 1;
            end
            else
            begin           
                shift8_out;
            end
        end
        else
        begin      
            ST_FSM_STATE    <= S_READ;
            RFF             <= 0;
            I_SREG_SDA_OUT  <= 8'b0;
            sh8out_state    <= sh8out_bit7;
            FF              <= 0;
        end
    end

    S_READ:
    begin
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b1;
        READREG_S<= 1'b1;
        READ_S<= 1'b0;
        WRITE_S<= 1'b1;
        STOP_S<= 1'b1;

        if(FF == 0) 
        begin
            if(RFF == 0)
            begin
                I_SREG_SDA_OUT  <= I_RD_VAL[7:0];
                //debug <= I_RD_VAL[0];
                RFF <= 1;
            end
            else
            begin           
                shift8_out;
            end
        end
        else
        begin      
            ST_FSM_STATE    <= S_STOP;
            FF              <= 0;
        end
    end

    S_STOP:
    begin
        IDLE_S<= 1'b1;
        READCTRL_S<= 1'b1;
        READREGH_S<= 1'b1;
        READREG_S<= 1'b1;
        READ_S<= 1'b1;
        WRITE_S<= 1'b1;
        STOP_S<= 1'b0;

        I_REG_ADDRHHH   <= 8'h00;
        I_REG_ADDRHH    <= 8'h00;
        I_REG_ADDRH     <= 8'h00;
        I_REG_ADDR      <= 8'h00;
        I_CTRL_BYTE     <= 8'h00;
        I_SDA_DATA      <= 8'h00;

        if(I_START_EDGE_CNT==0)
        begin
            ST_FSM_STATE    <= S_IDLE;
        end
        else
        begin
            ST_FSM_STATE    <= S_STOP;
        end
    end

    default:
    begin
        ST_FSM_STATE    <= S_IDLE;
    end

    endcase

    if (I_STOP_EDGE)
    begin
        ST_FSM_STATE <= S_IDLE;
    end
end

//------------------------串行数据转换为并行数据任务----------------------------------
// LSE 是支持综合带输入输出参数的task
// synplify, altera 好像不行, 只能是无输入输出参数的task
task shift8in; 
output reg [7:0] shift /* synthesis syn_keep = 1 */;
input  ctrl;
begin 
    case(sh8in_state)
    
    sh8in_begin:
    begin
        sh8in_state <= sh8in_bit7;
    end
    
    sh8in_bit7:
    begin
        if(I_SCL_RISE)   
        begin 
            shift[7] <= I_SDA_DEB;
            sh8in_state     <= sh8in_bit6;
        end
        else
        begin
            sh8in_state <= sh8in_bit7;
        end
    end
    
    sh8in_bit6:
    begin
        if(I_SCL_RISE) 
        begin
            shift[6] <= I_SDA_DEB;
            sh8in_state     <= sh8in_bit5;
        end
        else
        begin
            sh8in_state <= sh8in_bit6;
        end
    end

    sh8in_bit5:
    begin
        if(I_SCL_RISE) 
        begin
            shift[5] <= I_SDA_DEB;
            sh8in_state     <= sh8in_bit4;
        end
        else
        begin
            sh8in_state <= sh8in_bit5;
        end
    end
                 
    sh8in_bit4:
    begin
        if(I_SCL_RISE) 
        begin
            shift[4] <= I_SDA_DEB;
            sh8in_state     <= sh8in_bit3;
        end
        else
        begin
            sh8in_state <= sh8in_bit4;
        end
    end
            
    sh8in_bit3:
    begin
        if(I_SCL_RISE) 
        begin 
            shift[3] <= I_SDA_DEB;
            sh8in_state     <= sh8in_bit2;
        end
        else
        begin
            sh8in_state <= sh8in_bit3; 
        end    
    end

    sh8in_bit2:
    begin
        if(I_SCL_RISE) 
        begin 
            shift[2] <= I_SDA_DEB;
            sh8in_state     <= sh8in_bit1;
        end
        else
        begin
            sh8in_state <= sh8in_bit2;  
        end
    end

    sh8in_bit1:
    begin
        if(I_SCL_RISE) 
        begin 
            shift[1] <= I_SDA_DEB;
            sh8in_state     <= sh8in_bit0;
        end
        else
        begin
            sh8in_state <= sh8in_bit1;  
        end
    end
  
    sh8in_bit0:
    begin
        //if ((ctrl) && ({I_CTRL_BYTE[7:1], 1'b0} !=HardWriteAddress))
        if ((ctrl) && ({shift[7:1], 1'b0} !=HardWriteAddress))
        begin
            sh8in_state  <= sh8in_begin;
            FF              <= 1'b0;
            ST_FSM_STATE    <= S_IDLE;
            //debug <= 1'b0;
            //debug <= I_START_EDGE_CNT[0];
            //debug <= I_START_EDGE_CNT[0];
        end

        if(I_SCL_RISE) 
        begin
            shift[0] <= I_SDA_DEB;
            sh8in_state     <= sh8in_ack;
            ackout_state   <= ack_begin;
        end
        else
        begin
            sh8in_state <= sh8in_bit0;
        end
    end

    sh8in_ack:
    begin
        ack_out;
        if(ackout_state == ack_end)
        begin
            sh8in_state <= sh8in_end;
            ackout_state <= ack_begin;
        end
    end

    sh8in_end:
    begin
        //if(I_SCL_RISE)
        begin 
            //link_read   <= YES;
            FF          <=  1;                    
            sh8in_state <= sh8in_bit7; 
        end 
        //else
        //begin
            //sh8in_state  <= sh8in_end;
        //end
    end

    default:
    begin
        //link_read    <= NO;
        //sh8in_state  <= sh8in_bit7;
        sh8in_state  <= sh8in_begin;
    end
    
    endcase  
end  
endtask
//------------------------------ ack任务 ---------------------------
task ack_out;
begin
    case(ackout_state)
    ack_begin:
    begin
        if (I_SCL_FALL)
        begin
            I_SDA_ACK_OUT<=1'b0;
            I_ACK_OE<=1'b1;
            I_SDA_OUT_OE<=1'b1;
            ackout_state <= ack_bit;
        end
    end
    ack_bit:
    begin
        if (I_SCL_FALL)
        begin
            ackout_state <= ack_end;
        end
        else
        begin
            ackout_state <= ack_bit;
        end
    end
    ack_end:
    begin
        I_SDA_ACK_OUT<=1'b0;
        I_ACK_OE<=1'b0; 
        I_SDA_OUT_OE<=1'b0;
    end
    default:
    begin
        ackout_state    <= ack_begin;
    end

    endcase
end
endtask
//------------------------------ 并行数据转换为串行数据任务 ---------------------------
task shift8_out;
begin
    //debug <= I_SREG_SDA_OUT[0];
    case(sh8out_state)
    
    sh8out_bit7:
    begin
        I_RD_OE         <= 1'b1;
        I_SDA_OUT_OE    <= 1'b1;
        //if(I_SCL_FALL)
        //begin
            sh8out_state    <= sh8out_bit6;
        //end   
        //else
        //begin
            //sh8out_state <= sh8out_bit7;            
        //end
    end

    sh8out_bit6:
    begin
        if(I_SCL_FALL) 
        begin 
            sh8out_state  <= sh8out_bit5; 
            I_SREG_SDA_OUT    <= I_SREG_SDA_OUT<<1;
        end
        else
        begin
            sh8out_state <= sh8out_bit6;
        end
    end
                    
    sh8out_bit5: 
    begin
        if(I_SCL_FALL) 
        begin 
            sh8out_state <= sh8out_bit4; 
            I_SREG_SDA_OUT   <= I_SREG_SDA_OUT<<1;
        end   
        else
        begin
            sh8out_state <= sh8out_bit5;
        end
    end
    
    sh8out_bit4: 
    begin
        if(I_SCL_FALL) 
        begin 
            sh8out_state <= sh8out_bit3;
            I_SREG_SDA_OUT   <= I_SREG_SDA_OUT<<1;
        end    
        else
        begin
            sh8out_state <= sh8out_bit4;
        end
    end
 
    sh8out_bit3:
    begin    
        if(I_SCL_FALL) 
        begin 
            sh8out_state <= sh8out_bit2; 
            I_SREG_SDA_OUT   <= I_SREG_SDA_OUT<<1; 
        end    
        else
        begin
            sh8out_state <= sh8out_bit3;
        end
    end

    sh8out_bit2:
    begin
        if(I_SCL_FALL) 
        begin 
            sh8out_state <= sh8out_bit1; 
            I_SREG_SDA_OUT   <= I_SREG_SDA_OUT<<1;


        end    
        else
        begin
            sh8out_state <= sh8out_bit2;
        end
    end

    sh8out_bit1: 
    begin
        if(I_SCL_FALL)
        begin 
            sh8out_state <= sh8out_bit0; 
            I_SREG_SDA_OUT   <= I_SREG_SDA_OUT<<1; 
        end    
        else
        begin
            sh8out_state <= sh8out_bit1;
        end
    end

    sh8out_bit0: 
    begin
        if(I_SCL_FALL)
        begin 
            sh8out_state <= sh8out_ack; 
            I_SREG_SDA_OUT   <= I_SREG_SDA_OUT<<1; 
        end    
        else
        begin
            sh8out_state <= sh8out_bit0;
        end
    end

    sh8out_ack: 
    begin
        if(I_SCL_FALL) 
        begin
            sh8out_state <= sh8out_end; 
            I_RD_OE         <= 1'b0;
            I_SDA_OUT_OE    <= 1'b0;          
        end 
//        else if (I_SCL_RISE) 
//        begin
//            if(I_SDA_DEB)
//            begin
//                I_RD_NACK <= 1'b1;
//            end
//            else
//            begin
//                I_RD_NACK <= 1'b0;
//            end
//        end   
        else     
        begin
            sh8out_state <= sh8out_ack;
        end
    end

    sh8out_end: 
    begin
        if(I_SCL_FALL) 
        begin
            I_RD_OE         <= 1'b0;
            I_SDA_OUT_OE    <= 1'b0;
            FF              <= 1;
            I_RD_ACK <= 1'b0;
        end
        else if (I_SCL_RISE) 
        begin
            if(I_SDA_DEB)
            begin
                I_RD_ACK <= 1'b0;
            end
            else
            begin
                I_RD_ACK <= 1'b1;
                sh8out_state <= sh8out_repeat;
                I_RD_OP <= 1'b1;
                {I_REG_ADDRH,I_REG_ADDR} <= {I_REG_ADDRH,I_REG_ADDR} + 1'b1;
                I_RD_OE         <= 1'b1;
                //I_SDA_OUT_OE    <= 1'b0;
            end
        end  
        else     
        begin
            sh8out_state <= sh8out_end;
        end
    end

    sh8out_repeat: 
    begin
        I_RD_OP <= 1'b0;
        if(I_RD_ACK)
        begin
            I_RD_ACK <= 1'b0;
            //I_SREG_SDA_OUT  <= I_RD_VAL[7:0];
        end
        if(I_SCL_FALL) 
        begin
            I_SDA_OUT_OE <= 1'b1;
            I_SREG_SDA_OUT  <= I_RD_VAL[7:0];
            sh8out_state <= sh8out_bit6;
        end
    end

    default:
    begin
        sh8out_state <= sh8out_bit7;
    end

    endcase
    //debug <= I_SREG_SDA_OUT[0];     
end 
endtask

// synplify 支持直接给单个reg上电初值

//reg     [31:0]   ROReg0;   
//reg     [31:0]   ROReg1;  
//reg     [31:0]   ROReg2;  
//reg     [31:0]   ROReg3;  
//reg     [31:0]   ROReg4;   
//reg     [31:0]   ROReg5;  
//reg     [31:0]   ROReg6;  
//reg     [31:0]   ROReg7;  
//reg     [31:0]   ROReg8;  
//reg     [31:0]   ROReg9;  
//reg     [31:0]   ROReg10;  
//reg     [31:0]   ROReg11;  

reg     [7:0]   ROReg0;   
reg     [7:0]   ROReg1;  
reg     [7:0]   ROReg2;  
reg     [7:0]   ROReg3;  
//reg     [15:0]  RAM [0:3] /* synthesis syn_preserve = 1 */;
//reg     [15:0]  RAM [0:3] /* synthesis syn_ramstyle = "no_rw_check" */;
reg     [7:0]  RAM [0:35] /* synthesis syn_ramstyle = "no_rw_check" */;
//reg     [7:0]  RAM [0:255] /* synthesis syn_ramstyle = "no_rw_check" */;

//reg [D_WIDTH-1:0] RAM [0:2**A_WIDTH-1];

/*
initial
begin
    $readmemh ("mem.mem", RAM, 0, 7); // Initialize RAM with contents
    //mem.ini在synplify工程目录为相对目录起点, 而不是相对于源文件
end
文本文件mem.init的内容
8095
031d
0000
0000
*/

/*
//altera支持initial指定初始值, synplify 不行
initial
begin
    RAM[0]      = 16'h8095; // 这里是初始值
    RAM[1]      = 16'h031d; // 这里是初始值
    RAM[2]      = 16'h0000; // 这里是初始值
    RAM[3]      = 16'h0000; // 这里是初始值
    ROReg0      = 8'h10; // RO, default 0x10
    ROReg1      = 8'h20; // RO, default 0x20
    ROReg2      = 8'h30; // RO, default 0x30
    ROReg3      = 8'h40; // RO, default 0x40
end
*/

always @(posedge CLOCK)
begin
    if (RESET == 1'b1) 
    begin

        RAM[0]      <=   8'hB0; // 这里是初始值
        RAM[1]      <=   8'hB1; // 这里是初始值
        RAM[2]      <=   8'hB2; // 这里是初始值
        RAM[3]      <=   8'hB3; // 这里是初始值
        RAM[4]      <=   8'hB4; // 这里是初始值
        RAM[5]      <=   8'hB5; // 这里是初始值
        RAM[6]      <=   8'hB6; // 这里是初始值
        RAM[7]      <=   8'hB7; // 这里是初始值
        ROReg0      <=   8'hA0;
        ROReg1      <=   8'hA1;
        ROReg2      <=   8'hA2;
        ROReg3      <=   8'hA3;
		
		
		RAM[8]      <=   8'h58;
		RAM[9]      <=   8'h03;
		RAM[10]     <=   8'h43;
		RAM[11]     <=   8'h01;
		RAM[12]     <=   8'h03;
		RAM[13]     <=   8'h5E;
        RAM[14]     <=   8'h06;
        RAM[15]     <=   8'hD8;
        RAM[16]     <=   8'h03;
        RAM[17]     <=   8'h78;
		RAM[18]     <=   8'h03;
		RAM[19]     <=   8'h48;
		RAM[20]     <=   8'h21;
        RAM[21]     <=   8'h03;
        RAM[22]     <=   8'h0C;
        RAM[23]     <=   8'h01;
        RAM[24]     <=   8'h00;
        RAM[25]     <=   8'h19;
        RAM[26]     <=   8'hF4;
        RAM[27]     <=   8'h11;
        RAM[28]     <=   8'h87;
        RAM[29]     <=   8'h00;
        RAM[30]     <=   8'h28;
        RAM[31]     <=   8'h23;
        RAM[32]     <=   8'h19;
        RAM[33]     <=   8'h0F;
        RAM[34]     <=   8'h83;
        RAM[35]     <=   8'h07;
	
        //debug <= 1'b1;


        //ROReg0      <=   32'h00_00_00_00;
        //ROReg1      <=   32'h01_00_00_01;
        //ROReg2      <=   32'h10_C9_B0_03;
        //ROReg3      <=   32'h01_00_00_10;
        //ROReg4      <=   32'h00_00_00_00;
        //ROReg5      <=   32'h1B_00_00_00;
        //ROReg6      <=   32'h00_00_00_00;
        //ROReg7      <=   32'h00_46_D2_E8;
        //ROReg8      <=   32'h00_00_00_00;
        //ROReg9      <=   32'hAA_00_00_00;
        //ROReg10     <=   32'h00_00_00_00;
        //ROReg11     <=   32'h0C_00_00_00;

    end
    else
    begin
        //debug <= ROReg0[0];
        if (I_RD_OP == 1'b1) // --- I2C Read
        begin
            //if(!I_REG_ADDR[3])
            //begin
               //debug <= 1'b0; 
            //end

            //debug <= 1'b0;
            //debug <= I_REG_ADDR[3];
            //debug <= ROReg0[0];

            case ({I_REG_ADDRH,I_REG_ADDR})
            16'h0000: I_RD_VAL <= ROReg0;  
            16'h0001: I_RD_VAL <= ROReg1;  
            16'h0002: I_RD_VAL <= ROReg2;  
            16'h0003: I_RD_VAL <= ROReg3;  
            16'h0004: I_RD_VAL <= RAM[0][7:0];  
            16'h0005: I_RD_VAL <= RAM[1][7:0];  
            16'h0006: I_RD_VAL <= RAM[2][7:0];  
            16'h0007: I_RD_VAL <= RAM[3][7:0];  
            16'h0008: I_RD_VAL <= RAM[4][7:0];  
            16'h0009: I_RD_VAL <= RAM[5][7:0];  
            16'h000a: I_RD_VAL <= RAM[6][7:0]; 
            16'h000b: I_RD_VAL <= RAM[7][7:0];  
			
			16'h300A: I_RD_VAL <= RAM[8][7:0];
			16'h300B: I_RD_VAL <= RAM[9][7:0];
			16'h300C: I_RD_VAL <= RAM[10][7:0];
			16'h302A: I_RD_VAL <= RAM[11][7:0];
			16'h380E: I_RD_VAL <= RAM[12][7:0];
			16'h380F: I_RD_VAL <= RAM[13][7:0];
			16'h380C: I_RD_VAL <= RAM[14][7:0];
			16'h380D: I_RD_VAL <= RAM[15][7:0];			
			16'h388C: I_RD_VAL <= RAM[16][7:0];
			16'h388D: I_RD_VAL <= RAM[17][7:0];		
			16'h384C: I_RD_VAL <= RAM[18][7:0];
			16'h384D: I_RD_VAL <= RAM[19][7:0];
			16'h7000: I_RD_VAL <= RAM[20][7:0];
			16'h7001: I_RD_VAL <= RAM[21][7:0];
			16'h7002: I_RD_VAL <= RAM[22][7:0];
			16'h7003: I_RD_VAL <= RAM[23][7:0];
			16'h7004: I_RD_VAL <= RAM[24][7:0];
			16'h7005: I_RD_VAL <= RAM[25][7:0];
			16'h7006: I_RD_VAL <= RAM[26][7:0];
			16'h7007: I_RD_VAL <= RAM[27][7:0];
			16'h7008: I_RD_VAL <= RAM[28][7:0];
			16'h7009: I_RD_VAL <= RAM[29][7:0];
			16'h700A: I_RD_VAL <= RAM[30][7:0];
			16'h700B: I_RD_VAL <= RAM[31][7:0];
			16'h700C: I_RD_VAL <= RAM[32][7:0];
			16'h700D: I_RD_VAL <= RAM[33][7:0];
			16'h700E: I_RD_VAL <= RAM[34][7:0];
			16'h700F: I_RD_VAL <= RAM[35][7:0];
			
			
			
			
            default: I_RD_VAL <= 8'hFF; // i2c读非法内部地址, 返回0xff
            endcase

//            case ({I_REG_ADDRHHH,I_REG_ADDRHH,I_REG_ADDRH,I_REG_ADDR})
//            32'h1C_80_09_00: I_RD_VAL <= ROReg0;  
//            32'h98_04_05_00: I_RD_VAL <= ROReg1;  
//            32'h08_83_0A_00: I_RD_VAL <= ROReg2;  
//            32'h04_C2_02_00: I_RD_VAL <= ROReg3;  
//            32'h18_80_09_00: I_RD_VAL <= ROReg4;  
//            32'h04_00_30_00: I_RD_VAL <= ROReg5;  
//            32'h20_00_30_00: I_RD_VAL <= ROReg6;  
//            32'h0C_83_0A_00: I_RD_VAL <= ROReg7;  
//            32'h2C_00_30_00: I_RD_VAL <= ROReg8;  
//            32'h00_00_30_00: I_RD_VAL <= ROReg9; 
//            32'h1C_80_09_00: I_RD_VAL <= ROReg10; 
//            32'h0C_00_30_00: I_RD_VAL <= ROReg11; 
//            32'h0004: I_RD_VAL <= RAM[0][7:0];  
//            32'h0005: I_RD_VAL <= RAM[1][7:0];  
//            32'h0006: I_RD_VAL <= RAM[2][7:0];  
//            32'h0007: I_RD_VAL <= RAM[3][7:0];  
//            32'h0008: I_RD_VAL <= RAM[4][7:0];  
//            32'h0009: I_RD_VAL <= RAM[5][7:0];  
//            32'h000a: I_RD_VAL <= RAM[6][7:0]; 
//            32'h000b: I_RD_VAL <= RAM[7][7:0];  
//            default: I_RD_VAL <= 32'h00_00_00_00; // i2c读非法内部地址, 返回
//            endcase

            //debug <= I_RD_VAL[0];
        end

        else if (I_WR_OP == 1'b1) // --- I2C Write
        begin
            //debug <= 1'b0;
            case ({I_REG_ADDRH,I_REG_ADDR})
            16'h0004: RAM[0][7:0] <= I_SDA_DATA;  //  high byte
            16'h0005: RAM[1][7:0] <= I_SDA_DATA;   //  low byte
            16'h0006: RAM[2][7:0] <= I_SDA_DATA;
            16'h0007: RAM[3][7:0] <= I_SDA_DATA;
            16'h0008: RAM[4][7:0] <= I_SDA_DATA;
            16'h0009: RAM[5][7:0] <= I_SDA_DATA;
            16'h000a: RAM[6][7:0] <= I_SDA_DATA;
            16'h000b: RAM[7][7:0] <= I_SDA_DATA;
            /*
            if (I_REG_ADDR%2) // 如果是奇数地址
            begin
                RAM[I_REG_ADDR/2] <= {RAM[I_REG_ADDR/2][15:8], I_SDA_DATA}; // 低字节写入
            end
            else        // 如果是偶数数地址
            begin
                RAM[I_REG_ADDR/2] <= {I_SDA_DATA, RAM[I_REG_ADDR/2][7:0]}; // 高字节写入
            end
            */
            endcase
        end

//        else if (I_WR_OP == 1'b1) // --- I2C Write
//        begin
//            //debug <= 1'b0;
//            case ({I_REG_ADDRHHH,I_REG_ADDRHH,I_REG_ADDRH,I_REG_ADDR})
//            32'h0004: RAM[0][7:0] <= I_SDA_DATA;  //  high byte
//            32'h0005: RAM[1][7:0] <= I_SDA_DATA;   //  low byte
//            32'h0006: RAM[2][7:0] <= I_SDA_DATA;
//            32'h0007: RAM[3][7:0] <= I_SDA_DATA;
//            32'h0008: RAM[4][7:0] <= I_SDA_DATA;
//            32'h0009: RAM[5][7:0] <= I_SDA_DATA;
//            32'h000a: RAM[6][7:0] <= I_SDA_DATA;
//            32'h000b: RAM[7][7:0] <= I_SDA_DATA;
//            /*
//            if (I_REG_ADDR%2) // 如果是奇数地址
//            begin
//                RAM[I_REG_ADDR/2] <= {RAM[I_REG_ADDR/2][15:8], I_SDA_DATA}; // 低字节写入
//            end
//            else        // 如果是偶数数地址
//            begin
//                RAM[I_REG_ADDR/2] <= {I_SDA_DATA, RAM[I_REG_ADDR/2][7:0]}; // 高字节写入
//            end
//            */
//            endcase
//        end
    end
end

//always @(posedge CLOCK)
//begin
//    if (RESET == 1'b1) 
//    begin
//        DAT_OUT <= 8'h00;
//    end
//    else
//    begin
//        if (RD_EN)
//        begin
//            if (ADD_IN < 3'h4)
//            begin
//                DAT_OUT <= RAM[ADD_IN];
//            end
//            else
//            begin
//                DAT_OUT <= 8'h00;
//            end
//        end
//    end
//end

//assign MCLK_SPEED = RAM[1][0];
//assign IDLE_MODE = RAM[1][1];
//assign MCLK_MODE = RAM[1][7:6];
//assign ROWS_DELAY = RAM[1][15:11];

//assign SW0_0 = RAM[0][0];
//assign SW0_1 = RAM[0][1];
//assign SW0_2 = RAM[0][2];
//assign SW0_3 = RAM[0][3];
//assign SW0_4 = RAM[0][4];
//assign SW0_5 = RAM[0][5];
//assign SW0_6 = RAM[0][6];
//assign SW0_7 = RAM[0][7];

/*
// delay I_WR_OP for 1 tick
reg                 I_WR_OP_1;
always @(posedge CLOCK)
begin
    if (RESET == 1'b1) 
    begin
        I_WR_OP_1   <= 1'b0;
    end
    else
    begin
        I_WR_OP_1 <= I_WR_OP; 
    end
end
*/
//assign WR_EN        = I_WR_OP_1;
//assign ADD_OUT      = I_REG_ADDR_1;
//assign DAT_OUT      = I_WR_VAL;

endmodule
/*
always @(posedge CLOCK)
begin
    if (RESET == 1'b1) 
    begin
    end
    else
    begin
    end
end
*/
