# setup the correct hostname based on the Terraform configuration
export HOSTNAME=maha-ptfe.hashicorp-success.com

# install certbot
which certbot &>/dev/null || {
  sudo apt-get update
  sudo apt-get install -y software-properties-common
  sudo add-apt-repository -y ppa:certbot/certbot
  sudo apt-get update
  sudo apt-get install -y certbot 
}

# manually execute the following command
# make sure that http port 80 is open in ingress rule prior to running the below command
echo " ++++++++++++++ certbot installation is complete +++++++++ "
echo " "
echo "now run:"
echo "sudo certbot certonly --standalone -d $HOSTNAME"
echo " "

echo "certs will be:"
echo "/etc/letsencrypt/live/$HOSTNAME/privkey.pem"
echo "/etc/letsencrypt/live/$HOSTNAME/fullchain.pem"

echo "later, to renew you need to run:"
echo "sudo certbot renew"

# disable port 80 in ingress if required
