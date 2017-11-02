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

// ��������
// D�������ά��ϵ��
// iDim��ѹջʱ����ǰ�ǵڼ�ά
// indexList����������ʱ�õľ����±������б�
// it��ָ��indexList�����ڱ���indexList
// varType��matlab��������
void pushMatrix2LuaFromMxArray2(lua_State *L, mxArray *mx, const MATRIXDIMENSION &D, size_t iDim,
	const MATRIXINDEXLIST &indexList, ConstIteratorOfIndexList &it, const string &varType);

// 
void pushStruct2LuaFromMxArray(lua_State *L, mxArray *mx, int mLineIndex);
