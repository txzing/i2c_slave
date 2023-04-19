`timescale 1ns/1ps
module axis_passthrough_mon
       #
      (
       parameter WIDTH = 32'd48,
       parameter TUSER_WIDTH = 32'd1,
       parameter TDEST_WIDTH = 32'd4,
       parameter FREQ_HZ = 32'd100000000, 
        // Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 7
      )
     (
    input aclk,
    input aresetn,
    //
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)input s_axis_tvalid,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)output s_axis_tready,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)input [WIDTH-1:0] s_axis_tdata,//����д����ȲŻ������ý�������ʵʱ�ı�?
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)input s_axis_tlast,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)input [TUSER_WIDTH-1:0]s_axis_tuser,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)input [TDEST_WIDTH-1:0]s_axis_tdest,
    //
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output m_axis_tvalid,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)input m_axis_tready,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output [WIDTH-1:0] m_axis_tdata,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output m_axis_tlast,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output [TUSER_WIDTH-1:0]m_axis_tuser,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output [TDEST_WIDTH-1:0]m_axis_tdest,

    	// Ports of Axi Slave Bus Interface S00_AXI
		input s00_axi_aclk,
		input s00_axi_aresetn,
		input [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input [2 : 0] s00_axi_awprot,
		input s00_axi_awvalid,
		output s00_axi_awready,
		input [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input s00_axi_wvalid,
		output s00_axi_wready,
		output [1 : 0] s00_axi_bresp,
		output s00_axi_bvalid,
		input s00_axi_bready,
		input [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input [2 : 0] s00_axi_arprot,
		input s00_axi_arvalid,
		output s00_axi_arready,
		output [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output [1 : 0] s00_axi_rresp,
		output s00_axi_rvalid,
		input s00_axi_rready
    );

wire s00_axi_aclk;
wire s00_axi_aresetn;
wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr;
wire [2 : 0] s00_axi_awprot;
wire s00_axi_awvalid;
wire s00_axi_awready;
wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata;
wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb;
wire s00_axi_wvalid;
wire s00_axi_wready;
wire [1 : 0] s00_axi_bresp;
wire s00_axi_bvalid;
wire s00_axi_bready;
wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr;
wire [2 : 0] s00_axi_arprot;
wire s00_axi_arvalid;
wire s00_axi_arready;
wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata;
wire [1 : 0] s00_axi_rresp;
wire s00_axi_rvalid;
wire s00_axi_rready;

//
assign m_axis_tvalid = s_axis_tvalid;
assign s_axis_tready = m_axis_tready;
assign m_axis_tdata = s_axis_tdata;
assign m_axis_tuser = s_axis_tuser;
assign m_axis_tlast = s_axis_tlast;
assign m_axis_tdest = s_axis_tdest;

reg [31:0] freq_sec_cnt;
reg freq_sec_flag;
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        freq_sec_cnt <= 32'd0;
        freq_sec_flag <= 1'b0;
    end
    else
    begin
        if(freq_sec_cnt < FREQ_HZ)
        begin
            freq_sec_cnt <= freq_sec_cnt + 1'b1;
            freq_sec_flag <= 1'b0;
        end
        else
        begin
            freq_sec_cnt <= 32'd0;
            freq_sec_flag <= 1'b1;
        end
    end
end

reg [31:0] fps;
(* DONT_TOUCH = "yes", s="true",keep="true" *) (*MARK_DEBUG="TRUE"*)reg [31:0] fps_cnt;
wire frame_end;
reg [TUSER_WIDTH-1:0] m_axis_tuser_r;
reg stream_invalid;
always@(posedge aclk)
begin
    m_axis_tuser_r <= m_axis_tuser;
end
assign frame_end = ~m_axis_tuser_r[0]&m_axis_tuser[0];
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        fps <= 32'd0;
        fps_cnt <= 32'd0;
        stream_invalid <= 1'b0;
    end
    else
    begin
        if(freq_sec_flag)
        begin
            if(fps_cnt<32'd3)
            begin
                stream_invalid <= 1'b1;
            end
            else
            begin
                stream_invalid <= 1'b0;
            end
            fps <= fps_cnt;
            fps_cnt <= 32'd0;
        end
        else
        begin
            if(frame_end)
            begin
               fps_cnt <= fps_cnt +1'b1; 
            end
        end
    end
end


//
reg [15:0] col;
(* DONT_TOUCH = "yes", s="true",keep="true" *) (*MARK_DEBUG="TRUE"*)reg [15:0] col_cnt;
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        col <= 16'b0;
        col_cnt <= 16'b0;
    end
    else
    begin
        if((s_axis_tvalid ==1'b1) && (s_axis_tlast==1'b1) && (m_axis_tready ==1'b1)) 
        begin
            col <= col_cnt + 1'b1;
            col_cnt <= 16'b0;
        end
        else if((s_axis_tvalid ==1'b1) && (m_axis_tready==1'b1))
        begin
            col_cnt <= col_cnt + 1'b1;
        end
    end
end

reg [15:0] line;
(* DONT_TOUCH = "yes", s="true",keep="true" *) (*MARK_DEBUG="TRUE"*)reg [15:0] line_cnt;
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        line <= 16'b0;
        line_cnt <= 16'b0;
    end
    else
    begin
        if((s_axis_tvalid ==1'b1) && (s_axis_tlast==1'b1) && (m_axis_tready ==1'b1))
        begin
            line_cnt <= line_cnt+1;
        end
        else if((s_axis_tvalid ==1'b1) && (m_axis_tready==1'b1) && (m_axis_tuser[0]==1'b1))
        begin
            line <= line_cnt;
            line_cnt <= 16'b0;    
        end
    end
end


////////////////

reg [31:0] fps_data;
//(* DONT_TOUCH = "yes", s="true",keep="true" *) (*MARK_DEBUG="TRUE"*)reg [31:0] fps_data_cnt;
reg [31:0] fps_data_cnt;
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        fps_data <= 32'b0;
        fps_data_cnt <= 32'b0;
    end
    else
    begin
        if((s_axis_tvalid ==1'b1) && (m_axis_tready ==1'b1) && (m_axis_tuser[0]==1'b1)) 
        begin
            fps_data <= fps_data_cnt + 1'b1;
            fps_data_cnt <= 32'b0;
        end
        else if((s_axis_tvalid ==1'b1) && (m_axis_tready==1'b1))
        begin
            fps_data_cnt <= fps_data_cnt + 1'b1;
        end
    end
end

reg [31:0] total_data;
//(* DONT_TOUCH = "yes", s="true",keep="true" *) (*MARK_DEBUG="TRUE"*)reg [31:0] total_data_cnt;
reg [31:0] total_data_cnt;
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        total_data <= 32'b0;
        total_data_cnt <= 32'b0;
    end
    else
    begin
        if(freq_sec_flag ) 
        begin
            if(total_data_cnt == 0)
            begin
                total_data <= 0;
            end
            else
            begin
                total_data <= total_data_cnt + 1'b1;
            end
            total_data_cnt <= 32'b0;
        end
        else if((s_axis_tvalid ==1'b1) && (m_axis_tready==1'b1))
        begin
            total_data_cnt <= total_data_cnt + 1'b1;
        end
    end
end


// Instantiation of Axi Bus Interface S00_AXI
	AXI_LITE_REG_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) AXI_LITE_REG_v1_0_S00_AXI_inst (
	    .col(stream_invalid ? 32'b0 : col),
        .line(stream_invalid ? 32'b0 : line),
        .fps(stream_invalid ? 32'b0 : fps),
        .fps_data(stream_invalid ?32'b0 : fps_data),
        .total_data(stream_invalid ?32'b0 :total_data),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);
endmodule
