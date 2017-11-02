#pragma  once

#include <vector>
#include <engine.h>
using namespace std;

class SmartPointerMxArray {
	mxArray *m_mx;
public:
	SmartPointerMxArray();
	SmartPointerMxArray(mxArray *mx);
	~SmartPointerMxArray();
	SmartPointerMxArray &operator=(mxArray *mx);
	operator mxArray*();
	bool isMxArrayNull();
private:
	SmartPointerMxArray(const SmartPointerMxArray &);
};

class SmartPointerMwSize {
	mwSize *m_size;
public:
	SmartPointerMwSize();
	SmartPointerMwSize(const vector<mwSize> &vecSiz);
	~SmartPointerMwSize();
	operator mwSize*();
private:
	SmartPointerMwSize(const SmartPointerMwSize &);
};