#!/usr/bin/env bash

readonly USERNAME=$1
readonly PRODUCT_NAME=$2
readonly PRODUCT_VERSION=$3
readonly INSTALL_DIR=$4
readonly DEPLOYMENT_TYPE=$5
readonly CONF_TEMPLATE_DIR=$6
readonly CONF_MAPPINGS_FILE=$7

readonly WUM_PRODUCT_DIR=/home/${USERNAME}/.wum-wso2/products/${PRODUCT_NAME}/${PRODUCT_VERSION}
readonly WUM_PRODUCT_NAME=${PRODUCT_NAME}-${PRODUCT_VERSION}

create_wum_updated_pack() {
    sudo -u ${USERNAME} /usr/local/wum/bin/wum add $1 -y
    sudo -u ${USERNAME} /usr/local/wum/bin/wum update $1

    mkdir -p ${INSTALL_DIR}
    chown -R ${USERNAME} ${INSTALL_DIR}
    echo "Copying WUM updated pack to ${INSTALL_DIR}"
    sudo -u ${USERNAME} unzip ${WUM_PRODUCT_DIR}/$(ls -t ${WUM_PRODUCT_DIR} | grep .zip | head -1) -d ${INSTALL_DIR}
}

create_configs_from_templates() {
    local tmp_conf_dir=$1

    cp -r ${CONF_TEMPLATE_DIR} ${tmp_conf_dir}
    echo "Updating configuration values"
    input="${CONF_MAPPINGS_FILE}"
    while IFS='=' read -r key value
    do
      if [[ "${key}" =~ [^[:space:]] ]]; then
        escapedKey=$(echo ${key} | sed -e "s#/#\\\/#g")
        escapedValue=$(echo ${value} | sed -e "s#/#\\\/#g")
        grep -rl ${key} ${tmp_conf_dir} | xargs -rn 1 sed -i "s/#_${escapedKey}_#/${escapedValue}/g"
      fi
    done < "${input}"
}

replace_configs() {
    local tmp_conf_dir=/tmp/${WUM_PRODUCT_NAME}/

    create_configs_from_templates ${tmp_conf_dir}
    echo "Replacing configuration files"
    cp -r ${tmp_conf_dir}/* ${INSTALL_DIR}/${WUM_PRODUCT_NAME}/
}

main() {
    create_wum_updated_pack ${WUM_PRODUCT_NAME}
    if [ "${DEPLOYMENT_TYPE}" != "local" ]; then
        replace_configs
    fi
}

main