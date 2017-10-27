#!/usr/bin/env bash

readonly USERNAME=$1
readonly DEPLOYMENT_TYPE=$2
readonly DB_HOSTNAME=$3
readonly DB_USERNAME=$4
readonly DB_PASSWORD=$5

readonly PRODUCT_NAME=wso2ei
readonly PRODUCT_VERSION=6.1.1
readonly CONF_TEMPLATE_DIR=ei-6.1.1/conf/
readonly CONF_MAPPING_FILE=ei-6.1.1/template-mappings.txt
readonly EI_INSTALL_DIR=/opt/wso2

readonly USER_DB="um_db"
readonly REG_DB="reg_db"
readonly MB_DB="mb_db"
readonly BPS_DB="bps_db"
readonly ANALYTICS_DB="_db"
readonly DEMO_DB="demo_db"
readonly PRODUCT_HOME="${EI_INSTALL_DIR}/${PRODUCT_NAME}-${PRODUCT_VERSION}"

setup_database() {
    echo "Creating databases..."
    mysql -h ${DB_HOSTNAME} -u ${DB_USERNAME} -p${DB_PASSWORD} -e "CREATE DATABASE ${USER_DB}; CREATE DATABASE ${REG_DB}; \
    CREATE DATABASE ${BPS_DB}; CREATE DATABASE ${MB_DB}; CREATE DATABASE ${DEMO_DB};"
    echo "Done!"

    echo "Creating tables..."
    mysql -h ${DB_HOSTNAME} -u ${DB_USERNAME} -p${DB_PASSWORD} -e "USE ${USER_DB}; \
    SOURCE ${PRODUCT_HOME}/dbscripts/mysql5.7.sql; USE "${REG_DB}"; SOURCE ${PRODUCT_HOME}/dbscripts/mysql5.7.sql;"
    echo "Done!"

    cp $(find /home/${USERNAME}/bin/ -iname "mysql-connector*.jar" | head -n 1 ) ${PRODUCT_HOME}/lib/
}

start_product() {
    sudo -u ${USERNAME} bash ${PRODUCT_HOME}/bin/integrator.sh start
}

main() {
    bash setup-product.sh ${USERNAME} ${PRODUCT_NAME} ${PRODUCT_VERSION} ${EI_INSTALL_DIR} ${DEPLOYMENT_TYPE} ${CONF_TEMPLATE_DIR} ${CONF_MAPPING_FILE}
    if [ "${DEPLOYMENT_TYPE}" != "local" ]; then
        setup_database
    fi
    start_product
}

main
