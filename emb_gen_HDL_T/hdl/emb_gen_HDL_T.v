/**************************
note:
input size 1920*1286

(* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)
**************************/
`timescale 1ns/1ps
module emb_gen_HDL_T
#
(
/********************************/
//parameter WIDTH = 32'd16,
//parameter TUSER_WIDTH = 32'd96,
parameter FREQ_HZ = 32'd100000000, 
parameter EMB_TYPE      = 6'h2C    ,
parameter RAW12_TYPE    = 6'h2C    ,
parameter H_SIZE        = 16'd1920 ,
parameter V_SIZE        = 16'd1280 ,
parameter FRONT_LINE    = 2        ,
parameter TAIL_LINE     = 4
)
(
    input aclk,
    input aresetn,
    //
    input s_axis_tvalid,
    output s_axis_tready,
    input [15:0] s_axis_tdata,
    input s_axis_tlast,
    input s_axis_tuser,
    //
    output m_axis_tvalid,
    input  m_axis_tready,
    output reg [15:0] m_axis_tdata,
    output m_axis_tlast,
    output reg [95:0]m_axis_tuser

);


//
assign m_axis_tvalid    = s_axis_tvalid;
assign s_axis_tready    = m_axis_tready;
assign m_axis_tlast     = s_axis_tlast ;               


always@(posedge aclk)
begin
    if(!aresetn)
    begin
        s_axis_tuser_r  <= 1'd0;
    end
    begin
        s_axis_tuser_r  <= s_axis_tuser;
    end
end


reg    s_axis_tuser_r ;
reg [31:0] fps_cnt;
reg [31:0] tail_frame_cnt;
wire frame_end;
//pos_edge
assign frame_end = ~s_axis_tuser_r & s_axis_tuser;

always@(posedge aclk)
begin
    if(!aresetn)
    begin
        fps_cnt <= 32'd0;
        tail_frame_cnt <= 1'b1;
    end
    else
    begin
        if(frame_end)
            begin
               fps_cnt <= fps_cnt +1'b1; 
               tail_frame_cnt <= tail_frame_cnt + 1'b1;
            end
    end
end

reg [15:0] col_cnt;
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        col_cnt <= 16'b0;
    end
    else
    begin
        if((s_axis_tvalid ==1'b1) && (s_axis_tlast==1'b1) && (s_axis_tready ==1'b1)) 
        begin
            col_cnt <= 16'b0;
        end
        else if((s_axis_tvalid ==1'b1) && (s_axis_tready==1'b1))
        begin
            col_cnt <= col_cnt + 1'b1;
        end
    end
end

reg [15:0] line_cnt;
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        line_cnt <= 16'b0;
    end
    else
    begin
        if((s_axis_tvalid ==1'b1) && (s_axis_tlast==1'b1) && (s_axis_tready ==1'b1))
        begin
            line_cnt <= line_cnt+1;
        end
        else if((s_axis_tvalid ==1'b1) && (s_axis_tready==1'b1) && (s_axis_tuser ==1'b1))
        begin
            line_cnt <= 16'b0;    
        end
    end
end
////////////////
always@(*)
begin
    if(!aresetn)
    begin
        m_axis_tuser <= 96'd0;
    end
    else
    begin
        if(s_axis_tuser)
        begin
            m_axis_tuser <= {32'd0,H_SIZE[15:0],41'd0,EMB_TYPE[5:0],1'b1};
        end
        else if((line_cnt < FRONT_LINE) || (line_cnt >= (FRONT_LINE + V_SIZE)))
        begin
            m_axis_tuser <= {32'd0,H_SIZE[15:0],41'd0,EMB_TYPE[5:0],1'b0};
        end
        else if((line_cnt >= FRONT_LINE) && (line_cnt < (FRONT_LINE + V_SIZE)))
        begin
            m_axis_tuser <= {32'd0,H_SIZE[15:0],41'd0,RAW12_TYPE[5:0],1'b0};
        end
        else begin
            m_axis_tuser <= m_axis_tuser;
        end
    end
end


always@(*)
begin
    if(!aresetn)
    begin
        m_axis_tdata <= 16'd0;
    end
    else
    begin  
        if(s_axis_tuser || (line_cnt < FRONT_LINE))
            begin
                if((line_cnt == 16'd0) || (line_cnt == (FRONT_LINE + V_SIZE + TAIL_LINE)))
                begin
                    case(col_cnt)
                        16'd0   :m_axis_tdata <= {4'h0,8'hda,4'h0};
                        16'd1   :m_axis_tdata <= {4'h0,fps_cnt[31:24],4'h0};        
                        16'd2   :m_axis_tdata <= {4'h0,8'hda,4'h0};
                        16'd3   :m_axis_tdata <= {4'h0,fps_cnt[23:16],4'h0};   
                        16'd4   :m_axis_tdata <= {4'h0,8'hda,4'h0};
                        16'd5   :m_axis_tdata <= {4'h0,fps_cnt[15:8],4'h0};   
                        16'd6   :m_axis_tdata <= {4'h0,8'hda,4'h0};
                        16'd7   :m_axis_tdata <= {4'h0,fps_cnt[7:0],4'h0};                       
                        default: m_axis_tdata <= {4'h0,8'h00,4'h0};  
                    endcase
                end
                else begin
                    m_axis_tdata <= {4'h0,8'h00,4'h0};
                end
            end
        else if(line_cnt >= (FRONT_LINE + V_SIZE))
            begin
                if(line_cnt == (FRONT_LINE + V_SIZE + TAIL_LINE - 2))
                begin
                    case(col_cnt)//Î²²¿Ðè¼Ó1
                        16'd0   :m_axis_tdata <= {4'h0,8'hda,4'h0};
                        16'd1   :m_axis_tdata <= {4'h0,tail_frame_cnt[31:24],4'h0};        
                        16'd2   :m_axis_tdata <= {4'h0,8'hda,4'h0};
                        16'd3   :m_axis_tdata <= {4'h0,tail_frame_cnt[23:16],4'h0};   
                        16'd4   :m_axis_tdata <= {4'h0,8'hda,4'h0};
                        16'd5   :m_axis_tdata <= {4'h0,tail_frame_cnt[15:8],4'h0};   
                        16'd6   :m_axis_tdata <= {4'h0,8'hda,4'h0};
                        16'd7   :m_axis_tdata <= {4'h0,tail_frame_cnt[7:0],4'h0};                       
                        default: m_axis_tdata <= {4'h0,8'h00,4'h0}; 
                    endcase
                end
                else begin
                    m_axis_tdata <= {4'h0,8'h00,4'h0};
                end
            end
        else//normal video data
        begin
            m_axis_tdata <= s_axis_tdata; 
        end
    end
end


endmodule
