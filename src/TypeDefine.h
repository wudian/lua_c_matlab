#pragma once

#include <vector>
#include "engine.h"

using namespace std;

enum ErrorType {
	E_None = 1, // success: no error occur
	E_EngineOff = -3, // Matlab引擎关闭
	E_createMxArrayFromLua = -4, // 创建mxArray失败
	E_SetMxArray = -5, // 将mxArray设置到引擎中时失败
};

typedef vector<mwSize> MATRIXDIMENSION;
// 用于lua/c++、matlab中多维数组的转换
typedef MATRIXDIMENSION MATRIXINDEX;//举例：如果MATRIXINDEX中为2、3
typedef vector<MATRIXDIMENSION> MATRIXINDEXLIST;//举例：那么MATRIXINDEXLIST就应该为00、01、02、10、11、12
typedef MATRIXINDEXLIST::const_iterator ConstIteratorOfIndexList;