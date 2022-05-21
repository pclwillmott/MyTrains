//
//  SerialPort.h
//  MyTrains
//
//  Created by Paul Willmott on 19/05/2022.
//

#ifndef SerialPort_h
#define SerialPort_h

#include <sys/termios.h>
#include <unistd.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/serial/ioss.h>
#include <IOKit/IOBSD.h>

int openSerialPort(const char *path);

int setSerialPortOptions(
  int fd,
  speed_t baudRate,
  int numberOfDataBits,
  int numberOfStopBits,
  int parity,
  int usesRTSCTSFlowControl
);

int getSerialPortOptions(
  int fd,
  speed_t *baudRate,
  int *numberOfDataBits,
  int *numberOfStopBits,
  int *parity,
  int *usesRTSCTSFlowControl
);

void closeSerialPort(int fd);

ssize_t readSerialPort(int fd, unsigned char *buffer, ssize_t nbyte);

ssize_t writeSerialPort(int fd, unsigned char *buffer, ssize_t nbyte);

static kern_return_t findModems(io_iterator_t *matchingServices);

static kern_return_t getModemPath(io_iterator_t serialPortIterator, char *bsdPath, CFIndex maxPathSize);

void clearSerialPorts(void) ;

char * getSerialPortPath(int);

int findSerialPorts(void);

#endif /* SerialPort_h */
