###############################################################################
#
# Authors: MHD WALED BAIRAM <waled.bairam@company_name.com>
#
# ufw is a simpler tool above iptables. iptables is more flexible tool.
# Anyway, ufw is used here.
#
# Usage:
#
#   ./ufw_script.sh 
#
# Note: Perform this script once in each vm.
#
###############################################################################

#During the procedure, the script will echo messages starting with my name, and the current date.
#To get the current date, perform this command in the node, thus, use ``.
Date=`date "+%Y-%m-%d"`

echo "[MWB-"$Date"] enabling ufw ..."
sudo ufw enable
echo "[MWB-"$Date"] overriding docker iptables policy ..."
#Touch the file, give the ownership to the current user (will be user "ng", any user other than the root just to be able to write inside it).
sudo touch /etc/docker/daemon.json
sudo chown $USER:$USER /etc/docker/daemon.json
sudo chmod 644 /etc/docker/daemon.json
#write inside it (> will overwrite, >> will append)
sudo echo "{ \"iptables\": false }" > /etc/docker/daemon.json
#Now give the ownership back to root.
sudo chown root:root /etc/docker/daemon.json
echo "[MWB-"$Date"] restarting ufw and docker ..."
sudo systemctl restart ufw
sudo systemctl restart docker
echo "[MWB-"$Date"] allowing ssh ..."
sudo ufw allow 22/tcp
echo "[MWB-"$Date"] setting incoming default policy to deny ..."
sudo ufw default deny incoming 

CHECK1=$( sudo lsof -i:5432 | grep -i listen | wc -l )
#If there is a postgresql running with port 5432, the output of that command will be 1.
#lsof checks the ports used. Ref: https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/
if [ $CHECK1 -ne 0 ]
then
  #This is the case of ng-vm1.
  echo "[MWB-"$Date"] postgesql is listening to 5432, allowing the port in ufw ..."
  sudo ufw allow 5432/tcp
else
  #This is the case of ng-vm2.
  echo "[MWB-"$Date"] no postgresql was detected, skip opening its port ..."
fi

CHECK2=$( sudo lsof -i:8086 | grep -i listen | wc -l )
#If there is an influxdb running with port 8086, the output of that command will be 1.
#lsof checks the ports used. Ref: https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/
if [ ! $CHECK2 == 0 ]
then
  #This is the case of ng-vm1.
  echo "[MWB-"$Date"] influxdb is listening to 8086, allowing the port in ufw ..."
  sudo ufw allow 8086/tcp
else
  #This is the case of ng-vm2.
  echo "[MWB-"$Date"] no influxdb was detected, skip opening its port ..."
fi

echo "[MWB-"$Date"] enabling all ports for localhost management ..."
sudo ufw allow from 127.0.0.1 to 127.0.0.1 proto tcp

echo "[MWB-"$Date"] finished configuring ufw, below is the table you have:"
sudo ufw status verbose

exit 0