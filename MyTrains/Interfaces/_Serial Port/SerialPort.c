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
#include <sys/types.h>
#include <time.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/serial/ioss.h>
#include <IOKit/IOBSD.h>

// Given the path to a serial device, open the device and configure it.
// Return the file descriptor associated with the device.

int openSerialPort(const char *path)
{

  int fd = -1;

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

  /*
  if (fcntl(fd, F_SETFL, 0) == -1) {
      printf("Error clearing O_NONBLOCK %s - %s(%d).\n", path, strerror(errno), errno);
      goto error;
  }
  */
  
  // Success

  return fd;

  // Failure path

error:

  if (fd != -1) {
    close(fd);
  }

  return -1;

}

int setSerialPortOptions(
  int fd,
  speed_t baudRate,
  int numberOfDataBits,
  int numberOfStopBits,
  int parity,
  int usesRTSCTSFlowControl
)
{

  struct termios options;

  // Get the current options.

  if (tcgetattr(fd, &options) == -1) {
    goto error;
  }

  // The serial port attributes such as timeouts and baud rate are set by modifying the termios structure and then calling tcsetattr() to cause the changes to take effect. Note that the changes will not become effective without the tcsetattr() call.

  // See tcsetattr(4) <x-man-page://4/tcsetattr> for details.

  // Set raw input (non-canonical) mode, with reads blocking until either a single character has been received or a one second timeout expires.

  // See tcsetattr(4) <x-man-page://4/tcsetattr> and termios(4) <x-man-page://4/termios> for details.

  cfmakeraw(&options);

  // Return as many as you can without waiting
  
  options.c_cc[VMIN] = 0;
  options.c_cc[VTIME] = 0;

  // The baud rate, word length, and handshake options can be set as follows:
  
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
    goto error;
  }

  // Cause the new options to take effect immediately.

  if (tcsetattr(fd, TCSANOW, &options) == -1) {
      goto error;
  }

  unsigned long mics = 1UL;

  // Set the receive latency in microseconds. Serial drivers use this value to determine how often to dequeue characters received by the hardware. Most applications don't need to set this value: if an app reads lines of characters, the app can't do anything until the line termination character has been received anyway. The most common applications which are sensitive to read latency are MIDI and IrDA applications.

  // set latency to 1 microsecond

  if (ioctl(fd, IOSSDATALAT, &mics) == -1) {
    goto error;
  }

  // Success

  return 0;

  // Failure path

error:

  return -1;
  
}

int getSerialPortOptions(
  int fd,
  speed_t *baudRate,
  int *numberOfDataBits,
  int *numberOfStopBits,
  int *parity,
  int *usesRTSCTSFlowControl
)
{

  struct termios options;

  // Get the current options.

  if (tcgetattr(fd, &options) == -1) {
    goto error;
  }

  // The serial port attributes such as timeouts and baud rate are set by modifying the termios structure and then calling tcsetattr() to cause the changes to take effect. Note that the changes will not become effective without the tcsetattr() call.

  // See tcsetattr(4) <x-man-page://4/tcsetattr> for details.

  // Set raw input (non-canonical) mode, with reads blocking until either a single character has been received or a one second timeout expires.

  // See tcsetattr(4) <x-man-page://4/tcsetattr> and termios(4) <x-man-page://4/termios> for details.

  cfmakeraw(&options);

  // The baud rate, word length, and handshake options can be got as follows:
  
  switch (options.c_cflag & CSIZE) {
    case CS5:
      *numberOfDataBits = 5;
      break;
    case CS6:
      *numberOfDataBits = 6;
      break;
    case CS7:
      *numberOfDataBits = 7;
      break;
    default:
      *numberOfDataBits = 8;
      break;
  }
  
  *numberOfStopBits = (options.c_cflag & CSTOPB) ? 2 : 1;

  *usesRTSCTSFlowControl = (options.c_cflag & CRTSCTS) == CRTSCTS ? 1 : 0;
  
  if ((options.c_cflag & (PARENB | PARODD)) == (PARENB | PARODD)) {
    *parity = 2;
  }
  else if ((options.c_cflag & (PARENB)) == (PARENB)) {
    *parity = 1;
  }
  else {
    *parity = 0;
  }
  
  *baudRate = cfgetispeed(&options);

  // Success

  return 0;

  // Failure path

error:

  return -1;
  
}

void closeSerialPort(int fd)
{
  if (fd != -1) {
    close(fd);
  }
}

