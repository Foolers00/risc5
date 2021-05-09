onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /alu_tb/A
add wave -noupdate -radix unsigned /alu_tb/B
add wave -noupdate -radix unsigned /alu_tb/R
add wave -noupdate /alu_tb/Z
add wave -noupdate /alu_tb/op
add wave -noupdate /alu_tb/start_stimulus
add wave -noupdate /alu_tb/start_output
add wave -noupdate /alu_tb/inp
add wave -noupdate /alu_tb/outp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {999999110 ps} 0}
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
WaveRestoreZoom {0 ps} {1050 us}
