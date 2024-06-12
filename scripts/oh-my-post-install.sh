#!/bin/bash

# ==================== oh-my-posh ==================== #
echo '-----'
echo "install with the following command:"
echo "curl -s https://raw.githubusercontent.com/Anexgohan/homelab/main/scripts/oh-my-post-install.sh | bash"
echo "wget -qO- https://raw.githubusercontent.com/Anexgohan/homelab/main/scripts/oh-my-post-install.sh | bash"

# ---------- Variables (change these) ---------- #
echo '-----'
# save directory path:
DIR_PATH="/root/anex/oh-my-posh"
echo "Directory path: $DIR_PATH"

# ---------- Script (do not edit below if you do not know what you are doing) ---------- #
echo '-----'
echo "Script will install oh-my-posh: $DIR_PATH"
echo "Profiles will be downloaded to: $DIR_PATH/profiles"
echo '-----'
# make directory DIR_PATH:
mkdir -p $DIR_PATH
mkdir -p $DIR_PATH/profiles
# check if directory was created and has write permissions:
if [ ! -d "$DIR_PATH" ] || [ ! -w "$DIR_PATH" ]; then
    echo "Directory $DIR_PATH does not exist or does not have write permissions."
    exit 1
fi
# change directory:
cd $DIR_PATH
# install dependencies:
apt-get install -y curl wget unzip
# download oh-my-posh anex custom script:
# curl -s https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/scripts/linux/install.sh | bash -s
curl -s https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/scripts/linux/install.sh | bash -s -- -d $DIR_PATH

echo '-----'
echo "For more information, visit: https://www.nerdfonts.com/font-downloads"
echo "Recommended Fonts: FiraCode or Meslo LGM NF"
echo '-----'
# ask user to proceed y,Y,n,N:
read -p "Do you want to proceed with the installation of the recommended fonts? (y/n): " -n 1 -r

# download profile "anex.omp.json" using wget to DIR_PATH/profiles:
wget -N -P $DIR_PATH/profiles 'https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/profiles/json/anex.omp.json'

# edit .bashrc to include oh-my-posh initialization edit if not already present:
if ! grep -Fxq 'eval "$(oh-my-posh init bash --config $DIR_PATH/profiles/anex.omp.json)"' /root/.bashrc
then
    echo -e '\n\n# oh-my-posh''\neval "$(oh-my-posh init bash --config $DIR_PATH/profiles/anex.omp.json)"' | tee -a /root/.bashrc
fi

exec bash