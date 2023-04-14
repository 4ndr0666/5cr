#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Install yay AUR helper
if ! command -v yay &> /dev/null; then
    echo "Installing yay AUR helper..."
    pacman -S --noconfirm --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
fi

install_aur_pkg() {
    pkg_name=$1
    echo "Installing $pkg_name from AUR..."
    yay -S --noconfirm "$pkg_name"
}

# Update system
echo "Updating system..."
pacman -Syu --noconfirm

# Install graphics drivers
read -p "Do you want to install graphics drivers? (y/n): " install_drivers
if [ "$install_drivers" == "y" ]; then
    echo "Select your GPU manufacturer:"
    echo "1) NVIDIA"
    echo "2) AMD"
    read -p "Enter the number (1/2): " gpu_manufacturer

    case $gpu_manufacturer in
        1)
            pacman -S --noconfirm --needed nvidia nvidia-utils
            ;;
        2)
            pacman -S --noconfirm --needed xf86-video-amdgpu vulkan-radeon
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
fi

# Install basic utilities
echo "Installing basic utilities..."
pacman -S --noconfirm --needed \
    curl \
    wget \
    unzip \
    zip \
    p7zip \
    unrar \
    tar \
    gzip \
    bzip2 \
    xz \
    nano \
    vim \
    neovim \
    htop \
    glances \
    gparted \
    terminator \
    neofetch \
    filezilla \
    bleachbit \
    gnome-disk-utility \
    gnome-system-monitor \
    baobab \
    sysstat \
    iotop \
    iftop \
    powertop \
    nmon \
    lshw \
    lm_sensors

# Install codecs, fonts, and proprietary software
echo "Installing codecs, fonts, and proprietary software..."
pacman -S --noconfirm --needed \
    ttf-dejavu \
    ttf-liberation \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-cjk \
    ttf-hack \
    adobe-source-code-pro-fonts \
    ttf-roboto \
    ttf-opensans \
    ttf-droid \
    ttf-ubuntu-font-family \
    ttf-font-awesome \
    cantarell-fonts \
    gst-plugins-base \
    gst-plugins-good \
    gst-plugins-bad \
    gst-plugins-ugly \
    gst-libav \
    faac \
    faad2 \
    x265 \
    x264 \
    libdvdcss \
    libdvdread \
    libdvdnav \
    dvdbackup \
    dvdauthor \
    dvgrab \
    cdrdao \
    dvd+rw-tools

# Install desktop environments
echo "Select your desired desktop environment:"
echo "1) GNOME"
echo "2) KDE Plasma"
echo "3) XFCE"
echo "4) MATE"
echo "5) Cinnamon"
echo "6) Budgie"
echo "7) LXQt"
echo "8) LXDE"
echo "9) Deepin"
echo "10) None"
read -p "Enter the number (1-10): " desktop_environment

case $desktop_environment in
    1)
        pacman -S --noconfirm --needed gnome gnome-extra
        systemctl enable gdm.service
        ;;
    2)
        pacman -S --noconfirm --needed plasma-meta kde-applications-meta
        systemctl enable sddm.service
        ;;
    3)
        pacman -S --noconfirm --needed xfce4 xfce4-goodies
        systemctl enable lightdm.service
        ;;
    4)
        pacman -S --noconfirm --needed mate mate-extra
        systemctl enable lightdm.service
        ;;
    5)
        pacman -S --noconfirm --needed cinnamon
        systemctl enable lightdm.service
        ;;
    6)
        pacman -S --noconfirm --needed budgie-desktop
        systemctl enable gdm.service
        ;;
    7)
        pacman -S --noconfirm --needed lxqt
        systemctl enable sddm.service
        ;;
    8)
        pacman -S --noconfirm --needed lxde
        systemctl enable lxdm.service
        ;;
    9)
        pacman -S --noconfirm --needed deepin deepin-extra
        systemctl enable lightdm.service
        ;;
    10)
        echo "Skipping desktop environment installation"
        ;;
    *)
        echo "Invalid option"
        ;;
esac

# Install development tools
echo "Installing development tools..."
pacman -S --noconfirm --needed \
    base-devel \
    cmake \
    automake \
    autoconf \
    pkgconf \
    gcc \
    gdb \
    clang \
    lldb \
    python-pip \
    python-setuptools \
    python-wheel \
    python-virtualenv \
    python2-pip \
    python2-setuptools \
    python2-wheel \
    python2-virtualenv \
    ruby \
    rust \
    go \
    php \
    dotnet-sdk \
    jdk-openjdk \
    jre-openjdk \
    jdk8-openjdk \
    jre8-openjdk \
    nodejs \
    npm \
    yarn \
    docker \
    docker-compose \
    virtualbox \
    qemu \
    vagrant

# Install programming language extensions
echo "Installing programming language extensions..."
install_aur_pkg "visual-studio-code-bin"
code --install-extension ms-python.python
code --install-extension ms-vscode.cpptools
code --install-extension ms-dotnettools.csharp
code --install-extension vscjava.vscode-java-pack
code --install-extension rust-lang.rust
code --install-extension golang.go
code --install-extension rebornix.ruby
code --install-extension felixfbecker.php-pack
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension hashicorp.terraform
code --install-extension vscoss.vscode-ansible
code --install-extension redhat.vscode-yaml

# Install PostgreSQL
read -p "Do you want to install PostgreSQL? (y/n): " install_postgresql
if [ "$install_postgresql" == "y" ]; then
    pacman -S --noconfirm --needed postgresql
    sudo -u postgres initdb --locale en_US.UTF-8 -E UTF8 -D '/var/lib/postgres/data'
    systemctl enable postgresql.service
    systemctl start postgresql.service
fi

# Install MySQL
read -p "Do you want to install MySQL? (y/n): " install_mysql
if [ "$install_mysql" == "y" ]; then
    pacman -S --noconfirm --needed mariadb
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    systemctl enable mysqld.service
    systemctl start mysqld.service
fi

# Install SQLite
read -p "Do you want to install SQLite? (y/n): " install_sqlite
if [ "$install_sqlite" == "y" ]; then
    pacman -S --noconfirm --needed sqlite
fi

# Install Redis
read -p "Do you want to install Redis? (y/n): " install_redis
if [ "$install_redis" == "y" ]; then
    pacman -S --noconfirm --needed redis
    systemctl enable redis.service
    systemctl start redis.service
fi

# Install MongoDB
read -p "Do you want to install MongoDB? (y/n): " install_mongodb
if [ "$install_mongodb" == "y" ]; then
    install_aur_pkg "mongodb-bin"
    systemctl enable mongodb.service
    systemctl start mongodb.service
fi

# Install Elasticsearch
read -p "Do you want to install Elasticsearch? (y/n): " install_elasticsearch
if [ "$install_elasticsearch" == "y" ]; then
    pacman -S --noconfirm --needed elasticsearch
    systemctl enable elasticsearch.service
    systemctl start elasticsearch.service
fi

