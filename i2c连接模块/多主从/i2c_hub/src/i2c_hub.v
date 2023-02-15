module i2c_hub
(
//主从接口1
	input     upstream0_scl_T,
	input     upstream0_scl_I,
	output    upstream0_scl_O,
	input     upstream0_sda_T,
	input     upstream0_sda_I,
	output    upstream0_sda_O,
    
//主机接口2    
	input     upstream1_scl_T,
	input     upstream1_scl_I,
	output    upstream1_scl_O,
	input     upstream1_sda_T,
	input     upstream1_sda_I,
	output    upstream1_sda_O,
	
	
	output    downstream_scl_T,
	input     downstream_scl_I,
	output    downstream_scl_O,
	output    downstream_sda_T,
	input     downstream_sda_I,
	output    downstream_sda_O
);
/*
在连接过程中，对于输出端，T为1代表输出，但在输入端，T为1，代表输入

*/

assign downstream_scl_T = upstream0_scl_T & upstream1_scl_T;
assign downstream_scl_O = (upstream0_scl_T ? 1'b1 : upstream0_scl_I) & (upstream1_scl_T ? 1'b1 : upstream1_scl_I);
assign downstream_sda_T = upstream0_sda_T & upstream1_sda_T;
assign downstream_sda_O = (upstream0_sda_T ? 1'b1 : upstream0_sda_I) & (upstream1_sda_T ? 1'b1 : upstream1_sda_I);
assign upstream0_scl_O = downstream_scl_I;
assign upstream0_sda_O = downstream_sda_I;
assign upstream1_scl_O = downstream_scl_I;
assign upstream1_sda_O = downstream_sda_I;


// follows for spec proj
//assign upstream0_scl_O = downstream_scl_I & upstream1_scl_I;
//assign upstream0_sda_O = downstream_sda_I & upstream1_sda_I;
//assign upstream1_scl_O = downstream_scl_I & upstream0_scl_I;
//assign upstream1_sda_O = downstream_sda_I & upstream0_sda_I;

endmodule
