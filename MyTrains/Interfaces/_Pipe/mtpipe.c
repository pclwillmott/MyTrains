//
//  mtpipe.c
//  MyTrains
//
//  Created by Paul Willmott on 17/02/2024.
//

#include "mtpipe.h"
#include <sys/stat.h>
#include <sys/fcntl.h>
#include <errno.h>
#include <strings.h>
#include <limits.h>

int pipebufsize(void) 
{
  return PIPE_BUF;
}

int createPipe(const char *name)
{
  return mkfifo(name, 0x1b6);
}

int openWritePipe(const char *name)
{
  
  int fd = -1;
  
  if ((fd = open(name, O_WRONLY | O_NONBLOCK)) == -1) {
    printf("Error opening pipe %s - %s(%d).\n", name, strerror(errno), errno);
    goto error;
  }
  
  return fd;

error:

  if (fd != -1) {
    close(fd);
  }

  return -1;

}

int openReadPipe(const char *name)
{
  
  int fd = -1;
  
  if ((fd = open(name, O_RDONLY | O_NONBLOCK)) == -1) {
    printf("Error opening pipe %s - %s(%d).\n", name, strerror(errno), errno);
    goto error;
  }
  
  return fd;

error:

  if (fd != -1) {
    close(fd);
  }

  return -1;

}

void closePipe(int fd)
{
  if (fd != -1) {
    close(fd);
  }
}

ssize_t readPipe(int fd, unsigned char *buffer, ssize_t nbyte) {
  
  fd_set  set;
  
  struct timeval timeout;
  
  FD_ZERO (&set);
  FD_SET (fd, &set);
  
  timeout.tv_sec = 1;
  timeout.tv_usec = 0;
  
  // Go to sleep for 1 second or until something arrives
  
  if (select (FD_SETSIZE, &set, NULL, NULL, &timeout)) {
    ssize_t nb = read(fd, buffer, nbyte);
    return  nb;
  }
  
  return 0L;
  
}

ssize_t writePipe(int fd, unsigned char *buffer, ssize_t nbyte) {
  return write(fd, buffer, nbyte);
}