# Install Google Cloud SDK
read -p "Do you want to install Google Cloud SDK? (y/n): " install_gcloud
if [ "$install_gcloud" == "y" ]; then
    install_aur_pkg "google-cloud-sdk"
fi

# Install AWS CLI
read -p "Do you want to install AWS CLI? (y/n): " install_awscli
if [ "$install_awscli" == "y" ]; then
    pacman -S --noconfirm --needed aws-cli
fi

# Install Azure CLI
read -p "Do you want to install Azure CLI? (y/n): " install_azurecli
if [ "$install_azurecli" == "y" ]; then
    install_aur_pkg "azure-cli"
fi

# Install Heroku CLI
read -p "Do you want to install Heroku CLI? (y/n): " install_herokucli
if [ "$install_herokucli" == "y" ]; then
    install_aur_pkg "heroku-cli"
fi

# Install Terraform
read -p "Do you want to install Terraform? (y/n): " install_terraform
if [ "$install_terraform" == "y" ]; then
    pacman -S --noconfirm --needed terraform
fi

# Install Ansible
read -p "Do you want to install Ansible? (y/n): " install_ansible
if [ "$install_ansible" == "y" ]; then
    pacman -S --noconfirm --needed
    ansible
fi

# Install VirtualBox
read -p "Do you want to install VirtualBox? (y/n): " install_virtualbox
if [ "$install_virtualbox" == "y" ]; then
    pacman -S --noconfirm --needed virtualbox virtualbox-host-modules-arch
    systemctl enable vboxdrv.service
    systemctl start vboxdrv.service
    gpasswd -a "$USER" vboxusers
fi

# Install Vagrant
read -p "Do you want to install Vagrant? (y/n): " install_vagrant
if [ "$install_vagrant" == "y" ]; then
    pacman -S --noconfirm --needed vagrant
fi

# Install Docker
read -p "Do you want to install Docker? (y/n): " install_docker
if [ "$install_docker" == "y" ]; then
    pacman -S --noconfirm --needed docker
    systemctl enable docker.service
    systemctl start docker.service
    gpasswd -a "$USER" docker
fi

# Install Docker Compose
read -p "Do you want to install Docker Compose? (y/n): " install_docker_compose
if [ "$install_docker_compose" == "y" ]; then
    pacman -S --noconfirm --needed docker-compose
fi

# Install Kubernetes
read -p "Do you want to install Kubernetes? (y/n): " install_kubernetes
if [ "$install_kubernetes" == "y" ]; then
    pacman -S --noconfirm --needed kubectl kubeadm kubelet
    systemctl enable kubelet.service
fi

# Install Microsoft SQL Server
read -p "Do you want to install Microsoft SQL Server? (y/n): " install_sql_server
if [ "$install_sql_server" == "y" ]; then
    install_aur_pkg "mssql-server"
    sudo /opt/mssql/bin/mssql-conf setup
    systemctl enable mssql-server.service
    systemctl start mssql-server.service
fi

# Install TimescaleDB
read -p "Do you want to install TimescaleDB? (y/n): " install_timescaledb
if [ "$install_timescaledb" == "y" ]; then
    pacman -S --noconfirm --needed timescaledb
    echo "shared_preload_libraries = 'timescaledb'" | sudo tee -a /var/lib/postgres/data/postgresql.conf
    systemctl restart postgresql.service
fi

# Install VirtualBox Extension Pack
read -p "Do you want to install VirtualBox Extension Pack? (y/n): " install_vbox_ext_pack
if [ "$install_vbox_ext_pack" == "y" ]; then
    install_aur_pkg "virtualbox-ext-oracle"
fi

# Install Brave browser
read -p "Do you want to install Brave browser? (y/n): " install_brave
if [ "$install_brave" == "y" ]; then
    install_aur_pkg "brave-bin"
fi

# Install Google Chrome
read -p "Do you want to install Google Chrome? (y/n): " install_chrome
if [ "$install_chrome" == "y" ]; then
    install_aur_pkg "google-chrome"
fi

# Install Mozilla Firefox web browser
read -p "Do you want to install Mozilla Firefox web browser? (y/n): " install_firefox
if [ "$install_firefox" == "y" ]; then
    install_pkg "firefox"
fi

# Install Chromium web browser
read -p "Do you want to install Chromium web browser? (y/n): " install_chromium
if [ "$install_chromium" == "y" ]; then
    install_pkg "chromium"
fi

# Install Vivaldi web browser
read -p "Do you want to install Vivaldi web browser? (y/n): " install_vivaldi
if [ "$install_vivaldi" == "y" ]; then
    # Import GPG key
    curl -fsSL "https://repo.vivaldi.com/archive/linux_signing_key.pub" | gpg --import -

    # Add repository to pacman
    echo "[vivaldi]
    SigLevel = Required DatabaseOptional
    Server = https://repo.vivaldi.com/archive/arch_1_5" >> /etc/pacman.conf

    # Update package list
    pacman -Sy

    # Install Vivaldi
    install_pkg "vivaldi"
fi

# Install Slack
read -p "Do you want to install Slack? (y/n): " install_slack
if [ "$install_slack" == "y" ]; then
    install_aur_pkg "slack-desktop"
fi

# Install Discord
read -p "Do you want to install Discord? (y/n): " install_discord
if [ "$install_discord" == "y" ]; then
    pacman -S --noconfirm --needed discord
fi

# Install Zoom
read -p "Do you want to install Zoom? (y/n): " install_zoom
if [ "$install_zoom" == "y" ]; then
    install_aur_pkg "zoom"
fi

# Install Skype
read -p "Do you want to install Skype? (y/n): " install_skype
if [ "$install_skype" == "y" ]; then
    install_aur_pkg "skypeforlinux-stable-bin"
fi

# Install Microsoft Teams
read -p "Do you want to install Microsoft Teams? (y/n): " install_teams
if [ "$install_teams" == "y" ]; then
    install_aur_pkg "teams"
fi

# Install Telegram
read -p "Do you want to install Telegram? (y/n): " install_telegram
if [ "$install_telegram" == "y" ]; then
    pacman -S --noconfirm --needed telegram-desktop
fi

# Install Signal
read -p "Do you want to install Signal? (y/n): " install_signal
if [ "$install_signal" == "y" ]; then
    install_aur_pkg "signal-desktop-bin"
fi

# Install WhatsApp
read -p "Do you want to install WhatsApp? (y/n): " install_whatsapp
if [ "$install_whatsapp" == "y" ]; then
    install_aur_pkg "whatsapp-for-linux"
fi

# Install Wire
read -p "Do you want to install Wire? (y/n): " install_wire
if [ "$install_wire" == "y" ]; then
    install_aur_pkg "wire-desktop"
fi

# Install Keybase
read -p "Do you want to install Keybase? (y/n): " install_keybase
if [ "$install_keybase" == "y" ]; then
    install_aur_pkg "keybase-bin"
fi

