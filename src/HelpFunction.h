#pragma once

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

#include "TypeDefine.h"

// 获取矩阵的数据类型T（逻辑矩阵、数值矩阵、字符串矩阵）和矩阵的维度数D
bool getMatrixAttribute(lua_State *L, int &T, MATRIXDIMENSION &D);

// 如果lua栈中的matrix不符合要求，则set失败
// 参数：L lua栈； T 矩阵中元素类型； D 矩阵的维度系数； 
bool setMatrixMxArrayFromLuaStack(lua_State *L, const int &T, const MATRIXDIMENSION &D, mxArray *matrixMxArray);
// 参数：d 当前是第几维； indexList 由下标组成的索引的列表； it 指向indexList的迭代器
bool setMatrixMxArrayFromLuaStack2(lua_State *L, const int &T, const MATRIXDIMENSION &D, mwSize d,
	const MATRIXINDEXLIST &indexList, ConstIteratorOfIndexList &it, mxArray *matrixMxArray);

void getIndexList(const MATRIXDIMENSION &dimensions, MATRIXINDEXLIST &indexList); // indexList中的坐标的递增是以靠右先增的顺序

double getDoubleFromMatlabNumeric(const mxArray* mx, mwIndex i);

bool callMatlabScript(const char *mScript);