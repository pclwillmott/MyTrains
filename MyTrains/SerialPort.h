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

int openSerialPort(
  const char *path,
  speed_t baudRate,
  int numberOfDataBits,
  int numberOfStopBits,
  int parity,
  int usesRTSCTSFlowControl
);

void closeSerialPort(int fd);

ssize_t readSerialPort(int fd, unsigned char *buffer, ssize_t nbyte);

ssize_t writeSerialPort(int fd, unsigned char *buffer, ssize_t nbyte);

#endif /* SerialPort_h */