# Install Thunar
read -p "Do you want to install Thunar? (y/n): " install_thunar
if [ "$install_thunar" == "y" ]; then
    pacman -S --noconfirm --needed thunar
fi

# Install Nemo
read -p "Do you want to install Nemo? (y/n): " install_nemo
if [ "$install_nemo" == "y" ]; then
    pacman -S --noconfirm --needed nemo
fi

# Install Dolphin
read -p "Do you want to install Dolphin? (y/n): " install_dolphin
if [ "$install_dolphin" == "y" ]; then
    pacman -S --noconfirm --needed dolphin
fi

# Install Nautilus
read -p "Do you want to install Nautilus? (y/n): " install_nautilus
if [ "$install_nautilus" == "y" ]; then
    pacman -S --noconfirm --needed nautilus
fi

# Install PCManFM
read -p "Do you want to install PCManFM? (y/n): " install_pcmanfm
if [ "$install_pcmanfm" == "y" ]; then
    pacman -S --noconfirm --needed pcmanfm
fi

# Install Double Commander
read -p "Do you want to install Double Commander? (y/n): " install_doublecmd
if [ "$install_doublecmd" == "y" ]; then
    pacman -S --noconfirm --needed doublecmd-gtk2
fi

# Install Midnight Commander
read -p "Do you want to install Midnight Commander? (y/n): " install_mc
if [ "$install_mc" == "y" ]; then
    pacman -S --noconfirm --needed mc
fi

# Install Ranger
read -p "Do you want to install Ranger? (y/n): " install_ranger
if [ "$install_ranger" == "y" ]; then
    pacman -S --noconfirm --needed ranger
fi

# Install nnn
read -p "Do you want to install nnn? (y/n): " install_nnn
if [ "$install_nnn" == "y" ]; then
    pacman -S --noconfirm --needed nnn
fi

# Install fzf
read -p "Do you want to install fzf? (y/n): " install_fzf
if [ "$install_fzf" == "y" ]; then
    pacman -S --noconfirm --needed fzf
fi

# Install fd
read -p "Do you want to install fd? (y/n): " install_fd
if [ "$install_fd" == "y" ]; then
    pacman -S --noconfirm --needed fd
fi

# Install ripgrep
read -p "Do you want to install ripgrep? (y/n): " install_ripgrep
if [ "$install_ripgrep" == "y" ]; then
    pacman -S --noconfirm --needed ripgrep
fi

# Install exa
read -p "Do you want to install exa? (y/n): " install_exa
if [ "$install_exa" == "y" ]; then
    install_aur_pkg "exa"
fi

# Install bat
read -p "Do you want to install bat? (y/n): " install_bat
if [ "$install_bat" == "y" ]; then
    pacman -S --noconfirm --needed bat
fi

# Install htop
read -p "Do you want to install htop? (y/n): " install_htop
if [ "$install_htop" == "y" ]; then
    pacman -S --noconfirm --needed htop
fi

# Install bpytop
read -p "Do you want to install bpytop? (y/n): " install_bpytop
if [ "$install_bpytop" == "y" ]; then
    pacman -S --noconfirm --needed bpytop
fi

# Install gtop
read -p "Do you want to install gtop? (y/n): " install_gtop
if [ "$install_gtop" == "y" ]; then
    install_aur_pkg "gtop"
fi

# Install glances
read -p "Do you want to install glances? (y/n): " install_glances
if [ "$install_glances" == "y" ]; then
    pacman -S --noconfirm --needed glances
fi

# Install bashtop
read -p "Do you want to install bashtop? (y/n): " install_bashtop
if [ "$install_bashtop" == "y" ]; then
    install_aur_pkg "bashtop-git"
fi

# Install vtop
read -p "Do you want to install vtop? (y/n): " install_vtop
if [ "$install_vtop" == "y" ]; then
    install_aur_pkg "vtop"
fi

# Install ctop
read -p "Do you want to install ctop? (y/n): " install_ctop
if [ "$install_ctop" == "y" ]; then
    pacman -S --noconfirm --needed ctop
fi

# Install duf
read -p "Do you want to install duf? (y/n): " install_duf
if [ "$install_duf" == "y" ]; then
    pacman -S --noconfirm --needed duf
fi

# Install ncdu
read -p "Do you want to install ncdu? (y/n): " install_ncdu
if [ "$install_ncdu" == "y" ]; then
    pacman -S --noconfirm --needed ncdu
fi

# Install tldr
read -p "Do you want to install tldr? (y/n): " install_tldr
if [ "$install_tldr" == "y" ]; then
    pacman -S --noconfirm --needed tldr
fi

# Install cheat
read -p "Do you want to install cheat? (y/n): " install_cheat
if [ "$install_cheat" == "y" ]; then
    install_aur_pkg "cheat-git"
fi

# Install howdoi
read -p "Do you want to install howdoi? (y/n): " install_howdoi
if [ "$install_howdoi" == "y" ]; then
    install_aur_pkg "howdoi"
fi

# Install bro pages
read -p "Do you want to install bro pages? (y/n): " install_bropages
if [ "$install_bropages" == "y" ]; then
    install_aur_pkg "bropages"
fi

# Install explainshell
read -p "Do you want to install explainshell? (y/n): " install_explainshell
if [ "$install_explainshell" == "y" ]; then
    install_aur_pkg "explainshell"
fi

# Install neofetch
read -p "Do you want to install neofetch? (y/n): " install_neofetch
if [ "$install_neofetch" == "y" ]; then
    pacman -S --noconfirm --needed neofetch
fi

# Install screenfetch
read -p "Do you want to install screenfetch? (y/n): " install_screenfetch
if [ "$install_screenfetch" == "y" ]; then
    pacman -S --noconfirm --needed screenfetch
fi

# Install pfetch
read -p "Do you want to install pfetch? (y/n): " install_pfetch
if [ "$install_pfetch" == "y" ]; then
    install_aur_pkg "pfetch-git"
fi 

# Install Guake
read -p "Do you want to install Guake? (y/n): " install_guake
if [ "$install_guake" == "y" ]; then
    pacman -S --noconfirm --needed guake
fi

# Install Tilix
read -p "Do you want to install Tilix? (y/n): " install_tilix
if [ "$install_tilix" == "y" ]; then
    pacman -S --noconfirm --needed tilix
fi

# Install Terminator
read -p "Do you want to install Terminator? (y/n): " install_terminator
if [ "$install_terminator" == "y" ]; then
    pacman -S --noconfirm --needed terminator
fi

# Install Alacritty
read -p "Do you want to install Alacritty? (y/n): " install_alacritty
if [ "$install_alacritty" == "y" ]; then
    pacman -S --noconfirm --needed alacritty
fi

# Install Kitty
read -p "Do you want to install Kitty? (y/n): " install_kitty
if [ "$install_kitty" == "y" ]; then
    pacman -S --noconfirm --needed kitty
fi

# Install St
read -p "Do you want to install St? (y/n): " install_st
if [ "$install_st" == "y" ]; then
    install_aur_pkg "st-git"
