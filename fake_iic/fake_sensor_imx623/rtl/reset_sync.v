/*
实现异步复位，同步释放

*/
module reset_sync
(
	input  	sys_clk		,
	input  	sys_rst_n  		,
	output 	rst_sync_n 

);

reg  rst_s1;
reg  rst_s2;

always @(posedge sys_clk or negedge sys_rst_n)begin  
	if (!sys_rst_n) begin   
		rst_s1 <= 1'b0;  
		rst_s2 <= 1'b0;  
	end  
	else begin  
		rst_s1 <= 1'b1;  
		rst_s2 <= rst_s1;  //同步时钟释放
    end
end  
 
assign rst_sync_n = rst_s2; 

endmodule
  