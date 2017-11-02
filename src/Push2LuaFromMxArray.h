#pragma once

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}
#include "engine.h"
#include "TypeDefine.h"

void push2LuaFromMxArray(lua_State *L, mxArray *mx);

void pushScalar2LuaFromMxArray(lua_State *L, mxArray *mx);


void pushMatrix2LuaFromMxArray(lua_State *L, mxArray *mx);

// 参数解释
// D：矩阵的维度系数
// iDim：压栈时，当前是第几维
// indexList：遍历矩阵时用的矩阵下标索引列表
// it：指向indexList，用于遍历indexList
// varType：matlab变量类型
void pushMatrix2LuaFromMxArray2(lua_State *L, mxArray *mx, const MATRIXDIMENSION &D, size_t iDim,
	const MATRIXINDEXLIST &indexList, ConstIteratorOfIndexList &it, const string &varType);

// 
void pushStruct2LuaFromMxArray(lua_State *L, mxArray *mx, int mLineIndex);
