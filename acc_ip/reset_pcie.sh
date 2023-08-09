echo "Unload XDMA module"
rmmod /tools/xdma/xdma.ko
sleep 1
#echo "reset pcie device"
#echo '1' > /sys/bus/pci/devices/0000:01:00.0/reset
#sleep 1
echo "remove pcie device"
echo '1' > /sys/bus/pci/devices/0000:01:00.0/remove
sleep 1
echo "rescan pcie bus"
echo '1' > /sys/bus/pci/rescan
sleep 1
echo "load XDMA module"
/tools/xdma/load_driver.sh
sleep 1
