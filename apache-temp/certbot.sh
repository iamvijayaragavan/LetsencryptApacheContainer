domain="$1"
email="$2"
rootdir=${PWD}/dc-vol
subdir=${PWD}/dc-vol/letsencrypt
etcdir=${PWD}/dc-vol/letsencrypt/etc
libdir=${PWD}/dc-vol/letsencrypt/lib
sitedir=${PWD}/site
logdir=${PWD}/dc-vol/letsencrypt/log

if [ -z "$domain" ]; then
  echo "No Domain name is passed ..."
  exit
fi

if [ -z "$email" ]; then
  echo "Email address is needed ..."
  exit
fi

echo " Creating Volume dir in local"

createdir(){
mkdir $rootdir $subdir $etcdir $libdir $logdir
}

craetecontainer(){
echo "Checking ..."


docker run -it --rm -v "$etcdir":/etc/letsencrypt -v "$libdir":/var/lib/letsencrypt -v "$sitedir":/data/letsencrypt -v "$logdir":/var/log/letsencrypt certbot/certbot certonly --webroot --email "$email" --agree-tos --no-eff-email --webroot-path=/data/letsencrypt -d "$domain" 

#cc=`docker run -it --rm \
#-v "$etcdir":/etc/letsencrypt \ 
#-v "$libdir":/var/lib/letsencrypt \ 
#-v "$sitedir":/data/letsencrypt \
#-v "$logdir":/var/log/letsencrypt \ 
#certbot/certbot certonly --webroot \
#--email "$email" -agree-tos --no-eff-email \
#--webroot-path=/data/letsencrypt \
#-d "$domain" -d www.$domain`

#echo $cc
#if [ $cc ]; then
#	echo "Container Created successfuly ..."
#fi

}

if [ -d $rootdir ]; then
  echo "Directory already exsit .. Deleting"
  rm -rf $rootdir
  createdir;
else
  createdir;
  echo
  echo "Created Vol directory"
fi

echo
echo "Craeting certificate using Certbot"
echo
craetecontainer;
echo
