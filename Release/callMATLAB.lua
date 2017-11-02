--------------------------------------------------------------------------------
--              matlab���ܺ���API
--@Category callMATLAB
--@CategoryZH ����matlab
--@DisplayVersion 1.001.20130201
--@DisplayIcon matlab.gif
--@HelpLink
--@URLUpdateInfo
--@Publisher ����
--@<Description>
--Lua-MATLAB��չ��������DTS֧��MATLAB�����з��Ľ��������Lua-MATLAB��չ��������DTS֧��MATLAB�����з��Ľ��������
--ͨ������չ�⣬MATLAB������DTS������Lua�����ļ�(MAT�ļ�)�����߼����������Խ�m�ļ�ʵ�ֵ��߼�Ƕ�뵽Lua��ִ�С�
--�����û���MATLAB��Ϊ�����߼��ļ�������ʹ�á����DTS���������/����/�ز��Ż���ϵ�����󷽱���MATLAB���Ե��з���
--��Ϊ���ƻ����߰�������Ҫ�Ŀͻ���ϵDTS�ͷ��绰��021-202199**��
--�汾��Ϣ
--Release version: 1.002.20130410 [����_MATLABCallFun(...)�Ĳ���˵��������_GetMATLABUserPath()����ʵ��]
--@</Description>
--------------------------------------------------------------------------------

require "matlab"  --����matlab��չ��

local luaVarTypes = {['boolean']=true,['number']=true,['string']=true,['table']=true}  --֧�ֵı�׼lua������
local matlabTypes = {['logical']=true,['double']=true,['char']=true,['matrix']=true,['cell']=true,['struct']=true} --��ת����matlab������


local ErrorType = {}  --������Ϣ
ErrorType[1] = 'success: no error occur'
ErrorType[-1] = '��������ָ������'
ErrorType[-3] = 'Matlab����ر�'
ErrorType[-4] = '����mxArrayʧ��'
ErrorType[-5] = '��mxArray���õ�������ʱʧ��'
ErrorType[-6] = 'matlab�ű�ִ��ʧ��'
ErrorType[-7] = '��ȡ����ʧ�ܣ�ԭ��������رջ��߸ñ�����������'
ErrorType[-8] = '��MAT�ļ�ʧ��'
ErrorType[-9] = '���������MAT�ļ���ʧ��'
ErrorType[-10] = '�ر�MAT�ļ�ʧ��'
ErrorType[-11] = '��û�а�װmatlab����matlab�齨û��ע��������洰�ڵĿ���������ʧ��'
ErrorType[-12] = '���洰�ڿ����Ѿ����ر���'
ErrorType[-13] = '��mxArray���õ�������ʱʧ��'

local errorNo = 1  --������
local LastErrMsgForCallMScript = 'success: no error occur' --ִ�нű�ʧ��ʱ�Ĵ�����Ϣ


---------------------------------------------------------------------------------
--@<FuncName>_StartMATLAB</FuncName>
---����matlab����
--@param visiable boolean �Ƿ���ʾ���洰��,true��ʾ���ڣ�false����ʾ���ڡ�Ĭ��true��ʾ���ڡ�
--@return boolean engine�����ɹ�������true������ʧ�ܷ���false
--Ӧ������
--����
--if false==_StartMATLAB() then
--	_WriteAplLog(_getErrorMsg())
--end
function _StartMATLAB(visiable)
	if visiable==nil then
		visiable = true
	end

	if type(visiable)~='boolean' then
		errorNo = -1
		return false
	end

	if false == matlab.StartMATLAB(visiable) then
		errorNo = -11
		return false
	else
		errorNo = 1
		return true
	end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--@<FuncName>_TerminateMATLAB</FuncName>
---�ر�matlab����
--@return boolean engine�رճɹ�������true�����򷵻�false
--Ӧ������
--����
--if true == _TerminateMATLAB() then
--	_WriteAplLog(_getErrorMsg())
--end
function _TerminateMATLAB()
	if false == matlab.TerminateMATLAB() then
		errorNo = -12
		return false
	else
		errorNo = 1
		return true
	end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--@<FuncName>_SetMATLABVar</FuncName>
