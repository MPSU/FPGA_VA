#include "fpga_acc.h"

std::chrono::_V2::steady_clock::time_point start;

extern std::unique_ptr<uint8_t[], decltype(&delete_aligned)> write_buffer, read_buffer;
extern std::unique_ptr<int, decltype(&close_pcie_node)> read_fd, write_fd;

extern "C"{

void init_timer()
{
  start = std::chrono::steady_clock::now();
}

void print_time(const unsigned long long cntr)
{
  auto end = std::chrono::steady_clock::now();
  std::cout << cntr/ 1e3 / std::chrono::duration<double>(end - start).count() << " kHz";
}

void get_fpga_acc(const svBitVecVal *sig_in,
                             const unsigned long long arr_size_in,
                             const unsigned long long arr_size_out,
                             svBitVecVal *sig_out)
{
  using namespace std;
  memcpy(write_buffer.get(), sig_in, arr_size_in);
  streaming_write(*write_fd, write_buffer.get(), arr_size_out);
  streaming_read(*read_fd, read_buffer.get(), arr_size_in);
  memcpy(sig_out, read_buffer.get(), arr_size_out);
}

}