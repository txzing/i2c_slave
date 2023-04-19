`timescale 1ns/1ps
module stream_switch
#
(
    parameter FREQ_HZ = 32'd100000000, 
    parameter WIDTH = 32'd16,
    parameter TUSER_WIDTH = 32'd1,
    parameter TDEST_WIDTH = 32'd10
)
(
    input aclk,
    input aresetn,
    //
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)input s_axis_tvalid,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)output s_axis_tready,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)input [WIDTH-1:0] s_axis_tdata,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)input s_axis_tlast,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)input [TUSER_WIDTH-1:0]s_axis_tuser,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)input [TDEST_WIDTH-1:0]s_axis_tdest,
    //
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output m0_axis_tvalid,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)input m0_axis_tready,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output [WIDTH-1:0] m0_axis_tdata,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output m0_axis_tlast,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output [TUSER_WIDTH-1:0]m0_axis_tuser,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output [TDEST_WIDTH-1:0]m0_axis_tdest,

    (* DONT_TOUCH = "yes", s="true",keep="true" *)output m1_axis_tvalid,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)input m1_axis_tready,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output [WIDTH-1:0] m1_axis_tdata,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output m1_axis_tlast,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output [TUSER_WIDTH-1:0]m1_axis_tuser,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output [TDEST_WIDTH-1:0]m1_axis_tdest

);

assign s_axis_tready = m0_axis_tready|m1_axis_tready;
//
assign m0_axis_tvalid   = (s_axis_tdest == 10'h2c0)? s_axis_tvalid:1'b0;
assign m0_axis_tdata    = (s_axis_tdest == 10'h2c0)? s_axis_tdata:{WIDTH{1'b0}};
//assign m0_axis_tuser    = s_axis_tuser || m0_tuser_flag_r1;
assign m0_axis_tuser    = s_axis_tuser || m0_axis_tuser_r;
assign m0_axis_tlast    = (s_axis_tdest == 10'h2c0)? s_axis_tlast:1'b0;
assign m0_axis_tdest    = (s_axis_tdest == 10'h2c0)? s_axis_tdest:{TDEST_WIDTH{1'b0}};

assign m1_axis_tvalid   = (s_axis_tdest == 10'h2c1)? s_axis_tvalid:1'b0;
assign m1_axis_tdata    = (s_axis_tdest == 10'h2c1)? s_axis_tdata:{WIDTH{1'b0}};
//assign m1_axis_tuser    = s_axis_tuser || m1_tuser_flag_r1;
assign m1_axis_tuser    = s_axis_tuser || m1_axis_tuser_r;
assign m1_axis_tlast    = (s_axis_tdest == 10'h2c1)? s_axis_tlast:1'b0;
assign m1_axis_tdest    = (s_axis_tdest == 10'h2c1)? s_axis_tdest:{TDEST_WIDTH{1'b0}};

////////////////

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
        else if((s_axis_tvalid ==1'b1) && (s_axis_tready==1'b1) && (s_axis_tuser[0]==1'b1))
        begin
            line_cnt <= 16'b0;    
        end
    end
end


reg m0_axis_tuser_r;
always@(*)
begin
    if(!aresetn)
    begin
        m0_axis_tuser_r = 1'b0;
    end
    else
    begin                                     
        if((col_cnt == 0) && (line_cnt >= 16'd2571) && (s_axis_tdata == 16'h0da0) && (s_axis_tdest == 10'h2c0))
        begin
            m0_axis_tuser_r = 1'b1;
        end
        else 
        begin
            m0_axis_tuser_r = 1'b0;
        end
    end
end

reg m1_axis_tuser_r;
always@(*)
begin
    if(!aresetn)
    begin
        m1_axis_tuser_r = 1'b0;
    end
    else
    begin                                     
        if((col_cnt == 0) && (line_cnt >= 16'd2571)&& (s_axis_tdata == 16'h0da0) && (s_axis_tdest == 10'h2c1))
        begin
            m1_axis_tuser_r = 1'b1;
        end
        else 
        begin
            m1_axis_tuser_r = 1'b0;
        end
    end
end

/*

//寄存tuser到来时的tdest
reg [TDEST_WIDTH-1:0] s_axis_tdest_r;
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        s_axis_tdest_r <= {TDEST_WIDTH{1'b0}};
    end
    else
    begin  
        if(s_axis_tuser)
        begin
            s_axis_tdest_r <= s_axis_tdest;
        end
        else
        begin
            s_axis_tdest_r <= s_axis_tdest_r;
        end
    end
end



//主要是tuser
reg m0_tuser_flag_r0;
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        m0_tuser_flag_r0 <= 1'b0;
    end
    else
    begin  
        if(m0_axis_tlast && m0_tuser_flag_r0)
        begin
            m0_tuser_flag_r0 <= 1'b0;
        end
        else if(s_axis_tuser && !m0_tuser_flag_r0)
        begin
            m0_tuser_flag_r0 <= 1'b1;
        end
    end
end

reg m1_tuser_flag_r0;
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        m1_tuser_flag_r0 <= 1'b0;
    end
    else
    begin  
        if(m1_axis_tlast && m1_tuser_flag_r0)
        begin
            m1_tuser_flag_r0 <= 1'b0;
        end
        else if(s_axis_tuser && !m1_tuser_flag_r0)
        begin
            m1_tuser_flag_r0 <= 1'b1;
        end
    end
end

//脉冲信号
reg m0_tuser_flag_r1;
always@(*)
begin
    if(!aresetn)
    begin
        m0_tuser_flag_r1 = 1'b0;
    end
    else
    begin                                       //tuser对应2c1
        if((col_cnt == 0)&& m0_tuser_flag_r0 && (s_axis_tdest_r == 10'h2c1))
        begin
            m0_tuser_flag_r1 = 1'b1;
        end
        else 
        begin
            m0_tuser_flag_r1 = 1'b0;
        end
    end
end

reg m1_tuser_flag_r1;
always@(*)
begin
    if(!aresetn)
    begin
        m1_tuser_flag_r1 = 1'b0;
    end
    else
    begin                                       //tuser对应2c1
        if((col_cnt == 0)&& m1_tuser_flag_r0 && (s_axis_tdest_r == 10'h2c0))
        begin
            m1_tuser_flag_r1 = 1'b1;
        end
        else 
        begin
            m1_tuser_flag_r1 = 1'b0;
        end
    end
end
*/

endmodule