---����matlab����
--@param name string ��������
--@param luaVar any ����ֵ
--@param mType  string ���������ͣ�Ϊ��ѡ�Ĳ�����luaVar�����boolean���ͣ���mTypeָ��Ϊ'logical';�����number���ͣ���ָ��Ϊ'double';�����string���ͣ���ָ��Ϊ'char';�������ֵ�����߼������ַ�������ָ��Ϊ'matrix';�����ͨ��GetKLine()�Ƚӿڻ�ȡ���������ݣ���mTypeָ��Ϊ'struct'
--@return numeric ����1��ʾ���ñ����ɹ���С��0����ʾ���ñ���ʧ�ܡ��������Ӧ�Ĵ�����Ϣ���ɸ���ErrorType��ѯ
--Ӧ������
--����
--local numberVar = 100
--_SetMATLABVar('numberVar', numberVar)
--_WriteAplLog(_getErrorMsg())
--local matrixVar = {{{1,2,3,4},{5,6,7,8},{9,10,11,12}}, {{13,14,15,16},{17,18,19,20},{21,22,23,24}}} --2*3*4
--_SetMATLABVar('matrixVar', matrixVar)
--_WriteAplLog(_getErrorMsg())
----����ȡ��K�����ݴ洢��matlab�ռ���
--local kline = _SendToUI("",GetKLine("SH600000.stk", "1m", nil, nil, -100, 100))
--_SetMATLABVar('kline', kline, 'struct')
--_WriteAplLog(_getErrorMsg())
function _SetMATLABVar(name, luaVar, mType)
	if (mType == nil) then
		if (type(luaVar)=='boolean') then
			mType='logical'
		elseif (type(luaVar)=='number') then
			mType='double'
		elseif (type(luaVar)=='string') then
			mType='char'
		elseif (type(luaVar)=='table') then
			mType='matrix'
		else
			errorNo = -1
			return errorNo
		end
	end

	--���name��type�Ƿ�Ϊstring
	if (type(name)~="string" or type(mType)~='string') then
		errorNo = -1
		return errorNo
	end

	-- lua�����������Ƿ����Ҫ��
	if not luaVarTypes[type(luaVar)] then
		errorNo = -1
		return errorNo
	end

	-- Ҫ��ת����matlab�����Ƿ����Ҫ��
	if not matlabTypes[mType] then
		errorNo = -1
		return errorNo
	end


	errorNo = matlab.SetMATLABVar(mType, name, luaVar)
	return errorNo
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--@<FuncName>_getErrorMsg</FuncName>
---��ȡ����_SetMATLABVar��_MATLABCallFun ʱ���صĴ�����Ϣ
--@param ErrNo numeric ��ѡ������������
--@return string ������Ϣ
function _getErrorMsg(ErrNo)
	if ErrNo==nil then
		if errorNo==-6 then
			return LastErrMsgForCallMScript
		else
			return ErrorType[errorNo]
		end
	end

	if ErrNo>=0 then
		return 'success: no error occur'
	elseif ErrNo<-12 then
		return 'undefined error'
	elseif ErrNo==-6 then
		return LastErrMsgForCallMScript
	else
		return ErrorType[ErrNo]
	end
end
---------------------------------------------------------------------------------


---------------------------------------------------------------------------------
--@<FuncName>_Save2MAT</FuncName>
---����һ���µ�.MAT�ļ������ҽ�ָ����lua�������浽���.MAT�ļ���
--@param matFileName string .mat�ļ�ȫ·����
--@param varName string ������
--@param luaVar any ����ֵ
--@param mType string ͬ_SetMATLABVar()�еĽ���
--@return numeric ����1�������ɹ�����Ϊ.mat�ļ���С��0������ʧ��
--Ӧ������
--����
--_Save2MAT('C:/Users/wudian/Desktop/wudian.mat', 'a', 'my string')
--_Append2MAT('C:/Users/wudian/Desktop/wudian.mat', 'b',99)
--_Append2MAT('C:/Users/wudian/Desktop/wudian.mat', 'c',{1,2,3})
function _Save2MAT(matFileName, varName, luaVar, mType)
	if type(matFileName)~='string' or type(varName)~='string' then
		errorNo = -1
		return errorNo
	end

	errorNo = _SetMATLABVar(varName, luaVar, mType)
	if errorNo<0 then
		return errorNo
	end

	local t = _MATLABCallFun('fileparts', matFileName)
	if t[0] < 0 then
		errorNo = t[0]
		return errorNo
	end

	local pathstr = t[1]
	if pathstr == 'C:' or pathstr == 'c:' then
		pathstr = 'C:/'
	end
	local fileName = t[2]
	if false == _CallMATLAB("cd "..pathstr.."; save('"..fileName.."','"..varName.."');") then
		errorNo = -6
		return errorNo
	else
		errorNo = 1
		return errorNo
	end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--@<FuncName>_Append2MAT</FuncName>
