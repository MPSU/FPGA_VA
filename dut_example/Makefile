
.PHONY: prepare compile vsim questasim

prepare:
	vlib ../cad_project/work
	vmap work ../cad_project/work

./work: prepare rtl/inverse.sv tb/tb.sv
	vlog rtl/inverse.sv tb/tb.sv

../dpi_lib/libfpga_acc.so: ../dpi_lib/fpga_acc.cpp
	$(MAKE) -C ../dpi_lib

vsim: ../dpi_lib/libfpga_acc.so questacmnds.cmd ./work
	vsim -batch -sv_lib ../dpi_lib/interface_libs/pcie/libpcie -sv_lib ../dpi_lib/libfpga_acc testbench

questasim: ../dpi_lib/libfpga_acc.so questacmnds.cmd ./work
	vsim -gui -sv_lib ../dpi_lib/interface_libs/pcie/libpcie -sv_lib ../dpi_lib/libfpga_acc testbench