SHELL=bash
PREFIX=/usr/local
RC=${HOME}/.profile

all: Makefile README.md
	chmod +x src/repoactions.sh

install: all uninstall install.sh
	./install.sh "$(PREFIX)" "$(RC)"

uninstall:
	./uninstall.sh "$(PREFIX)" "$(RC)"

purge: uninstall
	rm -rf "${HOME}/.config/repoactions"

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

test: configure
	shellcheck $(shell find . -iname '*.sh')
