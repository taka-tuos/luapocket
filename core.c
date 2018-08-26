#include "core.h"
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#include <GL/glew.h>
#include <GL/glut.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

SDL_Joystick *joy;

void gfxUpdate(void)
{
	glFlush();
}

void gfxSetView2D(int width, int height)
{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0, width, height, 0, -1, 1);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

void gfxInitialize(int width, int height)
{
	gfxSetView2D(width, height);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glClearColor(0.0, 0.0, 0.0, 1.0);
}

void gfxFramerateAdjust(void)
{
	static unsigned long backtime = 0;
	static int frame = 0;
	long sleeptime;
	if (!backtime) backtime = SDL_GetTicks();
	frame++;
	sleeptime = (frame < FPS) ?
		(backtime + (long)((double)frame*(1000.0 / FPS)) - SDL_GetTicks()) :
		(backtime + 1000 - SDL_GetTicks());
	if (sleeptime > 0)SDL_Delay(sleeptime);
	if (frame >= FPS) {
		frame = 0;
		backtime = SDL_GetTicks();
	}
}

void sysQuitProgram(int code)
{
	Mix_CloseAudio(); 
	SDL_JoystickClose(joy);
	SDL_Quit();
	exit(code);
}

void sysPollEvent(SDL_Event *sdl_event)
{
	if (SDL_PollEvent(sdl_event)) {
		switch (sdl_event->type) {
		case SDL_QUIT:
			sysQuitProgram(0);
		}
	}
}

const int __pow2_list[] = {
	1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536
};

int __return_pow2(int n)
{
	int i;
	for (i = 1; i < 16; i++) {
		if (__pow2_list[i] >= n) return __pow2_list[i];
	}
	return 0;
}

GLuint atlas_texture;
int atlas_w, atlas_h;
float atlas_1dot;

void gfxAtlasInit()
{
	int w,h,dummy;
	unsigned int *pixels = (unsigned int *)stbi_load("atlas.png", &w, &h, &dummy, 4);
	
	atlas_w = w;
	atlas_h = h;
	
	atlas_1dot = 1.0f / (float)w;
	
	glGenTextures(1, &atlas_texture);
	
	glBindTexture(GL_TEXTURE_2D, atlas_texture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
	glEnable(GL_TEXTURE_2D);
}

int gfxDrawRect(lua_State *L) {
	int x = lua_tonumber(L, 1);
	int y = lua_tonumber(L, 2);
	int ud = lua_tonumber(L, 3);
	int vd = lua_tonumber(L, 4);
	int wd = lua_tonumber(L, 5);
	int hd = lua_tonumber(L, 6);
	
	float u = atlas_1dot * (float)ud;
	float v = atlas_1dot * (float)vd;
	float w = atlas_1dot * (float)wd;
	float h = atlas_1dot * (float)hd;
	
	glBindTexture(GL_TEXTURE_2D, atlas_texture);
	glBegin(GL_QUADS);
	glTexCoord2f(u    , v    ); glVertex2f(x     , y     );
	glTexCoord2f(u    , v + h);	glVertex2f(x     , y + hd);
	glTexCoord2f(u + w, v + h);	glVertex2f(x + wd, y + hd);
	glTexCoord2f(u + w, v    );	glVertex2f(x + wd, y     );
	glEnd();

	return 0;
}

int main(int argc, char *argv[])
{
	SDL_Event sdl_event;
	SDL_Surface *sdl_screen;

	SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK | SDL_INIT_AUDIO);
	
	const SDL_VideoInfo* info = NULL;
	int width = 0;
	int height = 0;
	int bpp = 0;
	int flags = 0;

	if(SDL_Init(SDL_INIT_VIDEO) < 0) {
		/* Failed, exit. */
		fprintf(stderr, "Video initialization failed: %s\n",
			 SDL_GetError());
		sysQuitProgram(1);
	}

	info = SDL_GetVideoInfo();

	if(!info) {
		fprintf(stderr, "Video query failed: %s\n",
			 SDL_GetError());
		sysQuitProgram(1);
	}

	width = 240;
	height = 160;
	bpp = info->vfmt->BitsPerPixel;

	SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 0);

	flags = SDL_OPENGL;

	if(SDL_SetVideoMode(width, height, bpp, flags) == 0) {
		fprintf(stderr, "Video mode set failed: %s\n",
			 SDL_GetError());
		sysQuitProgram(1);
	}
	
	glewInit();

	gfxInitialize(width, height);

	sdl_screen = SDL_GetVideoSurface();

	joy = SDL_JoystickOpen(0);
	
	Mix_OpenAudio(11025,AUDIO_U8,2,128); 
	
	gfxAtlasInit();
	
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);
	luaL_loadfile(L, "game.lua");
	lua_pcall(L, 0, 0, 0);
	
	lua_register(L, "gfxDrawRect", &gfxDrawRect);

	while (1) {
		gfxFramerateAdjust();
		Uint8 *key = SDL_GetKeyState(NULL);
		
		glClear(GL_COLOR_BUFFER_BIT);
		
		lua_getglobal(L, "onFrame");
		lua_pcall(L, 0, 0, 0);
		
		gfxUpdate();

		sysPollEvent(&sdl_event);
	}

	sysQuitProgram(0);

	return 0;
}

