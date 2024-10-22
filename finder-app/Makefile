#Define cross-compile flag (empty on default)
CROSS_COMPILE ?=

# Set Compiler based on CROSS_COMPILE flag
ifeq ($(CROSS_COMPILE),)
	CC = gcc
	CFLAGS = -Wall -g
else
	CC = $(CROSS_COMPILE)gcc
	CFLAGS = -Wall -g
endif

# Source files and executable name
SRC = writer.c
OBJ = writer.o
EXEC = writer

# The default target
all: $(EXEC)

# Rule to build the executable
$(EXEC): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -o $(EXEC)

# Rule to compile source files into object files
writer.o: writer.c
	$(CC) $(CFLAGS) -c writer.c

# Clean up build files
clean:
	rm -f $(EXEC) $(OBJ)

# Phony targets
.PHONY: all clean