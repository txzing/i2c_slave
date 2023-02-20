onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/Clk
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/Rst_n
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/Sclk
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/Sda_in
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -color Coral -radix unsigned /last_tb/i2c_slave/Sda_oe
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/Sda_o
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/rw_flag
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -color Red -radix ascii -radixshowbase 0 /last_tb/State_Machine
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/cnt_sclk
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/cnt_sdai_h
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -color Magenta -radix unsigned /last_tb/i2c_slave/bit_buf
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -color Blue -radix unsigned -childformat {{{/last_tb/i2c_slave/samp_flag[2]} -radix unsigned} {{/last_tb/i2c_slave/samp_flag[1]} -radix unsigned} {{/last_tb/i2c_slave/samp_flag[0]} -radix unsigned}} -subitemconfig {{/last_tb/i2c_slave/samp_flag[2]} {-color Blue -height 15 -radix unsigned} {/last_tb/i2c_slave/samp_flag[1]} {-color Blue -height 15 -radix unsigned} {/last_tb/i2c_slave/samp_flag[0]} {-color Blue -height 15 -radix unsigned}} /last_tb/i2c_slave/samp_flag
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/cnt_bit
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -color {Lime Green} /last_tb/i2c_slave/scl_neg
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/cnt_byte
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/RW_Addr
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -color Magenta -radix hexadecimal /last_tb/i2c_slave/data_buf
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/idle2start
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/start2jug_rw
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/jug_rw2rw_addr
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/jug_rw2rd_dat
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/jug_rw2idle
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/rw_addr2wr_dat
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/wr_dat2start
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/wr_dat2stop
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/rd_dat2stop
add wave -noupdate -expand -label sim:/last_tb/i2c_slave/Group1 -group {Region: sim:/last_tb/i2c_slave} -radix unsigned /last_tb/i2c_slave/stop2idle
add wave -noupdate /last_tb/i2c_slave/memery
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {16773831 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ps} {69583512 ps}
