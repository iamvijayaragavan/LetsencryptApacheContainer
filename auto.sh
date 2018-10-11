echo "Welcome to Container World"
echo
domain="$1"
email="$2"

if [ -z $domain ]; then
   echo "Please give vaild Domain name"
   exit
fi

if [ -z $email ]; then
   echo "Please give the vaild email address"
   exit
fi

echo 
echo " Setting up the configuration files .."
echo
echo "Configuring the http files ..."
sed -i 's/change_domain/'$1'/g' ./apache-prod/httpd.conf
echo
echo "Configuring the ssl files ..."
sed -i 's/change_domain/'$1'/g' ./apache-prod/httpd-ssl.conf
echo
echo "Configuring the compose files .."
sed -i 's/change_domain/'$1'/g' ./apache-prod/docker-compose.yml
echo
echo


echo "This is example to create Apache Container with Letsencrypt Contianer"
echo

echo "Creating temporary apache container for token generation"
cd ${PWD}/apache-temp/
docker-compose up -d
echo
echo
sleep 3
if [ "$(docker ps -q -f name=letsencrypt-apache)" ]; then
   echo "Container Created Successfully ..."
else
   echo "There is issue with contianer creation  ... Please check docker logs ...\n Hint: 80 Port might be binded"
   exit
fi
echo

echo "Creating CertBot Container for Domain vaildation & certificate creation"
echo
sh certbot.sh $domain $email
echo
sleep 2
if [ -f ./dc-vol/letsencrypt/etc/live/"$domain"/fullchain.pem ]; then
   echo "Certbot generated certificates successfully ..."
else
   echo "There is issue check in certbot continer log ... Report to Admin"
   exit
fi
echo

sleep 2
echo "Stopping temporary Contianer"
docker-compose down
echo 
if [ "$(docker ps -q -f name=letsencrypt-apache)" ]; then
   echo "Temporary container is not deleted "
   exit
else
   echo "Container has been deleted"
fi
echo


echo "Creating Prod Container"
cd ../apache-prod/
docker-compose up -d
echo
sleep 2
if [ "$(docker ps -q -f name=prod_apache)" ]; then
   echo "Prod contianer running successfully ..."
   echo
else
   echo "Issue with running container ... Port Bind exception .. check in container log"
fi
echo

echo "Clearing temp & local certificate file "
rm -rf ${PWD}/apache-temp/dc-vol
docker system prune -f
echo
echo "All Good!"

