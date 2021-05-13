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
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {126324 ps} {1845162 ps}
