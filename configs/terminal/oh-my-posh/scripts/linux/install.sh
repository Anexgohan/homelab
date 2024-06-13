#!/usr/bin/env bash
tty -s && echo -e "\e[32m""This shell is interactive""\e[0m" || echo -e "\e[32m""This shell is not interactive""\e[0m"
install_dir=""
themes_dir=""
executable=""

error() {
    printf "\e[31m$1\e[0m\n"
    exit 1
}

info() {
    printf "$1\n"
}

warn() {
    printf "⚠️  \e[33m$1\e[0m\n"
}

help() {
    # Display Help
    echo "Install script for Oh My Posh"
    echo
    echo "Syntax: install.sh [-h|d|t]"
    echo "\noptions:"
    echo "-h     Print this help."
    echo "-d     Specify the installation directory. Defaults to /usr/local/bin or the directory where oh-my-posh is installed."
    echo "-t     Specify the themes installation directory. Defaults to the oh-my-posh cache directory."
    echo
}

while getopts ":hd:t:" option; do
   case $option in
      h) # display Help
         help
         exit;;
      d) # Enter a name
         install_dir=${OPTARG};;
      t) # themes directory
         themes_dir=${OPTARG};;
     \?) # Invalid option
         echo "Invalid option command line option. Use -h for help."
         exit 1
   esac
done

SUPPORTED_TARGETS="linux-386 linux-amd64 linux-arm linux-arm64 darwin-amd64 darwin-arm64 freebsd-386 freebsd-amd64 freebsd-arm freebsd-arm64"

validate_dependency() {
    if ! command -v $1 >/dev/null; then
        error "$1 is required to install Oh My Posh. Please install $1 and try again.\n"
    fi
}

validate_dependencies() {
    validate_dependency curl
    validate_dependency unzip
    validate_dependency realpath
    validate_dependency dirname
}

set_install_directory() {
    if [ -n "$install_dir" ]; then
        # expand directory
        install_dir="${install_dir/#\~/$HOME}"
        return 0
    fi

    # check if we have oh-my-posh installed, if so, use the executable directory
    # to install into and follow symlinks
    if command -v oh-my-posh >/dev/null; then
        posh_dir=$(command -v oh-my-posh)
        real_dir=$(realpath $posh_dir)
        install_dir=$(dirname $real_dir)
        info "Oh My Posh is already installed, updating existing installation in:"
        info "  ${install_dir}"
    else
        install_dir="/usr/local/bin"
    fi
}

validate_install_directory() {
    if [ ! -d "$install_dir" ]; then
        error "Directory ${install_dir} does not exist, set a different directory and try again."
    fi

    # Check if sudo has write permission
    # anex sudo fix on proxmox bash
    if ! test -w "$install_dir"; then
        error "Cannot write to ${install_dir}. Please set a different directory and try again: \n  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d {directory}"
    # if ! sudo test -w "$install_dir"; then
    #     error "Cannot write to ${install_dir}. Please set a different directory and try again: \n  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d {directory}"
        
    # Check if regular user has write permission
    elif [ ! -w "$install_dir" ]; then
        error "Cannot write to ${install_dir}. Please set a different directory and try again: \n  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d {directory} OR use sudo"
    fi

    # check if the directory is in the PATH
    good=$(
        IFS=:
        for path in $PATH; do
        if [ "${path%/}" = "${install_dir}" ]; then
            printf 1
            break
        fi
        done
    )

    if [ "${good}" != "1" ]; then
        warn "Installation directory ${install_dir} is not in your \$PATH"
    fi
}

