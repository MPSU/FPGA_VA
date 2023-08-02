dpi_lib_path  = ../dpi_lib
interface     = pcie
intf_lib_path = ../dpi_lib/interface_libs/$(interface)

.PHONY: prepare compile vsim questasim clean

prepare: ../cad_project
	vlib $</work
	vmap work $</work

../cad_project:
	mkdir -p $@

./work: prepare rtl/inverse.sv tb/tb.sv
	vlog rtl/inverse.sv tb/tb.sv

#"$(@D)" means "directory part of target file"
$(dpi_lib_path)/libfpga_acc.so: $(dpi_lib_path)/fpga_acc.cpp $(intf_lib_path)/src/pcie_host_tranceiver.cpp
	$(MAKE) -C "$(@D)"

vsim: $(dpi_lib_path)/libfpga_acc.so ./work
	vsim -batch -voptargs="+acc=n+/testbench/sig_in+/testbench/sig_out" -sv_lib $(dpi_lib_path)/libfpga_acc -sv_lib $(intf_lib_path)/libpcie testbench

questasim: $(dpi_lib_path)/libfpga_acc.so ./work
	vsim -gui -voptargs="+acc=n+/testbench/sig_in+/testbench/sig_out" -sv_lib $(dpi_lib_path)/libfpga_acc -sv_lib $(intf_lib_path)/libpcie testbench

clean:
	$(RM) -rf ../cad_project/work