---��һ���Ѿ����ڵ�.MAT�ļ������lua����
--@param matFileName string .mat�ļ�ȫ·����
--@param varName string ������
--@param luaVar any ����ֵ
--@param mType string ͬ_SetMATLABVar()�еĽ���
--@return numeric ����1�������ɹ�����Ϊ.mat�ļ���С��0������ʧ��
function _Append2MAT(matFileName, varName, luaVar, mType)
	if type(matFileName)~='string' or type(varName)~='string' then
		errorNo = -1
		return errorNo
	end

	errorNo = _SetMATLABVar(varName, luaVar, mType)
	if errorNo<0 then
		return errorNo
	end

	local t = _MATLABCallFun('fileparts', matFileName)
	if t[0] < 0 then
		errorNo = t[0]
		return errorNo
	end

	local pathstr = t[1]
	if pathstr == 'C:' or pathstr == 'c:' then
		pathstr = 'C:/'
	end
	local fileName = t[2]
	if false == _CallMATLAB("cd "..pathstr.."; save('"..fileName.."','"..varName.."','-append');") then
		errorNo = -6
		return errorNo
	else
		errorNo = 1
		return errorNo
	end
end
---------------------------------------------------------------------------------



---------------------------------------------------------------------------------
--@<FuncName>_GetMATLABVar</FuncName>
---��ȡmatlab������ֵ
--@param name string ������
--@return any ������ֵ
--Ӧ������
--����
--local numberRet = _GetMATLABVar('numberVar')
--_SendToUI("", numberRet) --Ӧ�ô�ӡ100
--local matrixRet = _GetMATLABVar('matrixVar')
--_SendToUI("", matrixRet) --Ӧ�ô�ӡ{{{1,2,3,4},{5,6,7,8},{9,10,11,12}}, {{13,14,15,16},{17,18,19,20},{21,22,23,24}}}
function _GetMATLABVar(name)
	if (type(name)~="string") then
		errorNo = -1
		return nil
	end

	local res = matlab.GetMATLABVar(name)
	if nil == res then
		errorNo = -7
		return nil
	else
		errorNo = 1
		return res
	end
end
---------------------------------------------------------------------------------


---------------------------------------------------------------------------------
--@<FuncName>_CallMATLAB</FuncName>
---ִ��matlab�ű�
--@param mScript string m�ű�
--@return boolean ִ�гɹ�����true��ִ��ʧ�ܷ���false
--Ӧ������
--����
--if false == _CallMATLAB('x=-5:5; y=4*x+3; plot(x,y);') then
--	_WriteAplLog(_getErrorMsg())
--end
function _CallMATLAB(mScript)
	if type(mScript) ~= "string" then
		errorNo = -1
		return false
	end

	isSuccess,LastErrMsgForCallMScript =  matlab.CallMATLAB(mScript)
	if false==isSuccess then
		errorNo = -6
		return false
	else
		errorNo = 1
		LastErrMsgForCallMScript = 'success: no error occur'
		return true
	end
end
---------------------------------------------------------------------------------




---------------------------------------------------------------------------------
--@<FuncName>_GetMATLABUserPath</FuncName>
---��ȡStrategyStudio��MATLAB�Ĺ���Ŀ¼
--@return string �ɹ��򷵻�StrategyStudio��MATLAB�Ĺ���Ŀ¼��������string��ʧ�ܷ���nil
--@attention �ú�����Ҫ����StrategyStudio��ʹ�ã���Scite��ʹ��ʱ�Ƿ�
--Ӧ������
--����
--local path = _GetMATLABUserPath() --��ȡ����Ŀ¼
--_MATLABAddPath(path) --������Ŀ¼����MATLAB������·����
function _GetMATLABUserPath()
	local t = _GetStrategyInfo()
	return string.match(t.StrategyPath, "(.+)\\[^\\]*%.%w+$")
end
---------------------------------------------------------------------------------





---------------------------------------------------------------------------------
--@<FuncName>_MATLABAddPath</FuncName>
---����һ��matlab����Ŀ¼
--@param mFolderPath string ����Ŀ¼��·��
--@return boolean res��true��ִ�гɹ���res��false��ִ��ʧ��
--Ӧ������
--����
--if false == _MATLABAddPath('C:/Users/wudian/Documents/MATLAB') then
--	_WriteAplLog(_getErrorMsg())
--end
function _MATLABAddPath(mFolderPath)
	if (type(mFolderPath) ~= "string") then
		errorNo = -1
		return false
	end

	isSuccess,LastErrMsgForCallMScript =  matlab.CallMATLAB("addpath "..mFolderPath)
	if false==isSuccess then
		errorNo = -6
		return false
	else
		errorNo = 1
		LastErrMsgForCallMScript = 'success: no error occur'
		return true
	end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--@<FuncName>_MATLABDoFile</FuncName>
