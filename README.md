# repoactions 0.0.4

On navigating into a git repository, sources its repoactions.sh script.

## Motivation
For certain projects, it is often necessary to set up special shell environment variables. These variables change the behavior of the project. For example:

* [NVM](https://github.com/creationix/nvm) uses special variables to set the interpreter version.
* [Go](https://github.com/golang/go/wiki) uses the GOPATH variable to define where to look for special imports.
* Web servers may use special variables to set port numbers and other settings.

Wouldn't it be nice if all these variables got set up automatically as soon as you cd-ed into the repo? Wouldn't it be nice if you didn't have to clutter up your handcrafted dotfiles with project-specific code? Have you ever wished that you knew exactly how your colleagues set up their environment?

With `repoactions`, you can do it all!

The vision of `repoactions` is to have one script file in your git repo, in a standard location, which you can share with co-developers and follows your project around, so that your whole team is on the same page.

## Install

```bash
./configure
make install
```

The above should be enough for most users.

For more control, `configure` currently allows you to set the installation prefix with the `--prefix=` option. You can also specify where the login code gets injected by using the `--with-rc=FILE` option (default is `~/.profile`):

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

After that, you should see a message telling to add this repo to the whitelist. (This is a security feature.) Copy and paste in the command it tells you. For example:

```bash
echo "git@github.com:chaimleib/repoactions.git" >> "/Users/chalbert/.config/repoactions/whitelist"
```

From now on, the repoactions script will run each time you navigate from outside your repo into it.

You can relocate your repo anywhere on your disk, and your whitelist will still work, because your repo is identified by its URL:

```bash
git config --get remote.origin.url
```

### Silencing warnings

If there is a particular repo which has a `repoactions.sh` that you do not want to run, you can silence the warning message by adding the repo name to the ignore file:

```bash
echo "git@github.com:chaimleib/repoactions.git" >> "/Users/chalbert/.config/repoactions/ignore"
```

## Uninstall

```bash
make uninstall
```

To also remove the preferences, run

```bash
make purge
```

## Changelog
* 0.0.1 (2016-11-21) - initial release
* 0.0.2 (2016-11-21) - added support for RC configure variable. Set `PROMPT_COMMAND` in a more robust way. Improved safety of install and uninstall auxiliary scripts.
* 0.0.3 (2016-11-21) - added -v and -h option to `show_repoactions`
* 0.0.4 (2016-11-21) - changed RC configure variable to `--with-rc=FILE` option

