#cycloneIV EP4CE10F17C8  参数导入脚本;
# “#”号表示注释  
# -to 后面的为信号名，要和程序中保持一致

set_location_assignment PIN_E1   -to clk
set_location_assignment PIN_E16  -to rst_n

#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to clk
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to rst_n

#串口
#set_location_assignment PIN_B5  -to uart_rx
#set_location_assignment PIN_A6  -to uart_tx

#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to uart_rx
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to uart_tx


#蜂鸣器
#set_location_assignment PIN_L16 -to beep

#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to beep

#LED
#set_location_assignment PIN_A3  -to led[3]
#set_location_assignment PIN_A4  -to led[2]
#set_location_assignment PIN_B3  -to led[1]
#set_location_assignment PIN_A2  -to led[0]

#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to led[3]
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to led[2]
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to led[1]
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to led[0]


#按键
#set_location_assignment PIN_E16 -to key3
#set_location_assignment PIN_E15 -to key2
#set_location_assignment PIN_M16 -to key1

#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to key3
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to key2
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to key1


#数码管
#set_location_assignment PIN_F6  -to seg7_sclk
#set_location_assignment PIN_B4  -to seg7_rclk
#set_location_assignment PIN_E6  -to seg7_dio

#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to seg7_sclk
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to seg7_rclk
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to seg7_dio

#IIC-EEPROM
#set_location_assignment PIN_D8  -to iic_scl
#set_location_assignment PIN_F7  -to iic_sda
#set_location_assignment PIN_G16 -to rtc_ck0

#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to iic_scl
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to iic_sda
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to rtc_ck0


#SPI-FLASH
#set_location_assignment PIN_C1  -to asdio 
#set_location_assignment PIN_H2  -to data 
#set_location_assignment PIN_D2  -to ncs  
#set_location_assignment PIN_H1  -to dclk

#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to asdio 
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to data 
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to ncs  
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to dclk

#HDMI/DVI输出
#set_location_assignment PIN_B16 -to dvi_tx2_p
#set_location_assignment PIN_D16 -to dvi_tx2_n
#set_location_assignment PIN_D15 -to dvi_tx1_p
#set_location_assignment PIN_C16 -to dvi_tx1_n
#set_location_assignment PIN_D15 -to dvi_tx0_p
#set_location_assignment PIN_A11 -to dvi_tx0_n
#set_location_assignment PIN_F10 -to dvi_clk_p
#set_location_assignment PIN_F11 -to dvi_clk_n

#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to dvi_tx2_p
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to dvi_tx2_n
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to dvi_tx1_p
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to dvi_tx1_n
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to dvi_tx0_p
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to dvi_tx0_n
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to dvi_clk_p
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to dvi_clk_n

#以太网PHY
#set_location_assignment PIN_B11 -to txd3
#set_location_assignment PIN_A12 -to txd2
#set_location_assignment PIN_B12 -to txd1
#set_location_assignment PIN_C11 -to txd0
#set_location_assignment PIN_D11 -to tx_clk
#set_location_assignment PIN_B10 -to tx_en
#set_location_assignment PIN_B14 -to tx_gck
#set_location_assignment PIN_D14 -to rst_n

#set_location_assignment PIN_B13 -to rxd3
#set_location_assignment PIN_A14 -to rxd2
#set_location_assignment PIN_A13 -to rxd1
#set_location_assignment PIN_E10 -to rxd0
#set_location_assignment PIN_M15 -to rx_clk
#set_location_assignment PIN_A15 -to rx_dv
#set_location_assignment PIN_D12 -to mdio
#set_location_assignment PIN_E11 -to mdc

#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to txd3
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to txd2
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to txd1
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to txd0
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to tx_clk
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to tx_en
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to tx_gck
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to rst_n
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to rxd3
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to rxd2
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to rxd1
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to rxd0
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to rx_clk
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to rx_dv
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to mdio
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to mdc

#MM8731音频
#set_location_assignment PIN_A7  -to xck
#set_location_assignment PIN_A9  -to daclrck
#set_location_assignment PIN_F8  -to dacdat
#set_location_assignment PIN_B8  -to bclk
#set_location_assignment PIN_B10 -to adclrck
#set_location_assignment PIN_A10 -to adcdat

#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to xck
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to daclrck
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to dacdat
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to bclk
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to adclrck
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to adcdat

#AD & DA
#set_location_assignment PIN_B7  -to adc_sclk
#set_location_assignment PIN_C9  -to adc_saddr
#set_location_assignment PIN_D9  -to adc_cs_n
#set_location_assignment PIN_E9  -to adc_sdat
#set_location_assignment PIN_E7  -to dac_sclk
#set_location_assignment PIN_C8  -to dac_din
#set_location_assignment PIN_E8  -to dac_cs_n

#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to adc_sclk
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to adc_saddr
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to adc_cs_n
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to adc_sdat
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to dac_sclk
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to dac_din
#set_instance_assignment -name IOSTANDARD "3.3-V LVTTL" to dac_cs_n

#CAMREA  暂时不弄
#set_location_assignment PIN_F2  -to cmos_d5
#set_location_assignment PIN_E5  -to cmos_d6
#set_location_assignment PIN_C3  -to cmos_d7

