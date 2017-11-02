#pragma once

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

#include "TypeDefine.h"

// ��ȡ�������������T���߼�������ֵ�����ַ������󣩺;����ά����D
bool getMatrixAttribute(lua_State *L, int &T, MATRIXDIMENSION &D);

// ���luaջ�е�matrix������Ҫ����setʧ��
// ������L luaջ�� T ������Ԫ�����ͣ� D �����ά��ϵ���� 
bool setMatrixMxArrayFromLuaStack(lua_State *L, const int &T, const MATRIXDIMENSION &D, mxArray *matrixMxArray);
// ������d ��ǰ�ǵڼ�ά�� indexList ���±���ɵ��������б� it ָ��indexList�ĵ�����
bool setMatrixMxArrayFromLuaStack2(lua_State *L, const int &T, const MATRIXDIMENSION &D, mwSize d,
	const MATRIXINDEXLIST &indexList, ConstIteratorOfIndexList &it, mxArray *matrixMxArray);

void getIndexList(const MATRIXDIMENSION &dimensions, MATRIXINDEXLIST &indexList); // indexList�е�����ĵ������Կ���������˳��

double getDoubleFromMatlabNumeric(const mxArray* mx, mwIndex i);

bool callMatlabScript(const char *mScript);