ssize_t readSerialPort(int fd, unsigned char *buffer, ssize_t nbyte) {
  
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

ssize_t writeSerialPort(int fd, unsigned char *buffer, ssize_t nbyte) {
  return write(fd, buffer, nbyte);
}

// Returns an iterator across all known modems. Caller is responsible for releasing the iterator when iteration is complete.

static kern_return_t findModems(io_iterator_t *matchingServices)
{

  kern_return_t           kernResult;

  CFMutableDictionaryRef  classesToMatch;

  // Serial devices are instances of class IOSerialBSDClient.

  // Create a matching dictionary to find those instances.

  classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);

  if (classesToMatch == NULL) {
    printf("IOServiceMatching returned a NULL dictionary.\n");
  }

  else {

    // Look for devices that claim to be modems.

    CFDictionarySetValue(classesToMatch,
                         CFSTR(kIOSerialBSDTypeKey),
                         CFSTR(kIOSerialBSDModemType));


    // Each serial device object has a property with key kIOSerialBSDTypeKey and a value that is one of kIOSerialBSDAllTypes, kIOSerialBSDModemType, or kIOSerialBSDRS232Type. You can experiment with the matching by changing the last parameter in the above call to CFDictionarySetValue.

    // As shipped, this sample is only interested in modems, so add this property to the CFDictionary we're matching on. This will find devices that advertise themselves as modems, such as built-in and USB modems. However, this match won't find serial modems.

  }

  // Get an iterator across all matching devices.

  kernResult = IOServiceGetMatchingServices(kIOMainPortDefault, classesToMatch, matchingServices);

  if (KERN_SUCCESS != kernResult) {
    printf("IOServiceGetMatchingServices returned %d\n", kernResult);
    goto exit;
  }

exit:

  return kernResult;

}

// Given an iterator across a set of modems, return the BSD path to the first one with the callout device path matching MATCH_PATH if defined. If MATCH_PATH is not defined, return the first device found. If no modems are found the path name is set to an empty string.

static kern_return_t getModemPath(io_iterator_t serialPortIterator, char *bsdPath, CFIndex maxPathSize)
{

  io_object_t     modemService;

  kern_return_t   kernResult = KERN_FAILURE;

  extern int serialPortCount;
  
  extern char ** serialPortPaths;

  // Initialize the returned path

  *bsdPath = '\0';

  // Iterate across all modems found. In this example, we bail after finding the first modem.

  clearSerialPorts();
  
  while ((modemService = IOIteratorNext(serialPortIterator))) {

    CFTypeRef   bsdPathAsCFString;

    // Get the callout device's path (/dev/cu.xxxxx). The callout device should almost always be used: the dialin device (/dev/tty.xxxxx) would be used when monitoring a serial port for incoming calls, e.g. a fax listener.

    bsdPathAsCFString = IORegistryEntryCreateCFProperty(modemService, CFSTR(kIOCalloutDeviceKey), kCFAllocatorDefault, 0);
  //  bsdPathAsCFString = IORegistryEntryCreateCFProperty(modemService, CFSTR(kIODialinDeviceKey), kCFAllocatorDefault, 0);

    if (bsdPathAsCFString) {

      Boolean result;

      // Convert the path from a CFString to a C (NUL-terminated) string for use with the POSIX open() call.

      result = CFStringGetCString(bsdPathAsCFString, bsdPath, maxPathSize, kCFStringEncodingUTF8);

      CFRelease(bsdPathAsCFString);

#ifdef MATCH_PATH
      if (strncmp(bsdPath, MATCH_PATH, strlen(MATCH_PATH)) != 0) {
        result = false;
      }
#endif

      if (result) {
        
        serialPortCount++;
        
        if (serialPortPaths == NULL) {
          serialPortPaths = (char **) malloc(sizeof(char *) * serialPortCount);
        }
        else {
          serialPortPaths = (char **) realloc(serialPortPaths, sizeof(char *) * serialPortCount);
        }
        
        char *new = malloc(strlen(bsdPath)+1);
        
        strcpy(new, bsdPath);
        
        serialPortPaths[serialPortCount-1] = new;
        
  //      printf("Modem found with BSD path: %s", bsdPath);
        kernResult = KERN_SUCCESS;
      }

    }

//    printf("\n");

    // Release the io_service_t now that we are done with it.

    (void) IOObjectRelease(modemService);

  }

  return kernResult;

}

char **serialPortPaths = NULL;

int serialPortCount = 0;

void clearSerialPorts(void) {
  
  serialPortCount = 0;
  
  if (serialPortPaths != NULL) {
    for (int i=0; i<serialPortCount; i++) {
      free(serialPortPaths[i]);
    }
    free(serialPortPaths);
    serialPortPaths = NULL;
  }
  
}

int findSerialPorts(void) {
  
//  serialPortCount = 0;
  
  kern_return_t   kernResult;

  io_iterator_t   serialPortIterator;

  char            bsdPath[MAXPATHLEN];

  kernResult = findModems(&serialPortIterator);

  if (KERN_SUCCESS != kernResult) {
//    printf("No modems were found.\n");
  }
  
  kernResult = getModemPath(serialPortIterator, bsdPath, sizeof(bsdPath));

  if (KERN_SUCCESS != kernResult) {
//    printf("Could not get path for modem.\n");
  }

  IOObjectRelease(serialPortIterator);    // Release the iterator.
  
  return serialPortCount;

}

char * getSerialPortPath(int index) {
  if (index < 0 || index >= serialPortCount) {
    return NULL;
  }
  return serialPortPaths[index];
}

uint16_t my_rand (void) {
//  my_Randseed = my_Randseed * 1103515245UL + 12345UL;
//  return ((uint16_t)(my_Randseed >> 16) & MY_RAND_MAX);
  
  UInt32 t = my_Randseed;

  t ^= t >> 10;
  t ^= t << 9;
  t ^= t >> 25;

  my_Randseed = t;

  return(t & MY_RAND_MAX);

}

void my_srand (uint16_t seed) {
  my_Randseed = seed | 0x80000000;
}

uint32_t my_Randseed = 0x80000001;

