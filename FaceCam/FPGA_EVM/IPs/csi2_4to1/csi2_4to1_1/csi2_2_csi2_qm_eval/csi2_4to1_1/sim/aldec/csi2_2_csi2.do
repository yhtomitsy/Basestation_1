set sim_working_folder "C:/my_designs/"
set workspace_name "quaddphy2dphy_space"
set design_name "quaddphy2dphy"
set design_path "C:/my_designs/SIPB"
set design_inst "SIPB_inst"
set diamond_dir "C:/lscc/diamond/3.9_x64"

######## Do not modify ########
cd $sim_working_folder
workspace create $workspace_name
design create $design_name .
design open $design_name
cd $design_path/${design_inst}/csi2_2_csi2_qm_eval/testbench
runscript $design_path/${design_inst}/csi2_2_csi2_qm_eval/${design_inst}/sim/aldec/update_tb.pl ${design_inst}
if not [exist -file "$design_path/${design_inst}/csi2_2_csi2_qm_eval/models/lifmd/pll_wrapper.v"]
   echofile $design_path/${design_inst}/csi2_2_csi2_qm_eval/models/lifmd/pll_wrapper.v "module pll_wrapper(); endmodule"
endif
###############################

#compile the files
vlog \
-v2k5 \
###############################
# Update params as needed
+define+NUM_PIXELS=640 \
###############################
$diamond_dir/cae_library/simulation/blackbox/lifmd_black_boxes-aldec.vp \
$diamond_dir/cae_library/simulation/verilog/lifmd/*.v \
$diamond_dir/cae_library/simulation/verilog/pmi/*.v \
$design_path/${design_inst}/${design_inst}_params.v \
$design_path/${design_inst}/csi2_2_csi2_qm_eval/models/lifmd/pll_wrapper.v \
$design_path/${design_inst}/csi2_2_csi2_qm_eval/${design_inst}/src/beh_rtl/capture_ctrl_beh.v \
$design_path/${design_inst}/csi2_2_csi2_qm_eval/${design_inst}/src/beh_rtl/rx_global_ctrl_beh.v  \
$design_path/${design_inst}/csi2_2_csi2_qm_eval/${design_inst}/src/beh_rtl/dphy_rx_wrap_beh.v \
$design_path/${design_inst}/csi2_2_csi2_qm_eval/${design_inst}/src/beh_rtl/arbiter_fsm_beh.v  \
$design_path/${design_inst}/csi2_2_csi2_qm_eval/${design_inst}/src/beh_rtl/line_buffer_beh.v \
$design_path/${design_inst}/csi2_2_csi2_qm_eval/${design_inst}/src/beh_rtl/hdr_buffer_beh.v \
$design_path/${design_inst}/csi2_2_csi2_qm_eval/${design_inst}/src/beh_rtl/tx_byte_data_gen_beh.v \
$design_path/${design_inst}/csi2_2_csi2_qm_eval/${design_inst}/src/beh_rtl/dci_wrapper_beh.v \
$design_path/${design_inst}/csi2_2_csi2_qm_eval/${design_inst}/src/beh_rtl/tx_global_operation_beh.v \
$design_path/${design_inst}/csi2_2_csi2_qm_eval/${design_inst}/src/beh_rtl/pkt_header_csi2_2bg_beh.v \
$design_path/${design_inst}/csi2_2_csi2_qm_eval/${design_inst}/src/beh_rtl/tinit_count_beh.v \
$design_path/${design_inst}/${design_inst}_synchronizer.v \
$design_path/${design_inst}/${design_inst}_cmos_2_dphy_ip.v \
$design_path/${design_inst}/${design_inst}_dphy_2_cmos_ip.v \
$design_path/${design_inst}/${design_inst}_csi2_2_csi2_ip.v \
$design_path/${design_inst}/${design_inst}.v \
$design_path/${design_inst}/${design_inst}_capture_ctrl.v \
$design_path/${design_inst}/${design_inst}_rx_global_ctrl.v \
$design_path/${design_inst}/${design_inst}_dphy_rx_wrap.v \
$design_path/${design_inst}/${design_inst}_arbiter_fsm.v \
$design_path/${design_inst}/${design_inst}_line_buffer.v \
$design_path/${design_inst}/${design_inst}_hdr_buffer.v \
$design_path/${design_inst}/${design_inst}_tx_byte_data_gen.v \
$design_path/${design_inst}/${design_inst}_dci_wrapper.v \
$design_path/${design_inst}/${design_inst}_tx_global_operation.v \
$design_path/${design_inst}/${design_inst}_pkt_header_csi2_2bg.v \
$design_path/${design_inst}/${design_inst}_tinit_count.v \
$design_path/${design_inst}/${design_inst}_muxer.v \
$design_path/${design_inst}/csi2_2_csi2_qm_eval/testbench/csi2_2_csi2_tb.v

# Start the simulator #
vsim +access +r top

# adding the signals to wave window #########
wave /top/I_quad_dphy_2_dphy_camera/*

# run simulation cycles
run -all
