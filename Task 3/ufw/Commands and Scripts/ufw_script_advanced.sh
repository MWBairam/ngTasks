###############################################################################
#
# Authors: MHD WALED BAIRAM <waled.bairam@company_name.com>
#
# ufw is a simpler tool above iptables. iptables is more flexible tool.
# Anyway, ufw is used here.
# Controller node means the vm with the db and monitoring system.
# Compute node means the vm with the webapplication.
#
# Usage:
#
#   ./ufw_script_advanced.sh \
#   -crip <controller_node_IP_value> \
#   -cpip <compute_node_IP_value> \
#   -psqlport <postgresql_port_value> \
#   -fport <influxdb_port_value>
#
# Example:
#
#   ./ufw_script_advanced.sh \
#   -crip 172.16.1.1 \
#   -cpip 172.16.1.2 \
#   -psqlport 5432 \
#   -fport 8086 
#
# Arguments:
#
# -crip --controller-node-ip            
#    Controller Node IP
# -cpip --compute-node-ip                 
#    Compute Node IP
# -psqlport --postgresql-port
#    PostgreSQL Database Running Port
# -fport --influxdb-port 
#    Influx Time Series Database running Port 
#
# Note: Perform this script in one (any) vm since it will ssh the other vm automatically.
#
###############################################################################

#During the procedure, the script will echo messages starting with my name, and the current date.
#To get the current date, perform this command in the node, thus, use ``.
Date=`date "+%Y-%m-%d"`














# exit if the number of provided positional parameters is not 8 (each argument and its value).
# "$#" is the number of positional parameters passed to the script.
# Ref: https://unix.stackexchange.com/questions/25945/how-to-check-if-there-are-no-parameters-provided-to-a-command
# Ref: https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
if [  ! $# -eq 8 ]; 
then
  echo "[MWB-"$Date"] Please enter the mandatory 4 arguments (cat the .sh file to take a look)"
  exit 1
fi
















#Define default values:
ControllerNodeIP=172.16.1.1
ComputeNodeIP=172.16.1.2
PostgresqlPort=5432
InfluxdbPort=8086
# retrieve arguments, and replace defualt values: 
# Example: ./ufw_script_advanced.sh -crip 172.16.1.1 -cpip 172.16.1.2 -psqlport 5432 -fport 8086 
# at this point: $1=-crip , $2=172.16.1.1 , $3=-cpip , $4=172.16.1.2 , $5=-psqlport , $6=5432 , $7=-fport , $8=8086
# so first, check $1 and $2 to fill in the above mentioned var ControllerNodeIP.
# do shift shift. 
# at this point: $1=-cpip , $2=172.16.1.2 , $3=-psqlport , $4=5432 , $5=-fport , $6=8086
# so second, check the new $1 and $2 to fill in the above mentioned var ComputeNodeIP.
# then do shift shift again
# and so on .... until $# is decreased to 0, the loop is broken, 
# Ref: https://askubuntu.com/questions/939620/what-does-mean-in-bash
# Ref: https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script
while [[ ! $# -eq 0 ]]
do
  case $1 in
    --controller-node-ip | -crip)
      ControllerNodeIP=$2
      shift;shift
      ;;
    --compute-node-ip | -cpip)
      ComputeNodeIP=$2
      shift;shift
      ;;
    --postgresql-port | -psqlport)
      PostgresqlPort=$2
      shift;shift
      ;;
    --influxdb-port | -fport)
      InfluxdbPort=$2
      shift;shift
      ;;
  esac
done
















