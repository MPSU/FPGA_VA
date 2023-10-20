# FPGA_VA
Accelerate your verificiation modeling through FPGA

## Host config manual

This manual has been checked on the fresh installed Ubuntu 23.10.

### Update package manager info

```bash
sudo apt update && sudo apt upgrade -y
sudo snap refresh
```

### Install prerequesites

```bash
sudo apt-get install build-essential git -y
```

### Clone Accelerator repo

```bash
git clone --recursive https://github.com/MPSU/FPGA_VA.git $HOME/FPGA_VA
```

### (Optional) patch xdma

Currently kernel module need a patch in order to be built on the latest kernels.

```bash
cd $HOME/FPGA_VA/dpi_lib/interface_libs/pcie/submodules/pcie_drivers
wget --output-document=xdma.patch https://patch-diff.githubusercontent.com/raw/Xilinx/dma_ip_drivers/pull/238.patch
git apply xdma.patch
rm xdma.patch
```

### Build xdma

```bash
cd XDMA/linux-kernel/xdma
make
```

### (Optional) install xdma kernel module

You can set up module by make installing it.
In that case module will be available for modprobe-ing and autoloading it from `/etc/modules` while system startup.

```bash
sudo make install
echo "xdma" | sudo tee -a /etc/modules
```

### (Optional) create systemd service

If you prefer to not make install module, you still can automatically load you module through load_driver
script placed in `XDMA/linux_driver/tests/`. In that case you should create a systemd service:

```bash
cat <<EOL | sudo tee /etc/systemd/system/xdma.service
[Unit]
Description=Load xdma kernel module

[Service]
Type=simple
RemainAfterExit=yes

# Make sure this path is correct one
# and the load_drver.sh script has
# correct path to .ko file
ExecStart=$HOME/FPGA_VA/dpi_lib/interface_libs/pcie/submodules/pcie_drivers/XDMA/linux-kernel/tests/load_driver.sh
TimeoutStartSec=0

[Install]
WantedBy=default.target
EOL

sudo systemctl enable xdma.service
```

### Create xdma group

xdma devices supposed to be belongs `xdma` group, but on a fresh system there is no such group which makes one to run apps as `sudo` user.

In order to fix that, `xdma` group should be created and user needs to be add to that group. Additionaly rules described below needs to be created.

```bash
sudo addgroup xdma
sudo usermod -a -G xdma $USERNAME
echo 'SUBSYSTEM=="xdma" GROUP="xdma"' | sudo tee /etc/udev/rules.d/60-xdma.rules
```

### Reboot

**After making all ajustments, workstation should be rebooted.**
