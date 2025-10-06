# Pop Os Settings

## ZSH

```bash
sudo apt install zsh neovim zip unzip curl
```

## Oh my posh
```bash
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.config/zsh
```

## SDKMAN
```
curl -s "https://get.sdkman.io" | bash
```


## Dotfiles

`.zshrc`: 
```.zshrc
#Set up the prompt

autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
# zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'


source $HOME/.config/zsh/env.cfg
eval "$(oh-my-posh init zsh --config $HOME/.config/zsh/zen.toml)"
```
___

`.config/zsh/env.cfg`:
```cfg
export ZSH_HOME=$HOME/.config/zsh
export PATH=$PATH:$ZSH_HOME
export M2_HOME=$HOME/.sdkman/candidates/maven/current
export JAVA_HOME=$HOME/.sdkman/candidates/java/current
export PATH=$PATH:$M2_HOME/bin
export PATH=$PATH:JAVA_HOME/bin

source $ZSH_HOME/aliases.cfg

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
```

___
`.config/zsh/aliases.cfg`:
```cfg
# aliases
alias l="ls -l --color"
alias ls="ls --color"
alias la="ls -la --color"
alias ll="ls -ll --color"
alias vim="nvim"
alias config="nvim ~/.config/zsh"


# functions
function aze() {
	if [ -n "$1" ]; then
	  m "fix" && git rebase -i HEAD~$1 && git push -f
	else
	  m "fix" && git rebase -i HEAD~2 && git push -f
	fi
}

function m() {
	if [ -n "$1" ]; then
	  git add . && git commit -am "$1" && git push -f
	else
	  git add . && git commit -am "no message" && git push -f
	fi
}

function update() {
    echo "update dependencies ..."
	sudo apt update
    echo "upgrade dependencies ... "
	sudo apt upgrade
    echo "remove unnecessary dependencies ... "
	sudo apt autoremove
    echo "update flatpak dependencies ... "
	flatpak update
    echo "sdk self update"
    sdk selfupdate
    echo "sdk update"
    sdk update
}
```

___
`.config/zsh/zen.toml`:
```toml
console_title_template = '{{ .Shell }} in {{ .Folder }}'
version = 3
final_space = true

[secondary_prompt]
  template = '❯❯ '
  foreground = 'magenta'
  background = 'transparent'

[transient_prompt]
  template = '❯ '
  background = 'transparent'
  foreground_templates = ['{{if gt .Code 0}}red{{end}}', '{{if eq .Code 0}}magenta{{end}}']

[[blocks]]
  type = 'prompt'
  alignment = 'left'
  newline = true

  [[blocks.segments]]
    template = '{{ .Path }}'
    foreground = 'blue'
    background = 'transparent'
    type = 'path'
    style = 'plain'

    [blocks.segments.properties]
      style = 'full'

  [[blocks.segments]]
    template = ' {{ .HEAD }}{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }} <cyan>{{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}</>'
    foreground = 'p:grey'
    background = 'transparent'
    type = 'git'
    style = 'plain'

    [blocks.segments.properties]
      branch_icon = ''
      commit_icon = '@'
      fetch_status = true

[[blocks]]
  type = 'rprompt'
  overflow = 'hidden'

  [[blocks.segments]]
    template = '{{ .FormattedMs }}'
    foreground = 'yellow'
    background = 'transparent'
    type = 'executiontime'
    style = 'plain'

    [blocks.segments.properties]
      threshold = 5000

[[blocks]]
  type = 'prompt'
  alignment = 'left'
  newline = true

  [[blocks.segments]]
    template = '❯'
    background = 'transparent'
    type = 'text'
    style = 'plain'
    foreground_templates = ['{{if gt .Code 0}}red{{end}}', '{{if eq .Code 0}}magenta{{end}}']
```