#Check IPs and ports validity:
#Ref:https://stackoverflow.com/questions/13777387/check-for-ip-validity
if [[ "$ControllerNodeIP" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; 
then
  echo "[MWB-"$Date"] Controller Node IP is Valid ..."
else
  echo "[MWB-"$Date"] Controller Node IP is Invalid ..."
  exit 1
fi
if [[ "$ComputeNodeIP" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; 
then
  echo "[MWB-"$Date"] Compute Node IP is Valid ..."
else
  echo "[MWB-"$Date"] Compute Node IP is Invalid ..."
  exit 1
fi
if [[ "$PostgresqlPort" =~ ^([0-9][0-9][0-9][0-9])$ ]]; 
then
  echo "[MWB-"$Date"] PostgreSQL Database Running Port is Valid ..."
else
  echo "[MWB-"$Date"] PostgreSQL Database Running Port is Invalid ..."
  exit 1
fi
if [[ "$InfluxdbPort" =~ ^([0-9][0-9][0-9][0-9])$ ]]; 
then
  echo "[MWB-"$Date"] Influx Time Series Database running Port is Valid ..."
else
  echo "[MWB-"$Date"] Influx Time Series Database running Port is Invalid ..."
  exit 1
fi

















#The following allows the script to be run in any node, configure ufw, then ssh the other node to configure ufw there as well.
#Define a function.
function configureUfw () {
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

  CHECK1=$( sudo lsof -i:$PostgresqlPort | grep -i listen | wc -l )
  #If there is a postgresql running with the port specified, the output of that command will be 1.
  #lsof checks the ports used. Ref: https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/
  if [ $CHECK1 -ne 0 ]
  then
    echo "[MWB-"$Date"] postgesql listening to "$PostgresqlPort" is detected, allowing the port in ufw ..."
    sudo ufw allow from $ComputeNodeIP to $ControllerNodeIP port $PostgresqlPort proto tcp
  else
    echo "[MWB-"$Date"] no postgresql listening to "$PostgresqlPort" is detected, skip allowing its port ..."
  fi
  
  CHECK2=$( sudo lsof -i:$InfluxdbPort | grep -i listen | wc -l )
  #If there is an influxdb running with the port specified, the output of that command will be 1.
  #lsof checks the ports used. Ref: https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/
  if [ ! $CHECK2 == 0 ]
  then
    echo "[MWB-"$Date"] influxdb listening to "$InfluxdbPort" is detected, allowing the port in ufw ..."
    sudo ufw allow from $ComputeNodeIP to $ControllerNodeIP port $InfluxdbPort proto tcp
  else
    echo "[MWB-"$Date"] no influxdb listening to "$InfluxdbPort" is detected, skip allowing its port ..."
  fi
  
  echo "[MWB-"$Date"] enabling all ports for localhost management ..."
  sudo ufw allow from 127.0.0.1 to 127.0.0.1 proto tcp
  
  echo "[MWB-"$Date"] finished configuring ufw, below is the table you have:"
  sudo ufw status verbose
}
#Execute the function on this node.
configureUfw
#Execute the function on the other node.
CHECK_IP=$( sudo ip addr show | grep $ControllerNodeIP | wc -l )
#If the output is 1, that means this node is the controller node, so log in to the compute node (the other node), and vice versa.
if [ $CHECK_IP -ne 0 ]
then
  echo "[MWB-"$Date"] SSH to the compute node, and configure ufw ..." 
  #The below command does: SSH to the other node, declare the functiion and the variables we used above, then after the ";" it performs commands which are setting the values of the variables and then execute the function. 
  #Ref: https://stackoverflow.com/questions/23264657/how-to-run-a-bash-function-in-a-remote-host-in-ubuntu
  ssh $ComputeNodeIP "`declare -f configureUfw Date ControllerNodeIP ComputeNodeIP PostgresqlPort InfluxdbPort`; Date="$Date" ControllerNodeIP="$ControllerNodeIP" ComputeNodeIP="$ComputeNodeIP" PostgresqlPort="$PostgresqlPort" InfluxdbPort="$InfluxdbPort" configureUfw"

else
  echo "[MWB-"$Date"] SSH to the controller node, and configure ufw ..."
  ssh $ControllerNodeIP "`declare -f configureUfw Date ControllerNodeIP ComputeNodeIP PostgresqlPort InfluxdbPort`; Date="$Date" ControllerNodeIP="$ControllerNodeIP" ComputeNodeIP="$ComputeNodeIP" PostgresqlPort="$PostgresqlPort" InfluxdbPort="$InfluxdbPort" configureUfw"
fi
exit 0