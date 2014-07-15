# sourced from http://www.cs.colby.edu/maxwell/courses/tutorials/maketutor/

CC=gcc
CFLAGS=-I.
DEPS = cplusplus/hellomake.h
OBJ = cplusplus/hellomake.o cplusplus/hellofunc.o

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

build: $(OBJ)
	gcc -o cplusplus/hellomake $^ $(CFLAGS)

clean:
	rm cplusplus/*.o
	rm cplusplus/hellomake
