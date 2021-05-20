onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cpu/dut/pipeline_inst/clk
add wave -noupdate /tb_cpu/res_n
add wave -noupdate -divider -height 40 fetch
add wave -noupdate -expand -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/clk
add wave -noupdate -expand -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/res_n
add wave -noupdate -expand -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/stall
add wave -noupdate -expand -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/flush
add wave -noupdate -expand -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/mem_busy
add wave -noupdate -expand -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/pcsrc
add wave -noupdate -expand -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in
add wave -noupdate -expand -group fetch -radix unsigned /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out
add wave -noupdate -expand -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/instr
add wave -noupdate -expand -group fetch -radix binary /tb_cpu/dut/pipeline_inst/fetch_inst/mem_out
add wave -noupdate -expand -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/mem_in
add wave -noupdate -expand -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/pc_counter_reg
add wave -noupdate -expand -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/pc_counter_reg_next
add wave -noupdate -divider -height 40 decode
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/clk
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/res_n
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/stall
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/flush
add wave -noupdate -expand -group decode -radix unsigned /tb_cpu/dut/pipeline_inst/decode_inst/pc_in
add wave -noupdate -expand -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/instr
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/reg_write
add wave -noupdate -expand -group decode -radix unsigned /tb_cpu/dut/pipeline_inst/decode_inst/pc_out
add wave -noupdate -expand -group decode -expand /tb_cpu/dut/pipeline_inst/decode_inst/exec_op
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/mem_op
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/wb_op
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/exc_dec
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg
add wave -noupdate -expand -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/instr_reg
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/pc_in_reg
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/regfile_rdaddr1
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/regfile_rdaddr2
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/regfile_rddata1
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/regfile_rddata2
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/regfile_wraddr
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/regfile_wrdata
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/regfile_write
add wave -noupdate -divider -height 40 exec
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/clk
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/res_n
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/stall
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/flush
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/op
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/pc_in
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/pc_old_out
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/pc_new_out
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/aluresult
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/wrdata
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/zero
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/memop_in
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/memop_out
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/wbop_in
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/wbop_out
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/exec_op
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/reg_write_mem
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/reg_write_wr
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/wbop_reg
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/wbop_reg_next
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/mem_op_reg
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/mem_op_reg_next
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/pc_old_reg
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/pc_old_reg_next
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/temp_pc_new_out
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/exec_op_reg
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/exec_op_reg_next
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/pc_add_A_reg
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/pc_add_A_reg_next
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/pc_add_B_reg
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/pc_add_B_reg_next
add wave -noupdate -divider -height 40 mem
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/clk
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/res_n
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/stall
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/flush
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/mem_busy
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/mem_op
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/wbop_in
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/pc_new_in
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/pc_old_in
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/aluresult_in
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/wrdata
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/zero
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/reg_write
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/pc_new_out
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/pcsrc
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/wbop_out
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/pc_old_out
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/aluresult_out
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/memresult
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/mem_out
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/mem_in
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/exc_load
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/exc_store
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/wbop_reg
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/wbop_reg_next
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/aluresult_reg
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/aluresult_reg_next
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/pc_old_reg
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/pc_old_reg_next
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/pc_new_reg
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/pc_new_reg_next
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/mem_in_reg
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/mem_in_reg_next
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/mem_op_reg
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/mem_op_reg_next
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/wrdata_reg
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/wrdata_reg_next
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/zero_reg
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/zero_reg_next
add wave -noupdate -divider -height 40 wb
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/clk
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/res_n
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/stall
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/flush
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/op
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/aluresult
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/memresult
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/pc_old_in
add wave -noupdate -expand -group wb -expand /tb_cpu/dut/pipeline_inst/wb_inst/reg_write
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/op_reg
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/op_reg_next
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/aluresult_reg
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/aluresult_reg_next
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/memresult_reg
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/memresult_reg_next
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/pc_old_in_reg
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/pc_old_in_reg_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {87771 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 192
configure wave -valuecolwidth 273
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
configure wave -timelineunits us
update
WaveRestoreZoom {20850 ps} {116082 ps}
