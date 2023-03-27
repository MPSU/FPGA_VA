#pragma once
#include <cstdint>
#include <string>
#include <memory>
#include <iostream>

extern "C" {
  #include "cdev_sgdma.h"
  #include "dma_utils.h"

  #include <fcntl.h>
  #include <getopt.h>
  #include <stdint.h>
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <unistd.h>
  #include <errno.h>
  #include <time.h>

  #include <sys/mman.h>
  #include <sys/stat.h>
  #include <sys/time.h>
  #include <sys/types.h>
  #include <sys/ioctl.h>
}
constexpr size_t RW_MAX_SIZE = 0x7ffff000;

constexpr size_t PCIE_READ_SIZE = 64; // 50<<20 // 50MiB
constexpr size_t PCIE_NUMBER_OF_CHANNELS = 16;
constexpr size_t PCIE_CHANNEL_NUMBER_OF_SHORTS = (PCIE_READ_SIZE / PCIE_NUMBER_OF_CHANNELS) / 2;

ssize_t streaming_read(const int fpga_fd, uint8_t* const buffer, const size_t size);
ssize_t streaming_write(const int fpga_fd, uint8_t* const buffer, const size_t size);

void delete_aligned(uint8_t* data);
using pcie_buf_ptr = std::unique_ptr<uint8_t[], decltype(&delete_aligned)>;
pcie_buf_ptr allocate_aligned(const size_t size);

void close_pcie_node(int* fd);
using pcie_fd_ptr = std::unique_ptr<int, decltype(&close_pcie_node)>;
pcie_fd_ptr open_pcie_node(std::string dev_name);