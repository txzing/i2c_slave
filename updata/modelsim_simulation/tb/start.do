#/*================================================*\
#		  Filename 	﹕ start.do
#			Author 	﹕ Adolph
#	  Description  	﹕ Modelsim 仿真脚本文件
#		 Called by 	﹕ No file
#Revision History   ﹕ 2022-4-19 
#		  			  Revision 1.0
#  			  Email	﹕ adolph1354238998@gmail.com
#\*================================================*/
#此脚本文件存放于工程文件夹下的tb子文件夹
#在 modelsim 的 transcript 窗口执行的时候使用
# do filename.do 命令后，自动执行仿真


if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

#编译 testbench文件					       	
vlog    last_tb.v

#编译 设计文件（位于工程文件夹下的rtl子文件夹）					       	 
vlog ../rtl/*.v
#vlog ../rtl/*.v

#编译 IP文件
#vlog ../rtl/*.v

#指定仿真顶层模块	
#-L altera_ver 			这几个为可选项，用到谁的IP，就添加谁，不清楚就全部保留
#-L lpm_ver 	        
#-L sgate_ver 	        
#-L altera_mf_ver 	    
#-L altera_lnsim_ver	
#-L cycloneive_ver	    

vsim -t 1ps -L rtl_work -L work -voptargs="+acc"  last_tb

#添加信号到波形窗 
add wave -noupdate -radix ASCII -color Yellow sim:/last_tb/State_Machine							  
add wave -position insertpoint sim:/last_tb/u_i2c_slave/*
add wave -position insertpoint sim:/last_tb/u_i2c_slave/memory									
                                                             				   
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update

#do wave.do

run -all 