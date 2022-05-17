# ┌─ ◒●◯○⬡ ☺ ✹⚡➤➜ ✙✛✜ ✓✕✗
# └─ ‹› ▴▾ ▶◀ »« ⇒⇐
# RUN THIS COMMAND TO SHOW THE UNICODE $ echo "\uE0A0"
# Powerline Font    https://github.com/powerline/fonts
_xLmPrefix='╭─ '  # if in repo the first prompt line prefix
_xLnPrefix='╰─ '  # if in repo the second prompt line prefix
_xCmdError='✘ '   # show if last command error
_xIsRoot='☻ '     # show if current user is root
_xHasJobs='❄ '    # show if shell has other jobs

_xSeparator=' | ' # normal separator for segment
_xSepLeft=' «'    # normal separator for segment
_xSepRight='» '   # normal separator for segment

# git Repo Sign
_xRSClean='✔'     # local repo is clean
_xRSBranch=' § '  # repo name and branch separator

_xRSAhead='↑'     # ↑x local commit ahead remote by x commits
_xRSBehind='↓'    # ↓x local commit behind remote by x commits

_xRSStash='⚑'     # ⚑x local has x stash changes
_xRSStaged='✚'    # ✚x local staged x files
_xRSConflict='✖'  # ✖x local has x conflicts
_xRSUnstaged='✎'  # ✎x local has x files changed but not staged
_xRSUntracked='⍉' # ⍉x local has x files which is not tracked

ZSH_THEME_REPO_HIGHTLIGHT=false
ZSH_THEME_REPO_SHOW_GIT_USER=true
ZSH_THEME_REPO_SHOW_REMOTE_INFO=true

_GIT_REPO_NAME=""
_IS_IN_GIT_REPO="false"
function is_in_git_repo() {
  _GIT_REPO_NAME=""
  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    _IS_IN_GIT_REPO="true"
  else
    _IS_IN_GIT_REPO="false"
  fi
}

# Current directory of full path with symbolic link resolved
_THIS_DIR="$(realpath ${0%/*})"
_GITSTATUS_PY_DIR="$_THIS_DIR/../plugins/git-prompt"
function update_git_vars() {
  is_in_git_repo
  [[ "$_IS_IN_GIT_REPO" != "true" ]] && return

  local gitstatus="$_GITSTATUS_PY_DIR/gitstatus.py"
  local repostatus=$(python3 ${gitstatus} 2>/dev/null)
  repostatus=("${(@s: :)repostatus}")

  _GIT_REPO_BRANCH=$repostatus[1]
  _GIT_REPO_AHEAD=$repostatus[2]
  _GIT_REPO_BEHIND=$repostatus[3]
  _GIT_REPO_STAGED=$repostatus[4]
  _GIT_REPO_CONFLICTS=$repostatus[5]
  _GIT_REPO_CHANGED=$repostatus[6]
  _GIT_REPO_UNTRACKED=$repostatus[7]
  _GIT_REPO_STASHED=$repostatus[8]
  _GIT_REPO_CLEAN=$repostatus[9]
}

# Color Names
# white black yellow cyan magenta blue grey green red
#
# zsh Docs
# https://zsh.sourceforge.io/Doc/Release/zsh_toc.html
################################################################################
# Each segment will draw itself, and hide itself if no info needs to be shown  #
################################################################################
function draw_segment() {
  local color1=$1
  local message=$2
  local color2="${3:-black}"
  if [[ "$ZSH_THEME_REPO_HIGHTLIGHT" = "true" ]]; then
    echo -n "%{%K{$color1}%}%{%F{$color2}%}$message%f%k"
  else
    echo -n "%{%F{$color1}%}%{%K{$color2}%}$message%f%k"
  fi
}

# Check the working status:
# - was there an error
# - am I root
# - are there background jobs?
function show_status() {
  [[ "$_IS_IN_GIT_REPO" = "true" ]] && draw_segment cyan "$_xLmPrefix"
  [[ $RETVAL -ne 0 ]] && draw_segment red "$_xCmdError"
  [[ $UID -eq 0 ]] && draw_segment yellow "$_xIsRoot"
  [[ $(jobs -l | wc -l) -gt 0 ]] && draw_segment cyan "$_xHasJobs"
}

# user@hostname (who am I and where am I)
function show_user_host() {
  if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    draw_segment blue "%n"
    draw_segment red "@"
    draw_segment yellow "%m"
    draw_segment red "$_xSeparator"
  fi
}

