#include "pcie_host_tranceiver.h"

using namespace std;

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
  printf("open_pcie\n");
  int* fd = static_cast<int*>(malloc(sizeof(int)));
  // printf("%p\n", fd);
  *fd = open(dev_name.c_str(), O_RDWR);
  printf("%d\n", *fd);
  return pcie_fd_ptr{fd, &close_pcie_node};
}

void close_pcie_node(int* fd)
{
  close(*fd);
  free(fd);
  printf("\ngracefully close pcie node\n");
}

ssize_t streaming_read(const int fpga_fd, uint8_t* const buffer, const size_t size)
{
    perror("start reading\n");
    ssize_t rc;
    ssize_t count  = 0;
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
            fprintf(stderr, "failed to read from fd=%d:0x%lx.\n", fpga_fd, rc);
            perror("read file");
            return -EIO;
        }

        count += rc;
        if (rc != bytes)
        {
            fprintf(stderr,
                    "fd=%d, read 0x%lx out of 0x%lx bytes.\n",
                    fpga_fd,
                    rc,
                    bytes);
            break;
        }
        looped = 1;
  }

  if (count != size && looped)
    fprintf(stderr, "fd=%d, read underflow 0x%lx/0x%lx.\n",
      fpga_fd, count, size);
  return count;
}

ssize_t streaming_write(const int fpga_fd, uint8_t* const buffer, const size_t size)
{
    perror("start writing\n");
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
            fprintf(stderr, "failed to write to fd=%d:0x%lx.\n", fpga_fd, rc);
            perror("write file");
            return -EIO;
        }

        count += rc;
        if (rc != bytes)
        {
            fprintf(stderr,
                    "fd=%d, wrote 0x%lx out of 0x%lx bytes.\n",
                    fpga_fd,
                    rc,
                    bytes);
            break;
        }
        looped = 1;
  }

  if (count != size && looped)
    fprintf(stderr, "fd=%d, write underflow 0x%lx/0x%lx.\n",
      fpga_fd, count, size);
  return count;
}