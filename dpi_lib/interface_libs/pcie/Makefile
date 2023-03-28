XDMA_DIR			:= ./submodules/pcie_drivers/XDMA/linux-kernel/xdma/
INC_DIRS			:= ./inc $(XDMA_DIR)
LIB_SUFFIX		:= so
COMPILER			:= g++
SOURCE_SUFFIX	:= cpp
CPP_FLAGS			:= -std=c++17 -fPIC #-DDEBUG
PCIE_LIBS			:= pcie

libpcie.so: src/pcie_host_tranceiver.cpp inc/pcie_host_tranceiver.h
# "$<" means first prerequisite
# "$@" means target filename
	g++ -shared $(CPP_FLAGS) $(addprefix -I,$(INC_DIRS)) $< -o $@