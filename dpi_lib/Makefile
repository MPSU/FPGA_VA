name 								= fpga_acc
interface_lib				= pcie
interface_lib_path	= interface_libs/pcie
ifdef interface_lib
interface_shared_lib = lib$(interface_lib).so
link_option = -L$(interface_lib_path) -l$(interface_lib)
endif

CPP_FLAGS			:= -std=c++17 -pthread -fPIC -g -Bsymbolic

.PHONY: clean all

all: lib$(name).so

$(interface_lib_path)/$(interface_shared_lib):
	$(MAKE) -C $(interface_lib_path) $(interface_shared_lib)

libpcie.so: $(interface_lib_path)/src/pcie_host_tranceiver.cpp
	$(MAKE) -C $(interface_lib_path) $@


lib$(name).so: $(name).cpp libpcie.so
# "$<" means first prerequisite
# "$@" means target filename
	g++ $< -fPIC -shared  $(link_option) -o $@

clean:
	$(RM) lib$(name).so