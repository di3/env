# If not running interactively, don't do anything
[[ $- != *i* ]] && return

trap "" DEBUG

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#bell
if [ -n "$DISPLAY" ]; then
  xset b off
fi

# History settings
export HISTIGNORE="&:ls:[bf]g:exit:reset:clear:cd*:ll:la:l:lll:cls:hg:history";
export HISTSIZE=4096;
export HISTCONTROL="ignoreboth:erasedups"
shopt -s histreedit;

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color) color_prompt=yes;;
esac

# colored prompt, if the terminal has the capability
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  if [[ $EUID == 0 ]] ; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '
  else
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '
  fi
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
  ;;
*)
  ;;
esac

# dynamic screen titles
if [ "$TERM" = "screen" ]; then
    export PROMPT_COMMAND='true'
    set_screen_window() {
      #HPWD=`basename "$PWD"`
      HPWD=`pwd`
      if [ "$HPWD" = "$USER" ]; then HPWD='~'; fi
      if [ ${#HPWD} -ge 20 ]; then HPWD='..'${HPWD:${#HPWD}-18:${#HPWD}}; fi
      case "$BASH_COMMAND" in
        *\033]0*);;
        "true")
            printf '\ek%s\e\\' "$HPWD"
            ;;
        *)
            printf '\ek%s\e\\' "$HPWD: ${BASH_COMMAND:0:20}"
            ;;
      esac
    }
    trap set_screen_window DEBUG
fi

# EDITOR is vim
export EDITOR=vim;

# Color definitions
if [ -f ~/.bash_colors ]; then
  . ~/.bash_colors
fi

# Alias definitions.
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi
alias ll='ls -l --group-directories-first'
alias lla='ls -lA --group-directories-first'
alias la='ls -A'
alias l='ls -CF'
alias lll='ls -la | less'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cls='clear'

# history
alias hg='history | grep '

# sudo
alias apt-get='sudo apt-get'
alias sudo='sudo '

# get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

# get top process eating cpu
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'

alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'

alias mt='mount | column -t'

alias ports='netstat -tulanp'

# output without comments
alias nocomment='grep -Ev '\''^(#|$)'\'''

# Shows the individual partition usages without the temporary memory values
alias partusage='df -hlT --exclude-type=tmpfs --exclude-type=devtmpfs'

# Gives you what is using the most space. Both directories and files. Varies on current directory
alias most='du -hsx * | sort -rh | head -10'

alias psme='ps -ef | grep $USER --color=always '
alias ps2='ps -ef | grep -v $$ | grep -i '

alias ktcp='sudo ngrep -qK 1 $1 -d wlan0'
alias c='sudo lsof -n -P -i +c 15'

# git stuff
alias gr='git rm -rf'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'

# Function definitions.
function gp() {
  git push -u origin ${1:-"main"}
}
function gl() {
  git pull origin ${1:-"main"}
}
# git status
function gu() {
  local UPSTREAM=${1:-'@{u}'}
  local LOCAL=$(git rev-parse @)
  local REMOTE=$(git rev-parse "$UPSTREAM")
  local BASE=$(git merge-base @ "$UPSTREAM")

  git fetch
  if [ "$LOCAL" = "$REMOTE" ]; then
    echo "Up-to-date"
  elif [ "$LOCAL" = "$BASE" ]; then
    echo "Need to pull"
  elif [ "$REMOTE" = "$BASE" ]; then
    echo "Need to push"
  else
    echo "Diverged"
  fi
}

# pipe something
function pipe() {
  ${1:-} | ${2:-}
}

# mkdir and cd into it 
function mkcd() {
  mkdir -pv -- "$1" && cd -P -- "$1"
}

# remove current directory
function rmcd() {
  local tmp=`pwd`
  cd ..
  rm -rf $tmp
}

# Find a file with a pattern in name:
function ff() { find . -type f -iname '*'"$*"'*' -ls ; }

# Find a file with pattern $1 in name and Execute $2 on it:
function fe() { find . -type f -iname '*'"${1:-}"'*' -exec ${2:-file} {} \;  ; }

#  Find a pattern in a set of files and highlight them:
#+ (needs a recent version of egrep).
function fstr() {
  OPTIND=1
  local mycase=""
  local usage="fstr: find string in files.
  Usage: fstr [-i] \"pattern\" [\"filename pattern\"] "
  while getopts :it opt
  do
    case "$opt" in
      i) mycase="-i " ;;
       *) echo "$usage"; return ;;
    esac
  done
  shift $(( $OPTIND - 1 ))
  if [ "$#" -lt 1 ]; then
    echo "$usage"
    return;
  fi
  find . -type f -name "${2:-*}" -print0 | \
  xargs -0 egrep --color=always -sn ${case} "$1" 2>&- | more
}

# swap two files
function swap() {
  local TMPFILE=tmp.$$

  [ $# -ne 2 ] && echo "swap: 2 arguments needed" && return 1
  [ ! -e $1 ] && echo "swap: $1 does not exist" && return 1
  [ ! -e $2 ] && echo "swap: $2 does not exist" && return 1

  mv "$1" $TMPFILE
  mv "$2" "$1"
  mv $TMPFILE "$2"
}

# aextract
function aextract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)  tar xvjf $1;;
      *.tar.gz)    tar xvzf $1;;
      *.tar.xz)   tar xvJf $1;;
      *.tar.7z)   7za x -so $1 | tar xf - --numeric-owner;;
      *.bz2)      bunzip2 $1;;
      *.gz)        gunzip $1;;
      *.tar)      tar xvf $1;;
      *.tbz2)      tar xvjf $1;;
      *.tgz)      tar xvzf $1;;
      *.zip)      unzip $1;;
      *.Z)        uncompress $1;;
      *.7z)        7zr x $1;;
      *) echo "don't know how to extract '$1'" ;;
    esac
  else
    echo "'$1' is not a valid file!"
  fi
}

function alist() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)  tar -jtvf $1;;
      *.tar.gz)   tar -ztvf $1;;
      *.gz)       tar -ztf $1;;
      *.tar)      tar -tf $1;;
      *.zip)      unzip -l $1;;
      *.7z)       7z l $1;;
      *) echo "don't know how to list '$1'" ;;
    esac
  else
    echo "'$1' is not a valid file!"
  fi
}

function acreate() {
  if [ -d $2 ] ; then
    case $1 in
      *.tar.gz)   tar -zcvf $1 $2;;
      *.tar.7z)   tar cf - $2 | 7za a -si $1;;
      *.gz)       tar -zcvf $1 $2;;
      *.tar)      tar -cf $1 $2;;
      *.zip)      7z a -tzip $1 $2;;
      *.7z)       7z a -t7z $1 $2;;
      *.tar.7z)       7z a -t7z $1 $2;;
      *) echo "don't know how to create '$1'" ;;
    esac
  else
    echo "'$1' is not a valid file!"
  fi
}

#grep files and open them with vim
function vg() {
  local usage="vg [path] grepstring"
  if [ -z "$1" ] ; then
    echo "No argument supplied"
    echo -e $usage
  else
    if [ $2 ] ; then
      vim -p $(ls -A -d -1 $PWD/$1* | grep $2)
    else
      vim -p $(ls -A | grep $1)
    fi
  fi
}

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export PATH="$PATH:$HOME/.composer/vendor/bin"
export PATH="$PATH:$HOME/.config/composer/vendor/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
