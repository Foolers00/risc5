onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /decode_tb/clk
add wave -noupdate /decode_tb/exc_dec
add wave -noupdate /decode_tb/exec_op
add wave -noupdate /decode_tb/flush
add wave -noupdate /decode_tb/instr
add wave -noupdate /decode_tb/mem_op
add wave -noupdate /decode_tb/pc_in
add wave -noupdate /decode_tb/pc_out
add wave -noupdate /decode_tb/reg_write
add wave -noupdate /decode_tb/res_n
add wave -noupdate /decode_tb/stall
add wave -noupdate /decode_tb/stop_clk
add wave -noupdate /decode_tb/wb_op
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
WaveRestoreZoom {0 ps} {10500 ns}
