# auto Completion
# autoload -Uz compinit
# compinit
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi
source /usr/share/nvm/init-nvm.sh


# >>>> Vagrant command completion (start)
# fpath=(/opt/vagrant/embedded/gems/2.3.3/gems/vagrant-2.3.3/contrib/zsh $fpath)
# compinit
# <<<<  Vagrant command completion (end)
fpath=(/usr/local/share/zsh-completions $fpath)

# alias vi=vim
#export VAGRANT_DEFAULT_PROVIDER=virtualbox

## >>> conda initialize >>>
## !! Contents within this block are managed by 'conda init' !!
#__conda_setup="$('/home/admin/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
#if [ $? -eq 0 ]; then
#    eval "$__conda_setup"
#else
#    if [ -f "/home/admin/anaconda3/etc/profile.d/conda.sh" ]; then
#        . "/home/admin/anaconda3/etc/profile.d/conda.sh"
#    else
#        export PATH="/home/admin/anaconda3/bin:$PATH"
#    fi
#fi
#unset __conda_setup
## <<< conda initialize <<<
#source /etc/profile
# function showproxy() {
# env | grep -i proxy
# }
#export PATH=$PATH:~/go/bin/
#export PATH=/home/admin/istio-1.20.3/bin:$PATH
#export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
#alias myvpc="tailscale  ssh easyadmin@kvmla-pro-sg"
# my_cunction
# function kustomizeIt {
#     kustomize build \
#     --enable-helm \
#     $1
# }
## ollama
## export OLLAMA_HOST=0.0.0.0
## go
# export GOPROXY=https://goproxy.io,direct
# export TERM=xterm-256color

# . "/home/admin/.acme.sh/acme.sh.env"
