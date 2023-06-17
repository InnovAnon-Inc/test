#LIBTOOL_DEPS = @LIBTOOL_DEPS@
#libtool: $(LIBTOOL_DEPS)
#	$(SHELL) ./config.status libtool

# Install the pkg-config file.
pkgconfigdir = $(libdir)/pkgconfig
#pkgconfig_DATA = src/libezudp-client.pc src/libezudp-server.pc src/ezudp-client-test.pc src/ezudp-server-test.pc

DISTCLEANFILES = $(pkgconfig_DATA)
#EXTRA_DIST = src/libezudp-client.pc.in src/libezudp-server.pc.in src/ezudp-client-test.pc.in src/ezudp-server-test.pc.in

SUBDIRS = src . tests
#dist_doc_DATA = README.md
ACLOCAL_AMFLAGS = -I m4

