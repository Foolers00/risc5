onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /memu_tb/A
add wave -noupdate /memu_tb/B
add wave -noupdate /memu_tb/D
add wave -noupdate /memu_tb/M
add wave -noupdate /memu_tb/R
add wave -noupdate /memu_tb/W
add wave -noupdate /memu_tb/XL
add wave -noupdate /memu_tb/XS
add wave -noupdate /memu_tb/inp
add wave -noupdate /memu_tb/op
add wave -noupdate /memu_tb/outp
add wave -noupdate /memu_tb/start_output
add wave -noupdate /memu_tb/start_stimulus
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
configure wave -timelineunits ns
update
WaveRestoreZoom {999978445 ps} {1000001135 ps}
