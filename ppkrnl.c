#include "drivers/video/video.h"

int main(unsigned long long *fBuffer, unsigned long long  *gopHandle)
{
	initGOP(gopHandle);

	while (1);
}