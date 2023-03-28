#pragma once
#include "svdpi.h"  // <- DPI header
#include <memory>   // <- smart_pointers
#include <cstring>  // <- memcpy
#include <iostream> // <- cout
#include <chrono>   // <- profiling
/*
From IEEE 1800-2012:

(a chunk of) packed bit array
typedef uint32_t svBitVecVal

*/

extern "C" {
  void init_timer();
  void print_time(const unsigned long long cntr);
  void get_fpga_acc(const svBitVecVal *sig_in,
                    const unsigned long long arr_size_in,
                    const unsigned long long arr_size_out,
                    svBitVecVal *sig_out);
}
void delete_aligned(uint8_t *data);
void close_pcie_node(int *fd);

ssize_t streaming_read(const int fpga_fd, uint8_t *const buffer, const size_t size);
ssize_t streaming_write(const int fpga_fd, uint8_t *const buffer, const size_t size);