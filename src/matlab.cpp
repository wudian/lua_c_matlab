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
	bool visiable = true; // Ĭ��ֵ
	if (0 == lua_toboolean(L, 1))
		visiable = false;

	g_MatlabEngine = engOpen(NULL); // ��������
	if (NULL == g_MatlabEngine) { // ��������ʧ��
		lua_pushboolean(L, 0);
		return 1;
	}

	if (0 != engSetVisible(g_MatlabEngine, visiable)) { // ���ÿ��ӻ�ʧ��
		lua_pushboolean(L, 0);
		return 1;
	}
		
	lua_pushboolean(L, 1); // �ɹ�
	return 1;
}

static int lua_TerminateMATLAB(lua_State *L)
{
	if (0 == engClose(g_MatlabEngine)) // �ر�����ɹ�
		lua_pushboolean(L, 1);
	else // �ر�����ʧ��
		lua_pushboolean(L, 0);

	return 1;
}

static int lua_CallMATLAB(lua_State *L)
{
	string mScript = (string)"clear temp_errMsg;\r\n" + "try \r\n" + lua_tostring(L, 1)
		+ "\r\n catch temp_exp \r\n temp_errMsg = temp_exp.message; \r\n end";

	if (0 != engEvalString(g_MatlabEngine, mScript.c_str())) { // �����������
		lua_pushboolean(L, 0);
		lua_pushstring(L, "the engine session is no longer running or the engine pointer is invalid or NULL");
		return 2;
	}

	SmartPointerMxArray mx = engGetVariable(g_MatlabEngine, "temp_errMsg");
	if (!mx.isMxArrayNull()) { // ִ�нű�ʱ�������󣬲��׳����쳣
		char *str = mxArrayToString(mx);
		lua_pushboolean(L, 0);
		lua_pushstring(L, str);
		mxFree(str);
		return 2;
	}

	lua_pushboolean(L, 1); // �ɹ�ִ�нű�
	return 1;
}

static int lua_GetMATLABVar(lua_State *L)
{
	const char *varName = lua_tostring(L, 1); // ������
	// ��sym�����Լ�cell/struct�е�sym����ת����char�������sym2charΪ����Ա�Զ���ĺ����������matlab����·���С�
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
	if (NULL == g_MatlabEngine) { // ����ر�
		lua_pushnumber(L, E_EngineOff);
		return 1;
	}

	SmartPointerMxArray MxArray;
	if (!createMxArrayFromLua(L, MxArray)) { // ����mxArrayʧ��
		lua_pushnumber(L, E_createMxArrayFromLua);
		return 1;
	}

	const char *varName = lua_tostring(L, 2); // ��ȡ������
	if (0 != engPutVariable(g_MatlabEngine, varName, MxArray)) { // ���ñ�����������ʱʧ��
		lua_pushnumber(L, E_SetMxArray);
		return 1;
	}

	lua_pushnumber(L, E_None); // ���ñ����ɹ�
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