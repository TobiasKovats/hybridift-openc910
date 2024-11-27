# Modelsim build script
# Not suitable for designs with dependencies.

# TRACE must be `notrace` or `trace` or `trace_fst`

if { [info exists ::env(HYBRIDIFT_DIR)] }         { set HYBRIDIFT_DIR $::env(HYBRIDIFT_DIR)}                     else { puts "Please set HYBRIDIFT_DIR environment variable"; exit 1 }
if { [info exists ::env(MODELSIM_WORKROOT)] }   { set MODELSIM_WORKROOT $::env(MODELSIM_WORKROOT)}         else { puts "Please set MODELSIM_WORKROOT environment variable"; exit 1 }
if { [info exists ::env(INSTRUMENTATION)] }     { set INSTRUMENTATION $::env(INSTRUMENTATION)}             else { puts "Please set INSTRUMENTATION environment variable"; exit 1 }
if { [info exists ::env(TRACE)] }               { set TRACE $::env(TRACE)}                                 else { puts "Please set TRACE environment variable"; exit 1 }
if { [info exists ::env(HYBRIDIFT_META_COMMON)] } { set HYBRIDIFT_META_COMMON $::env(HYBRIDIFT_META_COMMON)}     else { puts "Please set HYBRIDIFT_META_COMMON environment variable"; exit 1 }
if { [info exists ::env(SV_TOP)] }              { set SV_TOP $HYBRIDIFT_DIR/$::env(SV_TOP) }                 else { puts "Please set SV_TOP environment variable"; exit 1 }
if { [info exists ::env(TOP_SOC)] }             { set TOP_SOC   $::env(TOP_SOC) }                          else { puts "Please set TOP_SOC environment variable"; exit 1 }
if { [info exists ::env(SV_MEM)] }              { set SV_MEM    $::env(SV_MEM) }                           else { puts "Please set SV_MEM environment variable"; exit 1 }
if { [info exists ::env(SV_TB)] }               { set SV_TB  $HYBRIDIFT_DIR/$::env(SV_TB) }                  else { puts "Please set SV_TB environment variable"; exit 1 }
if { [info exists ::env(IFT_AXI_TO_MEM)] }               { set IFT_AXI_TO_MEM $::env(IFT_AXI_TO_MEM) }                  else { set IFT_AXI_TO_MEM ""}
if { [info exists ::env(ALL_MEMSHADE)] }               { set ALL_MEMSHADE $::env(ALL_MEMSHADE) }                  else { set ALL_MEMSHADE ""}
if { [info exists ::env(FPGA_SRAM)] }               { set FPGA_SRAM $::env(FPGA_SRAM) }                  else { set FPGA_SRAM ""}
if { [info exists ::env(FUZZCOREID)] }          { set FUZZCOREID  $::env(FUZZCOREID) }                     else { puts "No FUZZCOREID specified. Defaulting to 0."; set FUZZCOREID 0 }
# Useful if multiple designs have the same top soc name (typically rocket and boom)
if { [info exists ::env(VARIANT_ID)] }          { set VARIANT_ID  $::env(VARIANT_ID) }                     else { set VARIANT_ID "" }
# In case we want to have an include directory, MODELSIM_INCDIRSTR="+incdir+my/first/incdirectory +incdir+my/second/incdirectory" for example
if { [info exists ::env(MODELSIM_INCDIRSTR)] }  { set MODELSIM_INCDIRSTR  $::env(MODELSIM_INCDIRSTR) }     else { set MODELSIM_INCDIRSTR "" }
# Cover flag should be +cover or empty, or for example +cover=bcst
# if { [info exists ::env(MODELSIM_VLOG_COVERFLAG)] }  { set MODELSIM_VLOG_COVERFLAG  $::env(MODELSIM_VLOG_COVERFLAG) }     else { set MODELSIM_VLOG_COVERFLAG "" }

set LIB ${MODELSIM_WORKROOT}/${TOP_SOC}${VARIANT_ID}_${FUZZCOREID}/work_${INSTRUMENTATION}_${TRACE}

vlog -64 -suppress 7061 -suppress 2583 -suppress 8386 -suppress 13314 -suppress 7063 -suppress 3009 -sv -work $LIB +define+RANDOMIZE_INIT=1 +define+STOP_COND=0 -ccflags '-std=c++14' $MODELSIM_INCDIRSTR -sv $HYBRIDIFT_DIR/generated/out/$INSTRUMENTATION.sv

vlog -64 -suppress 7061 -suppress 2583 -suppress 8386 -suppress 13314 -suppress 7063 -sv -work $LIB -ccflags '-std=c++14' -sv $SV_TOP
vlog -64 -suppress 7061 -suppress 2583 -suppress 8386 -suppress 13314 -suppress 7034 -suppress 7063 -sv -work $LIB -ccflags '-std=c++14' -sv $SV_MEM
vlog -64 -suppress 7061 -suppress 2583 -suppress 8386 -suppress 13314 -suppress 7063 -sv -work $LIB -ccflags '-std=c++14' -sv $SV_TB 

vlog -64 -ccflags '-std=c++14' -work $LIB -dpiheader $HYBRIDIFT_META_COMMON/dv/elf.h $HYBRIDIFT_META_COMMON/dv/elfloader.cc $HYBRIDIFT_META_COMMON/dv/common_functions.cc $HYBRIDIFT_META_COMMON/dv/taintloader.cc

vlog -64 -sv -work $LIB $HYBRIDIFT_META_COMMON/dv/sv/rst_gen.sv $HYBRIDIFT_META_COMMON/dv/sv/clk_rst_gen.sv  $IFT_AXI_TO_MEM $SV_TOP

# Optimize with +acc and -debugdb when tracing.
if { $TRACE != "trace_fst" && $TRACE != "trace" } {
    vopt -64 -sv -work $LIB tb_top -o tb_top_opt
} else {
    vopt -64 -sv +acc -debugdb  -work $LIB tb_top -o tb_top_trace
}

quit -f
