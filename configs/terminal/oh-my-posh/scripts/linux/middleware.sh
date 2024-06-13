#!/usr/bin/env bash

# ==================== oh-my-posh ==================== #

# download oh-my-posh anex custom script:
curl -s https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/scripts/linux/install.sh -o $DIR_PATH/scripts/install.sh
# chmod +x $DIR_PATH/scripts/install.sh
. $DIR_PATH/scripts/install.sh

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
    options=( "FiraCode" "Meslo LGM NF" "Inconsolata" "JetBrainsMono" "RobotoMono" "Ubuntu" "UbuntuMono" "More..")
    select opt in "${options[@]}"
    do
        case $opt in
            "FiraCode")
                oh-my-posh font install FiraCode
                break
                ;;
            "Meslo LGM NF")
                oh-my-posh font install Meslo
                break
                ;;
            "Inconsolata")
                oh-my-posh font install Inconsolata
                break
                ;;
            "JetBrainsMono")
                oh-my-posh font install JetBrainsMono
                break
                ;;
            "RobotoMono")
                oh-my-posh font install RobotoMono
                break
                ;;
            "Ubuntu")
                oh-my-posh font install Ubuntu
                break
                ;;
            "UbuntuMono")
                oh-my-posh font install UbuntuMono
                break
                ;;
            "More..")
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
echo -e "\e[32m""Profile saved at: $DIR_PATH/profiles""\e[0m"
# reload your profile for the changes to take effect:
# note: no other command can run after "exec bash" in the script, keep all commands above only.
exec bash
