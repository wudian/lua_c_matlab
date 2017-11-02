#pragma once

#ifdef MATLAB_EXPORTS
	#define MATLAB_API __declspec(dllexport)
#else
	#define MATLAB_API __declspec(dllimport)
#endif

struct lua_State;
extern "C" MATLAB_API int luaopen_matlab(lua_State *L);