fi

# Install Urxvt
read -p "Do you want to install Urxvt? (y/n): " install_urxvt
if [ "$install_urxvt" == "y" ]; then
    pacman -S --noconfirm --needed rxvt-unicode
fi

# Install Xterm
read -p "Do you want to install Xterm? (y/n): " install_xterm
if [ "$install_xterm" == "y" ]; then
    pacman -S --noconfirm --needed xterm
fi

# Install Konsole
read -p "Do you want to install Konsole? (y/n): " install_konsole
if [ "$install_konsole" == "y" ]; then
    pacman -S --noconfirm --needed konsole
fi

# Install Gnome Terminal
read -p "Do you want to install Gnome Terminal? (y/n): " install_gnome_terminal
if [ "$install_gnome_terminal" == "y" ]; then
    pacman -S --noconfirm --needed gnome-terminal
fi

# Install XFCE Terminal
read -p "Do you want to install XFCE Terminal? (y/n): " install_xfce_terminal
if [ "$install_xfce_terminal" == "y" ]; then
    pacman -S --noconfirm --needed xfce4-terminal
fi

# Install LXTerminal
read -p "Do you want to install LXTerminal? (y/n): " install_lxterminal
if [ "$install_lxterminal" == "y" ]; then
    pacman -S --noconfirm --needed lxterminal
fi

# Install MATE Terminal
read -p "Do you want to install MATE Terminal? (y/n): " install_mate_terminal
if [ "$install_mate_terminal" == "y" ]; then
    pacman -S --noconfirm --needed mate-terminal
fi

# Install Deepin Terminal
read -p "Do you want to install Deepin Terminal? (y/n): " install_deepin_terminal
if [ "$install_deepin_terminal" == "y" ]; then
    pacman -S --noconfirm --needed deepin-terminal
fi

# Install Termite
read -p "Do you want to install Termite? (y/n): " install_termite
if [ "$install_termite" == "y" ]; then
    install_aur_pkg "termite"
fi

# Install Tmux
read -p "Do you want to install Tmux? (y/n): " install_tmux
if [ "$install_tmux" == "y" ]; then
    pacman -S --noconfirm --needed tmux
fi

# Install Byobu
read -p "Do you want to install Byobu? (y/n): " install_byobu
if [ "$install_byobu" == "y" ]; then
    install_aur_pkg "byobu"
fi

# Install dwm
read -p "Do you want to install dwm? (y/n): " install_dwm
if [ "$install_dwm" == "y" ]; then
    install_pkg "dwm" "suckless-tools" "dmenu" "compton" "feh" "nitrogen" "redshift" "brightnessctl" "pulseaudio" "pavucontrol" "alsa-utils" "scrot" "imagemagick"
    systemctl enable lightdm.service
    systemctl set-default graphical.target
fi

# Install i3
read -p "Do you want to install i3? (y/n): " install_i3
if [ "$install_i3" == "y" ]; then
    pacman -S --noconfirm --needed i3
fi

# Install sway
read -p "Do you want to install sway? (y/n): " install_sway
if [ "$install_sway" == "y" ]; then
    install_pkg "sway" "swaylock" "swayidle" "mako" "waybar" "brightnessctl" "redshift" "xdg-desktop-portal-wlr"
    install_aur_pkg "slurp" "sway-launcher-desktop"
    systemctl enable lightdm.service
    systemctl set-default graphical.target
fi

# Install bspwm
read -p "Do you want to install bspwm? (y/n): " install_bspwm
if [ "$install_bspwm" == "y" ]; then
    install_pkg "bspwm" "sxhkd" "rofi" "compton" "nitrogen" "feh" "brightnessctl" "redshift" "xclip" "pulseaudio" "pavucontrol" "alsa-utils" "scrot" "imagemagick"
    systemctl enable lightdm.service
    systemctl set-default graphical.target
fi

# Install herbstluftwm
read -p "Do you want to install herbstluftwm? (y/n): " install_herbstluftwm
if [ "$install_herbstluftwm" == "y" ]; then
    install_pkg "herbstluftwm" "rofi" "compton" "feh" "nitrogen" "redshift" "brightnessctl" "xclip" "pulseaudio" "pavucontrol" "alsa-utils" "scrot" "imagemagick"
    systemctl enable lightdm.service
    systemctl set-default graphical.target
fi

# Install qtile
read -p "Do you want to install qtile? (y/n): " install_qtile
if [ "$install_qtile" == "y" ]; then
    install_pkg "qtile" "rofi" "compton" "feh" "nitrogen" "brightnessctl" "redshift" "xclip" "pulseaudio" "pavucontrol" "alsa-utils" "scrot" "imagemagick"
    systemctl enable lightdm.service
    systemctl set-default graphical.target
fi

# Install AwesomeWM
read -p "Do you want to install AwesomeWM? (y/n): " install_awesome
if [ "$install_awesome" == "y" ]; then
    install_pkg "awesome" "lxappearance" "rofi" "compton" "brightnessctl" "redshift" "pulseaudio" "pavucontrol" "alsa-utils" "scrot" "imagemagick" "xclip"
    systemctl enable lightdm.service
    systemctl set-default graphical.target
fi

# Install xmonad
read -p "Do you want to install xmonad? (y/n): " install_xmonad
if [ "$install_xmonad" == "y" ]; then
    pacman -S --noconfirm --needed xmonad
fi

# Install openbox
read -p "Do you want to install Openbox? (y/n): " install_openbox
if [ "$install_openbox" == "y" ]; then
    install_pkg "openbox" "obconf" "obmenu-generator" "rofi" "compton" "lxappearance" "feh" "nitrogen" "redshift" "brightnessctl" "xclip" "pulseaudio" "pavucontrol" "alsa-utils" "scrot" "imagemagick"
    systemctl enable lightdm.service
    systemctl set-default graphical.target
fi


# Install jwm
read -p "Do you want to install jwm? (y/n): " install_jwm
if [ "$install_jwm" == "y" ]; then
    install_aur_pkg "jwm-git"
fi

# Install ratpoison
read -p "Do you want to install ratpoison? (y/n): " install_ratpoison
if [ "$install_ratpoison" == "y" ]; then
    pacman -S --noconfirm --needed ratpoison
fi

# Install spectrwm
read -p "Do you want to install spectrwm? (y/n): " install_spectrwm
if [ "$install_spectrwm" == "y" ]; then
    install_pkg "spectrwm" "rofi" "compton" "feh" "nitrogen" "redshift" "brightnessctl" "xclip" "pulseaudio" "pavucontrol" "alsa-utils" "scrot" "imagemagick"
    systemctl enable lightdm.service
    systemctl set-default graphical.target
fi

# Install qtile
read -p "Do you want to install qtile? (y/n): " install_qtile
if [ "$install_qtile" == "y" ]; then
    pacman -S --noconfirm --needed qtile
fi

