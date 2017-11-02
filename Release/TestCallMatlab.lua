require "callMATLAB"
_StartMATLAB() --����matlab engine


--1����ֵ ����lua�������õ�matlab-------------------------------------------------------

--errnoС��0����ʾset����ʧ�ܣ�ͨ��_getErrorMsg��ӡ������Ϣ������ɹ���_getErrorMsg��ӡ��success��

--a��boolean����
local booleanVar = true
local errno = _SetMATLABVar('booleanVar', booleanVar)
_SendToUI("", errno)
_SendToUI("", _getErrorMsg(errno))

--b��number����
local numberVar1 = 100
local errno=_SetMATLABVar('numberVar1', numberVar1)
_SendToUI("", errno)
_SendToUI("", _getErrorMsg(errno))
--NAN
local numberVar2 = 0/0
local errno=_SetMATLABVar('numberVar2', numberVar2)
_SendToUI("", errno)
_SendToUI("", _getErrorMsg(errno))


--c)string����
local stringVar = 'this is a string'
local errno=_SetMATLABVar('stringVar', stringVar)
_SendToUI("", errno)
_SendToUI("", _getErrorMsg(errno))

--d)����ά������ֵ����

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




--2�� ȡֵ����matlab�л�ȡ������ֵ--------------------------------------

--a��boolean����
local booleanRet = _GetMATLABVar('booleanVar')
_SendToUI("", tostring(booleanRet)) --Ӧ�ô�ӡtrue

--b��number����
local numberRet1 = _GetMATLABVar('numberVar1')
_SendToUI("", numberRet1) --Ӧ�ô�ӡ100

local numberRet2 = _GetMATLABVar('numberVar2')
_SendToUI("", numberRet2) --Ӧ�ô�ӡ-1.#IND

--c)string����
local stringRet = _GetMATLABVar('stringVar')
_SendToUI("", stringRet) --Ӧ�ô�ӡ'this is a string'

--d)����ά������ֵ����
local matrixRet1 = _GetMATLABVar('matrixVar1')
_SendToUI("", matrixRet1)--Ӧ�ô�ӡ{ 1, 2, 3, 4, 5 }

local matrixRet2 = _GetMATLABVar('matrixVar2')
_SendToUI("", matrixRet2)--Ӧ�ô�ӡ{ { 1 }, { 2 }, { 3 }, { 4 }, { 5 } }

local matrixRet3 = _GetMATLABVar('matrixVar3')
_SendToUI("", matrixRet3)
--Ӧ�ô�ӡ{ { { 1, 2, 3, 4 }, { 5, 6, 7, 8 }, { 9, 10, 11, 12 } }, { { 13, 14, 15, 16 }, { 17, 18, 19, 20 }, { 21, 22, 23, 24 } } }

--local matrixRet4 = _GetMATLABVar('matrixVar4')
--table.print(matrixRet4)

--4��ִ��m�ű�
if false == _CallMATLAB('x=-5:5; y=4*x+3; plot(x,y);') then
	_SendToUI("", _getErrorMsg())
end


--5��m�ű���ִ��----------------------------------------------------------------------------

--a)����matlab����Ŀ¼���ڹ���Ŀ¼�е�m������m�ű��ɱ�ִ��
if false==_MATLABAddPath('C:') then
	_SendToUI("", _getErrorMsg())
end

--b)ִ�й���Ŀ¼�µ�����m�ű�,����ִ��test.m
if false==_MATLABDoFile('test') then--ע�ⲻҪ������׺".m"
	_SendToUI("", _getErrorMsg())
end


--6������m����

--a)matlab�Դ�����
_LuaDebugger();  --���ڿ����༭�����Թ���


local ret = _MATLABCallFun('solve', 'x+y=2', 'x-y=3')
if ret[0]<0 then
	_SendToUI("", _getErrorMsg(ret[0]))
else
	_SendToUI("", ret)
end
--Ӧ�ô�ӡ���̵Ľ� { y = "-1/2", x = "5/2" }

ret = _MATLABCallFun('sin', math.pi/2)
if ret[0]<0 then
	_SendToUI("", _getErrorMsg(ret[0]))
else
	_SendToUI("", ret)
end
--Ӧ�ô�ӡsin(pi)��ֵ1

--b)�û������m����

ret = _MATLABCallFun('userFun1')
if ret[0]<0 then
	_SendToUI("", _getErrorMsg(ret[0]))
else
	_SendToUI("", ret)
end






Tick_stk1 = GetTick("SZ000001.stk");
--SendToUI("",Tick_stk1);




_Save2MAT("c:/bb.mat", 'SZ000001_20130222', Tick_stk1,'struct');














