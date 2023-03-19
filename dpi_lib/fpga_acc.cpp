#include "fpga_acc.h"

extern std::unique_ptr<uint8_t[]> write_buffer, read_buffer;
extern std::unique_ptr<int> read_fd, write_fd;

extern "C" void get_fpga_acc( const svOpenArrayHandle sig_in,
                              const unsigned long long arr_size_in,
                              const unsigned long long arr_size_out,
                                    svOpenArrayHandle sig_out)
{
  using namespace std;
  memcpy(write_buffer.get(), svGetArrayPtr(sig_in), arr_size_in);

  streaming_read(*read_fd, read_buffer.get(), arr_size_in);
  streaming_write(*write_fd, write_buffer.get(), arr_size_out);

  memcpy(svGetArrayPtr(sig_out), read_buffer.get(), arr_size_out);
}
