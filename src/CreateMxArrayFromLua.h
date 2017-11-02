#pragma once

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}
#include "engine.h"
#include "SmartPointer.h"

bool createMxArrayFromLua(lua_State *L, SmartPointerMxArray &MxArray);
bool createMxArrayFromLua(lua_State *L, mxArray *&MxArray);

bool createLogicalMxArrayFromLua(lua_State *L, mxArray *&logicalMxArray);

bool createDoubleMxArrayFromLua(lua_State *L, mxArray *&doubleMxArray);

bool createCharMxArrayFromLua(lua_State *L, mxArray *&charMxArray);

// luaջ�еľ��󲻷��Ϲ淶������رյȾ��ɵ��´���mxArrayʧ��
bool createMatrixMxArrayFromLua(lua_State *L, mxArray *&matrixMxArray);

bool createCellMxArrayFromLua(lua_State *L, mxArray *&cellMxArray);

bool createStructMxArrayFromLua(lua_State *L, mxArray *&structMxArray);