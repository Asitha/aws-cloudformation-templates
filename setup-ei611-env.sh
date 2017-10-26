#!/bin/bash

USERNAME=ubuntu
WSO2_DIR=/opt/wso2/
WUM_PRODUCT_DIR=/home/$USERNAME/.wum-wso2/products/wso2ei/6.1.1
WUM_PRODUCT_NAME=wso2ei-6.1.1

create_wum_updated_pack() {
    sudo -u $USERNAME /usr/local/wum/bin/wum add $1 -y
    sudo -u $USERNAME /usr/local/wum/bin/wum update $1

    mkdir -p $WSO2_DIR
    cd $WSO2_DIR
    chown -R $USERNAME $WSO2_DIR
    sudo -u $USERNAME unzip $WUM_PRODUCT_DIR/$(ls -t $WUM_PRODUCT_DIR | grep .zip | head -1)
}

create_wum_updated_pack $WUM_PRODUCT_NAME
