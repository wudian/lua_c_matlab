#include <vector>
#include <string>
#include "HelpFunction.h"
#include "SmartPointer.h"
#include "createMxArrayFromLua.h"

using namespace std;

extern Engine* g_MatlabEngine;


// 矩阵位于lua栈的顶端
bool getMatrixAttribute(lua_State *L, int &T, MATRIXDIMENSION &D)
{
	if (LUA_TTABLE != lua_type(L, -1))
		return false;

	while (LUA_TTABLE == lua_type(L, -1)) {
		if (0 == lua_objlen(L, -1)) // 空table
			break;
		D.push_back(lua_objlen(L, -1));
		lua_pushnil(L);
		lua_next(L, -2);
	}

	if (D.size() > 0) {
		T = lua_type(L, -1);
		lua_pop(L, static_cast<int>(2*D.size()));
	}

	if (LUA_TBOOLEAN!=T && LUA_TNUMBER!=T && LUA_TSTRING!=T)
		return false;
	else
		return true;
}

bool setMatrixMxArrayFromLuaStack(lua_State *L, const int &T, const MATRIXDIMENSION &D, mxArray *matrixMxArray)
{
	MATRIXINDEXLIST indexlist;
	getIndexList(D, indexlist);
	ConstIteratorOfIndexList it = indexlist.begin();
	return setMatrixMxArrayFromLuaStack2(L, T, D, 1, indexlist, it, matrixMxArray);
}

bool setMatrixMxArrayFromLuaStack2(lua_State *L, const int &T, const MATRIXDIMENSION &D, mwSize d,
	const MATRIXINDEXLIST &indexList, ConstIteratorOfIndexList &it, mxArray *matrixMxArray)
{
	int type = lua_type(L, -1);
	if (LUA_TTABLE == type) {
		if (d-1>=D.size() || D[d-1]!=lua_objlen(L, -1))
			return false;
		int t = lua_gettop(L);
		lua_pushnil(L);
		while (lua_next(L, t) != 0) {
			if (lua_type(L, -2) != LUA_TNUMBER)
				return false;
			if (!setMatrixMxArrayFromLuaStack2(L, T, D, d+1, indexList, it, matrixMxArray))
				return false;
			lua_pop(L, 1);
		}
	}
	else {
		if (type != T)
			return false;
		if (indexList.end() == it)
			return false;
		SmartPointerMwSize subs(*it); // mwIndex 数组的索引
		mwIndex mLinIdx = mxCalcSingleSubscript(matrixMxArray, it->size(), subs);
		switch (T) {
		case LUA_TNUMBER:
			((double*)mxGetData(matrixMxArray))[mLinIdx] = lua_tonumber(L, -1);
			break;
		case LUA_TBOOLEAN:
			{
				mxLogical v = false;
				if (lua_toboolean(L, -1))
					v = true;
				((bool*)mxGetData(matrixMxArray))[mLinIdx] = v;
			}
			break;
		case LUA_TSTRING:
			{
				mxArray *mx = NULL;
				if (!createCharMxArrayFromLua(L, mx))
					return false;
				
				mxSetCell(matrixMxArray, mLinIdx, mx);
			}
			break;
		default:
			return false;
		}

		++it;
	}

	return true;
}

void getIndexList(const MATRIXDIMENSION &dimensions, MATRIXINDEXLIST &indexList)
{
	MATRIXINDEX vecEx;
	mwSize temp = 1;
	MATRIXINDEX::const_reverse_iterator it;
	for(it = dimensions.rbegin(); it != dimensions.rend();	++it) {
		temp *= *it;
		vecEx.push_back(temp);
	}

	mwSize nums = vecEx.back();
	vecEx.pop_back();
	for(mwSize i=0; i<nums; ++i) {
		MATRIXINDEX in;
		mwSize last = i;
		for (it = vecEx.rbegin();	it != vecEx.rend();	++it) {
			in.push_back(last/ *it);
			last %= *it;
		}

		in.push_back(last);
		indexList.push_back(in);
	}
}

double getDoubleFromMatlabNumeric(const mxArray* mx, mwIndex i)
{
	switch (mxGetClassID(mx)) {
	case mxDOUBLE_CLASS:
		return ((double*)mxGetData(mx))[i];
	case mxSINGLE_CLASS:
		return ((float*)mxGetData(mx))[i];
	case mxINT8_CLASS:
		return ((signed char*)mxGetData(mx))[i];
	case mxUINT8_CLASS:
		return ((unsigned char*)mxGetData(mx))[i];
	case mxINT16_CLASS:
		return ((short int*)mxGetData(mx))[i];
	case mxUINT16_CLASS:
		return ((unsigned short int*)mxGetData(mx))[i];
	case mxINT32_CLASS:
		return ((int*)mxGetData(mx))[i];
	case mxUINT32_CLASS:
		return ((size_t*)mxGetData(mx))[i];
	case mxINT64_CLASS:
		return (double)(((int64_T*)mxGetData(mx))[i]);
	case mxUINT64_CLASS:
		return (double)(((uint64_T*)mxGetData(mx))[i]);
	default:
		return 0.;
	}
}

bool callMatlabScript(const char *mScript)
{
	string _mScript = (string)"clear temp_exp;\r\n" + "try \r\n"
		+ mScript + "\r\n catch temp_exp \r\n temp_exp \r\n end";
	if (0 != engEvalString(g_MatlabEngine, _mScript.c_str()))
		return false;

	SmartPointerMxArray mx = engGetVariable(g_MatlabEngine, "temp_exp");
	if (!mx.isMxArrayNull()) {
		engEvalString(g_MatlabEngine, "clear temp_exp;");
		return false;
	}

	return true;
}