# Install IceWM
read -p "Do you want to install IceWM? (y/n): " install_icewm
if [ "$install_icewm" == "y" ]; then
    pacman -S --noconfirm --needed icewm
fi

# Install Fluxbox
read -p "Do you want to install Fluxbox? (y/n): " install_fluxbox
if [ "$install_fluxbox" == "y" ]; then
    install_pkg "fluxbox" "fbautostart" "fluxbox-pulseaudio" "rofi" "compton" "lxappearance" "feh" "nitrogen" "redshift" "brightnessctl" "xclip" "pavucontrol" "alsa-utils" "scrot" "imagemagick"
    systemctl enable lightdm.service
    systemctl set-default graphical.target
fi

# Install FVWM
read -p "Do you want to install FVWM? (y/n): " install_fvwm
if [ "$install_fvwm" == "y" ]; then
    install_pkg "fvwm" "rofi" "compton" "lxappearance" "feh" "nitrogen" "redshift" "brightnessctl" "xclip" "pulseaudio" "pavucontrol" "alsa-utils" "scrot" "imagemagick"
    systemctl enable lightdm.service
    systemctl set-default graphical.target
fi

# Install blackbox
read -p "Do you want to install blackbox? (y/n): " install_blackbox
if [ "$install_blackbox" == "y" ]; then
    install_pkg "blackbox" "bbkeys" "rofi" "compton" "lxappearance" "feh" "nitrogen" "redshift" "brightnessctl" "xclip" "pulseaudio" "pavucontrol" "alsa-utils" "scrot" "imagemagick"
    systemctl enable lightdm.service
    systemctl set-default graphical.target
fi

# Install wmutils
read -p "Do you want to install wmutils? (y/n): " install_wmutils
if [ "$install_wmutils" == "y" ]; then
    install_pkg "wmutils" "rofi" "compton" "lxappearance" "feh" "nitrogen" "redshift" "brightnessctl" "xclip" "pulseaudio" "pavucontrol" "alsa-utils" "scrot" "imagemagick"
    systemctl enable lightdm.service
    systemctl set-default graphical.target
fi

# Install dwm-like window managers
read -p "Do you want to install suckless dwm-like window managers? (y/n): " install_suckless
if [ "$install_suckless" == "y" ]; then
    # Clone and build dwm
    git clone https://git.suckless.org/dwm /tmp/dwm
    cd /tmp/dwm || exit
    make && sudo make install && sudo chmod +s /usr/local/bin/dwm
    cd "$dir" || exit

    # Clone and build st
    git clone https://git.suckless.org/st /tmp/st
    cd /tmp/st || exit
    make && sudo make install
    cd "$dir" || exit

    # Clone and build slstatus
    git clone https://git.suckless.org/slstatus /tmp/slstatus
    cd /tmp/slstatus || exit
    make && sudo make install
    cd "$dir" || exit

    # Clone and build dmenu
    git clone https://git.suckless.org/dmenu /tmp/dmenu
    cd /tmp/dmenu || exit
    make && sudo make install
    cd "$dir" || exit

    # Install tabbed
    install_pkg "tabbed"

    # Install surf
      read -p "Do you want to install surf? (y/n): " install_surf
    if [ "$install_surf" == "y" ]; then
        install_pkg "surf" "webkit2gtk"
        systemctl enable lightdm.service
        systemctl set-default graphical.target
    fi
fi

# Install WindowMaker
read -p "Do you want to install WindowMaker? (y/n): " install_windowmaker
if [ "$install_windowmaker" == "y" ]; then
    pacman -S --noconfirm --needed windowmaker
fi

# Install Enlightenment
read -p "Do you want to install Enlightenment? (y/n): " install_enlightenment
if [ "$install_enlightenment" == "y" ]; then
    install_pkg "enlightenment" "enlightenment-extra" "enlightenment-modules" "enlightenment-themes" "terminology" "econnman" "eflete" "rage" "entrance" "geany" "geany-plugins" "mpv" "mpv-mpris" "firefox" "file-roller" "xorg-xkill" "xorg-xsetroot" "compton" "gnome-calculator" "scrot" "xautolock" "xclip"
    systemctl enable lightdm.service
    systemctl set-default graphical.target
fi

# Install Regolith
read -p "Do you want to install Regolith? (y/n): " install_regolith
if [ "$install_regolith" == "y" ]; then
    install_aur_pkg "regolith-desktop-git"
fi

# Install Java
read -p "Do you want to install Java? (y/n): " install_java
if [ "$install_java" == "y" ]; then
    pacman -S --noconfirm --needed jre-openjdk jdk-openjdk openjdk-doc openjdk-src
fi

# Install Mono
read -p "Do you want to install Mono? (y/n): " install_mono
if [ "$install_mono" == "y" ]; then
    pacman -S --noconfirm --needed mono mono-tools
fi

# Install .NET
read -p "Do you want to install .NET? (y/n): " install_dotnet
if [ "$install_dotnet" == "y" ]; then
    pacman -S --noconfirm --needed dotnet-sdk dotnet-runtime dotnet-host
fi

# Install Go
read -p "Do you want to install Go? (y/n): " install_go
if [ "$install_go" == "y" ]; then
    pacman -S --noconfirm --needed go go-tools
fi

# Install Rust
read -p "Do you want to install Rust? (y/n): " install_rust
if [ "$install_rust" == "y" ]; then
    pacman -S --noconfirm --needed rust rust-docs
fi

# Install Node.js
read -p "Do you want to install Node.js? (y/n): " install_nodejs
if [ "$install_nodejs" == "y" ]; then
    pacman -S --noconfirm --needed nodejs npm
fi

# Install Python
read -p "Do you want to install Python? (y/n): " install_python
if [ "$install_python" == "y" ]; then
    pacman -S --noconfirm --needed python python-pip python-docs
fi

# Install Ruby
read -p "Do you want to install Ruby? (y/n): " install_ruby
if [ "$install_ruby" == "y" ]; then
    pacman -S --noconfirm --needed ruby ruby-docs
fi

# Install Perl
read -p "Do you want to install Perl? (y/n): " install_perl
if [ "$install_perl" == "y" ]; then
    pacman -S --noconfirm --needed perl perl-docs
fi

# Install PHP
read -p "Do you want to install PHP? (y/n): " install_php
if [ "$install_php" == "y" ]; then
    pacman -S --noconfirm --needed php php-apache php-gd php-intl php-sqlite
fi

# Install Haskell
read -p "Do you want to install Haskell? (y/n): " install_haskell
if [ "$install_haskell" == "y" ]; then
    pacman -S --noconfirm --needed ghc cabal-install happy alex
fi

# Install Lua
read -p "Do you want to install Lua? (y/n): " install_lua
if [ "$install_lua" == "y" ]; then
    pacman -S --noconfirm --needed lua lua-lgi lua-lpeg lua-sec lua-socket lua-docs
fi

# Install R
read -p "Do you want to install R? (y/n): " install_r
if [ "$install_r" == "y" ]; then
    pacman -S --noconfirm --needed r
