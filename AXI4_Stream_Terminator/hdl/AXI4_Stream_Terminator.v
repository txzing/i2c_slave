//`define COMPONENTS			3

module AXI4_Stream_Terminator #
(
    parameter NUM_VIDEO_COMPONENTS = 3,
    parameter SAMPLES_PER_CLOCK = 1,
    parameter MAXIMUM_DATA_WIDTH = 8
)
(
    ap_clk,
    ap_rst_n,
    s_axis_video_TDATA,
    s_axis_video_TVALID,
    s_axis_video_TREADY,
    s_axis_video_TKEEP,
    s_axis_video_TSTRB,
    s_axis_video_TUSER,
    s_axis_video_TLAST,
    s_axis_video_TID,
    s_axis_video_TDEST
);

parameter  S_AXIS_BYTES = ((SAMPLES_PER_CLOCK*MAXIMUM_DATA_WIDTH*NUM_VIDEO_COMPONENTS+7)/8);
parameter  S_AXIS_WIDTH = ((SAMPLES_PER_CLOCK*MAXIMUM_DATA_WIDTH*NUM_VIDEO_COMPONENTS+7)/8)*8;

input   ap_clk;
input   ap_rst_n;

input  [S_AXIS_WIDTH -1:0] s_axis_video_TDATA;
input   s_axis_video_TVALID;
output   s_axis_video_TREADY;
input  [S_AXIS_BYTES -1:0] s_axis_video_TKEEP;
input  [S_AXIS_BYTES -1:0] s_axis_video_TSTRB;
input  [0:0] s_axis_video_TUSER;
input  [0:0] s_axis_video_TLAST;
input  [0:0] s_axis_video_TID;
input  [0:0] s_axis_video_TDEST;

assign  s_axis_video_TREADY=1'b1;

endmodule
