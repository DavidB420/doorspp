int main(unsigned long long *fBuffer, int fBufferPPS)
{
	int val = -1;
	for (unsigned long long i = 0; i < 100; i++)
	{
		fBuffer[i] = val;
	}

	while (1);
}