#! /bin/bash

# This script setup environment for WSO2 product deployment

USERNAME=ubuntu
BIN_DIR=/home/$USERNAME/bin
WUM_USER=$1
WUM_PASS=$2

update_apt() {
    echo "127.0.0.1 $(hostname)" >> /etc/hosts
    apt-get update -y
}

install_mysql() {
apt install -y mysql-client
    mkdir -p $BIN_DIR
    wget -P $BIN_DIR http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.44/mysql-connector-java-5.1.44.jar
}

install_wum() {
    wget -P $BIN_DIR https://product-dist.wso2.com/downloads/wum/1.0.0/wum-1.0-linux-x64.tar.gz
    cd /usr/local/
    tar -zxvf "$BIN_DIR/wum-1.0-linux-x64.tar.gz"
    chown -R $USERNAME wum/
    
    local is_path_set=$(grep -r "usr/local/wum/bin" /etc/profile | wc -l  )
    echo "Adding WUM to PATH ..." 
    if [ $is_path_set = 0 ]; then
        echo "Adding WUM to PATH variable"
        echo "export PATH=\$PATH:/usr/local/wum/bin" >> /etc/profile
    fi


    sudo -u $USERNAME /usr/local/wum/bin/wum init -u $1 -p $2

};

install_java8() {
    local jdk_filename='jdk-8u144-linux-x64.tar.gz'
    local java_installer_dir='/usr/lib/jvm/java-8-oracle'

    # TODO: Need to get a proper way to retrieve JAVA 8
    wget -P $BIN_DIR https://www.dropbox.com/s/e5sdv8f7p1ifnkf/jdk-8u144-linux-x64.tar.gz
    # INSTALLER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    echo "script file location: $INSTALLER_DIR"
    # echo "Installing JAVA...i ${BASH_SOURCE[0]} "
    sudo mkdir -p $java_installer_dir
    cd $java_installer_dir
    sudo tar -zxvf $BIN_DIR/$jdk_filename
    JAVA_HOME_FOUND=$(grep -r "JAVA_HOME=" /etc/profile | wc -l  )
    echo "setting up JAVA_HOME ..." 
    if [ $JAVA_HOME_FOUND = 0 ]; then
        echo "Adding java home entry."
        echo JAVA_HOME=$java_installer_dir >> /etc/profile 
    else
        echo "Updating java home entry."
        sed -i "/JAVA_HOME=/c\JAVA_HOME=$java_installer_dir" /etc/profile
    fi
    
}

update_apt
install_mysql
install_wum $WUM_USER $WUM_PASS
install_java8
echo "Done!"
