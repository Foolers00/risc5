onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fetch_tb/clk
add wave -noupdate /fetch_tb/flush
add wave -noupdate /fetch_tb/stall
add wave -noupdate /fetch_tb/pcsrc
add wave -noupdate /fetch_tb/instr
add wave -noupdate /fetch_tb/mem_busy
add wave -noupdate /fetch_tb/mem_in
add wave -noupdate /fetch_tb/mem_out
add wave -noupdate /fetch_tb/pc_in
add wave -noupdate /fetch_tb/pc_out
add wave -noupdate /fetch_tb/res_n
add wave -noupdate /fetch_tb/fetch_inst/flush_reg
add wave -noupdate /fetch_tb/fetch_inst/instr_reg
add wave -noupdate /fetch_tb/fetch_inst/mem_busy_reg
add wave -noupdate /fetch_tb/fetch_inst/mem_in_reg
add wave -noupdate /fetch_tb/fetch_inst/mem_out_reg
add wave -noupdate /fetch_tb/fetch_inst/pc_counter_reg
add wave -noupdate /fetch_tb/fetch_inst/pc_in_reg
add wave -noupdate /fetch_tb/fetch_inst/pc_out_reg
add wave -noupdate /fetch_tb/fetch_inst/pcsrc_reg
add wave -noupdate /fetch_tb/fetch_inst/stall_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {127950 ps} 0}
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
WaveRestoreZoom {81243 ps} {434503 ps}
