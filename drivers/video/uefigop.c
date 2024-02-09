#include "uefigop.h"

unsigned long long* uefiGopHandle;
unsigned long long* gopBltPointer;

void initGOP(unsigned long long *gopHandle)
{
	uefiGopHandle = gopHandle;
	gopBltPointer = gopHandle + 24;
}
