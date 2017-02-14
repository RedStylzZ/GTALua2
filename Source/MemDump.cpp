#include "stdafx.h"

void MemDump(char *address, int size) {
	int i;

	for (i = 0; i < size; i++) {
		printf("%02x", *address);
		address++;
	}
	printf("\n");
}