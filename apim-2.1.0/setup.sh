#!/bin/sh

#################################INPUTS###################################
#APIM RDS
rds_apim_host="localhost"
rds_apim_username="root"
rds_apim_password="root"
am_db="am_dbx"
um_db="um_dbx"
reg_db="reg_dbx"

#Analytics RDS
rds_analytics_host="localhost"
rds_analytics_username="root"
rds_analytics_password="root"
event_store_db="event_store_dbx"
processed_data_db="processed_data_dbx"
stats_db="stats_dbx"

#Loadbalancers
gateway_lb_hostname="localhost"
apim_lb_hostname="localhost"

INSTALL_DIR=/opt/wso2
#################################INPUTS###################################

#echo "Killing Servers..."
#kill -9 $(cat ../wso2am-2.1.0/wso2carbon.pid)
#kill -9 $(cat ../wso2am-analytics-2.1.0/wso2carbon.pid)
#echo "Done!"

echo "Extracting Servers..."
#rm -rf ../wso2am-2.1.0
#rm -rf ../wso2am-analytics-2.1.0
sudo -u ubuntu unzip ${WUM_PRODUCT_DIR}/$(ls -t ${WUM_PRODUCT_DIR} | grep .zip | head -1) -d ${INSTALL_DIR}
unzip ../wso2am-2.1.0.*.zip -d ${INSTALL_DIR}
unzip ../wso2am-analytics-2.1.0.*.zip -d ${INSTALL_DIR}
echo "Servers extracted!"

echo "Copying configuration files..."
cp -r apim_conf/* ${INSTALL_DIR}/wso2am-2.1.0/repository/conf/
cp -r apim_analytics_conf/* ${INSTALL_DIR}/wso2am-analytics-2.1.0/repository/conf/
cp /home/ubuntu/bin/mysql-connector-java-5.1.44.jar ${INSTALL_DIR}/wso2am-2.1.0/repository/components/lib/
cp /home/ubuntu/bin/mysql-connector-java-5.1.44.jar ${INSTALL_DIR}/wso2am-analytics-2.1.0/repository/components/lib/
cp _HealthCheck_.xml ${INSTALL_DIR}/wso2am-2.1.0/repository/deployment/server/synapse-configs/default/api/
echo "Done!"

echo "Configuring files..."
find ${INSTALL_DIR}/wso2am-* -type f \( -iname "*.properties" -o -iname "*.xml" \) -print0 | xargs -0 sed -i 's/#_RDS_APIM_HOST_#/'$rds_apim_host'/g'
find ${INSTALL_DIR}/wso2am-* -type f \( -iname "*.properties" -o -iname "*.xml" \) -print0 | xargs -0 sed -i 's/#_RDS_APIM_USERNAME_#/'$rds_apim_username'/g'
find ${INSTALL_DIR}/wso2am-* -type f \( -iname "*.properties" -o -iname "*.xml" \) -print0 | xargs -0 sed -i 's/#_RDS_APIM_PASSWORD_#/'$rds_apim_password'/g'
find ${INSTALL_DIR}/wso2am-* -type f \( -iname "*.properties" -o -iname "*.xml" \) -print0 | xargs -0 sed -i 's/#_AM_DB_#/'$am_db'/g'
find ${INSTALL_DIR}/wso2am-* -type f \( -iname "*.properties" -o -iname "*.xml" \) -print0 | xargs -0 sed -i 's/#_UM_DB_#/'$um_db'/g'
find ${INSTALL_DIR}/wso2am-* -type f \( -iname "*.properties" -o -iname "*.xml" \) -print0 | xargs -0 sed -i 's/#_REG_DB_#/'$reg_db'/g'
find ${INSTALL_DIR}/wso2am-* -type f \( -iname "*.properties" -o -iname "*.xml" \) -print0 | xargs -0 sed -i 's/#_RDS_ANALYTICS_HOST_#/'$rds_analytics_host'/g'
find ${INSTALL_DIR}/wso2am-* -type f \( -iname "*.properties" -o -iname "*.xml" \) -print0 | xargs -0 sed -i 's/#_RDS_ANALYTICS_USERNAME_#/'$rds_analytics_username'/g'
find ${INSTALL_DIR}/wso2am-* -type f \( -iname "*.properties" -o -iname "*.xml" \) -print0 | xargs -0 sed -i 's/#_RDS_ANALYTICS_PASSWORD_#/'$rds_analytics_password'/g'
find ${INSTALL_DIR}/wso2am-* -type f \( -iname "*.properties" -o -iname "*.xml" \) -print0 | xargs -0 sed -i 's/#_EVENT_STORE_DB_#/'$event_store_db'/g'
find ${INSTALL_DIR}/wso2am-* -type f \( -iname "*.properties" -o -iname "*.xml" \) -print0 | xargs -0 sed -i 's/#_PROCESSED_DATA_DB_#/'$processed_data_db'/g'
find ${INSTALL_DIR}/wso2am-* -type f \( -iname "*.properties" -o -iname "*.xml" \) -print0 | xargs -0 sed -i 's/#_STATS_DB_#/'$stats_db'/g'
find ${INSTALL_DIR}/wso2am-* -type f \( -iname "*.properties" -o -iname "*.xml" \) -print0 | xargs -0 sed -i 's/#_GW_LB_HOSTNAME_#/'$gateway_lb_hostname'/g'
find ${INSTALL_DIR}/wso2am-* -type f \( -iname "*.properties" -o -iname "*.xml" \) -print0 | xargs -0 sed -i 's/#_APIM_LB_HOSTNAME_#/'$apim_lb_hostname'/g'
echo "Done!"

echo "Creating databases..."
mysql -h $rds_apim_host -u $rds_apim_username -p$rds_apim_password -e "DROP DATABASE IF EXISTS "$am_db"; DROP DATABASE IF EXISTS "$um_db"; DROP DATABASE IF EXISTS "$reg_db"; CREATE DATABASE "$am_db"; CREATE DATABASE "$um_db"; CREATE DATABASE "$reg_db";"
mysql -h $rds_analytics_host -u $rds_analytics_username -p$rds_analytics_password -e "DROP DATABASE IF EXISTS "$event_store_db"; DROP DATABASE IF EXISTS "$processed_data_db"; DROP DATABASE IF EXISTS "$stats_db"; CREATE DATABASE "$event_store_db"; CREATE DATABASE "$processed_data_db"; CREATE DATABASE "$stats_db";"
echo "Done!"

echo "Creating tables..."
mysql -h $rds_apim_host -u $rds_apim_username -p$rds_apim_password -e "USE "$am_db"; SOURCE ../wso2am-2.1.0/dbscripts/apimgt/mysql5.7.sql; USE "$um_db"; SOURCE ../wso2am-2.1.0/dbscripts/mysql5.7.sql; USE "$reg_db"; SOURCE ../wso2am-2.1.0/dbscripts/mysql5.7.sql;"
echo "Done!"

echo "Starting Servers..."
sh ${INSTALL_DIR}/wso2am-analytics-2.1.0/bin/wso2server.sh start
echo "APIM Analytics Server is starting up..."
sleep 30
sh ${INSTALL_DIR}/wso2am-2.1.0/bin/wso2server.sh start
echo "APIM Server is starting up..."
