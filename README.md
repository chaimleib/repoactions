# repoactions 0.0.1

On navigating into a git repository, sources its repoactions.sh script.

## Motivation
Often in Node and Go projects, it is necessary to set up the interpreter version or import paths via project-specific environment variables. repoactions runs these actions for you automatically when you enter the project directory.

## Install

```bash
make install
```

## Usage

To add a repoactions script to a git repo, add a file called `repoactions.sh` to the root of the repo, and make it executable:

```bash
cd /path/to/repo
touch repoactions.sh
chmod +x repoactions.sh
```

After that, you should see a message telling to add this repo to the whitelist. Copy and paste in the command it tells you. For example:

```bash
echo "git@github.com:chaimleib/repoactions.git" >> "/Users/chalbert/.config/repoactions/whitelist"
```

From now on, the repoactions script will run each time you navigate from outside your repo into it.

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
* 0.0.1 - initial release

