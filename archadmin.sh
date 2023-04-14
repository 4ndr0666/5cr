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

echo "Installation completed!"
exit 0