fi

# Install Swift
read -p "Do you want to install Swift? (y/n): " install_swift
if [ "$install_swift" == "y" ]; then
    install_aur_pkg "swift-language"
fi

# Install Kotlin
read -p "Do you want to install Kotlin? (y/n): " install_kotlin
if [ "$install_kotlin" == "y" ]; then
    install_aur_pkg "kotlin"
fi

# Install TypeScript
read -p "Do you want to install TypeScript? (y/n): " install_typescript
if [ "$install_typescript" == "y" ]; then
    npm install -g typescript
fi

# Install Dart
read -p "Do you want to install Dart? (y/n): " install_dart
if [ "$install_dart" == "y" ]; then
    install_aur_pkg "dart"
fi

# Install Julia
read -p "Do you want to install Julia? (y/n): " install_julia
if [ "$install_julia" == "y" ]; then
    pacman -S --noconfirm --needed julia
fi

# Install Crystal
read -p "Do you want to install Crystal? (y/n): " install_crystal
if [ "$install_crystal" == "y" ]; then
    install_aur_pkg "crystal"
fi

# Install Nim
read -p "Do you want to install Nim? (y/n): " install_nim
if [ "$install_nim" == "y" ]; then
    pacman -S --noconfirm --needed nim nimble
fi

# Install D
read -p "Do you want to install D? (y/n): " install_d
if [ "$install_d" == "y" ]; then
    pacman -S --noconfirm --needed dlang
fi

# Install Elixir
read -p "Do you want to install Elixir? (y/n): " install_elixir
if [ "$install_elixir" == "y" ]; then
    pacman -S --noconfirm --needed elixir
fi

# Install Clojure
read -p "Do you want to install Clojure? (y/n): " install_clojure
if [ "$install_clojure" == "y" ]; then
    pacman -S --noconfirm --needed clojure
fi

# Install Erlang
read -p "Do you want to install Erlang? (y/n): " install_erlang
if [ "$install_erlang" == "y" ]; then
    pacman -S --noconfirm --needed erlang
fi

# Install OCaml
read -p "Do you want to install OCaml? (y/n): " install_ocaml
if [ "$install_ocaml" == "y" ]; then
    pacman -S --noconfirm --needed ocaml ocaml-findlib
fi

# Install F#
read -p "Do you want to install F#? (y/n): " install_fsharp
if [ "$install_fsharp" == "y" ]; then
    pacman -S --noconfirm --needed fsharp
fi

# Install Scala
read -p "Do you want to install Scala? (y/n): " install_scala
if [ "$install_scala" == "y" ]; then
    pacman -S --noconfirm --needed scala sbt
fi

# Install Groovy
read -p "Do you want to install Groovy? (y/n): " install_groovy
if [ "$install_groovy" == "y" ]; then
    pacman -S --noconfirm --needed groovy
fi

# Install Apache Maven
read -p "Do you want to install Apache Maven? (y/n): " install_maven
if [ "$install_maven" == "y" ]; then
    pacman -S --noconfirm --needed maven
fi

# Install Gradle
read -p "Do you want to install Gradle? (y/n): " install_gradle
if [ "$install_gradle" == "y" ]; then
    pacman -S --noconfirm --needed gradle
fi

# Install Apache Ant
read -p "Do you want to install Apache Ant? (y/n): " install_ant
if [ "$install_ant" == "y" ]; then
    pacman -S --noconfirm --needed apache-ant
fi

# Install CMake
read -p "Do you want to install CMake? (y/n): " install_cmake
if [ "$install_cmake" == "y" ]; then
    pacman -S --noconfirm --needed cmake
fi

# Install Make
read -p "Do you want to install Make? (y/n): " install_make
if [ "$install_make" == "y" ]; then
    pacman -S --noconfirm --needed make
fi

# Install Visual Studio Code
read -p "Do you want to install Visual Studio Code? (y/n): " install_vscode
if [ "$install_vscode" == "y" ]; then
    install_aur_pkg "visual-studio-code-bin"
fi

# Install Atom
read -p "Do you want to install Atom? (y/n): " install_atom
if [ "$install_atom" == "y" ]; then
    install_aur_pkg "atom"
fi

# Install Sublime Text
read -p "Do you want to install Sublime Text? (y/n): " install_sublimetext
if [ "$install_sublimetext" == "y" ]; then
    install_aur_pkg "sublime-text-dev"
fi

# Install Brackets
read -p "Do you want to install Brackets? (y/n): " install_brackets
if [ "$install_brackets" == "y" ]; then
    install_aur_pkg "brackets"
fi

# Install Notepad++
read -p "Do you want to install Notepad++? (y/n): " install_notepadpp
if [ "$install_notepadpp" == "y" ]; then
    install_aur_pkg "notepadplusplus"
fi

# Install Geany
read -p "Do you want to install Geany? (y/n): " install_geany
if [ "$install_geany" == "y" ]; then
    pacman -S --noconfirm --needed geany geany-plugins
fi

# Install Bluefish
read -p "Do you want to install Bluefish? (y/n): " install_bluefish
if [ "$install_bluefish" == "y" ]; then
    pacman -S --noconfirm --needed bluefish
fi

# Install PhpStorm
read -p "Do you want to install PhpStorm? (y/n): " install_phpstorm
if [ "$install_phpstorm" == "y" ]; then
    install_aur_pkg "phpstorm"
fi

# Install PyCharm
read -p "Do you want to install PyCharm? (y/n): " install_pycharm
if [ "$install_pycharm" == "y" ]; then
    install_aur_pkg "pycharm"
fi

# Install IntelliJ IDEA
read -p "Do you want to install IntelliJ IDEA? (y/n): " install_intellij
if [ "$install_intellij" == "y" ]; then
    install_aur_pkg "intellij-idea-ultimate-edition"
fi

# Install CLion
read -p "Do you want to install CLion? (y/n): " install_clion
if [ "$install_clion" == "y" ]; then
    install_aur_pkg "clion"
fi

# Install Rider
read -p "Do you want to install Rider? (y/n): " install_rider
if [ "$install_rider" == "y" ]; then
    install_aur_pkg "rider"
fi

# Install WebStorm
read -p "Do you want to install WebStorm? (y/n): " install_webstorm
if [ "$install_webstorm" == "y" ]; then
    install_aur_pkg "webstorm"
fi

# Install RubyMine
read -p "Do you want to install RubyMine? (y/n): " install_rubymine
if [ "$install_rubymine" == "y" ]; then
    install_aur_pkg "rubymine"
fi

# Install DataGrip
read -p "Do you want to install DataGrip? (y/n): " install_datagrip
if [ "$install_datagrip" == "y" ]; then
    install_aur_pkg "datagrip"
fi

# Install Android Studio
read -p "Do you want to install Android Studio? (y/n): " install_androidstudio
if [ "$install_androidstudio" == "y" ]; then
    install_aur_pkg "android-studio"
