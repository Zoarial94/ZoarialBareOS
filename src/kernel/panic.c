#include <stdlib.h>
#include <stdio.h>

__attribute__((__noreturn__))
void panic(char* str) {

	printf("Entered kernel panic zone./n");
	printf("%s", str);

	while (1) { }
	__builtin_unreachable();

}
