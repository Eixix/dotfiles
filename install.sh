#!/bin/bash

# TODO: Fonts, NVM, LVIM

# Execute with "sudo bash install.sh"
while true; do
  echo "Enter your user username"
  read USER

  HOME="/home/$USER"

  if [ -d "$HOME" ]; then
    break
  else
    echo "User does not exist, enter a real user"
  fi
done

sed -i 's/#EnableAUR/EnableAUR/' /etc/pamac.conf

echo "========================================="
echo "Install Default packages and updates"
yes | sudo -u $USER install_pulse
pacman -Syu --noconfirm
pacman -S git npm numlockx rust yubikey-manager-qt yubikey-personalization-gui yubioath-desktop thunderbird telegram-desktop signal-desktop dolphin direnv exa neovim --noconfirm
pamac install whatsapp-for-linux visual-studio-code-bin google-chrome --no-confirm

echo "========================================="
echo "Install zsh"
yes | sudo -u $USER sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "========================================="
echo "Install lunarvim"
yes | sudo -u $USER sh -c "$(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)" -y

echo "========================================="
echo "GPG keys integration"
KEYID="0x4b7228cfe59b7380"
sudo -u $USER gpg --recv $KEYID
echo -e "5y" | sudo -u $USER gpg --command-fd 0 --edit-key "$KEYID" trust
wget -O -P $HOME/.gnupg/gpg-agent.conf https://raw.githubusercontent.com/drduh/config/master/gpg-agent.conf

# Configure for git
sudo -u $USER git config --global user.signingkey "$KEYID"
sudo -u $USER git config --global commit.gpgsign true

echo "========================================="
echo "Clone and link dotfiles"
sudo -u $USER git clone https://github.com/Eixix/.dotfiles
sudo -u $USER git -C .dotfiles remote set-url origin git@github.com:Eixix/.dotfiles.git
sudo -u $USER rm $HOME/.zshrc $HOME/.Xresources
sudo -u $USER ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc
sudo -u $USER ln -s $HOME/.dotfiles/.Xresources $HOME/.Xresources
sudo -u $USER rm $HOME/.i3/config
sudo -u $USER ln -s $HOME/.dotfiles/config $HOME/.i3/config

echo "========================================="
echo "Add Yubikey PAM auth to all configs"
pamu2fcfg > ~/.config/Yubico/u2f_keys
PAM_LINE="auth sufficient pam_u2f.so"
echo $PAM_LINE >> /etc/pam.d/sudo
echo $PAM_LINE >> /etc/pam.d/polkit-1
echo $PAM_LINE >> /etc/pam.d/lightdm
echo $PAM_LINE >> /etc/pam.d/i3lock

echo "========================================="
echo "Install optional software"
while true; do
    read -p "Do you wish to install Discord? " yn
    case $yn in
        [Yy]* ) pamac install discord --no-confirm; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
  done

while true; do
    read -p "Do you wish to install Steam? " yn
    case $yn in
        [Yy]* ) pamac install steam-manjaro --no-confirm; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
  done

while true; do
    read -p "Do you wish to install Corsair drivers? " yn
    case $yn in
        [Yy]* ) pamac install ckb-next --no-confirm; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
  done