---ִ��һ��matlab�ű��ļ�
--@param mFile string �ű��ļ���������.m��׺
--@return boolean res��true��ִ�гɹ���res��false��ִ��ʧ��
--Ӧ������
--����
--if false == _MATLABDoFile('test') then
--	_WriteAplLog(_getErrorMsg())
--end
function _MATLABDoFile(mFile)
	if type(mFile) ~= "string" then
		errorNo = -1
		return false
	end

	isSuccess,LastErrMsgForCallMScript =  matlab.CallMATLAB(mFile)
	if false==isSuccess then
		errorNo = -6
		return false
	else
		errorNo = 1
		LastErrMsgForCallMScript = 'success: no error occur'
		return true
	end
end
---------------------------------------------------------------------------------



---------------------------------------------------------------------------------
--@<FuncName>_MATLABDoFile</FuncName>
---����ִ��һ��matlab����
--@param ... ����Ϊm��������m������Ҫ�Ĳ�����Ҫע�⣬����table���͵ı�����ֻ�����ó�'matrix'����������Ϊ'cell'��'struct'
--@return table ��res[0]С��0�����ʾ�����룬����_getErrorMsg(errno)�ɻ�ȡ������Ϣ;��res[0]���ڵ���0�����ʾm��������ֵ�ĸ���;res[1]��res[2]��res[3]....����Ϊ����ֵ
--Ӧ������
--����
--ret = _MATLABCallFun('userFun',param1,param2)
--if ret[0]<0 then
--	_SendToUI("", _getErrorMsg(ret[0]))
--else
--	_SendToUI("", ret)
--end
function _MATLABCallFun(...)
	local ret = {}
	local arguments = {...}
	local numberArguments = #arguments
	local functionName = arguments[1]
	if type(functionName) ~= 'string' then
		errorNo = -1
		ret[0]=-1
		return ret
	end

	local nRetArgs = _getNumberOfRetValues(functionName)
	if nRetArgs==nil then
		errorNo = -6
		ret[0]=-6
		return ret
	end

	local mScript = ''
	if nRetArgs > 0 then
		mScript = '['
		for i=1,nRetArgs do
			if i==nRetArgs then
				mScript = mScript..('temp_ret'..i)..']='
			else
				mScript = mScript..('temp_ret'..i)..','
			end
		end
	end

	if numberArguments==1 then
		mScript = mScript..arguments[1]..'();'
	else
		for i,v in ipairs(arguments) do
			if i==1 then
				mScript = mScript..arguments[i]..'('
			else
				local temp_param = 'temp_param'..(i-1)
				errorNo = _SetMATLABVar(temp_param, v)
				if (errorNo < 0) then
					ret[0] = errorNo
					return ret
				end

				if i==numberArguments then
					mScript = mScript..temp_param..');'
				else
					mScript = mScript..temp_param..','
				end
			end
		end
	end

	isSuccess,LastErrMsgForCallMScript = matlab.CallMATLAB(mScript)
	if false==isSuccess then
		errorNo = -6
		ret[0] = -6
		return ret
	end

	ret[0] = nRetArgs
	for i=1,nRetArgs do
		ret[i] = _GetMATLABVar('temp_ret'..i)
	end

	_CallMATLAB('clear temp_*;')
	errorNo = 1
	return ret
end
---------------------------------------------------------------------------------





----local function------------------------------------------------------------------------------

--��ȡ��������ֵ�ĸ���
function _getNumberOfRetValues(functionName)
	local temp = 'temp_ret'
	isSuccess,LastErrMsgForCallMScript = matlab.CallMATLAB(temp.."=nargout('"..functionName.."');")
	local ret = _GetMATLABVar(temp)
	if isSuccess==false or ret==nil then
		return nil
	end
	_CallMATLAB('clear '..temp)
	return math.abs(ret)
end

--�����ֵ�����Ƿ����Ҫ��,���ǵ�Ч�����⣬�ú�������ʹ�á��������Ƿ�Ϸ��Ĺ����ڱ�������ʱȥ����
function _checkMatrix(luaTable)
	local dims = {} --�洢ÿһά��ά��

	local function _getDims(luaTable, d)
		dims[d] = #luaTable
		for i,v in pairs(luaTable) do
			if type(i)~='number' then
				return false
			end

			if (i==1 and type(v)=='table') then
				if (_getDims(v, d+1)==false) then
					return false
				end
			end
		end

		return true
	end

	local function _checkTableHelp(luaTable, d)
		if #luaTable ~= dims[d] then
			return false
		end

		for i,v in pairs(luaTable) do
			if type(v)=='table' then
				if (false==_checkTableHelp(v, d+1)) then
					return false
				end
			elseif type(v)~='number' and type(v)~='boolean' then
				return false
			end
		end

		return true
	end

	if (false==_getDims(luaTable, 1)) then
		return false
	end

	return _checkTableHelp(luaTable, 1)
end
