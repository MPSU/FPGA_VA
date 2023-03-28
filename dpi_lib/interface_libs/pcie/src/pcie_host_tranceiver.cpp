#include "pcie_host_tranceiver.h"

using namespace std;

pcie_fd_ptr read_fd = open_pcie_node("/dev/xdma0_c2h_0");
pcie_fd_ptr write_fd = open_pcie_node("/dev/xdma0_h2c_0");
pcie_buf_ptr write_buffer = allocate_aligned(128/8);
pcie_buf_ptr read_buffer = allocate_aligned(128/8);

pcie_buf_ptr allocate_aligned(const size_t size)
{
  uint8_t* raw = nullptr;
  posix_memalign((void **)&raw, 4096, size+4096);
  return pcie_buf_ptr{raw, &delete_aligned};
}

void delete_aligned(uint8_t* data)
{
  free(data);
}

pcie_fd_ptr open_pcie_node(string dev_name)
{
  cout << "open_pcie" << endl;
  int* fd = static_cast<int*>(malloc(sizeof(int)));
  *fd = open(dev_name.c_str(), O_RDWR);
  printf("%d\n", *fd);
  return pcie_fd_ptr{fd, &close_pcie_node};
}

void close_pcie_node(int* fd)
{
  close(*fd);
  free(fd);
  cout << "gracefully close pcie node" << endl;
}

ssize_t streaming_read(const int fpga_fd, uint8_t* const buffer, const size_t size)
{
#ifdef DEBUG
  cout << "start reading" << endl;
#endif
  ssize_t rc;
  ssize_t count = 0;
  uint8_t looped = 0;

  while (count < size)
  {
    size_t bytes = size - count;

    if (bytes > RW_MAX_SIZE)
      bytes = RW_MAX_SIZE;

    /* read data from file into memory buffer */
    rc = read(fpga_fd, buffer, bytes);
    if (rc < 0)
    {
      cout << "failed to read from fd=" << fpga_fd <<":0x" << rc << endl;
      perror("read file");
      return -EIO;
    }

    count += rc;
    if (rc != bytes)
    {
      cout << "fd=" << fpga_fd << ", read " << rc << "out of " << bytes << " bytes" << endl;
      break;
    }
    looped = 1;
  }

  if (count != size && looped)
    cout << "fd=" << fpga_fd << ", read underflow " << count << "/" << size << endl;
  return count;
}

ssize_t streaming_write(const int fpga_fd, uint8_t* const buffer, const size_t size)
{
#ifdef DEBUG
  cout << "start writing" << endl;
#endif
  ssize_t rc;
  ssize_t count  = 0;
  uint8_t looped = 0;

  while (count < size)
  {
    size_t bytes = size - count;

    if (bytes > RW_MAX_SIZE)
        bytes = RW_MAX_SIZE;

    /* read data from file into memory buffer */
    rc = write(fpga_fd, buffer, bytes);
    if (rc < 0)
    {
        cout << "failed to write to fd=" << fpga_fd << ":0x" << rc << endl;
        perror("write file");
        return -EIO;
    }

    count += rc;
    if (rc != bytes)
    {
        cout << "fd=" << fpga_fd << ", wrote " << rc << "out of " << bytes << " bytes" << endl;
        break;
    }
    looped = 1;
  }

  if (count != size && looped)
    cout << "fd=" << fpga_fd << ", write underflow " << count << "/" << size << endl;
  return count;
}