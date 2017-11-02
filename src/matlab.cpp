extern "C" {
	#include "lua.h"
	#include "lualib.h"
	#include "lauxlib.h"
}
#include <string>
#include <engine.h>
#include "matlab.h"
#include "SmartPointer.h"
#include "TypeDefine.h"
#include "createMxArrayFromLua.h"
#include "Push2LuaFromMxArray.h"
#include "HelpFunction.h"

using namespace std;

// global
Engine* g_MatlabEngine = NULL;

static int lua_StartMATLAB(lua_State *L)
{
	bool visiable = true; // 默认值
	if (0 == lua_toboolean(L, 1))
		visiable = false;

	g_MatlabEngine = engOpen(NULL); // 开启引擎
	if (NULL == g_MatlabEngine) { // 开启引擎失败
		lua_pushboolean(L, 0);
		return 1;
	}

	if (0 != engSetVisible(g_MatlabEngine, visiable)) { // 设置可视化失败
		lua_pushboolean(L, 0);
		return 1;
	}
		
	lua_pushboolean(L, 1); // 成功
	return 1;
}

static int lua_TerminateMATLAB(lua_State *L)
{
	if (0 == engClose(g_MatlabEngine)) // 关闭引擎成功
		lua_pushboolean(L, 1);
	else // 关闭引擎失败
		lua_pushboolean(L, 0);

	return 1;
}

static int lua_CallMATLAB(lua_State *L)
{
	string mScript = (string)"clear temp_errMsg;\r\n" + "try \r\n" + lua_tostring(L, 1)
		+ "\r\n catch temp_exp \r\n temp_errMsg = temp_exp.message; \r\n end";

	if (0 != engEvalString(g_MatlabEngine, mScript.c_str())) { // 错误出在引擎
		lua_pushboolean(L, 0);
		lua_pushstring(L, "the engine session is no longer running or the engine pointer is invalid or NULL");
		return 2;
	}

	SmartPointerMxArray mx = engGetVariable(g_MatlabEngine, "temp_errMsg");
	if (!mx.isMxArrayNull()) { // 执行脚本时发生错误，并抛出了异常
		char *str = mxArrayToString(mx);
		lua_pushboolean(L, 0);
		lua_pushstring(L, str);
		mxFree(str);
		return 2;
	}

	lua_pushboolean(L, 1); // 成功执行脚本
	return 1;
}

static int lua_GetMATLABVar(lua_State *L)
{
	const char *varName = lua_tostring(L, 1); // 变量名
	// 将sym变量以及cell/struct中的sym变量转换成char。这里的sym2char为程序员自定义的函数，需放在matlab搜索路径中。
	/*string mScript = string(varName)+"=sym2char("+varName+");";
	if (!callMatlabScript(mScript.c_str())) {
		lua_pushnil(L);
		return 1;
	}*/
	
	SmartPointerMxArray mx = engGetVariable(g_MatlabEngine, varName);
	push2LuaFromMxArray(L, mx);
	return 1;
}

static int lua_SetMATLABVar(lua_State *L)
{
	if (NULL == g_MatlabEngine) { // 引擎关闭
		lua_pushnumber(L, E_EngineOff);
		return 1;
	}

	SmartPointerMxArray MxArray;
	if (!createMxArrayFromLua(L, MxArray)) { // 创建mxArray失败
		lua_pushnumber(L, E_createMxArrayFromLua);
		return 1;
	}

	const char *varName = lua_tostring(L, 2); // 获取变量名
	if (0 != engPutVariable(g_MatlabEngine, varName, MxArray)) { // 设置变量到引擎中时失败
		lua_pushnumber(L, E_SetMxArray);
		return 1;
	}

	lua_pushnumber(L, E_None); // 设置变量成功
	return 1;
}

static const struct luaL_Reg myReg[] =
{	
	{"StartMATLAB",		lua_StartMATLAB},
	{"TerminateMATLAB",	lua_TerminateMATLAB},
	{"CallMATLAB",		lua_CallMATLAB},
	{"GetMATLABVar",	lua_GetMATLABVar},
	{"SetMATLABVar",	lua_SetMATLABVar},
	{NULL,				NULL}
};

extern "C" int luaopen_matlab(lua_State *L)
{
	luaL_register(L, "matlab", myReg);
	return 1;
}