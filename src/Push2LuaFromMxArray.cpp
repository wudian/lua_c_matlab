#include <string>
#include "Push2LuaFromMxArray.h"
#include "TypeDefine.h"
#include "HelpFunction.h"
#include "SmartPointer.h"

using namespace std;

void push2LuaFromMxArray(lua_State *L, mxArray *mxObj)
{
	if (NULL == mxObj) // 变量不存在
		lua_pushnil(L);
	else if (0 == mxGetNumberOfElements(mxObj)) // 空的变量
		lua_pushnil(L);
	else if (1 == mxGetNumberOfElements(mxObj)) // 1*1的矩阵
		pushScalar2LuaFromMxArray(L, mxObj);
	else // 矩阵
		pushMatrix2LuaFromMxArray(L, mxObj);
}

void pushScalar2LuaFromMxArray(lua_State *L, mxArray *mx)
{
	string varType;
	if (mxIsNumeric(mx))
		varType = "double";
	else
		varType = mxGetClassName(mx);

	if ("logical" == varType) {
		if (mxIsLogicalScalarTrue(mx))
			lua_pushboolean(L, 1);
		else
			lua_pushboolean(L, 0);
	}
	else if ("double" == varType)
		lua_pushnumber(L, getDoubleFromMatlabNumeric(mx, 0));
	else if ("char" == varType) {
		char *str = mxArrayToString(mx);
		lua_pushstring(L, str);
		mxFree(str);
	}
	else if ("cell" == varType) { // 对于一个1*1的cell，看做只有1个元素的table
		lua_newtable(L);
		lua_pushinteger(L, 1);
		mxArray *mxObj = mxGetCell(mx, 0);
		push2LuaFromMxArray(L, mxObj);
		lua_settable(L, -3);
	}
	else if ("struct" == varType) {
		pushStruct2LuaFromMxArray(L, mx, 0);
	}
	else
		lua_pushnil(L);
}

void pushMatrix2LuaFromMxArray(lua_State *L, mxArray *mx)
{
	mwSize nDimensions = mxGetNumberOfDimensions(mx); //always 2 or greater
	const mwSize *dimensions = mxGetDimensions(mx);
	MATRIXDIMENSION matrixD; // 求出矩阵的维度系数
	if (dimensions[0] > 1)
		matrixD.push_back(dimensions[0]);
	for (mwSize i=1; i<nDimensions; ++i)
		matrixD.push_back(dimensions[i]);

	MATRIXINDEXLIST indexlist; // 求出矩阵的下标索引的列表
	getIndexList(matrixD, indexlist);
	ConstIteratorOfIndexList it = indexlist.begin(); // 准备迭代索引列表

	string varType; // 矩阵中元素的类型
	if (mxIsNumeric(mx))
		varType = "double";
	else
		varType = mxGetClassName(mx);

	pushMatrix2LuaFromMxArray2(L, mx, matrixD, 0, indexlist, it, varType);
}


void pushMatrix2LuaFromMxArray2(lua_State *L, mxArray *mx, const MATRIXDIMENSION &D, size_t iDim,
	const MATRIXINDEXLIST &indexList, ConstIteratorOfIndexList &it, const string &varType)
{
	if ("logical"!=varType && "double"!=varType && "char"!=varType && "cell"!=varType && "struct"!=varType) {
		lua_pushnil(L);
		return;
	}

	// 只支持将1*n的字符矩阵转成lua字符串，其余的均视为nil
	if ("char" == varType) {
		if (D.size()<2 || (D.size()==2 && D[0]==1)) {
			char *str = mxArrayToString(mx);
			lua_pushstring(L, str);
			mxFree(str);
		}
		else
			lua_pushnil(L);
		return;
	}
	else if ("struct" == varType) {
		if (D.size() == 0) { // 空struct
			lua_pushnil(L);
			return;
		}
		else if ((D.size()==1 && D[0]==1) || (D.size()==2 && D[0]==1 && D[2]==1)) { // 1*1的struct
			pushStruct2LuaFromMxArray(L, mx, 0);
			return;
		}
		// 对于非1*1的struct，在下面的代码中做解析
	}

	lua_newtable(L);
	if (D.size()-1 == iDim) {
		for (mwSize i=0; i<D[iDim]; ++i) {
			lua_pushinteger(L, i+1);
			if (it >= indexList.end()) // 异常的情况
				lua_pushnil(L);
			else {
				SmartPointerMwSize subs(*it); // mwIndex 数组的索引
				mwIndex mLinIdx = mxCalcSingleSubscript(mx, it->size(), subs);

				if ("logical" == varType) {
					if (((bool*)mxGetData(mx))[mLinIdx])
						lua_pushboolean(L, 1);
					else
						lua_pushboolean(L, 0);
				}
				else if ("double" == varType)
					lua_pushnumber(L, getDoubleFromMatlabNumeric(mx, mLinIdx));
				else if ("cell" == varType) {
					mxArray *mxObj = mxGetCell(mx, mLinIdx);
					push2LuaFromMxArray(L, mxObj);
				}
				else { // "struct"
					pushStruct2LuaFromMxArray(L, mx, mLinIdx);
				}
			}
			++it;
			lua_settable(L, -3);
		}
		return;
	}

	for (mwSize j=0; j<D[iDim]; ++j) {
		lua_pushinteger(L, j+1);
		pushMatrix2LuaFromMxArray2(L, mx, D, iDim+1, indexList, it, varType);
		lua_settable(L, -3);
	}
}

void pushStruct2LuaFromMxArray(lua_State *L, mxArray *mx, int mLineIndex)
{
	lua_newtable(L);
	int numFields = mxGetNumberOfFields(mx); // struct中域名的数目
	for (int i=0; i<numFields; ++i) {
		const char *fieldName = mxGetFieldNameByNumber(mx, i);
		lua_pushstring(L, fieldName);
		mxArray *mxObj = mxGetFieldByNumber(mx, mLineIndex, i);
		push2LuaFromMxArray(L, mxObj);
		lua_settable(L, -3);
	}
}