#SDRAM
#set_location_assignment PIN_P11 -to sdram_addr[0]
#set_location_assignment PIN_L10 -to sdram_addr[1]
#set_location_assignment PIN_P14 -to sdram_addr[2]
#set_location_assignment PIN_T13 -to sdram_addr[3]
#set_location_assignment PIN_N12 -to sdram_addr[4]
#set_location_assignment PIN_M11 -to sdram_addr[5]
#set_location_assignment PIN_L11 -to sdram_addr[6]
#set_location_assignment PIN_T15 -to sdram_addr[7]
#set_location_assignment PIN_R14 -to sdram_addr[8]
#set_location_assignment PIN_T14 -to sdram_addr[9]
#set_location_assignment PIN_M10 -to sdram_addr[10]
#set_location_assignment PIN_R13 -to sdram_addr[11]
#set_location_assignment PIN_N11 -to sdram_addr[12]

#set_location_assignment PIN_T12 -to sdram_ba[0]
#set_location_assignment PIN_M9  -to sdram_ba[1]
#set_location_assignment PIN_R11 -to sdram_cas_n
#set_location_assignment PIN_T11 -to sdram_cke
#set_location_assignment PIN_T10 -to sdram_clk
#set_location_assignment PIN_R12 -to sdram_cs_n
#set_location_assignment PIN_T8	 -to sdram_dqm[0]
#set_location_assignment PIN_R10 -to sdram_dqm[1]

#set_location_assignment PIN_R3 	-to sdram_dq[0]
#set_location_assignment PIN_T3 	-to sdram_dq[1]
#set_location_assignment PIN_R4 	-to sdram_dq[2]
#set_location_assignment PIN_T4 	-to sdram_dq[3]
#set_location_assignment PIN_R5 	-to sdram_dq[4]
#set_location_assignment PIN_T5 	-to sdram_dq[5]
#set_location_assignment PIN_R6 	-to sdram_dq[6]
#set_location_assignment PIN_R8 	-to sdram_dq[7]
#set_location_assignment PIN_R9 	-to sdram_dq[8]
#set_location_assignment PIN_K9 	-to sdram_dq[9]
#set_location_assignment PIN_L9 	-to sdram_dq[10]
#set_location_assignment PIN_K8 	-to sdram_dq[11]
#set_location_assignment PIN_L8 	-to sdram_dq[12]
#set_location_assignment PIN_M8 	-to sdram_dq[13]
#set_location_assignment PIN_N8 	-to sdram_dq[14]
#set_location_assignment PIN_P9 	-to sdram_dq[15]
#set_location_assignment PIN_N9 	-to sdram_ras_n
#set_location_assignment PIN_T9 	-to sdram_we_n

#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[12]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[11]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[10]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[9]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[8]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[7]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[6]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[5]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[4]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[3]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[2]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[1]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[0]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_ba[1]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_ba[0]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_cas_n
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_cke
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_clk
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_cs_n
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[15]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[14]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[13]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[12]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[11]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[10]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[9]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[8]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[7]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[6]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[5]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[4]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[3]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[2]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[1]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[0]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dqm[1]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dqm[0]
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_ras_n
#set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_we_n

#摄像头采集数据，经双端口RAM暂存后，显示至TFT-RGB565显示屏
#set_location_assignment PIN_J16 -to disp_blue[4]
#set_location_assignment PIN_K15 -to disp_blue[3]
#set_location_assignment PIN_K16 -to disp_blue[2]
#set_location_assignment PIN_J13 -to disp_blue[1]
#set_location_assignment PIN_L15 -to disp_blue[0]
#set_location_assignment PIN_L12 -to disp_green[5]
#set_location_assignment PIN_K12 -to disp_green[4]
#set_location_assignment PIN_L13 -to disp_green[3]
#set_location_assignment PIN_M12 -to disp_green[2]
#set_location_assignment PIN_L14 -to disp_green[1]
#set_location_assignment PIN_N16 -to disp_green[0]
#set_location_assignment PIN_P16 -to disp_red[4]
#set_location_assignment PIN_N15 -to disp_red[3]
#set_location_assignment PIN_R16 -to disp_red[2]
#set_location_assignment PIN_P15 -to disp_red[1]
#set_location_assignment PIN_N13 -to disp_red[0]
#set_location_assignment PIN_J15 -to disp_pclk
#set_location_assignment PIN_K11 -to disp_hs
#set_location_assignment PIN_J11 -to disp_de
#set_location_assignment PIN_J14 -to disp_vs

#set_location_assignment PIN_K10 -to camera_data[0]
#set_location_assignment PIN_P8  -to camera_data[1]
#set_location_assignment PIN_M7  -to camera_data[2]
#set_location_assignment PIN_T6  -to camera_data[3]
#set_location_assignment PIN_N6  -to camera_data[4]
#set_location_assignment PIN_P6  -to camera_data[5]
#set_location_assignment PIN_L7  -to camera_data[6]
#set_location_assignment PIN_P3  -to camera_data[7]
#set_location_assignment PIN_N3  -to camera_href
#set_location_assignment PIN_M2  -to camera_pclk
#set_location_assignment PIN_P1  -to camera_pwdn
#set_location_assignment PIN_T7  -to camera_rst_n
#set_location_assignment PIN_M6  -to camera_vsync
#set_location_assignment PIN_N5  -to camera_xclk
#set_location_assignment PIN_T2  -to camera_sclk
#set_location_assignment PIN_R7  -to camera_sdat
