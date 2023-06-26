//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/16 16:05:00
// Design Name: 
// Module Name: reset_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

// 产生FPGA内部复位信号

module Reset_Delay  # (
    parameter        FREQ_HZ        = 32'd100000000,
    parameter        RST_MS_MAX     = 'd20          // 对MS_CNT_MAX计数
)
(
    input wire         clk,
    output wire        rst_o,
    output wire        rst_n_o
);

localparam MS_CNT = (FREQ_HZ/1000);//1ms
localparam MS_CNT_MAX = MS_CNT * RST_MS_MAX;

reg [31:0]    reset_cnt = 'd0;
reg           rst_o_reg;

always @ (posedge clk)
begin
    if (reset_cnt < MS_CNT_MAX)
    begin
        reset_cnt <= reset_cnt + 1'd1;
    end
end


always @ (posedge clk)
begin
    if (reset_cnt >= MS_CNT_MAX)
    begin
        rst_o_reg <= 1'b0;
    end
    else
    begin
        rst_o_reg <= 1'b1;
    end
end

assign rst_o = rst_o_reg;
assign rst_n_o = ~rst_o_reg;

endmodule
