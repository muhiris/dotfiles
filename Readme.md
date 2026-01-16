> Note After Installation, paste the above folders in `$HOME/.config` folder.


## Prerequisite
```console
sudo apt install build-essentials git
```
## Alacritty Installation

```console
sudo apt install alacritty -y
git clone https://github.com/alacritty/alacritty.git
cd alacritty
rustup override set stable
rustup update stable
sudo apt-get install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
sudo apt install cargo
cargo build --release
# To Check If allacritty is installed correctly
# sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
# infocmp alacritty
sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database
curl -sS https://starship.rs/install.sh | sh
```
> Note: Move the `starship.toml` file from alacritty Folder to `$HOME/.config`

> Add the following to the end of `~/.bashrc` :
```console
eval "$(starship init bash)"
```



## ZSH - Ohmyzsh Installation
```console
sudo apt install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
chsh -s $(which zsh)
```

## Nerd Font Initialize
>Have to unzip there or paste manually
```console
mkdir ~/.local/share/fonts
mv "CascadiaCode_Nerd Font" ~/.local/share/fonts
sudo fc-cache -fv
```

## Qtile Installation
```console
sudo apt install pip
pip install xcffib
pip install qtile
sudo cd /usr/share/xsessions/
sudo touch qtile.desktop
sudo echo "[Desktop Entry]
Name=Qtile
Comment=Qtile Session
Exec=qtile start
Type=Application
Keywords=wm;tiling" >> qtile.desktop
```

> Add the following to the start of `~/.bashrc` :
```console
PATH=$HOME/.local/bin:$PATH
```

Add this path to .bashrc file  
## i3 Installation
```console
sudo apt install i3
```

## NeoVim Installation
```console
sudo apt-get install python-dev python-pip python3-dev python3-pip
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim
```
> To run the config `save plugin file with :w (loc)--> nvim/lua/haris/plugins.lua`


