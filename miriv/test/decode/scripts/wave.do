onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /exec_tb/clk
add wave -noupdate /exec_tb/res_n
add wave -noupdate /exec_tb/stall
add wave -noupdate /exec_tb/flush
add wave -noupdate /exec_tb/op
add wave -noupdate /exec_tb/aluresult
add wave -noupdate /exec_tb/memop_in
add wave -noupdate /exec_tb/memop_out
add wave -noupdate /exec_tb/pc_in
add wave -noupdate /exec_tb/pc_new_out
add wave -noupdate /exec_tb/pc_old_out
add wave -noupdate /exec_tb/wbop_in
add wave -noupdate /exec_tb/wbop_out
add wave -noupdate /exec_tb/wrdata
add wave -noupdate /exec_tb/zero
add wave -noupdate /exec_tb/exec_inst/exec_op_reg
add wave -noupdate /exec_tb/exec_inst/mem_op_reg
add wave -noupdate /exec_tb/exec_inst/pc_add_A_reg
add wave -noupdate /exec_tb/exec_inst/pc_add_B_reg
add wave -noupdate /exec_tb/exec_inst/pc_old_reg
add wave -noupdate /exec_tb/exec_inst/wbop_reg
add wave -noupdate /exec_tb/exec_inst/temp_pc_new_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {51 ps} 0}
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
WaveRestoreZoom {9999050 ps} {10000050 ps}
