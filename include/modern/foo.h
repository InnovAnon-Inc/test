#ifndef _FOO_H_
#define _FOO_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>

#define error_check(C) \
	if(__builtin_expect((C), false))

typedef int err_t;

err_t foo() ;

#ifdef __cplusplus
}
#endif

#endif

