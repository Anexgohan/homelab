#!/usr/bin/env bash

# ==================== oh-my-posh ==================== #

# ---------- Variables (change these) ---------- #
echo -e '-----'
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
mkdir -p $DIR_PATH/scripts
# check if directory was created and has write permissions:
if [ ! -d "$DIR_PATH" ] || [ ! -w "$DIR_PATH" ]; then
    echo "Directory $DIR_PATH does not exist or does not have write permissions."
    exit 1
fi
# change directory:
cd $DIR_PATH
# install dependencies:
apt-get install -y -q curl unzip

# ----- initialization script ----- #

# Download the script
curl -o $DIR_PATH/scripts/middleware.sh https://raw.githubusercontent.com/Anexgohan/homelab/main/configs/terminal/oh-my-posh/scripts/linux/middleware.sh

# Make the script executable
chmod +x $DIR_PATH/scripts/middleware.sh

# Run the script
echo '-----'
echo "Running middleware script..."
#source $DIR_PATH/scripts/middleware.sh
# or
# . $DIR_PATH/scripts/middleware.sh < /dev/tty
# To use it for a parent process e.g., substitute $$ with $PPID.
. $DIR_PATH/scripts/middleware.sh < "/dev/$(ps -p $PPID -o tty=)"
