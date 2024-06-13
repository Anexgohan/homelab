#!/bin/bash

# ==================== oh-my-posh ==================== #
echo
echo '-----'
echo "install with the following command:"
echo -e "1." "\e[36m""curl https://raw.githubusercontent.com/Anexgohan/homelab/main/scripts/oh-my-post-install.sh | bash""\e[0m"
echo -e "2." "\e[36m""wget -qO- https://raw.githubusercontent.com/Anexgohan/homelab/main/scripts/oh-my-post-install.sh | bash""\e[0m"

# ---------- Variables (change these) ---------- #
echo '-----'
# save directory path:
DIR_PATH="/root/anex/oh-my-posh"
echo -e "\e[32m""Directory path: $DIR_PATH""\e[0m"

# ---------- Script (do not edit below if you do not know what you are doing) ---------- #
echo '-----'
echo -e "\e[32m""Script will install oh-my-posh: $DIR_PATH""\e[0m"
echo -e "\e[32m""Profiles will be downloaded to: $DIR_PATH/profiles""\e[0m"
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
apt-get install -y -q curl unzip
# download oh-my-posh anex custom script:
curl -s https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/scripts/linux/install.sh -o $DIR_PATH/install.sh
sh $DIR_PATH/install.sh
# curl -s https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/scripts/linux/install.sh | bash -s
# curl -s https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/scripts/linux/install.sh | bash -s -- -d $DIR_PATH

echo '-----'
echo -e "For more information, visit:" "\e[36m"https://www.nerdfonts.com/font-downloads"\e[0m"
echo -e "Recommended Fonts:" "\e[32m""FiraCode or Meslo LGM NF""\e[0m"
echo '-----'

echo -e "\e[32m""Do you want to install fonts? (y/n)""\e[0m"
read install_fonts
install_fonts=$(echo $install_fonts | tr '[:upper:]' '[:lower:]')
if [ "$install_fonts" = "y" ] || [ "$install_fonts" = "yes" ]; then
    # present a choice of fonts to install:
    echo "Please select a font to install:"
    echo # Recommended: FiraCode or Meslo LGM NF
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

# download "anex.omp.json" profile using curl:
curl -s --create-dirs --output-dir "$DIR_PATH/profiles" -O https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/profiles/json/anex.omp.json
# download "anex.omp.json" profile using wget:
# wget -N -P "$DIR_PATH/profiles" 'https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/profiles/json/anex.omp.json'

# add oh-my-posh profile to ".bashrc" if not already present:
# oh-my-posh
# eval "$(oh-my-posh init bash --config $DIR_PATH/profiles/anex.omp.json)"
if ! grep -Fxq 'eval "$(oh-my-posh init bash --config '"$DIR_PATH"'/profiles/anex.omp.json)"' /root/.bashrc
then
    echo -e "\n\n# oh-my-posh" '\neval "$(oh-my-posh init bash --config '"$DIR_PATH"'/profiles/anex.omp.json)"' | tee -a /root/.bashrc
fi

echo '-----'
echo -e "\e[32m""oh-my-posh installation complete.""\e[0m"
# reload your profile for the changes to take effect:
# note: no other command can run after "exec bash" in the script, keep all commands above only.
exec bash
