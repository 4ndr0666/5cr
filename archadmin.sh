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

# Part 5 begins here

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

# Install Microsoft Edge
read -p "Do you want to install Microsoft Edge? (y/n): " install_edge
if [ "$install_edge" == "y" ]; then
    install_aur_pkg "microsoft-edge-dev-bin"
fi

# Install Vivaldi
read -p "Do you want to install Vivaldi? (y/n): " install_vivaldi
if [ "$install_vivaldi" == "y" ]; then
    pacman -S --noconfirm --needed vivaldi
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

# Install DWM
read -p "Do you want to install DWM? (y/n): " install_dwm
if [ "$install_dwm" == "y" ]; then
    install_aur_pkg "dwm-git"
fi

# Install i3
read -p "Do you want to install i3? (y/n): " install_i3
if [ "$install_i3" == "y" ]; then
    pacman -S --noconfirm --needed i3
fi

# Install bspwm
read -p "Do you want to install bspwm? (y/n): " install_bspwm
if [ "$install_bspwm" == "y" ]; then
    pacman -S --noconfirm --needed bspwm
fi

# Install herbstluftwm
read -p "Do you want to install herbstluftwm? (y/n): " install_herbstluftwm
if [ "$install_herbstluftwm" == "y" ]; then
    pacman -S --noconfirm --needed herbstluftwm
fi

# Install awesome
read -p "Do you want to install awesome? (y/n): " install_awesome
if [ "$install_awesome" == "y" ]; then
    pacman -S --noconfirm --needed awesome
fi

# Install xmonad
read -p "Do you want to install xmonad? (y/n): " install_xmonad
if [ "$install_xmonad" == "y" ]; then
    pacman -S --noconfirm --needed xmonad
fi

# Install openbox
read -p "Do you want to install openbox? (y/n): " install_openbox
if [ "$install_openbox" == "y" ]; then
    pacman -S --noconfirm --needed openbox
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
if [ "$install_spectrwm" == "y



