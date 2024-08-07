#!/bin/bash
###
# Selenium Grid Auto Deploy Script
# Author: LTY_CK_TS(https://tian-shen.me/)
# Date: 01/03/2023
# Update Date：22/02/2024
# Copyright © 2024 by LTY_CK_TS, All Rights Reserved.
###
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'
BLUE="\033[36m"

not_root() {
  echo -e "${YELLOW}Warning:${PLAIN}not running in root privilege, but it seems docker command can be used directly"
  echo "Script will proceed, if you encounter docker permission problems during the run, please try to run with root(sudo)!"
  echo ""
  sleep 1
}

hub() {
  echo -e "${BLUE}Start deploying ${RED}Hub${BLUE}, pulling the latest version of Hub image${PLAIN}"
  sleep 2
  docker pull $docker_hub
  echo -e "${BLUE}Pull complete!${PLAIN}"
  if [ $delete = true ]; then
    echo -e "${YELLOW}Deleting old images...${PLAIN}"
    image_id=$(docker images | grep "$docker_hub" | grep "latest" | awk '{print $3}')
    docker rmi $(docker images | grep "$docker_hub" | grep -v "$image_id" | awk '{print $3}')
    echo -e "${BLUE}Delete complete!${PLAIN}"
  fi
  echo -e "${YELLOW}Caution: you need to use two ports for nodes connection and one port for WebUI!${PLAIN}"
  echo -e "${YELLOW}If you change those 2 ports for ${RED}nodes connection${BLUE}, make sure to use the same ports when installing ${RED}nodes${BLUE}!${PLAIN}"
  port1=4442
  if [ $# -gt 0 ] ;then
    if [ $# -gt 2 ] ;then
      port1=$3
      echo -e "Port 1 has been changed to: ${BLUE}" $port1 "${PLAIN}"
    else
      echo -e "${BLUE}Port ${YELLOW}4442${BLUE} is used as ${RED}the first node connection port${PLAIN}"
    fi
  else
    echo -e "${BLUE}By default, port ${YELLOW}4442${BLUE} is used as ${RED}the first node connection port${PLAIN}"
    read -p "Please enter a new port for first node connection(leave blank to use default port 4442):" port1_enter
    if [ "$port1_enter" ] ;then
      port1=$port1_enter
      echo -e "Port 1 has been changed to: ${BLUE}" $port1 "${PLAIN}"
    fi
  fi
  port2=4443
  if [ $# -gt 0 ] ;then
    if [ $# -gt 2 ] ;then
      port2=$4
      echo -e "Port 2 has been changed to: ${BLUE}" $port2 "${PLAIN}"
    else
      echo -e "${BLUE}Port ${YELLOW}4443${BLUE} is used as ${RED}the second node connection port${PLAIN}"
    fi
  else
    echo -e "${BLUE}By default, port ${YELLOW}4443${BLUE} is used as ${RED}the second node connection port${PLAIN}"
    read -p "Please enter a new port for second node connection(leave blank to use default port 4443):" port2_enter
    if [ "$port2_enter" ] ;then
      port2=$port2_enter
      echo -e "Port 2 has been changed to: ${BLUE}" $port2 "${PLAIN}"
    fi
  fi
  portUI=4444
  if [ $# -gt 0 ] ;then
    if [ $# -gt 2 ] ;then
      portUI=$5
      echo -e "Port UI has been changed to: ${BLUE}" $portUI "${PLAIN}"
    else
      echo -e "${BLUE}Port ${YELLOW}4444${BLUE} is used as ${RED}the WebUI port${PLAIN}"
    fi
  else
    echo -e "${BLUE}By default, port ${YELLOW}4444${BLUE} is used as ${RED}the WebUI port${PLAIN}"
    read -p "Please enter a new port for WebUI(leave blank to use default port 4444):" portUI_enter
    if [ "$portUI_enter" ] ;then
      portUI=$portUI_enter
      echo -e "Port UI has been changed to: ${BLUE}" $portUI "${PLAIN}"
    fi
  fi
  echo -e "${RED}To protect Selenium from unauthorized calls, you must set up a username and password for it${PLAIN}"
  echo -e "${BLUE}Please set the username:${PLAIN}"
  read username
  echo -e "${BLUE}Please set the password${PLAIN}"
  read -s password
  docker run -d -p $port1:4442 -p $port2:4443 -p $portUI:4444 --name wd-hub --log-opt max-size=1m --log-opt max-file=1 -e SE_OPTS="--username $username --password $password" --restart=always $docker_hub
  echo -e "${BLUE}Hub has been deployed!${PLAIN}"
}

node() {
  echo -e "${BLUE}Start deploying ${RED}Node${BLUE}, pulling the latest version of Node image${PLAIN}"
  sleep 2
  docker pull $docker_node
  echo -e "${BLUE}Pull complete!${PLAIN}"
  if [ $delete = true ]; then
    echo -e "${YELLOW}Deleting old images...${PLAIN}"
    image_id=$(docker images | grep "$docker_node" | grep "latest" | awk '{print $3}')
    docker rmi $(docker images | grep "$docker_node" | grep -v "$image_id" | awk '{print $3}')
    echo -e "${BLUE}Delete complete!${PLAIN}"
  fi
  if [[ $(curl -m 10 -Ls https://ipapi.co/json | grep 'China') != "" ]]; then
    echo -e "${BLUE}It seems that this IP is in ${RED}Mainland China${BLUE}, using ${YELLOW}ipip.net${BLUE} to get your IP address...${PLAIN}"
    address=$(curl -Ls -4 myip.ipip.net/s)
  else
    echo -e "${BLUE}It seems that this IP is not in ${RED}Mainland China${BLUE}, using ${YELLOW}ip.sb${BLUE} to get your IP address...${PLAIN}"
    address=$(curl -Ls -4 ip.sb)
  fi
  echo -e "Current IP/domain name: ${BLUE}" $address "${PLAIN}"
  if [ $# -gt 0 ] ;then
    if [ $# -gt 2 ] ;then
      address=$3
      echo -e "${RED}IP/domain name ${PLAIN}has been changed to: ${BLUE}" $address "${PLAIN}"
      hub_address=$4
      echo -e "${RED}Hub IP/domain name ${PLAIN}has been changed to: ${BLUE}" $hub_address "${PLAIN}"
      port1=$5
      echo -e "${RED}Port 1 ${PLAIN}has been changed to: ${BLUE}" $port1 "${PLAIN}"
      port2=$6
      echo -e "${RED}Port 2 ${PLAIN}has been changed to: ${BLUE}" $port2 "${PLAIN}"
      node_port=$7
      echo -e "${RED}Node port ${PLAIN}has been changed to: ${BLUE}" $node_port "${PLAIN}"
      memory=$8
      echo -e "${RED}Maximum RAM allowed ${PLAIN}has been changed to: ${BLUE}" $memory "${PLAIN}"
      number=$9
      echo -e "${RED}Maximum number of working threads ${PLAIN}has been changed to: ${BLUE}" $number "${PLAIN}"
      vnc=${10}
      if [ "$vnc" = "y" ] ;then
        vnc_pwd=${11}
        echo -e "${YELLOW}VNC function turned on${PLAIN}"
        echo -e "${RED}VNC password ${PLAIN}has been changed to: ${BLUE}" $vnc_pwd "${PLAIN}"
        echo -e "${BLUE}Start deploying!${PLAIN}"
        docker run -d --name=wd -p $node_port:$node_port -p 5900:5900 -e SE_NODE_HOST=$address \
        -e SE_EVENT_BUS_HOST=$hub_address -e SE_EVENT_BUS_PUBLISH_PORT=$port1 -e SE_EVENT_BUS_SUBSCRIBE_PORT=$port2 \
        -e SE_NODE_PORT=$node_port -e SE_NODE_MAX_SESSIONS=$number -e SE_NODE_OVERRIDE_MAX_SESSIONS=true \
        -e SE_SESSION_RETRY_INTERVAL=1 -e SE_VNC_VIEW_ONLY=1 -e SE_VNC_PASSWORD="$vncpwd" --log-opt max-size=1m \
        --log-opt max-file=1 --shm-size="$memory" --restart=always $docker_node
      else
        echo -e "${YELLOW}VNC function turned off${PLAIN}"
        echo -e "${BLUE}Start deploying!${PLAIN}"
        docker run -d --name=wd -p $node_port:$node_port -e SE_NODE_HOST=$address -e SE_EVENT_BUS_HOST=$hub_address \
         -e SE_EVENT_BUS_PUBLISH_PORT=$port1 -e SE_EVENT_BUS_SUBSCRIBE_PORT=$port2 -e SE_NODE_PORT=$node_port \
         -e SE_NODE_MAX_SESSIONS=$number -e SE_NODE_OVERRIDE_MAX_SESSIONS=true \
         -e SE_SESSION_RETRY_INTERVAL=1 -e SE_START_VNC=false --log-opt max-size=1m --log-opt max-file=1 \
         --shm-size="$memory" --restart=always $docker_node
      fi
    else
      echo -e "${BLUE}If your machine has a dynamic IP or the obtained IP is incorrect, please rerun the script and provide the domain name pointing to this machine in the parameters.${PLAIN}"
      hub_address=$address
      echo -e "By default, the current server IP is used as the address for the ${RED}Hub to connect${PLAIN}."
      port1=4442
      echo -e "${BLUE}By default, ${YELLOW}4442${BLUE} port is used as ${RED}Hub connection port 1 (please ensure it matches what you filled in during your Hub deployment)${PLAIN}."
      port2=4443
      echo -e "${BLUE}By default, ${YELLOW}4443${BLUE} port is used as ${RED}Hub connection port 2 (please ensure it matches what you filled in during your Hub deployment)${PLAIN}."
      node_port=5556
      echo -e "${BLUE}By default, ${YELLOW}5556${BLUE} port is used as the communication port for the ${RED}current node${PLAIN}."
      memory=512m
      echo -e "${BLUE}By default, ${YELLOW}512m${BLUE} of memory is allocated to the ${RED}current node${PLAIN}."
      number=5
      echo -e "${BLUE}By default, the maximum number of processes is set to ${YELLOW}5${PLAIN}."
      echo -e "${BLUE}VNC debugging is disabled by default.${PLAIN}"
      echo -e "${BLUE}Deployment begins!${PLAIN}"
      docker run -d --name=wd -p $node_port:$node_port -e SE_NODE_HOST=$address -e SE_EVENT_BUS_HOST=$hub_address \
       -e SE_EVENT_BUS_PUBLISH_PORT=$port1 -e SE_EVENT_BUS_SUBSCRIBE_PORT=$port2 -e SE_NODE_PORT=$node_port \
       -e SE_NODE_MAX_SESSIONS=$number -e SE_NODE_OVERRIDE_MAX_SESSIONS=true \
       -e SE_SESSION_RETRY_INTERVAL=1 -e SE_START_VNC=false --log-opt max-size=1m --log-opt max-file=1 \
       --shm-size="$memory" --restart=always $docker_node
    fi
  else
    echo -e "${RED}If the IP of this server is not static, please use a domain name${PLAIN}"
    read -p "Please enter the IP/domain name of this server(leave blank to use the IP/domain name above):" change
    if [ "$change" ] ;then
      address=$change
      echo -e "IP/domain name has been changed to: ${BLUE}" $address "${PLAIN}"
    fi
    hub_address=$address
    echo -e "${BLUE}By default, the IP/domain name of ${RED}Hub${BLUE} is the same as that of this server${PLAIN}"
    read -p "Please enter the IP/domain name of Hub(leave blank if hub is also on this server):" hub_add
    if [ "$hub_add" ] ;then
      hub_address=$hub_add
      echo -e "IP/domain name of Hub has been changed to: ${BLUE}" $hub_address "${PLAIN}"
    fi
    port1=4442
    echo -e "${BLUE}By default, port ${YELLOW}4442${BLUE} is used as ${RED}the first node connection port${PLAIN}"
    read -p "Please enter the port of first node connection(leave blank to use default port 4442):" port1_enter
    if [ "$port1_enter" ] ;then
      port1=$port1_enter
      echo -e "Port 1 has been changed to: ${BLUE}" $port1 "${PLAIN}"
    fi
    port2=4443
    echo -e "${BLUE}By default, port ${YELLOW}4443${BLUE} is used as ${RED}the second node connection port${PLAIN}"
    read -p "Please enter the port of second node connection(leave blank to use default port 4443):" port2_enter
    if [ "$port2_enter" ] ;then
      port2=$port2_enter
      echo -e "Port 2 has been changed to: ${BLUE}" $port2 "${PLAIN}"
    fi
    node_port=5556
    echo -e "${BLUE}By default, port ${YELLOW}5556${BLUE} is used as ${RED}the node communication port${PLAIN}"
    read -p "Please enter the port of node communication(leave blank to use default port 5556):" node_port_enter
    if [ "$node_port_enter" ] ;then
      node_port=$node_port_enter
      echo -e "Port of node communication has been changed to: ${BLUE}" $node_port "${PLAIN}"
    fi
    read -p "Enter the maximum RAM allowed(e.g. 512m or 2g): " memory
    read -p "Enter the maximum number of working threads: " number
    echo -e "${BLUE}Do you need to use VNC?(${RED}Using port 5900${BLUE})?${PLAIN}"
    read -p "Enter your choice, leave blank for No(y/N)：" vnc
    if [ "$vnc" = "y" ] ;then
      echo -e "${YELLOW}VNC function turned on${PLAIN}"
      read -p "Enter the password for VNC connection(leave blank for default password 'secret'):" vncpwd
      if [ "$vncpwd" = "" ] ;then
        vncpwd="secret"
      fi
      echo -e "Set VNC password to ${BLUE}" $vncpwd "${PLAIN}"
      echo -e "${BLUE}Start deploying!${PLAIN}"
      docker run -d --name=wd -p $node_port:$node_port -p 5900:5900 -e SE_NODE_HOST=$address -e SE_EVENT_BUS_HOST=$hub_address -e SE_EVENT_BUS_PUBLISH_PORT=$port1 -e SE_EVENT_BUS_SUBSCRIBE_PORT=$port2 -e SE_NODE_PORT=$node_port -e SE_NODE_MAX_SESSIONS=$number -e SE_NODE_OVERRIDE_MAX_SESSIONS=true -e SE_SESSION_RETRY_INTERVAL=1 -e SE_VNC_VIEW_ONLY=1 -e SE_VNC_PASSWORD=$vncpwd --log-opt max-size=1m --log-opt max-file=1 --shm-size="$memory" --restart=always $docker_node
    else
      echo -e "${YELLOW}VNC function turned off${PLAIN}"
      echo -e "${BLUE}Start deploying!${PLAIN}"
      docker run -d --name=wd -p $node_port:$node_port -e SE_NODE_HOST=$address -e SE_EVENT_BUS_HOST=$hub_address -e SE_EVENT_BUS_PUBLISH_PORT=$port1 -e SE_EVENT_BUS_SUBSCRIBE_PORT=$port2 -e SE_NODE_PORT=$node_port -e SE_NODE_MAX_SESSIONS=$number -e SE_NODE_OVERRIDE_MAX_SESSIONS=true -e SE_SESSION_RETRY_INTERVAL=1 -e SE_START_VNC=false --log-opt max-size=1m --log-opt max-file=1 --shm-size="$memory" --restart=always $docker_node
    fi
  fi
  echo -e "${BLUE}Deploy complete!${PLAIN}"
}

mac=false # check if mac
delete=false # check if delete
docker_hub="selenium/hub" # By default, the x86 Hub image is used
docker_node="selenium/node-chrome" # By default, the x86 Node image is used

# Check System
arch=$(uname -m)
if [ $arch == "x86_64" ]; then
  echo -e "${BLUE}System architecture detected as ${YELLOW}x86_64${BLUE}. Using x86 images${PLAIN}"
  elif [ $arch == "aarch64" ]; then
    docker_hub="seleniarm/hub" # arm64 Hub image
    docker_node="seleniarm/node-chromium" # arm64 Node image
    echo -e "${BLUE}System architecture detected as ${YELLOW}arm64${BLUE}. Using ARM images${PLAIN}"
  elif [ $arch == "armv7l" ]; then
    docker_hub="seleniarm/hub" # arm32 Hub Image
    docker_node="seleniarm/node-chromium" # arm32 Node Image
    echo -e "${BLUE}System architecture detected as ${YELLOW}arm32${BLUE}. Using ARM images${PLAIN}"
  else
    echo -e "${BLUE}System architecture detected as ${YELLOW}$arch${PLAIN}"
    echo -e "${RED}This script does not support your system architecture, exiting...${PLAIN}"
    exit 1
fi
echo -e "Hub Image: ${YELLOW}$docker_hub${PLAIN} | Node Image: ${YELLOW}$docker_node${PLAIN}"

# check docker permission
current_user=$(whoami)
if [ $current_user != "root" ]; then # check if root
  if [[ $(uname) == "Darwin" ]]; then # check if mac
    echo -e "${BLUE}System is detected as ${YELLOW}macOS${PLAIN}"
    mac=true
    if [ "$(docker info > /dev/null 2>&1; echo $?)" != "0" ]; then
      echo -e "${RED}Docker socket connection failed${PLAIN}"
      echo -e "${YELLOW}Please make sure Docker Desktop is installed and running!${PLAIN}"
      echo -e "${RED}If it's running correctly, try run the script in sudo!${PLAIN}"
      exit 1
    else
      not_root
    fi
  else
    echo -e "${BLUE}System is detected as ${YELLOW}Linux${PLAIN}"
    if test -z "$(groups $current_user | grep docker)"; then # check if in docker group
      echo -e "${RED}You are not in the docker group, you can't use docker commands${PLAIN}"
      echo -e "${YELLOW}There are 2 solutions:${PLAIN}"
      echo -e "1.${BLUE}Add yourself into docker group${YELLOW}(sudo gpasswd -a <user> docker)${BLUE} and then restart terminal${PLAIN}"
      echo -e "2.${BLUE}Run the script in sudo${PLAIN}"
      exit 1
    else
      not_root
    fi
  fi
  else
    echo -e "${BLUE}You are running the script by ${YELLOW}root${PLAIN}"
fi

echo -e "${BLUE}Welcome to ${PLAIN}Selenium Grid${BLUE} Auto Deploy ${YELLOW}V2.1${PLAIN}"
if [[ $(curl -m 10 -Ls https://ipapi.co/json | grep 'China') != "" ]]; then
  echo -e "${BLUE}It seems that your IP is in ${RED}China Mainland${BLUE}, skip retrieving run count${PLAIN}"
else
  count=$(curl -Ls https://tian-shen.me/wd/count)
  echo -e "${YELLOW}This script has been run ${PLAIN}$count${YELLOW} times ${PLAIN}"
fi
echo -e "${BLUE}Author: ${YELLOW}LTY_CK_TS${PLAIN}"

echo -e "${GREEN}Checking ${BLUE}Docker${GREEN} environment...${PLAIN}"
if docker >/dev/null 2>&1; then
    echo -e "${BLUE}Docker${GREEN} is installed${PLAIN}"
else
  if [ $mac = true ]; then
    echo -e "${RED}Docker not installed${PLAIN}"
    echo -e "${YELLOW}Please install Docker Desktop and start the Docker Desktop service!${PLAIN}"
    exit 1
  else
    read -p "Docker not installed, do you want to install?(y/N):" install
    if [ "$install" != "y" ] ;then
      echo -e "${RED}Install cancelled${PLAIN}"
      exit 1
    else
      echo -e "${BLUE}Start installing...${PLAIN}"
      docker version > /dev/null || curl -fsSL get.docker.com | bash
      systemctl enable docker && systemctl restart docker
      echo -e "${BLUE}Docker${GREEN} install complete${PLAIN}"
    fi
  fi
fi

show_menu() {
  echo -e "${GREEN}Choose an option:${PLAIN}"
  echo -e "${BLUE}1.${YELLOW} Initial deploy${PLAIN} - WebDriver Hub(central management)"
  echo -e "${BLUE}2.${YELLOW} Initial deploy${PLAIN} - WebDriver Node"
  echo -e "${BLUE}3.${YELLOW} Update ${PLAIN}WebDriver Hub and preserve data(using WatchTower image)"
  echo -e "${BLUE}4.${YELLOW} Update ${PLAIN}WebDriver Node and preserve data(using WatchTower image)"
  echo -e "${BLUE}5.${YELLOW} Delete ${PLAIN}WebDriver Hub"
  echo -e "${BLUE}6.${YELLOW} Delete ${PLAIN}WebDriver Node"
  echo -e "${BLUE}7.${YELLOW} Update ${PLAIN}WebDriver Hub without preserving data"
  echo -e "${BLUE}8.${YELLOW} Update ${PLAIN}WebDriver Node without preserving data"
  echo -e "${BLUE}0.${YELLOW} Exit${PLAIN}"
  echo -e "${RED}Caution: ${BLUE}if you choose 3 ~ 8, please make sure the containers are deployed by this script!${PLAIN}"
  echo -e "That is, hub container using name: ${YELLOW}wd-hub${PLAIN} and node container using name: ${YELLOW}wd${PLAIN}"
  echo -e "Otherwise the containers would not be detected correctly and causing unwanted errors!${PLAIN}"
  echo -e "${YELLOW}You have to re-enter arguments when updating using(7)(8), while(3)(4)provides arguments preservation.${PLAIN}"
  read -p "Enter your choice: " mode
  case $mode in
  1)
    clear
    hub
    exit 0
  ;;
  2)
    clear
    node
    exit 0
  ;;
  3)
    clear
    echo -e "${BLUE}Pulling ${YELLOW}WatchTower${BLUE} image...${PLAIN}"
    docker pull containrrr/watchtower
    echo -e "${BLUE}Updating ${YELLOW}WebDriver Hub${BLUE}...(may take a while, please wait)${PLAIN}"
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once --cleanup wd-hub
    echo -e "${YELLOW}WatchTower ${BLUE}completed, if the line below showing 'Up X seconds', then the update is successful!${PLAIN}"
    docker ps --filter "name=wd-hub" --format "{{.Status}}"
    echo -e "If it's not, your hub image may already be the latest one. If no line is presented, then your container is not named ${YELLOW}wd-hub${PLAIN}"
    exit 0
  ;;
  4)
    clear
    echo -e "${BLUE}Pulling ${YELLOW}WatchTower${BLUE} image...${PLAIN}"
    docker pull containrrr/watchtower
    echo -e "${BLUE}Updating ${YELLOW}WebDriver Node${BLUE}...(may take a while, please wait)${PLAIN}"
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once --cleanup wd
    echo -e "${YELLOW}WatchTower ${BLUE}completed, if the line below showing 'Up X seconds', then the update is successful!${PLAIN}"
    docker ps --filter "name=wd" --format "{{.Status}}"
    echo -e "If it's not, your node image may already be the latest one. If no line is presented, then your container is not named ${YELLOW}wd${PLAIN}"
    exit 0
  ;;
  5)
    echo -e "${RED}Deleting...${PLAIN}"
    docker stop wd-hub && docker rm wd-hub
    exit 0
  ;;
  6)
    echo -e "${RED}Deleting...${PLAIN}"
    docker stop wd && docker rm wd
    exit 0
  ;;
  7)
    clear
    echo -e "${RED}Deleting...${PLAIN}"
    docker stop wd-hub && docker rm wd-hub
    delete=true
    hub
    exit 0
  ;;
  8)
    clear
    echo -e "${RED}Deleting...${PLAIN}"
    docker stop wd && docker rm wd
    delete=true
    node
    exit 0
  ;;
  0)
    echo -e "${BLUE}Exited${PLAIN}"
    exit 0
  ;;
  *)
    echo -e "${RED}Invalid input${PLAIN}"
    exit 1
  ;;
  esac
}


if [ $# = 0 ]; then
  show_menu
else
  case $1 in
    "hub")
      case $2 in
        "update")
          echo -e "${BLUE}Pulling the ${YELLOW}WatchTower${BLUE} image...${PLAIN}"
          docker pull containrrr/watchtower
          echo -e "${BLUE}Updating ${YELLOW}WebDriver Hub${BLUE}...(may take some time, please be patient)${PLAIN}"
          docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once --cleanup wd-hub
          echo -e "${YELLOW}WatchTower${BLUE} execution complete. The following shows the status of the Hub container; if it's a few seconds ago, it means it has been updated to the latest version${PLAIN}"
          docker ps --filter "name=wd-hub" --format "{{.Status}}"
          echo -e "If the time hasn't changed, it's possible that your image is already up to date. If not displayed, it means your container name is not ${YELLOW}wd-hub${PLAIN}"
          exit 0
          ;;
        "delete")
          echo -e "${RED}Deleting the current container...${PLAIN}"
          docker stop wd-hub && docker rm wd-hub
          exit 0
          ;;
        "install")
          hub $@
          exit 0
          ;;
        *)
          echo -e "${RED}Invalid parameter. Please rerun the script.${PLAIN}"
          exit 1
          ;;
      esac
      ;;
    "node")
      case $2 in
        "update")
          echo -e "${BLUE}Pulling the ${YELLOW}WatchTower${BLUE} image...${PLAIN}"
          docker pull containrrr/watchtower
          echo -e "${BLUE}Updating ${YELLOW}WebDriver Node${BLUE}...(may take some time, please be patient)${PLAIN}"
          docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once --cleanup wd
          echo -e "${YELLOW}WatchTower${BLUE} execution complete. The following shows the status of the Node container; if it's a few seconds ago, it means it has been updated to the latest version${PLAIN}"
          docker ps --filter "name=wd" --format "{{.Status}}"
          echo -e "If the time hasn't changed, it's possible that your image is already up to date. If not displayed, it means your container name is not ${YELLOW}wd${PLAIN}"
          exit 0
          ;;
        "delete")
          echo -e "${RED}Deleting the current container...${PLAIN}"
          docker stop wd && docker rm wd
          exit 0
          ;;
        "install")
          node $@
          exit 0
          ;;
        *)
          echo -e "${RED}Invalid parameter. Please rerun the script.${PLAIN}"
          exit 1
          ;;
      esac
      ;;
    *)
      echo -e "${RED}Invalid parameter. Please rerun the script.${PLAIN}"
      exit 1
      ;;
  esac
fi
