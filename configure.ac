AC_INIT(repoactions,0.0.3)
AC_MSG_NOTICE(AC_PACKAGE_NAME AC_PACKAGE_VERSION)
AC_ARG_VAR(RC,[Where to install the login script that enables ]AC_PACKAGE_NAME[ (default: ~/.profile)])
AC_PREFIX_DEFAULT([/usr/local])

AC_SUBST(version,AC_PACKAGE_VERSION)
AC_SUBST(url,[https://github.com/chaimleib/repoactions])
if test "$RC" != ""; then
  AC_SUBST(rc,$RC)
else
  AC_SUBST(rc,[\${HOME}/.profile])
fi

AC_OUTPUT([src/show_repoactions.sh])
AC_OUTPUT([README.md])
AC_OUTPUT([Makefile])