# The working directory path
function show_workding_directory() {
  local xpath=$(pwd)
  _GIT_REPO_NAME="$(git_repo_name)"

  if [[ -h "$xpath" && -n "$_GIT_REPO_NAME" ]]; then
    # 当前路径是软链接，查找其链接文件路径
    local hlpath="$xpath"
    while [ -h $hlpath ]; do # 非软链接，则退出循环
      hlpath=$(ls -ld $hlpath | awk '{print $NF}')
    done
    local repo_path=$(git rev-parse --show-toplevel 2>/dev/null)
    # 已经获取软链接指向的路径, 判断其是否是 GIT 仓库路径
    if [[ "$hlpath" = "$repo_path" ]]; then
      # 将软链接的文件名标记为仓库名称
      _GIT_REPO_NAME=${xpath:t}
    fi
  fi

  # zsh数组操作 https://www.jianshu.com/p/ed9338ee219e
  # 正向: 开始索引 1，逆向: 开始索引 -1
  xpath=(${xpath//\// }) # space replace /
  local xarray=(${=xpath}) # convert to array
  if [[ "$xarray[1]" = "home" && "$xarray[2]" = "$USERNAME" ]]; then
    draw_segment magenta "~"
    xarray[1]=() # delete first one
    xarray[1]=() # do it again
  fi

  for item ($xarray) {
    if [[ "$_GIT_REPO_NAME" = "$item" ]]; then
      draw_segment blue "/"
      draw_segment green "$item"
    else
      draw_segment blue "/"
      draw_segment magenta "$item"
    fi
  }
  draw_segment blue "/"
}

function show_git_repo_information() {
  [[ "$_IS_IN_GIT_REPO" != "true" ]] && return # NOT in git repo

  if [[ "$ZSH_THEME_REPO_SHOW_GIT_USER" = "true" ]]; then
    draw_segment red "$_xSeparator"
    local user_name="$(git_current_user_name)"
    local user_email="$(git_current_user_email)"
    draw_segment blue "$user_name"
    draw_segment green "<"
    draw_segment yellow "$user_email"
    draw_segment green ">"
  fi

  echo "" # newline
  draw_segment cyan "$_xLnPrefix"
  draw_segment green "$_GIT_REPO_NAME"

  local short_sha="$(git rev-parse --short HEAD 2> /dev/null)"
  if [[ -n "$_GIT_REPO_BRANCH" ]]; then
    draw_segment red "$_xRSBranch"
    draw_segment blue "$_GIT_REPO_BRANCH"
    draw_segment yellow "($short_sha)"

    if [[ "$ZSH_THEME_REPO_SHOW_REMOTE_INFO" = "true" ]]; then
      local remotes=$(git remote -v | awk '{print $(NF-2)}' | sed 's/\n/ /g')
      if [[ -n "$remotes" ]]; then
        remotes=(${=remotes}) # 转换为数组
        remotes=(${(u)remotes}) # 删除重复项
      fi
      for item ($remotes) {
        local xinfo=$(git show-ref $item/$_GIT_REPO_BRANCH)
        if [[ -n "$xinfo" ]]; then
          draw_segment green "->"
          draw_segment magenta "$item/$_GIT_REPO_BRANCH"
          break
        fi
      }
    fi
  else
    draw_segment red "$_xRSBranch"
    draw_segment yellow "$short_sha"
  fi

  draw_segment red "$_xSeparator"

  if [[ "$_GIT_REPO_CLEAN" -eq "1" ]]; then
    draw_segment green "$_xRSClean"
  fi

  if [[ "$_GIT_REPO_AHEAD" -ne "0" ]]; then
    draw_segment green "$_xRSAhead$_GIT_REPO_AHEAD"
  fi
  if [[ "$_GIT_REPO_BEHIND" -ne "0" ]]; then
    draw_segment red "$_xRSBehind$_GIT_REPO_BEHIND"
  fi

  if [[ "$_GIT_REPO_STAGED" -ne "0" ]]; then
    draw_segment green "$_xRSStaged$_GIT_REPO_STAGED"
  fi
  if [[ "$_GIT_REPO_CHANGED" -ne "0" ]]; then
    draw_segment blue "$_xRSUnstaged$_GIT_REPO_CHANGED"
  fi
  if [[ "$_GIT_REPO_UNTRACKED" -ne "0" ]]; then
    draw_segment red "$_xRSUntracked$_GIT_REPO_UNTRACKED"
  fi
  if [[ "$_GIT_REPO_STASHED" -ne "0" ]]; then
    draw_segment blue "$_xRSStash$_GIT_REPO_STASHED"
  fi
  if [[ "$_GIT_REPO_CONFLICTS" -ne "0" ]]; then
    draw_segment red "$_xRSConflict$_GIT_REPO_CONFLICTS"
  fi
}

function main() {
  RETVAL=$?
  local _ts=$(date +%s.%N)
  show_status
  show_user_host
  show_workding_directory
  show_git_repo_information
  local _te=$(date +%s.%N)
  draw_segment red "$_xSeparator"
  draw_segment magenta "`printf "%d" $(( (_te - _ts)*1000 ))`ms"
  # 显示 zsh 主题加载刷新时间
  draw_segment cyan " $ "
}

PROMPT='$(main)'

# 显示命令执行时间
function time_keep() {
  _cmd_time_s=$(date +%s.%N)
}

function time_show() {
  if [ $_cmd_time_s ]; then
    local _cmd_time_e=$(date +%s.%N)
    time_used=`printf "%d" $(( (_cmd_time_e - _cmd_time_s)*1000 ))`
    RPROMPT='%{%F{green}%}$_xSepLeft%{%F{red}%}${time_used}ms%{%F{green}%}$_xSepRight%f'
    unset _cmd_time_s
  fi
}

# https://zsh.sourceforge.io/Doc/Release/Functions.html
autoload -Uz add-zsh-hook
# Executed before each prompt.
add-zsh-hook precmd time_show
# Executed just after a command has been read and is about to be executed.
add-zsh-hook preexec time_keep
# Executed whenever the current working directory is changed.
add-zsh-hook chpwd update_git_vars
