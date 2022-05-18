<p align="center">
  <img src="/img/preview-20220518.gif?raw=true"/>
</p>

# zsh-repo-theme
[ohmyzsh](https://github.com/ohmyzsh/ohmyzsh) theme which shows details git repo information.

# How To Use
What you need to do is just put [repo.zsh-theme](repo.zsh-theme)
to `ohmyzsh/custom/themes` or `ohmyzsh/themes`

- use symbolic link
```shell
# Open ZSH shell
git clone https://github.com/gkide/zsh-repo-theme.git
cd zsh-repo-theme
ln -s `pwd`/repo.zsh-theme $ZSH/custom/themes/repo.zsh-theme
```

# Prompt Information

The prompt message for current working directory is not git repo, it will as
```shell
✘ ☻ ❄ user@host | working-directory | Xms $               ....             «Yms»
```
- `✘` if last command error, then it shows up
- `☻` if current user is root, then it shows up
- `❄` if terminal has more jobs, then it shows up
- `X` is for the theme refresh time(ms)
- `Y` is for the user last command used time(ms)

The prompt message for current working directory is a git repo, it will as
```shell
╭─ ✘ ☻ ❄ user@host | working-directory | git-config-user-name<git-config-user-email>
╰─ repo-name § repo-branch(sha1) | ✔↑x↓x✚x✎x⍉x⚑x✖x | Xms $        ....     «Yms»
```
- `✘` if last command error, then it shows up
- `☻` if current user is root, then it shows up
- `❄` if terminal has more jobs, then it shows up
- `X` is for the theme refresh time(ms)
- `Y` is for the user last command used time(ms)
- `repo-name` is for current repo directory name, which is repo name
- `repo-branch` is for current working branch
- `sha` is the SHA1 of `repo-branch`
- `✔` if repo is clean, then it shows up
- `↑x` if local ahead of remote by `x` commits, then it shows up
- `↓x` if local behind of remote by `x` commits, then it shows up
- `✚x` if local has staged `x` files, then it shows up
- `✎x` if local has `x` files changed but not staged, then it shows up
- `⍉x` if local has `x` files which is not tracked, then it shows up
- `⚑x` if local has `x` stash changes, then it shows up
- `✖x` if local has `x` conflicts, then it shows up
