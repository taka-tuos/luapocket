TARGET		= luapocket
OBJS_TARGET	= core.o

CFLAGS += -O2 -g -std=gnu99 `sdl-config --cflags`
LIBS += `sdl-config --libs` -lm -lc -lGL -lGLU -lglut -lGLEW -lSDL_mixer

include Makefile.in
