//
//  SerialPort.c
//  MyTrains
//
//  Created by Paul Willmott on 19/05/2022.
//

#include "SerialPort.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <paths.h>
#include <termios.h>
#include <sysexits.h>
#include <sys/param.h>
#include <sys/select.h>
#include <sys/time.h>
#include <time.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/serial/ioss.h>
#include <IOKit/IOBSD.h>

// Given the path to a serial device, open the device and configure it.
// Return the file descriptor associated with the device.

int openSerialPort(
  const char *path,
  speed_t baudRate,
  int numberOfDataBits,
  int numberOfStopBits,
  int parity,
  int usesRTSCTSFlowControl
)
{

  int fd = -1;

  int handshake;

  struct termios options;

  // Open the serial port read/write, with no controlling terminal, and don't wait for a connection.

  // The O_NONBLOCK flag also causes subsequent I/O on the device to be non-blocking.

  // See open(2) <x-man-page://2/open> for details.


  if ((fd = open(path, O_RDWR | O_NOCTTY | O_NONBLOCK)) == -1) {
      printf("Error opening serial port %s - %s(%d).\n", path, strerror(errno), errno);
      goto error;
  }

  // Note that open() follows POSIX semantics: multiple open() calls to the same file will succeed unless the TIOCEXCL ioctl is issued. This will prevent additional opens except by root-owned processes.

  // See tty(4) <x-man-page//4/tty> and ioctl(2) <x-man-page//2/ioctl> for details.

  if (ioctl(fd, TIOCEXCL) == -1) {
      printf("Error setting TIOCEXCL on %s - %s(%d).\n", path, strerror(errno), errno);
      goto error;
  }

  // Now that the device is open, clear the O_NONBLOCK flag so subsequent I/O will block.

  // See fcntl(2) <x-man-page//2/fcntl> for details.

  if (fcntl(fd, F_SETFL, 0) == -1) {
      printf("Error clearing O_NONBLOCK %s - %s(%d).\n", path, strerror(errno), errno);
      goto error;
  }

  // Get the current options.

  if (tcgetattr(fd, &options) == -1) {
      printf("Error getting tty attributes %s - %s(%d).\n", path, strerror(errno), errno);
      goto error;
  }

  // The serial port attributes such as timeouts and baud rate are set by modifying the termios structure and then calling tcsetattr() to cause the changes to take effect. Note that the changes will not become effective without the tcsetattr() call.

  // See tcsetattr(4) <x-man-page://4/tcsetattr> for details.

  // Set raw input (non-canonical) mode, with reads blocking until either a single character has been received or a one second timeout expires.

  // See tcsetattr(4) <x-man-page://4/tcsetattr> and termios(4) <x-man-page://4/termios> for details.

  cfmakeraw(&options);

  options.c_cc[VMIN] = 0;
  options.c_cc[VTIME] = 0;

  // The baud rate, word length, and handshake options can be set as follows:

//  cfsetspeed(&options, B19200);       // Set 19200 baud

#if defined eric
#if !defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE)
#define CIGNORE         0x00000001      /* ignore control flags */
#endif
#define CSIZE           0x00000300      /* character size mask */
#define     CS5             0x00000000      /* 5 bits (pseudo) */
#define     CS6             0x00000100      /* 6 bits */
#define     CS7             0x00000200      /* 7 bits */
#define     CS8             0x00000300      /* 8 bits */
#define CSTOPB          0x00000400      /* send 2 stop bits */
#define CREAD           0x00000800      /* enable receiver */
#define PARENB          0x00001000      /* parity enable */
#define PARODD          0x00002000      /* odd parity, else even */
#define HUPCL           0x00004000      /* hang up on last close */
#define CLOCAL          0x00008000      /* ignore modem status lines */
#if !defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE)
#define CCTS_OFLOW      0x00010000      /* CTS flow control of output */
#define CRTSCTS         (CCTS_OFLOW | CRTS_IFLOW)
#define CRTS_IFLOW      0x00020000      /* RTS flow control of input */
#define CDTR_IFLOW      0x00040000      /* DTR flow control of input */
#define CDSR_OFLOW      0x00080000      /* DSR flow control of output */
#define CCAR_OFLOW      0x00100000      /* DCD flow control of output */
#define MDMBUF          0x00100000      /* old name for CCAR_OFLOW */
#endif
#endif
  
  options.c_cflag &= ~(CSIZE | CSTOPB | CREAD | PARENB | PARODD | CRTSCTS);
  
  options.c_cflag |= (CREAD | CLOCAL);
  
  switch (numberOfDataBits) {
    case 5:
      options.c_cflag |= CS5;
      break;
    case 6:
      options.c_cflag |= CS6;
      break;
    case 7:
      options.c_cflag |= CS7;
      break;
    default:
      options.c_cflag |= CS8;
      break;
  }
  
  if (numberOfStopBits == 2) {
    options.c_cflag |= CSTOPB;
  }
  
  if (usesRTSCTSFlowControl) {
    options.c_cflag |= CRTSCTS ;
  }
  
  switch (parity) {
    case 1:
      options.c_cflag |= (PARENB);
      break;
    case 2:
      options.c_cflag |= (PARENB | PARODD);
      break;
    default:
      break;
  }
  
  options.c_lflag &= ~(ICANON | ECHO);
  
  // The IOSSIOSPEED ioctl can be used to set arbitrary baud rates other than those specified by POSIX. The driver for the underlying serial hardware ultimately determines which baud rates can be used. This ioctl sets both the input and output speed.

  speed_t speed = baudRate;

  if (ioctl(fd, IOSSIOSPEED, &speed) == -1) {
      printf("Error calling ioctl(..., IOSSIOSPEED, ...) %s - %s(%d).\n", path, strerror(errno), errno);
  }

  // Cause the new options to take effect immediately.

  if (tcsetattr(fd, TCSANOW, &options) == -1) {
      printf("Error setting tty attributes %s - %s(%d).\n", path, strerror(errno), errno);
      goto error;
  }

  // To set the modem handshake lines, use the following ioctls.

  // See tty(4) <x-man-page//4/tty> and ioctl(2) <x-man-page//2/ioctl> for details.

  
/*
  // Assert Data Terminal Ready (DTR)

  if (ioctl(fd, TIOCSDTR) == -1) {
    printf("Error asserting DTR %s - %s(%d).\n", path, strerror(errno), errno);
  }

  // Clear Data Terminal Ready (DTR)

  if (ioctl(fd, TIOCCDTR) == -1) {
    printf("Error clearing DTR %s - %s(%d).\n", path, strerror(errno), errno);
  }

  // Set the modem lines depending on the bits set in handshake

  handshake = TIOCM_DTR | TIOCM_RTS | TIOCM_CTS | TIOCM_DSR;

  if (ioctl(fd, TIOCMSET, &handshake) == -1) {
      printf("Error setting handshake lines %s - %s(%d).\n", path, strerror(errno), errno);
  }

  // To read the state of the modem lines, use the following ioctl.

  // See tty(4) <x-man-page//4/tty> and ioctl(2) <x-man-page//2/ioctl> for details.

  // Store the state of the modem lines in handshake

  if (ioctl(fd, TIOCMGET, &handshake) == -1) {
    printf("Error getting handshake lines %s - %s(%d).\n", path, strerror(errno), errno);
  }

  printf("Handshake lines currently set to %d\n", handshake);

  */

  unsigned long mics = 1UL;

  // Set the receive latency in microseconds. Serial drivers use this value to determine how often to dequeue characters received by the hardware. Most applications don't need to set this value: if an app reads lines of characters, the app can't do anything until the line termination character has been received anyway. The most common applications which are sensitive to read latency are MIDI and IrDA applications.

  if (ioctl(fd, IOSSDATALAT, &mics) == -1) {

      // set latency to 1 microsecond

      printf("Error setting read latency %s - %s(%d).\n", path, strerror(errno), errno);

      goto error;

  }

  // Success

  return fd;

  // Failure path

error:

  if (fd != -1) {
    close(fd);
  }

  return -1;

}

void closeSerialPort(int fd)
{
  if (fd != -1) {
    close(fd);
  }
}

ssize_t readSerialPort(int fd, unsigned char *buffer, ssize_t nbyte) {
  ssize_t nb = read(fd, buffer, nbyte);
  /*
  if (nb == -1) {
    printf("%i", errno);
  }
   */
  return  nb;
}

ssize_t writeSerialPort(int fd, unsigned char *buffer, ssize_t nbyte) {
  return write(fd, buffer, nbyte);
}

