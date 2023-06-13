#include "config.h"
#include <stdio.h>
#include <stdlib.h>
#include "foo.h"

int main(const int c, char *const args[]) {
	const err_t e = foo();
	error_check(e == EOF) return EXIT_FAILURE;
	return EXIT_SUCCESS;
}

