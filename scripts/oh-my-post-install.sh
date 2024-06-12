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
curl -s https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/scripts/linux/install.sh -o $DIR_PATH/install.sh
bash $DIR_PATH/install.sh
# curl -s https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/scripts/linux/install.sh | bash -s
# curl -s https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/scripts/linux/install.sh | bash -s -- -d $DIR_PATH

echo '-----'
echo "For more information, visit: https://www.nerdfonts.com/font-downloads"
echo "Recommended Fonts: FiraCode or Meslo LGM NF"
echo '-----'
echo "Do you want to install fonts? (y/n)"
read install_fonts
# convert to lowercase:
install_fonts=$(echo $install_fonts | tr '[:upper:]' '[:lower:]')
if [ "$install_fonts" = "y" ] || [ "$install_fonts" = "yes" ]; then
    # present a choice of fonts to install:
    echo "Please select a font to install:"
    echo "Recommended: FiraCode or Meslo LGM NF"
    options=("FiraCode" "MonoFont" "Select manually")
    select opt in "${options[@]}"
    do
        case $opt in
            "FiraCode")
                oh-my-posh font install FiraCode
                break
                ;;
            "MonoFont")
                oh-my-posh font install Meslo
                break
                ;;
            "Select manually")
                oh-my-posh font install
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
fi

# download profile "anex.omp.json" using wget to DIR_PATH/profiles:
wget -N -P $DIR_PATH/profiles 'https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/profiles/json/anex.omp.json'

# edit .bashrc to include oh-my-posh initialization edit if not already present:
if ! grep -Fxq "eval \"$(oh-my-posh init bash --config $DIR_PATH/profiles/anex.omp.json)\"" /root/.bashrc
then
    echo -e "\n\n# oh-my-posh\neval \"$(oh-my-posh init bash --config $DIR_PATH/profiles/anex.omp.json)\"" | tee -a /root/.bashrc
fi

exec bash