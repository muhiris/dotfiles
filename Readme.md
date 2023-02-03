Just a few Key Steps for installing the following after installing paste the folder in $HOME/.config folder.


sudo apt install build-essentials git


#Alacritty Install 
git clone https://github.com/alacritty/alacritty.git
cd alacritty
rustup override set stable
rustup update stable
sudo apt-get install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
cargo build --release
sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database
#Move the starship.toml file from alacritty Folder to $HOME/.config
curl -sS https://starship.rs/install.sh | sh

#ZSH
sudo apt install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
chsh -s $(which zsh)


//Nerd Font Initialize
mkdir ~/.local/share/fonts
#Have to unzip there or paste manually
mv CascadiaCode_Nerd Font ~/.local/share/fonts
sudo fc-cache -fv


#Install Qtile
sudo apt install pip
pip install xcffib
pip install qtile
sudo apt-get install qtile
cd /usr/share/xsessions/
touch qtile.desktop
echo "[Desktop Entry]
Name=Qtile
Comment=Qtile Session
Exec=qtile start
Type=Application
Keywords=wm;tiling" >> qtile.desktop


# Install i3
sudo apt install i3

# Install NeoVim
sudo apt-get install python-dev python-pip python3-dev python3-pip
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim
# To run the config
save plugin file --> nvim/lua/haris/plugins.lua


