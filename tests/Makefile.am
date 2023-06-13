TESTS = check_foo
check_PROGRAMS = check_foo
check_foo_SOURCES = check_foo.c $(top_builddir)/src/foo.h
check_foo_CFLAGS = @CHECK_CFLAGS@
check_foo_LDADD = $(top_builddir)/src/libfoo.la @CHECK_LIBS@