fi

# Install MonoDevelop
read -p "Do you want to install MonoDevelop? (y/n): " install_monodevelop
if [ "$install_monodevelop" == "y" ]; then
    install_aur_pkg "monodevelop-bin"
fi

# Install KDevelop
read -p "Do you want to install KDevelop? (y/n): " install_kdevelop
if [ "$install_kdevelop" == "y" ]; then
    pacman -S --noconfirm --needed kdevelop
fi

# Install Anjuta
read -p "Do you want to install Anj
# Part 16 begins here

uta? (y/n): " install_anjuta
if [ "$install_anjuta" == "y" ]; then
    pacman -S --noconfirm --needed anjuta
fi

# Install Gambas
read -p "Do you want to install Gambas? (y/n): " install_gambas
if [ "$install_gambas" == "y" ]; then
    pacman -S --noconfirm --needed gambas3
fi

# Install Code::Blocks
read -p "Do you want to install Code::Blocks? (y/n): " install_codeblocks
if [ "$install_codeblocks" == "y" ]; then
    pacman -S --noconfirm --needed codeblocks
fi

# Install CodeLite
read -p "Do you want to install CodeLite? (y/n): " install_codelite
if [ "$install_codelite" == "y" ]; then
    pacman -S --noconfirm --needed codelite
fi

# Install Eclipse
read -p "Do you want to install Eclipse? (y/n): " install_eclipse
if [ "$install_eclipse" == "y" ]; then
    install_aur_pkg "eclipse"
fi

# Install NetBeans
read -p "Do you want to install NetBeans? (y/n): " install_netbeans
if [ "$install_netbeans" == "y" ]; then
    install_aur_pkg "netbeans"
fi

# Install Lazarus
read -p "Do you want to install Lazarus? (y/n): " install_lazarus
if [ "$install_lazarus" == "y" ]; then
    pacman -S --noconfirm --needed lazarus
fi

# Install Arduino IDE
read -p "Do you want to install Arduino IDE? (y/n): " install_arduino
if [ "$install_arduino" == "y" ]; then
    pacman -S --noconfirm --needed arduino arduino-docs
fi

# Install Scratch
read -p "Do you want to install Scratch? (y/n): " install_scratch
if [ "$install_scratch" == "y" ]; then
    install_aur_pkg "scratch-desktop"
fi

# Install Processing
read -p "Do you want to install Processing? (y/n): " install_processing
if [ "$install_processing" == "y" ]; then
    install_aur_pkg "processing"
fi

# Install RStudio
read -p "Do you want to install RStudio? (y/n): " install_rstudio
if [ "$install_rstudio" == "y" ]; then
    install_aur_pkg "rstudio-desktop-bin"
fi

# Install Jupyter Notebook
read -p "Do you want to install Jupyter Notebook? (y/n): " install_jupyter
if [ "$install_jupyter" == "y" ]; then
    pacman -S --noconfirm --needed jupyter
fi

# Install Spyder
read -p "Do you want to install Spyder? (y/n): " install_spyder
if [ "$install_spyder" == "y" ]; then
    pacman -S --noconfirm --needed spyder
fi

# Install Octave
read -p "Do you want to install Octave? (y/n): " install_octave
if [ "$install_octave" == "y" ]; then
    pacman -S --noconfirm --needed octave
fi

# Install OpenVPN
read -p "Do you want to install OpenVPN? (y/n): " install_openvpn
if [ "$install_openvpn" == "y" ]; then
    pacman -S --noconfirm --needed openvpn
fi

# Install Wireshark
read -p "Do you want to install Wireshark? (y/n): " install_wireshark
if [ "$install_wireshark" == "y" ]; then
    pacman -S --noconfirm --needed wireshark-qt
    sudo gpasswd -a "$USER" wireshark
    echo "wireshark has been installed, please log out and log back in before using it"
fi

# Install LAMP Stack
read -p "Do you want to install LAMP Stack? (y/n): " install_lamp
if [ "$install_lamp" == "y" ]; then
    pacman -S --noconfirm --needed apache mariadb php php-apache php-gd php-intl php-mcrypt php-pgsql php-sqlite php-xsl phpmyadmin
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    systemctl enable httpd.service
    systemctl start httpd.service
    systemctl enable mariadb.service
    systemctl start mariadb.service
    sudo mysql_secure_installation <<EOF
y
$password
$password
y
y
y
y
EOF
    mysql -u root -p"$password" -e "CREATE DATABASE IF NOT EXISTS wordpress DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -u root -p"$password" -e "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY '$password';"
    mysql -u root -p"$password" -e "GRANT ALL ON wordpress.* TO 'wordpress'@'localhost';"
    sudo sed -i 's/;extension=pdo_mysql.so/extension=pdo_mysql.so/g' /etc/php/php.ini
    systemctl restart httpd.service
    systemctl restart mariadb.service
    echo "LAMP Stack has been installed"
fi

# Install MEAN Stack
read -p "Do you want to install MEAN Stack? (y/n): " install_mean
if [ "$install_mean" == "y" ]; then
    pacman -S --noconfirm --needed mongodb npm
    systemctl enable mongodb.service
    systemctl start mongodb.service
    sudo npm install -g @angular/cli
    echo "MEAN Stack has been installed"
fi

# Install GitKraken
read -p "Do you want to install GitKraken? (y/n): " install_gitkraken
if [ "$install_gitkraken" == "y" ]; then
    install_aur_pkg "gitkraken"
fi

# Install Dropbox CLI
read -p "Do you want to install Dropbox CLI? (y/n): " install_dropbox_cli
if [ "$install_dropbox_cli" == "y" ]; then
    install_aur_pkg "dropbox-cli"
    echo "The Dropbox CLI has been installed. Please run 'dropbox-cli start' to start it."
fi

# Install Mega cloud storage client
read -p "Do you want to install Mega cloud storage client? (y/n): " install_mega
if [ "$install_mega" == "y" ]; then
    # Install dependencies
    install_pkg "curl" "libcurl-gnutls" "libmediainfo" "sqlite"

    # Download and extract MegaSync package
    tmp_dir=$(mktemp -d)
    curl -L "https://mega.nz/linux/MEGAsync/Arch_Extra/x86_64/megasync-4.6.4-1-x86_64.pkg.tar.zst" -o "$tmp_dir/megasync.pkg.tar.zst"
    tar -xf "$tmp_dir/megasync.pkg.tar.zst" -C "$tmp_dir"

    # Install MegaSync package
    pacman -U --noconfirm "$tmp_dir/megasync-4.6.4-1-x86_64.pkg.tar.zst"

    # Clean up temporary files
    rm -rf "$tmp_dir"
fi


# Install MegaTools
read -p "Do you want to install MegaTools? (y/n): " install_megatools
if [ "$install_megatools" == "y" ]; then
    install_aur_pkg "megatools"
fi

