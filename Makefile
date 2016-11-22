SHELL=bash
PREFIX=/usr/local

all: Makefile README.md

install: all uninstall install.sh
	./install.sh "$(PREFIX)"

uninstall:
	./uninstall.sh "$(PREFIX)"

purge: uninstall
	rm -rf ~/.config/repoactions

clean:
	rm -rf autom4te.cache/
	rm -f config.log
	rm -f config.cache
	rm -f config.status

distclean: clean

Makefile: Makefile.in config.status
	./config.status $@

README.md: README.md.in config.status
	./config.status $@

config.status: configure
	./configure

configure: configure.ac
	autoconf

