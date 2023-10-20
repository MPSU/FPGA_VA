#!/bin/bash

# ####################################
# should use after clean installation
# of distro before packages install
# ####################################
sudo apt update && sudo apt upgrade -y
sudo snap refresh
# ####################################


# ####################################
# install prerequesites
# ####################################
sudo apt-get install build-essential git -y
# ####################################


# ####################################
# clone Accelerator repo
# ####################################
cd ~
git clone --recursive git@github.com:MPSU/FPGA_VA.git
# ####################################


# ####################################
# Currently kernel module need a patch
# in order to be built on the latest
# kernels.
# ####################################
wget --output-document=~/xdma.patch https://patch-diff.githubusercontent.com/raw/Xilinx/dma_ip_drivers/pull/238.patch
git apply xdma.patch
# ####################################


# ####################################
# XDMA module can be built simply by
# calling `make` iside xdma folder
# ####################################
cd FPGA_VA/dpi_lib/interface_libs/pcie/submodules/pcie_drivers/XDMA/linux-kernel/xdma
make
# ####################################


# ####################################
# You can also set up module by
# make installing it.
# In that case module will be available
# for modprobe-ing and autoloading it
# ####################################
sudo make install
echo "xdma" | sudo tee -a /etc/modules
# ####################################


# ####################################
# If you prefer to not make install
# module, you still can automatically
# load you module through load_driver
# script placed in:
# XDMA/linux_driver/tests/
# ####################################

# cat <<EOL | sudo tee /etc/systemd/system/xdma.service
# [Unit]
# Description=Load xdma kernel module

# [Service]
# Type=simple
# RemainAfterExit=yes

## Make sure this path is correct one
## and the load_drver.sh script has
## correct path to .ko file
# ExecStart=$HOME/FPGA_VA/dpi_lib/interface_libs/pcie/submodules/pcie_drivers/XDMA/linux-kernel/tests/load_driver.sh
# TimeoutStartSec=0

# [Install]
# WantedBy=default.target
# EOL

# sudo systemctl enable xdma.service

# ####################################

# ####################################
# xdma devices supposed to be belongs
# xdma group, but on a fresh system
# there is no such group which makes
# one to run apps as sudo user.
# In order to fix xdma group should be
# created, user needs to be add to that
# group, and rules described below needs
# to be created:
# ####################################
sudo addgroup xdma
sudo usermod -a -G xdma $USERNAME
echo 'SUBSYSTEM=="xdma" GROUP="xdma"' | sudo tee /etc/udev/rules.d/60-xdma.rules
# ####################################


# ####################################
# After making all ajustments workstation
# should be rebooted
# ####################################
echo "Script has been finished."
echo "You should restart to make changes work."
# ####################################
