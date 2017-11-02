#pragma once

#include <vector>
#include "engine.h"

using namespace std;

enum ErrorType {
	E_None = 1, // success: no error occur
	E_EngineOff = -3, // Matlab����ر�
	E_createMxArrayFromLua = -4, // ����mxArrayʧ��
	E_SetMxArray = -5, // ��mxArray���õ�������ʱʧ��
};

typedef vector<mwSize> MATRIXDIMENSION;
// ����lua/c++��matlab�ж�ά�����ת��
typedef MATRIXDIMENSION MATRIXINDEX;//���������MATRIXINDEX��Ϊ2��3
typedef vector<MATRIXDIMENSION> MATRIXINDEXLIST;//��������ôMATRIXINDEXLIST��Ӧ��Ϊ00��01��02��10��11��12
typedef MATRIXINDEXLIST::const_iterator ConstIteratorOfIndexList;