validate_themes_directory() {
    if [ ! -d "$install_dir" ]; then
        error "Directory ${install_dir} does not exist, set a different directory and try again."
    fi

    # Check if sudo has write permission
    # anex sudo fix on proxmox bash
    if ! test -w "$install_dir"; then
        error "Cannot write to ${install_dir}. Please set a different directory and try again: \n  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d {directory}"
    # if ! sudo test -w "$install_dir"; then
    #     error "Cannot write to ${install_dir}. Please set a different directory and try again: \n  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d {directory}"
        
    # Check if regular user has write permission
    elif [ ! -w "$install_dir" ]; then
        error "Cannot write to ${install_dir}. Please set a different directory and try again: \n  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d {directory} OR use sudo"
    fi

    # check if the directory is in the PATH
    good=$(
        IFS=:
        for path in $PATH; do
        if [ "${path%/}" = "${install_dir}" ]; then
            printf 1
            break
        fi
        done
    )

    if [ "${good}" != "1" ]; then
        warn "Installation directory ${install_dir} is not in your \$PATH"
    fi
}

install_themes() {
    if [ -n "$themes_dir" ]; then
        # expand directory
        themes_dir="${themes_dir/#\~/$HOME}"
    fi

    cache_dir=$($executable cache path)

    # validate if the user set the path to the themes directory
    if [ -z "$themes_dir" ]; then
        themes_dir="${cache_dir}/themes"
    fi

    # Validate if the themes directory exists
    if [ ! -d "$themes_dir" ]; then
        mkdir -p $themes_dir
    fi

    info "🎨 Installing oh-my-posh themes in ${themes_dir}\n"

    zip_file="${cache_dir}/themes.zip"

    url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip"

    http_response=$(curl -s -f -L $url -o $zip_file -w "%{http_code}")

    if [ $http_response = "200" ] && [ -f $zip_file ]; then
        unzip -o -q $zip_file -d $themes_dir
        # make sure the files are readable and writable for all users
        chmod a+rwX ${themes_dir}/*.omp.*
        rm $zip_file
    else
        warn "Unable to download themes at ${url}\nPlease validate your curl, connection and/or proxy settings"
    fi
}

install() {
    arch=$(detect_arch)
    platform=$(detect_platform)
    target="${platform}-${arch}"

    good=$(
        IFS=" "
        for t in $SUPPORTED_TARGETS; do
        if [ "${t}" = "${target}" ]; then
            printf 1
            break
        fi
        done
    )

    if [ "${good}" != "1" ]; then
        error "${arch} builds for ${platform} are not available for Oh My Posh"
    fi

    info "\nℹ️  Installing oh-my-posh for ${target} in ${install_dir}"

    executable=${install_dir}/oh-my-posh
    url=https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-${target}

    info "⬇️  Downloading oh-my-posh from ${url}"

    http_response=$(curl -s -f -L $url -o $executable -w "%{http_code}")

    if [ $http_response != "200" ] || [ ! -f $executable ]; then
        error "Unable to download executable at ${url}\nPlease validate your curl, connection and/or proxy settings"
    fi

    chmod +x $executable

    install_themes

    info "🚀 Installation complete.\n\nYou can follow the instructions at https://ohmyposh.dev/docs/installation/prompt"
    info "to setup your shell to use oh-my-posh."
    if [ $http_response = "200" ]; then
        info "\nIf you want to use a built-in theme, you can find them in the ${theme_dir} directory:"
        info "  oh-my-posh init {shell} --config ${theme_dir}/{theme}.omp.json\n"
    fi
}

detect_arch() {
  arch="$(uname -m | tr '[:upper:]' '[:lower:]')"

  case "${arch}" in
    x86_64) arch="amd64" ;;
    armv*) arch="arm" ;;
    arm64) arch="arm64" ;;
    aarch64) arch="arm64" ;;
    i686) arch="386" ;;
  esac

  if [ "${arch}" = "arm64" ] && [ "$(getconf LONG_BIT)" -eq 32 ]; then
    arch=arm
  fi

  printf '%s' "${arch}"
}


detect_platform() {
  platform="$(uname -s | awk '{print tolower($0)}')"

  case "${platform}" in
    linux) platform="linux" ;;
    darwin) platform="darwin" ;;
  esac

  printf '%s' "${platform}"
}

validate_dependencies
set_install_directory
validate_install_directory
install
