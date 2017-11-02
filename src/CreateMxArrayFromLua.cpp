#include <string>
#include "createMxArrayFromLua.h"
#include "HelpFunction.h"

using namespace std;

bool createMxArrayFromLua(lua_State *L, SmartPointerMxArray &MxArray)
{
	mxArray *mx = NULL;
	if (createMxArrayFromLua(L, mx)) {
		MxArray = mx;
		return true;
	}
	else {
		MxArray = mx;
		return false;
	}
}
bool createMxArrayFromLua(lua_State *L, mxArray *&MxArray)
{
	string varType = lua_tostring(L, 1); // 变量类型
	if (varType == "logical")
		return createLogicalMxArrayFromLua(L, MxArray);
	else if (varType == "double")
		return createDoubleMxArrayFromLua(L, MxArray);
	else if (varType == "char")
		return createCharMxArrayFromLua(L, MxArray);
	else if (varType == "matrix")
		return createMatrixMxArrayFromLua(L, MxArray);
	else if (varType == "cell")
		return createCellMxArrayFromLua(L, MxArray);
	else if (varType == "struct")
		return createStructMxArrayFromLua(L, MxArray);
	else
		return false;
}

bool createLogicalMxArrayFromLua(lua_State *L, mxArray *&logicalMxArray)
{
	mxLogical bValue = false;
	if (lua_toboolean(L, -1))
		bValue = true;

	if (logicalMxArray = mxCreateLogicalScalar(bValue))
		return true;
	else
		return false;
}

bool createDoubleMxArrayFromLua(lua_State *L, mxArray *&doubleMxArray)
{
	if (doubleMxArray = mxCreateDoubleScalar(lua_tonumber(L, -1)))
		return true;
	else
		return false;
}

bool createCharMxArrayFromLua(lua_State *L, mxArray *&charMxArray)
{
	if (charMxArray = mxCreateString(lua_tostring(L, -1)))
		return true;
	else
		return false;
}

bool createMatrixMxArrayFromLua(lua_State *L, mxArray *&matrixMxArray)
{
	int matrixType = LUA_TNUMBER; // 矩阵中元素的类型
	MATRIXDIMENSION matrixD; // 矩阵的维度
	if (!getMatrixAttribute(L, matrixType, matrixD))
		return false;

	mwSize ndim = matrixD.size();
	if (0 == ndim) { // 空矩阵
		mwSize dimensions[2] = {0,0};
		if (LUA_TBOOLEAN == matrixType)
			matrixMxArray = mxCreateLogicalArray(0, dimensions);
		else if (LUA_TNUMBER == matrixType)
			matrixMxArray = mxCreateNumericArray(0, dimensions, mxDOUBLE_CLASS, mxREAL);
		else if (LUA_TSTRING == matrixType)
			matrixMxArray = mxCreateCellArray(0, dimensions);
		else
			return false;
		return true; // 空矩阵直接返回
	}
	else if (1 == ndim) {
		if (matrixD[0] == 0) { // 空矩阵
			mwSize dimensions[2] = {0,0};
			if (LUA_TBOOLEAN == matrixType)
				matrixMxArray = mxCreateLogicalArray(0, dimensions);
			else if (LUA_TNUMBER == matrixType)
				matrixMxArray = mxCreateNumericArray(0, dimensions, mxDOUBLE_CLASS, mxREAL);
			else if (LUA_TSTRING == matrixType)
				matrixMxArray = mxCreateCellArray(0, dimensions);
			else
				return false;
			return true; // 空矩阵直接返回
		}
		else {
			mwSize dimensions[2] = {1, matrixD[0]}; // 一维的矩阵
			if (LUA_TBOOLEAN == matrixType)
				matrixMxArray = mxCreateLogicalArray(2, dimensions);
			else if (LUA_TNUMBER == matrixType)
				matrixMxArray = mxCreateNumericArray(2, dimensions, mxDOUBLE_CLASS, mxREAL);
			else if (LUA_TSTRING == matrixType) // 将字符串矩阵转成多维的CELL
				matrixMxArray = mxCreateCellArray(2, dimensions);
			else
				return false;
		}
	}
	else {
		SmartPointerMwSize dimensions(matrixD);
		if (LUA_TBOOLEAN == matrixType)
			matrixMxArray = mxCreateLogicalArray(ndim, dimensions);
		else if (LUA_TNUMBER == matrixType)
			matrixMxArray = mxCreateNumericArray(ndim, dimensions, mxDOUBLE_CLASS, mxREAL);
		else if (LUA_TSTRING == matrixType)
			matrixMxArray = mxCreateCellArray(ndim, dimensions);
		else
			return false;
	}

	if (NULL == matrixMxArray) // 创建mxArray失败
		return false;

	// 给mxArray填写值
	if (!setMatrixMxArrayFromLuaStack(L, matrixType, matrixD, matrixMxArray))
		return false;

	return true;
}

