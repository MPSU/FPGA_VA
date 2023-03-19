#pragma once
#include "svdpi.h"
#include <stdio.h>  // <- printf/fprintf
#include <stdlib.h> // <- atoi
#include <string.h> // <- memset
#include <iostream>
#include <chrono>
#include <ctime>
#include <memory>
#include <unistd.h>
#include <cstring> // <- memcpy

extern "C" void get_fpga_acc(const svOpenArrayHandle sig_in,
                             const unsigned long long arr_size_in,
                             const unsigned long long arr_size_out,
                             svOpenArrayHandle sig_out);

ssize_t streaming_read(const int fpga_fd, uint8_t *const buffer, const size_t size);
ssize_t streaming_write(const int fpga_fd, uint8_t *const buffer, const size_t size);