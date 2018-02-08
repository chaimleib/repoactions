AC_INIT(repoactions,0.3.1)
AC_MSG_NOTICE(AC_PACKAGE_NAME AC_PACKAGE_VERSION)
AC_ARG_WITH(rc,
            AS_HELP_STRING([--with-rc=FILE], [Where to install the login script that enables ]AC_PACKAGE_NAME[ (default: none)]))
AC_PREFIX_DEFAULT([/usr/local])

AC_SUBST(version,AC_PACKAGE_VERSION)
AC_SUBST(url,[https://github.com/chaimleib/repoactions])
AC_SUBST(rc,$with_rc)
AC_MSG_NOTICE([rc file: ]"AS_ESCAPE("$rc", [""])")

AC_OUTPUT([src/repoactions.sh])
AC_OUTPUT([README.md])
AC_OUTPUT([Makefile])