bool createCellMxArrayFromLua(lua_State *L, mxArray *&cellMxArray)
{
	mwSize len = lua_objlen(L, -1); // cell的长度
	cellMxArray = mxCreateCellMatrix(1, len); // 创建1*len的cell矩阵
	if (NULL == cellMxArray)
		return false;

	int idx = lua_gettop(L);
	lua_pushnil(L);
	mwIndex i = 0;
	while (lua_next(L, idx) != 0) {
		if (lua_type(L, -2) != LUA_TNUMBER)
			return false;
		if (i >= len)
			return false;

		mxArray *mx = NULL;
		switch (lua_type(L, -1)) {
		case LUA_TBOOLEAN:
			if (!createLogicalMxArrayFromLua(L, mx))
				return false;
			break;
		case LUA_TNUMBER:
			if (!createDoubleMxArrayFromLua(L, mx))
				return false;
			break;
		case LUA_TSTRING:
			if (!createCharMxArrayFromLua(L, mx))
				return false;
			break;
		case LUA_TTABLE: // 矩阵
			if (!createMatrixMxArrayFromLua(L, mx))
				return false;
			break;
		default:
			return false;
		}

		mxSetCell(cellMxArray, i, mx);
		++i;
		lua_pop(L, 1);
	}

	return true;
}

bool createStructMxArrayFromLua(lua_State *L, mxArray *&structMxArray)
{
	structMxArray = mxCreateStructMatrix(1, 1, 0, NULL); // 创建1*1的struct
	if (NULL == structMxArray)
		return false;

	int idx = lua_gettop(L);
	lua_pushnil(L);
	while (lua_next(L, idx) != 0) {
		if (lua_type(L, -2) != LUA_TSTRING)
			return false;

		if (-1 == mxAddField(structMxArray, lua_tostring(L, -2)))
			return false;

		mxArray *mx = NULL;
		switch (lua_type(L, -1)) {
		case LUA_TBOOLEAN:
			if (!createLogicalMxArrayFromLua(L, mx))
				return false;
			break;
		case LUA_TNUMBER:
			if (!createDoubleMxArrayFromLua(L, mx))
				return false;
			break;
		case LUA_TSTRING:
			if (!createCharMxArrayFromLua(L, mx))
				return false;
			break;
		case LUA_TTABLE: // 矩阵或者嵌套struct
			{
				// 先检测是矩阵还是嵌套struct
				lua_pushnil(L);
				if (0 == lua_next(L, -2)) { // 空的table
					if (!createMatrixMxArrayFromLua(L, mx))
						return false;
				}
				else {
					bool alsoStruct = false;
					if (LUA_TSTRING == lua_type(L, -2))
						alsoStruct = true;
					lua_pop(L, 2);
					if (alsoStruct) {
						if (!createStructMxArrayFromLua(L, mx))
							return false;
					}
					else {
						if (!createMatrixMxArrayFromLua(L, mx))
							return false;
					}
				}
			}
			break;
		default:
			return false;
		}

		mxSetField(structMxArray, 0, lua_tostring(L, -2), mx);
		lua_pop(L, 1);
	}

	return true;
}
