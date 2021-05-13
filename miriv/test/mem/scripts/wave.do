onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mem_tb/clk
add wave -noupdate /mem_tb/res_n
add wave -noupdate /mem_tb/stall
add wave -noupdate /mem_tb/flush
add wave -noupdate /mem_tb/mem_busy
add wave -noupdate /mem_tb/mem_op
add wave -noupdate /mem_tb/mem_in
add wave -noupdate /mem_tb/mem_out
add wave -noupdate /mem_tb/wrdata
add wave -noupdate /mem_tb/memresult
add wave -noupdate /mem_tb/exc_load
add wave -noupdate /mem_tb/exc_store
add wave -noupdate /mem_tb/aluresult_in
add wave -noupdate /mem_tb/aluresult_out
add wave -noupdate /mem_tb/zero
add wave -noupdate /mem_tb/pcsrc
add wave -noupdate /mem_tb/pc_old_in
add wave -noupdate /mem_tb/pc_old_out
add wave -noupdate /mem_tb/pc_new_in
add wave -noupdate /mem_tb/pc_new_out
add wave -noupdate /mem_tb/wbop_in
add wave -noupdate /mem_tb/wbop_out
add wave -noupdate /mem_tb/reg_write
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
WaveRestoreZoom {0 ps} {1 ns}
