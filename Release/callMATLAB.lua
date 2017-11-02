--------------------------------------------------------------------------------
--              matlab功能函数API
--@Category callMATLAB
--@CategoryZH 调用matlab
--@DisplayVersion 1.001.20130201
--@DisplayIcon matlab.gif
--@HelpLink
--@URLUpdateInfo
--@Publisher 龙软
--@<Description>
--Lua-MATLAB扩展函数库是DTS支持MATLAB策略研发的解决方案。Lua-MATLAB扩展函数库是DTS支持MATLAB策略研发的解决方案。
--通过该扩展库，MATLAB可以用DTS导出的Lua变量文件(MAT文件)进行逻辑开发。可以将m文件实现的逻辑嵌入到Lua中执行。
--方便用户将MATLAB作为策略逻辑的计算引擎使用。结合DTS本身的行情/交易/回测优化体系，极大方便了MATLAB策略的研发。
--作为定制化工具包，请需要的客户联系DTS客服电话：021-202199**。
--版本信息
--Release version: 1.002.20130410 [增加_MATLABCallFun(...)的参数说明；修正_GetMATLABUserPath()函数实现]
--@</Description>
--------------------------------------------------------------------------------

require "matlab"  --导入matlab扩展库

local luaVarTypes = {['boolean']=true,['number']=true,['string']=true,['table']=true}  --支持的标准lua的类型
local matlabTypes = {['logical']=true,['double']=true,['char']=true,['matrix']=true,['cell']=true,['struct']=true} --可转换的matlab的类型


local ErrorType = {}  --错误信息
ErrorType[1] = 'success: no error occur'
ErrorType[-1] = '参数类型指定错误'
ErrorType[-3] = 'Matlab引擎关闭'
ErrorType[-4] = '创建mxArray失败'
ErrorType[-5] = '将mxArray设置到引擎中时失败'
ErrorType[-6] = 'matlab脚本执行失败'
ErrorType[-7] = '获取变量失败，原因是引擎关闭或者该变量名不存在'
ErrorType[-8] = '打开MAT文件失败'
ErrorType[-9] = '保存变量到MAT文件中失败'
ErrorType[-10] = '关闭MAT文件失败'
ErrorType[-11] = '您没有安装matlab或者matlab组建没有注册或者引擎窗口的可视性设置失败'
ErrorType[-12] = '引擎窗口可能已经被关闭了'
ErrorType[-13] = '将mxArray设置到引擎中时失败'

local errorNo = 1  --错误码
local LastErrMsgForCallMScript = 'success: no error occur' --执行脚本失败时的错误信息


---------------------------------------------------------------------------------
--@<FuncName>_StartMATLAB</FuncName>
---启动matlab引擎
--@param visiable boolean 是否显示引擎窗口,true显示窗口，false不显示窗口。默认true显示窗口。
--@return boolean engine启动成功，返回true，启动失败返回false
--应用例子
--代码
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
---关闭matlab引擎
--@return boolean engine关闭成功，返回true，否则返回false
--应用例子
--代码
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
---设置matlab变量
--@param name string 变量名称
--@param luaVar any 变量值
--@param mType  string 变量的类型，为可选的参数。luaVar如果是boolean类型，则mType指定为'logical';如果是number类型，则指定为'double';如果是string类型，则指定为'char';如果是数值矩阵、逻辑矩阵、字符串矩阵，指定为'matrix';如果是通过GetKLine()等接口获取的行情数据，则mType指定为'struct'
--@return numeric 等于1表示设置变量成功；小于0，表示设置变量失败。错误码对应的错误信息，可根据ErrorType查询
--应用例子
--代码
--local numberVar = 100
--_SetMATLABVar('numberVar', numberVar)
--_WriteAplLog(_getErrorMsg())
--local matrixVar = {{{1,2,3,4},{5,6,7,8},{9,10,11,12}}, {{13,14,15,16},{17,18,19,20},{21,22,23,24}}} --2*3*4
--_SetMATLABVar('matrixVar', matrixVar)
--_WriteAplLog(_getErrorMsg())
----将获取的K线数据存储到matlab空间中
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

	--检查name、type是否为string
	if (type(name)~="string" or type(mType)~='string') then
		errorNo = -1
		return errorNo
	end

	-- lua变量的类型是否符合要求
	if not luaVarTypes[type(luaVar)] then
		errorNo = -1
		return errorNo
	end

	-- 要求转化的matlab类型是否符合要求
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
---获取调用_SetMATLABVar或_MATLABCallFun 时返回的错误信息
--@param ErrNo numeric 可选参数，错误编号
--@return string 错误信息
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
---生成一个新的.MAT文件，并且将指定的lua变量保存到这个.MAT文件中
--@param matFileName string .mat文件全路径名
--@param varName string 变量名
--@param luaVar any 变量值
--@param mType string 同_SetMATLABVar()中的解释
--@return numeric 等于1，表明成功保存为.mat文件，小于0，表明失败
--应用例子
--代码
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
---向一个已经存在的.MAT文件中添加lua变量
--@param matFileName string .mat文件全路径名
--@param varName string 变量名
--@param luaVar any 变量值
--@param mType string 同_SetMATLABVar()中的解释
--@return numeric 等于1，表明成功保存为.mat文件，小于0，表明失败
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
---获取matlab变量的值
--@param name string 变量名
--@return any 变量的值
--应用例子
--代码
--local numberRet = _GetMATLABVar('numberVar')
--_SendToUI("", numberRet) --应该打印100
--local matrixRet = _GetMATLABVar('matrixVar')
--_SendToUI("", matrixRet) --应该打印{{{1,2,3,4},{5,6,7,8},{9,10,11,12}}, {{13,14,15,16},{17,18,19,20},{21,22,23,24}}}
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
---执行matlab脚本
--@param mScript string m脚本
--@return boolean 执行成功返回true；执行失败返回false
--应用例子
--代码
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
---获取StrategyStudio中MATLAB的工作目录
--@return string 成功则返回StrategyStudio中MATLAB的工作目录，类型是string；失败返回nil
--@attention 该函数需要放在StrategyStudio中使用，在Scite中使用时非法
--应用例子
--代码
--local path = _GetMATLABUserPath() --获取工作目录
--_MATLABAddPath(path) --将工作目录加入MATLAB的搜索路径中
function _GetMATLABUserPath()
	local t = _GetStrategyInfo()
	return string.match(t.StrategyPath, "(.+)\\[^\\]*%.%w+$")
end
---------------------------------------------------------------------------------





---------------------------------------------------------------------------------
--@<FuncName>_MATLABAddPath</FuncName>
---增加一个matlab工作目录
--@param mFolderPath string 工作目录的路径
--@return boolean res是true，执行成功；res是false，执行失败
--应用例子
--代码
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
---执行一个matlab脚本文件
--@param mFile string 脚本文件名，不含.m后缀
--@return boolean res是true，执行成功；res是false，执行失败
--应用例子
--代码
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
---单独执行一个matlab函数
--@param ... 依次为m函数名和m函数需要的参数。要注意，对于table类型的变量，只能设置成'matrix'，不能设置为'cell'或'struct'
--@return table 若res[0]小于0，则表示错误码，根据_getErrorMsg(errno)可获取错误信息;若res[0]大于等于0，则表示m函数返回值的个数;res[1]、res[2]、res[3]....依次为返回值
--应用例子
--代码
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

--获取函数返回值的个数
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

--检查数值矩阵是否符号要求,考虑到效率问题，该函数不被使用。检查矩阵是否合法的过程在遍历矩阵时去做。
function _checkMatrix(luaTable)
	local dims = {} --存储每一维的维度

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
