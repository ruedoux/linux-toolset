#!/bin/bash

[[ $- != *i* ]] && return
PS1='[\u@\h \W]\$ '

if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# EXPORTS
export PATH=$PATH:$HOME/.local/bin
export DOTNET_CLI_TELEMETRY_OPTOUT=1

export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=erasedups:ignoredups:ignorespace
shopt -s checkwinsize
shopt -s histappend
PROMPT_COMMAND='history -a'

if [[ $iatest -gt 0 ]]; then bind "set completion-ignore-case on"; fi
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi
if [[ $iatest -gt 0 ]]; then bind "set bell-style visible"; fi

export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ALIASES
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -Flah'
alias cd='cd_func() { builtin cd "$@" && ls -a; }; cd_func'
alias cp='cp -i'
alias mv='mv -i'
alias cls='clear'
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'

# FUNCTIONS
extract() {
	for archive in "$@"; do
		if [ -f "$archive" ]; then
			case $archive in
			*.tar.bz2) tar xvjf $archive ;;
			*.tar.gz) tar xvzf $archive ;;
			*.bz2) bunzip2 $archive ;;
			*.rar) rar x $archive ;;
			*.gz) gunzip $archive ;;
			*.tar) tar xvf $archive ;;
			*.tbz2) tar xvjf $archive ;;
			*.tgz) tar xvzf $archive ;;
			*.zip) unzip $archive ;;
			*.Z) uncompress $archive ;;
			*.7z) 7z x $archive ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

# INIT
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

if [ -f $(which pyenv) ]; then
	export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - bash)"
fi

# CUSTOM ENV
export SCRIPT_DIR=$HOME/files/scripts
export PATH=$PATH:$SCRIPT_DIR
export BASHRC_EXTENSION_PATH=$HOME/bashrc-extension.sh

if [ -f $BASHRC_EXTENSION_PATH ]; then
  . $BASHRC_EXTENSION_PATH
else
  echo "extend the .bashrc functionality by creating '${BASHRC_EXTENSION_PATH}' file"
fi
