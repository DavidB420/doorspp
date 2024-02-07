#include "uefigop.h"

void initGOP(unsigned long long *gopHandle)
{
	uefiGopHandle = gopHandle;
	gopBltPointer = gopHandle + 24;
}
