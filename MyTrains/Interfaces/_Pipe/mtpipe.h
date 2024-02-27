//
//  mtpipe.h
//  MyTrains
//
//  Created by Paul Willmott on 17/02/2024.
//

#ifndef mtpipe_h
#define mtpipe_h

#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>

int createPipe(const char *);

int openWritePipe(const char *);

int openReadPipe(const char *);

ssize_t readPipe(int fd, unsigned char *buffer, ssize_t nbyte);

ssize_t writePipe(int fd, unsigned char *buffer, ssize_t nbyte);

void closePipe(int fd);

int pipebufsize(void);

#endif /* mtpipe_h */
