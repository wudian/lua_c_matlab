require "callMATLAB"
_StartMATLAB() --启动matlab engine


--1、赋值 ：把lua变量设置到matlab-------------------------------------------------------

--errno小于0，表示set变量失败，通过_getErrorMsg打印错误信息。否则成功，_getErrorMsg打印‘success’

--a）boolean变量
local booleanVar = true
local errno = _SetMATLABVar('booleanVar', booleanVar)
_SendToUI("", errno)
_SendToUI("", _getErrorMsg(errno))

--b）number变量
local numberVar1 = 100
local errno=_SetMATLABVar('numberVar1', numberVar1)
_SendToUI("", errno)
_SendToUI("", _getErrorMsg(errno))
--NAN
local numberVar2 = 0/0
local errno=_SetMATLABVar('numberVar2', numberVar2)
_SendToUI("", errno)
_SendToUI("", _getErrorMsg(errno))


--c)string变量
local stringVar = 'this is a string'
local errno=_SetMATLABVar('stringVar', stringVar)
_SendToUI("", errno)
_SendToUI("", _getErrorMsg(errno))

--d)任意维数的数值矩阵

local matrixVar1 = {1,2,3,4,5} --1*5
local errno=_SetMATLABVar('matrixVar1', matrixVar1)
_SendToUI("", errno)
_SendToUI("", _getErrorMsg(errno))

local matrixVar2 = {{1},{2},{3},{4},{5}} --5*1
local errno=_SetMATLABVar('matrixVar2', matrixVar2)
_SendToUI("", errno)
_SendToUI("", _getErrorMsg(errno))

local matrixVar3 = {{{1,2,3,4},{5,6,7,8},{9,10,11,12}}, {{13,14,15,16},{17,18,19,20},{21,22,23,24}}} --2*3*4
local errno=_SetMATLABVar('matrixVar3', matrixVar3)
_SendToUI("", errno)
_SendToUI("", _getErrorMsg(errno))


--local matrixVar4 = {a={{1,2,3,4},{5,6,7,8},{9,10,11,12}}, b={{13,14,15,16},{17,18,19,20},{21,22,23,24}}}
--local errno=_SetMATLABVar('matrixVar4', matrixVar4,'struct')
--_SendToUI("", errno)
--_SendToUI("", _getErrorMsg(errno))




--2、 取值：从matlab中获取变量的值--------------------------------------

--a）boolean变量
local booleanRet = _GetMATLABVar('booleanVar')
_SendToUI("", tostring(booleanRet)) --应该打印true

--b）number变量
local numberRet1 = _GetMATLABVar('numberVar1')
_SendToUI("", numberRet1) --应该打印100

local numberRet2 = _GetMATLABVar('numberVar2')
_SendToUI("", numberRet2) --应该打印-1.#IND

--c)string变量
local stringRet = _GetMATLABVar('stringVar')
_SendToUI("", stringRet) --应该打印'this is a string'

--d)任意维数的数值矩阵
local matrixRet1 = _GetMATLABVar('matrixVar1')
_SendToUI("", matrixRet1)--应该打印{ 1, 2, 3, 4, 5 }

local matrixRet2 = _GetMATLABVar('matrixVar2')
_SendToUI("", matrixRet2)--应该打印{ { 1 }, { 2 }, { 3 }, { 4 }, { 5 } }

local matrixRet3 = _GetMATLABVar('matrixVar3')
_SendToUI("", matrixRet3)
--应该打印{ { { 1, 2, 3, 4 }, { 5, 6, 7, 8 }, { 9, 10, 11, 12 } }, { { 13, 14, 15, 16 }, { 17, 18, 19, 20 }, { 21, 22, 23, 24 } } }

--local matrixRet4 = _GetMATLABVar('matrixVar4')
--table.print(matrixRet4)

--4、执行m脚本
if false == _CallMATLAB('x=-5:5; y=4*x+3; plot(x,y);') then
	_SendToUI("", _getErrorMsg())
end


--5、m脚本的执行----------------------------------------------------------------------------

--a)设置matlab工作目录，在工作目录中的m函数、m脚本可被执行
if false==_MATLABAddPath('C:') then
	_SendToUI("", _getErrorMsg())
end

--b)执行工作目录下的任意m脚本,例如执行test.m
if false==_MATLABDoFile('test') then--注意不要包含后缀".m"
	_SendToUI("", _getErrorMsg())
end


--6、调用m函数

--a)matlab自带函数
_LuaDebugger();  --用于开启编辑器调试功能


local ret = _MATLABCallFun('solve', 'x+y=2', 'x-y=3')
if ret[0]<0 then
	_SendToUI("", _getErrorMsg(ret[0]))
else
	_SendToUI("", ret)
end
--应该打印方程的解 { y = "-1/2", x = "5/2" }

ret = _MATLABCallFun('sin', math.pi/2)
if ret[0]<0 then
	_SendToUI("", _getErrorMsg(ret[0]))
else
	_SendToUI("", ret)
end
--应该打印sin(pi)的值1

--b)用户定义的m函数

ret = _MATLABCallFun('userFun1')
if ret[0]<0 then
	_SendToUI("", _getErrorMsg(ret[0]))
else
	_SendToUI("", ret)
end






Tick_stk1 = GetTick("SZ000001.stk");
--SendToUI("",Tick_stk1);




_Save2MAT("c:/bb.mat", 'SZ000001_20130222', Tick_stk1,'struct');














