require "callMATLAB"
_StartMATLAB() --Æô¶¯matlab engine
--require "numlua.seeall"
--require "metalua.table2"

--local matrixVar3 = matrix{{{1,2,3,4},{5,6,7,8},{9,10,11,12}}, {{13,14,15,16},{17,18,19,20},{21,22,23,24}}} --2*3*4
local matrixVar3 = {{{1,2,3,4},{5,6,7,8},{9,10,11,12}}, {{13,14,15,16},{17,18,19,20},{21,22,23,24}}} --2*3*4
--~ table.print(matrixVar3[1]);
--print(matrixVar3:size("#"))
--print(matrixVar3)

--a=matrix.zeros(2,2,2)
--print(a:size("#"))

local errno=_SetMATLABVar('matrixVar3', matrixVar3)
