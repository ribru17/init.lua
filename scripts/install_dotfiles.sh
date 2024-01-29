git clone git@github.com:ribru17/.dotfiles.git $HOME/.dotfiles
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dots config --local status.showUntrackedFiles no
dots checkout
if [ $? = 0 ]; then
  echo "Installed config!";
  else
    echo "Must move or delete conflicting files.";
fi;
