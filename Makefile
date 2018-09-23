TARGET		= luapocket
OBJS_TARGET	= core.o

CFLAGS += -O2 -g -std=gnu99 `sdl-config --cflags` `pkg-config lua51 --cflags` -pipe
LIBS += `sdl-config --libs` `pkg-config lua51 --libs` -lm -lc -lGL -lGLU -lglut -lGLEW -lSDL_mixer -pipe

include Makefile.in
