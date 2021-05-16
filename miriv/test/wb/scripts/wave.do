onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /wb_tb/clk
add wave -noupdate /wb_tb/flush
add wave -noupdate /wb_tb/stall
add wave -noupdate /wb_tb/res_n
add wave -noupdate /wb_tb/op
add wave -noupdate /wb_tb/aluresult
add wave -noupdate /wb_tb/memresult
add wave -noupdate /wb_tb/pc_old_in
add wave -noupdate /wb_tb/reg_write
add wave -noupdate /wb_tb/wb_inst/op_reg
add wave -noupdate /wb_tb/wb_inst/aluresult_reg
add wave -noupdate /wb_tb/wb_inst/memresult_reg
add wave -noupdate /wb_tb/wb_inst/pc_old_in_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {98803 ps} 0}
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
configure wave -timelineunits ps
update
WaveRestoreZoom {4351164 ps} {5034150 ps}