# Install NVIDIA drivers and PRIME render offload support
read -p "Do you want to install NVIDIA drivers and PRIME render offload support? (y/n): " install_nvidia_drivers
if [ "$install_nvidia_drivers" == "y" ]; then
    install_pkg "nvidia-dkms" "nvidia-utils" "nvidia-settings" "libvdpau" "libxnvctrl" "lib32-nvidia-utils" "lib32-libvdpau" "lib32-libxnvctrl" "mesa" "mesa-demos" "libva-vdpau-driver" "vulkan-icd-loader" "libva-utils" "vdpauinfo" "libdrm"
    echo "Please make sure that the following line is added to /etc/X11/xorg.conf.d/20-nvidia.conf"
    echo "Option      \"PrimaryGPU\"     \"yes\""
    read -p "Press enter to continue"
    echo "Please reboot your system to load the NVIDIA drivers"
    read -p "Press enter to continue"
    echo "Enabling PRIME render offload support"
    echo "xrandr --setprovideroutputsource modesetting NVIDIA-0
    xrandr --auto" >> /usr/local/bin/nvidia-xrandr
    chmod +x /usr/local/bin/nvidia-xrandr
fi

# Install AMDGPU drivers and PRIME render offload support
read -p "Do you want to install AMDGPU drivers and PRIME render offload support? (y/n): " install_amdgpu_drivers
if [ "$install_amdgpu_drivers" == "y" ]; then
    install_pkg "xf86-video-amdgpu" "mesa" "mesa-vdpau" "vulkan-radeon" "libva-mesa-driver" "libvdpau" "libdrm"
    echo "Please make sure that the following line is added to /etc/X11/xorg.conf.d/20-amdgpu.conf"
    echo "Option      \"PrimaryGPU\"     \"yes\""
    read -p "Press enter to continue"
    echo "Please reboot your system to load the AMDGPU drivers"
    read -p "Press enter to continue"
    echo "Enabling PRIME render offload support"
    echo "xrandr --setprovideroutputsource modesetting AMD-0
    xrandr --auto" >> /usr/local/bin/amdgpu-xrandr
    chmod +x /usr/local/bin/amdgpu-xrandr
fi

# Install VirtualBox virtualization software
read -p "Do you want to install VirtualBox virtualization software? (y/n): " install_virtualbox
if [ "$install_virtualbox" == "y" ]; then
    install_pkg "virtualbox" "virtualbox-host"
    # Add user to the vboxusers group
    sudo usermod -a -G vboxusers $USER

    # Install VirtualBox Extension Pack
    version=$(pacman -Q virtualbox | cut -d ' ' -f 2 | cut -d '-' -f 1)
    extpack="Oracle_VM_VirtualBox_Extension_Pack-$version.vbox-extpack"
    wget "https://download.virtualbox.org/virtualbox/$version/$extpack" -P ~/Downloads
    vboxmanage extpack install --replace ~/Downloads/$extpack
fi

# Install QEMU and the QEMU-KVM package
read -p "Do you want to install QEMU and the QEMU-KVM package? (y/n): " install_qemu
if [ "$install_qemu" == "y" ]; then
    install_pkg "qemu" "qemu-arch-extra" "libvirt" "virt-manager" "dnsmasq" "bridge-utils" "openbsd-netcat"
    systemctl enable libvirtd.service
    systemctl start libvirtd.service
fi

# Install Kodi media center
read -p "Do you want to install Kodi media center? (y/n): " install_kodi
if [ "$install_kodi" == "y" ]; then
    install_pkg "kodi"
fi

# Install GIMP image editor
read -p "Do you want to install GIMP image editor? (y/n): " install_gimp
if [ "$install_gimp" == "y" ]; then
    install_pkg "gimp"
fi

# Install Inkscape vector graphics editor
read -p "Do you want to install Inkscape vector graphics editor? (y/n): " install_inkscape
if [ "$install_inkscape" == "y" ]; then
    install_pkg "inkscape"
fi

# Install Wine compatibility layer for Windows software
read -p "Do you want to install Wine compatibility layer for Windows software? (y/n): " install_wine
if [ "$install_wine" == "y" ]; then
    install_pkg "wine" "wine-mono" "wine_gecko"
fi

# Install Wine and the Wine-Staging package
read -p "Do you want to install Wine and the Wine-Staging package? (y/n): " install_wine
if [ "$install_wine" == "y" ]; then
    install_pkg "wine-staging" "wine-mono" "wine_gecko"
fi
# Import GPG key
    curl https://dl.winehq.org/wine-builds/winehq.key | gpg --import -

    # Add repository to pacman
    echo "[wine-staging]
    Server = https://dl.winehq.org/wine-builds/Arch/$arch/
    SigLevel = Required DatabaseOptional" >> /etc/pacman.conf

    # Update package list
    pacman -Sy

    # Install Wine-Staging
    install_pkg "wine-staging" "wine-mono" "wine_gecko"
fi

# Install PlayOnLinux compatibility layer for Windows software
read -p "Do you want to install PlayOnLinux compatibility layer for Windows software? (y/n): " install_playonlinux
if [ "$install_playonlinux" == "y" ]; then
    install_pkg "playonlinux"
fi

# Install qBittorrent BitTorrent client
read -p "Do you want to install qBittorrent BitTorrent client? (y/n): " install_qbittorrent
if [ "$install_qbittorrent" == "y" ]; then
    install_pkg "qbittorrent"
fi

# Install Transmission BitTorrent client
read -p "Do you want to install Transmission BitTorrent client? (y/n): " install_transmission
if [ "$install_transmission" == "y" ]; then
    install_pkg "transmission-cli" "transmission-gtk"
fi

# Install HandBrake video converter
read -p "Do you want to install HandBrake video converter? (y/n): " install_handbrake
if [ "$install_handbrake" == "y" ]; then
    install_pkg "handbrake"
fi

# Install SimpleScreenRecorder screen recording software
read -p "Do you want to install SimpleScreenRecorder screen recording software? (y/n): " install_simplescreenrecorder
if [ "$install_simplescreenrecorder" == "y" ]; then
    install_pkg "simplescreenrecorder"
fi

# Install VLC media player
read -p "Do you want to install VLC media player? (y/n): " install_vlc
if [ "$install_vlc" == "y" ]; then
    install_pkg "vlc"
fi

# Install mpv media player
read -p "Do you want to install mpv media player? (y/n): " install_mpv
if [ "$install_mpv" == "y" ]; then
    install_pkg "mpv"
fi

# Install Telegram messaging client
read -p "Do you want to install Telegram messaging client? (y/n): " install_telegram
if [ "$install_telegram" == "y" ]; then
    # Import GPG key
    gpg --recv-keys "3EE67F3D0FF405B2"

    # Add repository to pacman
    echo "[telegram]
    Server = https://dl.escomposlinux.org/pub/archlinux/telegram
    SigLevel = Never" >> /etc/pacman.conf

    # Update package list
    pacman -Sy

    # Install Telegram
    install_pkg "telegram-desktop"
fi





