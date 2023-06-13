#include<stdbool.h>
#include<stdio.h>
#include<stdlib.h>

#define error_check(C) \
	if(__builtin_expect((C), false))

typedef int err_t;

int main(const int c, char *const args[]) {
	const err_t e = puts("paadh chak la");
	error_check(e == EOF) return EXIT_FAILURE;
	return EXIT_SUCCESS;
}

