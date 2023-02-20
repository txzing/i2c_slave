#cycloneIV EP4CE6F17C8  参数导入脚本;
# “#”号表示注释  
# -to 后面的为信号名，要和程序中保持一致

set_location_assignment PIN_E1  -to clk
set_location_assignment PIN_E15 -to rst_n

#串口
#set_location_assignment PIN_M2 -to uart_rx
#set_location_assignment PIN_G1 -to uart_tx

#LED
#set_location_assignment PIN_D16 -to led[3]
#set_location_assignment PIN_F15 -to led[2]
#set_location_assignment PIN_F16 -to led[1]
#set_location_assignment PIN_G15 -to led[0]

#按键
#set_location_assignment PIN_M15 -to key4
#set_location_assignment PIN_M16 -to key3
#set_location_assignment PIN_E16 -to key2
#set_location_assignment PIN_E15 -to key1

#数码管选段
#set_location_assignment PIN_B7 -to sen_duan[0]
#set_location_assignment PIN_A8 -to sen_duan[1]
#set_location_assignment PIN_A6 -to sen_duan[2]
#set_location_assignment PIN_B5 -to sen_duan[3]
#set_location_assignment PIN_B6 -to sen_duan[4]
#set_location_assignment PIN_A7 -to sen_duan[5]
#set_location_assignment PIN_B8 -to sen_duan[6]
#set_location_assignment PIN_A5 -to sen_duan[7]

#数码管片选
#set_location_assignment PIN_A4 -to sen_wei[0]
#set_location_assignment PIN_B4 -to sen_wei[1]
#set_location_assignment PIN_A3 -to sen_wei[2]
#set_location_assignment PIN_B3 -to sen_wei[3]
#set_location_assignment PIN_A2 -to sen_wei[4]
#set_location_assignment PIN_B1 -to sen_wei[5]

#蜂鸣器
#set_location_assignment PIN_J1 -to beep

#IIC-EEPROM
#set_location_assignment PIN_L1 -to SCL
#set_location_assignment PIN_L2 -to SDA

#SPI-FLASH
#set_location_assignment PIN_C1 -to mosi 
#set_location_assignment PIN_H2 -to miso 
#set_location_assignment PIN_D2 -to cs_n 
#set_location_assignment PIN_H1 -to sck

#VGA
#set_location_assignment PIN_C16 -to hsync
#set_location_assignment PIN_D15 -to vsync
#set_location_assignment PIN_C15 -to rgb[0]
#set_location_assignment PIN_B16 -to rgb[1]
#set_location_assignment PIN_A15 -to rgb[2]
#set_location_assignment PIN_B14 -to rgb[3]
#set_location_assignment PIN_A14 -to rgb[4]
#set_location_assignment PIN_B13 -to rgb[5]
#set_location_assignment PIN_A13 -to rgb[6]
#set_location_assignment PIN_B12 -to rgb[7]
#set_location_assignment PIN_A12 -to rgb[8]
#set_location_assignment PIN_B11 -to rgb[9]
#set_location_assignment PIN_A11 -to rgb[10]
#set_location_assignment PIN_B10 -to rgb[11]
#set_location_assignment PIN_A10 -to rgb[12]
#set_location_assignment PIN_B9  -to rgb[13]
#set_location_assignment PIN_A9  -to rgb[14]
#set_location_assignment PIN_C8  -to rgb[15]

#CAMERA
#set_location_assignment PIN_C6 -to CMOS_SCL
#set_location_assignment PIN_D6 -to CMOS_SDA
#set_location_assignment PIN_D5 -to CMOS_PCLK
#set_location_assignment PIN_D3 -to CMOS_XCLK
#set_location_assignment PIN_F1 -to CMOS_RESET
#set_location_assignment PIN_F6 -to CMOS_VSYNC
#set_location_assignment PIN_D1 -to CMOS_HREF
#set_location_assignment PIN_G2 -to CMOS_PWDN
#set_location_assignment PIN_F5 -to CMOS_D0
#set_location_assignment PIN_G5 -to CMOS_D1
#set_location_assignment PIN_D4 -to CMOS_D2
#set_location_assignment PIN_M1 -to CMOS_D3
#set_location_assignment PIN_F3 -to CMOS_D4
#set_location_assignment PIN_F2 -to CMOS_D5
#set_location_assignment PIN_E5 -to CMOS_D6
#set_location_assignment PIN_C3 -to CMOS_D7

#SDRAM
#set_location_assignment PIN_T8  -to S_A0
#set_location_assignment PIN_P9  -to S_A1
#set_location_assignment PIN_T9  -to S_A2
#set_location_assignment PIN_R9  -to S_A3
#set_location_assignment PIN_L16 -to S_A4
#set_location_assignment PIN_L15 -to S_A5
#set_location_assignment PIN_N16 -to S_A6
#set_location_assignment PIN_N15 -to S_A7
#set_location_assignment PIN_P16 -to S_A8
#set_location_assignment PIN_P15 -to S_A9
#set_location_assignment PIN_R8  -to S_A10
#set_location_assignment PIN_R16 -to S_A11
#set_location_assignment PIN_T15 -to S_A12

#set_location_assignment PIN_R4  -to  S_CLK
#set_location_assignment PIN_R7  -to  S_BA0
#set_location_assignment PIN_T7  -to  S_BA1
#set_location_assignment PIN_T5  -to  S_nCAS
#set_location_assignment PIN_R14 -to  S_CKE
#set_location_assignment PIN_R6  -to  S_nRAS
#set_location_assignment PIN_N1  -to  S_nWE
#set_location_assignment PIN_T6  -to  S_nCS

#set_location_assignment PIN_R5  -to  S_DB0
#set_location_assignment PIN_T4  -to  S_DB1
#set_location_assignment PIN_T3  -to  S_DB2
#set_location_assignment PIN_R3  -to  S_DB3
#set_location_assignment PIN_T2  -to  S_DB4
#set_location_assignment PIN_R1  -to  S_DB5
#set_location_assignment PIN_P2  -to  S_DB6
#set_location_assignment PIN_P1  -to  S_DB7
#set_location_assignment PIN_R13 -to  S_DB8
#set_location_assignment PIN_T13 -to  S_DB9
#set_location_assignment PIN_R12 -to  S_DB10
#set_location_assignment PIN_T12 -to  S_DB11
#set_location_assignment PIN_T10 -to  S_DB12
#set_location_assignment PIN_R10 -to  S_DB13
#set_location_assignment PIN_T11 -to  S_DB14
#set_location_assignment PIN_R11 -to  S_DB15

#set_location_assignment PIN_N2  -to  S_DQM0
#set_location_assignment PIN_T14 -to  S_DQM1
