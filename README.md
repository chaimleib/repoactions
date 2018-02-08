# repoactions 0.3.0

On navigating into a git repository, sources its repoactions.sh script.

## Motivation
For certain projects, it is often necessary to set up special shell environment variables. For example:

* [NVM](https://github.com/creationix/nvm) uses special variables to set the interpreter version.
* [Go](https://github.com/golang/go/wiki) uses the GOPATH variable to define where to look for special imports.
* Web servers may use special variables to set port numbers and other settings.

Wouldn't it be nice if all these variables got set up automatically as soon as you cd-ed into the repo? If you didn't have to clutter your handcrafted dotfiles with project-specific code? If you knew exactly how your colleagues set up their environment? With repoactions, you can do it all!

## Install

```bash
./configure
sudo make install
```

### Homebrew
Mac users with [Homebrew](http://brew.sh/) installed can simply run:

```bash
brew install chaimleib/formulae/repoactions
```

### Advanced options
For more control, `configure` currently allows you to set the installation prefix with the `--prefix=` option. You can also specify where your shell's `PROMPT_COMMAND` gets updated by using the `--with-rc=FILE` option (default is `$HOME/.profile`):

```bash
./configure --prefix=/opt --with-rc="$HOME/.bashrc.d/repoactions.sh"
```

For more information, run `./configure --help`.

## Usage

To add a repoactions script to a git repo, add a file called `repoactions.sh` to the root of the repo, and make it executable:

```bash
cd /path/to/repo
touch repoactions.sh
chmod +x repoactions.sh
```

After that, you should see a message telling you to enable and add this repo to the whitelist. (This is a security feature.) You can do so by running

```bash
repoactions -w
```

From now on, the repoactions script will run each time you navigate from outside your repo into it.

> If your repo is cloned from a remote repository, you can relocate your repo anywhere on your disk, and your whitelist will still work, because your repo is identified by its URL:

  ```bash
git config --get remote.origin.url
```

### Silencing warnings

If there is a particular repo which has a `repoactions.sh` that you do not want to run, you can silence the warning message by running

```bash
repoactions -s
```

## Uninstall

To remove the preferences, run

```bash
repoactions -z
```

Then, you can uninstall repoactions itself:

```bash
make uninstall
```

## Changelog
* 0.0.1 (2016-11-21) - initial release
* 0.0.2 (2016-11-21) - added support for RC configure variable. Set `PROMPT_COMMAND` in a more robust way. Improved safety of install and uninstall auxiliary scripts.
* 0.0.3 (2016-11-21) - added -v and -h option to `show_repoactions`
* 0.0.4 (2016-11-21) - changed RC configure variable to `--with-rc=FILE` option, added ignore list
* 0.0.5 (2016-11-22) - fixed missing Makefile.in
* 0.0.6 (2016-11-22) - prevent uninstall error on missing rc
* 0.0.7 (2016-11-22) - readme edits for Homebrew instructions
* 0.0.8 (2016-11-22) - fix readme link to Homebrew
* 0.0.9 (2016-11-22) - use $HOME instead of ~ in documentation; absolute paths are required for `--with-rc=`, shorten readme
* 0.0.10 (2017-08-18) - simplified certain commands. Add shellcheck test. Fix: `uninstall.sh`, and therefore `make uninstall` and `make install`, failed when `~/.profile` was missing
* 0.0.11 (2017-09-01) - Fix: `show_repoactions -v` did not display version
* 0.1.0 (2017-12-01) - Restructured the main script, simplified the command for setting `PROMPT_COMMAND`. Main script has many more options.
* 0.2.0 (2017-12-19) - Made install default to not modify RC files. Hint is now displayed only the first time user cd's into the repo. Fix missing options in help message.
* 0.2.1 (2017-12-19) - address `make test` warning about `sed` usage
* 0.3.0 (2018-02-08) - Inject self at end of `PROMPT_COMMAND` instead of the beginning, to enable prompt commands sensitive to exit codes. Shorten script name in docs if we are on the `PATH`. Fix `make test` warnings about unnecessary checks on `$?`.

