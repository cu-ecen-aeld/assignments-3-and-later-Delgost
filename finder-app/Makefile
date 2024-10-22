#Define cross-compile flag (empty on default)
CROSS_COMPILE ?=

# Set Compiler based on CROSS_COMPILE flag
ifeq ($CROSS_COMPILE,)
	CC = gcc
else
	CC = $(CROSS_COMPILE)gcc
endif

# Source files and executable name
SRC = writer.c
OBJ = $(SRC:.c=.o)
EXEC = writer

# The default target
all: $(EXEC)

# Rule to build the executable
$(EXEC): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -o $(EXEC)

# Rule to compile source files into object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean up build files
clean:
	rm -f $(EXEC) $(OBJ)

# Phony targets
.PHONY: all clean