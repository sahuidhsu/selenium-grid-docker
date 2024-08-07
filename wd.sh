#!/bin/bash
###
# Selenium Grid 自动部署脚本
# 作者：天神(https://tian-shen.me/)
# 日期：2023-03-01
# 更新日期：2024-02-22
# Copyright © 2024 by 天神, All Rights Reserved.
###
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'
BLUE="\033[36m"

not_root() {
  echo -e "${YELLOW}Warning:${PLAIN}当前非root用户，但本用户似乎可以直接使用docker命令"
  echo "脚本将继续运行，如在运行途中遇到docker权限问题请尝试使用root(sudo)运行!"
  echo ""
  sleep 1
}

hub() {
  echo -e "${BLUE}开始准备部署${RED}Hub${BLUE}，即将开始拉取最新版本Hub镜像${PLAIN}"
  sleep 2
  docker pull $docker_hub
  echo -e "${BLUE}拉取完毕！${PLAIN}"
  if [ $delete = true ]; then
    echo -e "${YELLOW}正在删除旧镜像...${PLAIN}"
    image_id=$(docker images | grep "$docker_hub" | grep "latest" | awk '{print $3}')
    docker rmi $(docker images | grep "$docker_hub" | grep -v "$image_id" | awk '{print $3}')
    echo -e "${BLUE}删除完毕！${PLAIN}"
  fi
  echo -e "${YELLOW}请注意：部署Hub需要使用两个端口来连接节点以及一个端口来部署WebUI${PLAIN}"
  echo -e "${YELLOW}如果修改您填写的两个${RED}节点连接端口${BLUE}，部署node时也请填写相同端口！${PLAIN}"
  port1=4442
  if [ $# -gt 0 ] ;then
    if [ $# -gt 2 ] ;then
      port1=$3
      echo -e "${BLUE}已修正${RED}连接端口1${PLAIN}为：${BLUE}" $port1 "${PLAIN}"
    else
      echo -e "${BLUE}使用默认端口${YELLOW}4442${BLUE}作为${RED}第一个节点连接端口${PLAIN}"
    fi
  else
    echo -e "${BLUE}默认使用${YELLOW}4442${BLUE}端口作为${RED}第一个节点连接端口${PLAIN}"
    read -p "如需修改请输入新的第一个节点连接端口(留空则使用默认的4442)：" port1_enter
    if [ "$port1_enter" ] ;then
      port1=$port1_enter
      echo -e "已修正${RED}连接端口1${PLAIN}为：${BLUE}" $port1 "${PLAIN}"
    fi
  fi
  port2=4443
  if [ $# -gt 0 ] ;then
    if [ $# -gt 2 ] ;then
      port2=$4
      echo -e "${BLUE}已修正${RED}连接端口2${PLAIN}为：${BLUE}" $port2 "${PLAIN}"
    else
      echo -e "${BLUE}使用默认端口${YELLOW}4443${BLUE}作为${RED}第二个节点连接端口${PLAIN}"
    fi
  else
    echo -e "${BLUE}默认使用${YELLOW}4443${BLUE}端口作为${RED}第二个节点连接端口${PLAIN}"
    read -p "如需修改请输入新的第二个节点连接端口(留空则使用默认的4443)：" port2_enter
    if [ "$port2_enter" ] ;then
      port2=$port2_enter
      echo -e "已修正${RED}连接端口2${PLAIN}为：${BLUE}" $port2 "${PLAIN}"
    fi
  fi
  portUI=4444
  if [ $# -gt 0 ] ;then
    if [ $# -gt 2 ] ;then
      portUI=$5
      echo -e "${BLUE}已修正${RED}WebUI端口${PLAIN}为：${BLUE}" $portUI "${PLAIN}"
    else
      echo -e "${BLUE}使用默认端口${YELLOW}4444${BLUE}作为${RED}WebUI端口${PLAIN}"
    fi
  else
    echo -e "${BLUE}默认使用${YELLOW}4444${BLUE}端口作为${RED}WebUI端口${PLAIN}"
    read -p "如需修改请输入新的WebUI端口(留空则使用默认的4444)：" portUI_enter
    if [ "$portUI_enter" ] ;then
      portUI=$portUI_enter
      echo -e "已修正${RED}WebUI端口${PLAIN}为：${BLUE}" $portUI "${PLAIN}"
    fi
  fi
  echo -e "${RED}为防止Selenium受到未授权的调用，您必须为其设置用户名和密码${PLAIN}"
  echo -e "${BLUE}请输入用户名：${PLAIN}"
  read username
  echo -e "${BLUE}请输入密码：${PLAIN}"
  read password
  docker run -d -p $port1:4442 -p $port2:4443 -p $portUI:4444 --name wd-hub --log-opt max-size=1m --log-opt max-file=1 -e SE_OPTS="--username $username --password $password" --restart=always $docker_hub
  echo -e "${BLUE}Hub部署完毕${PLAIN}"
}

node() {
  echo -e "${BLUE}开始准备部署${RED}Node${BLUE}，即将开始拉取最新版本Node镜像${PLAIN}"
  sleep 2
  docker pull $docker_node
  echo -e "${BLUE}拉取完毕！${PLAIN}"
  if [ $delete = true ]; then
    echo -e "${YELLOW}正在删除旧镜像...${PLAIN}"
    image_id=$(docker images | grep "$docker_node" | grep "latest" | awk '{print $3}')
    docker rmi $(docker images | grep "$docker_node" | grep -v "$image_id" | awk '{print $3}')
    echo -e "${BLUE}删除完毕！${PLAIN}"
  fi
  if [[ $(curl -m 10 -Ls https://ipapi.co/json | grep 'China') != "" ]]; then
    echo -e "${BLUE}根据ipapi.co提供的信息，当前IP可能${RED}在中国大陆${BLUE}，将采用${YELLOW}ipip${BLUE}提供的API获取IP...${PLAIN}"
    address=$(curl -Ls -4 myip.ipip.net/s)
  else
    echo -e "${BLUE}根据ipapi.co提供的信息，当前IP可能${RED}不在中国大陆${BLUE}，将采用${YELLOW}ip.sb${BLUE}提供的API获取IP...${PLAIN}"
    address=$(curl -Ls -4 ip.sb)
  fi
  echo -e "当前服务器IP/域名：${BLUE}" $address "${PLAIN}"
  if [ $# -gt 0 ] ;then
    if [ $# -gt 2 ] ;then
      address=$3
      echo -e "${BLUE}已修正IP/域名为：${BLUE}" $address "${PLAIN}"
      hub_address=$4
      echo -e "${BLUE}已修正Hub地址为：${BLUE}" $hub_address "${PLAIN}"
      port1=$5
      echo -e "${BLUE}已修正${RED}连接端口1${PLAIN}为：${BLUE}" $port1 "${PLAIN}"
      port2=$6
      echo -e "${BLUE}已修正${RED}连接端口2${PLAIN}为：${BLUE}" $port2 "${PLAIN}"
      node_port=$7
      echo -e "${BLUE}已修正${RED}当前节点通讯端口${PLAIN}为：${BLUE}" $node_port "${PLAIN}"
      memory=$8
      echo -e "${BLUE}已修正分配的内存为：${BLUE}" $memory "${PLAIN}"
      number=$9
      echo -e "${BLUE}已修正最大进程数为：${BLUE}" $number "${PLAIN}"
      vnc=${10}
      if [ "$vnc" = "y" ] ;then
        vnc_pwd=${11}
        echo -e "${BLUE}已修正VNC会话密码为：${BLUE}" $vnc_pwd "${PLAIN}"
        echo -e "${BLUE}开始部署！${PLAIN}"
        docker run -d --name=wd -p $node_port:$node_port -p 5900:5900 -e SE_NODE_HOST=$address \
        -e SE_EVENT_BUS_HOST=$hub_address -e SE_EVENT_BUS_PUBLISH_PORT=$port1 -e SE_EVENT_BUS_SUBSCRIBE_PORT=$port2 \
        -e SE_NODE_PORT=$node_port -e SE_NODE_MAX_SESSIONS=$number -e SE_NODE_OVERRIDE_MAX_SESSIONS=true \
        -e SE_SESSION_RETRY_INTERVAL=1 -e SE_VNC_VIEW_ONLY=1 -e SE_VNC_PASSWORD="$vncpwd" --log-opt max-size=1m \
        --log-opt max-file=1 --shm-size="$memory" --restart=always $docker_node
      else
        echo -e "${YELLOW}关闭VNC调试${PLAIN}"
        echo -e "${BLUE}开始部署！${PLAIN}"
        docker run -d --name=wd -p $node_port:$node_port -e SE_NODE_HOST=$address -e SE_EVENT_BUS_HOST=$hub_address \
         -e SE_EVENT_BUS_PUBLISH_PORT=$port1 -e SE_EVENT_BUS_SUBSCRIBE_PORT=$port2 -e SE_NODE_PORT=$node_port \
         -e SE_NODE_MAX_SESSIONS=$number -e SE_NODE_OVERRIDE_MAX_SESSIONS=true \
         -e SE_SESSION_RETRY_INTERVAL=1 -e SE_START_VNC=false --log-opt max-size=1m --log-opt max-file=1 \
         --shm-size="$memory" --restart=always $docker_node
      fi
    else
      echo -e "${BLUE}如果本机是动态IP或获取到的IP不正确，请重新运行脚本，并在参数中填写解析到本机的域名${PLAIN}"
      hub_address=$address
      echo -e "默认使用当前服务器IP作为${RED}要连接的Hub${PLAIN}的地址"
      port1=4442
      echo -e "${BLUE}默认使用${YELLOW}4442${BLUE}端口作为${RED}Hub连接端口1(请确保和您Hub部署时填写的一致)${PLAIN}"
      port2=4443
      echo -e "${BLUE}默认使用${YELLOW}4443${BLUE}端口作为${RED}Hub连接端口2(请确保和您Hub部署时填写的一致)${PLAIN}"
      node_port=5556
      echo -e "${BLUE}默认使用${YELLOW}5556${BLUE}端口作为${RED}当前节点的通讯端口${PLAIN}"
      memory=512m
      echo -e "${BLUE}默认分配${YELLOW}512m${BLUE}内存给${RED}当前节点${PLAIN}"
      number=5
      echo -e "${BLUE}默认最大进程数为${YELLOW}5${PLAIN}"
      echo -e "${BLUE}默认关闭vnc调试${PLAIN}"
      echo -e "${BLUE}开始部署！${PLAIN}"
      docker run -d --name=wd -p $node_port:$node_port -e SE_NODE_HOST=$address -e SE_EVENT_BUS_HOST=$hub_address \
       -e SE_EVENT_BUS_PUBLISH_PORT=$port1 -e SE_EVENT_BUS_SUBSCRIBE_PORT=$port2 -e SE_NODE_PORT=$node_port \
       -e SE_NODE_MAX_SESSIONS=$number -e SE_NODE_OVERRIDE_MAX_SESSIONS=true \
       -e SE_SESSION_RETRY_INTERVAL=1 -e SE_START_VNC=false --log-opt max-size=1m --log-opt max-file=1 \
       --shm-size="$memory" --restart=always $docker_node
    fi
  else
    echo -e "${RED}如果本机是动态IP，请填写解析到本机的域名${PLAIN}"
    read -p "如需修改，请输入(否则留空)：" change
    if [ "$change" ] ;then
      address=$change
      echo -e "已修正IP/域名为：${BLUE}" $address "${PLAIN}"
    fi
    hub_address=$address
    echo -e "默认使用当前服务器IP作为${RED}要连接的Hub${PLAIN}的地址"
    read -p "请输入Hub的IP/域名(如果Hub就在本机则请留空)：" hub_add
    if [ "$hub_add" ] ;then
      hub_address=$hub_add
      echo -e "已修正Hub地址为：${BLUE}" $hub_address "${PLAIN}"
    fi
    port1=4442
    echo -e "${BLUE}默认使用${YELLOW}4442${BLUE}端口作为${RED}Hub连接端口1(请确保和您Hub部署时填写的一致)${PLAIN}"
    read -p "如您的Hub修改过请输入正确的端口(留空则使用默认的4442)：" port1_enter
    if [ "$port1_enter" ] ;then
      port1=$port1_enter
      echo -e "已修正${RED}连接端口1${PLAIN}为：${BLUE}" $port1 "${PLAIN}"
    fi
    port2=4443
    echo -e "${BLUE}默认使用${YELLOW}4443${BLUE}端口作为${RED}Hub连接端口2(请确保和您Hub部署时填写的一致)${PLAIN}"
    read -p "如您的Hub修改过请输入正确的端口(留空则使用默认的4443)：" port2_enter
    if [ "$port2_enter" ] ;then
      port2=$port2_enter
      echo -e "已修正${RED}连接端口2${PLAIN}为：${BLUE}" $port2 "${PLAIN}"
    fi
    node_port=5556
    echo -e "${BLUE}默认使用${YELLOW}5556${BLUE}端口作为${RED}当前节点的通讯端口${PLAIN}"
    read -p "如需修改请输入新的通讯端口(留空则使用默认的5556)：" node_port_enter
    if [ "$node_port_enter" ] ;then
      node_port=$node_port_enter
      echo -e "已修正${RED}当前节点通讯端口${PLAIN}为：${BLUE}" $node_port "${PLAIN}"
    fi
    read -p "请输入分配的内存(e.g. 512m 或 2g)：" memory
    read -p "请输入最大进程数：" number
    echo -e "${BLUE}是否需要打开VNC调试功能(${RED}会打开5900端口${BLUE})?${PLAIN}"
    read -p "请输入选择，留空默认不开启(y/N)：" vnc
    if [ "$vnc" = "y" ] ;then
      echo -e "${YELLOW}打开VNC调试${PLAIN}"
      read -p "请设置VNC会话密码(留空则使用默认密码 'secret')：" vncpwd
      if [ "$vncpwd" = "" ] ;then
        vncpwd="secret"
      fi
      echo -e "${YELLOW}开启VNC调试${PLAIN}"
      echo -e "已设置VNC会话密码：${BLUE}" $vncpwd "${PLAIN}"
      echo -e "${BLUE}开始部署！${PLAIN}"
      docker run -d --name=wd -p $node_port:$node_port -p 5900:5900 -e SE_NODE_HOST=$address \
      -e SE_EVENT_BUS_HOST=$hub_address -e SE_EVENT_BUS_PUBLISH_PORT=$port1 -e SE_EVENT_BUS_SUBSCRIBE_PORT=$port2 \
      -e SE_NODE_PORT=$node_port -e SE_NODE_MAX_SESSIONS=$number -e SE_NODE_OVERRIDE_MAX_SESSIONS=true \
      -e SE_SESSION_RETRY_INTERVAL=1 -e SE_VNC_VIEW_ONLY=1 -e SE_VNC_PASSWORD="$vncpwd" --log-opt max-size=1m \
      --log-opt max-file=1 --shm-size="$memory" --restart=always $docker_node
    else
      echo -e "${YELLOW}关闭VNC调试${PLAIN}"
      echo -e "${BLUE}开始部署！${PLAIN}"
      docker run -d --name=wd -p $node_port:$node_port -e SE_NODE_HOST=$address -e SE_EVENT_BUS_HOST=$hub_address \
       -e SE_EVENT_BUS_PUBLISH_PORT=$port1 -e SE_EVENT_BUS_SUBSCRIBE_PORT=$port2 -e SE_NODE_PORT=$node_port \
       -e SE_NODE_MAX_SESSIONS=$number -e SE_NODE_OVERRIDE_MAX_SESSIONS=true \
       -e SE_SESSION_RETRY_INTERVAL=1 -e SE_START_VNC=false --log-opt max-size=1m --log-opt max-file=1 \
       --shm-size="$memory" --restart=always $docker_node
    fi
  fi
  echo -e "${BLUE}Node部署完毕${PLAIN}"
}

standalone() {
  echo -e "${BLUE}开始准备部署${RED}Standalone${BLUE}，即将开始拉取最新版本Standalone镜像${PLAIN}${PLAIN}"
  sleep 2
  docker pull $docker_standalone
  echo -e "${BLUE}拉取完毕！${PLAIN}"
  if [ $delete = true ]; then
    echo -e "${YELLOW}正在删除旧镜像...${PLAIN}"
    image_id=$(docker images | grep "$docker_standalone" | grep "latest" | awk '{print $3}')
    docker rmi $(docker images | grep "$docker_standalone" | grep -v "$image_id" | awk '{print $3}')
    echo -e "${BLUE}删除完毕！${PLAIN}"
  fi
  if [ $# -gt 0 ] ;then
    echo -e "${RED}暂不支持使用参数部署Standalone${PLAIN}"
  else
    echo -e "${BLUE}默认使用${YELLOW}4444${BLUE}作为Selenium运行端口${PLAIN}"
    port=4444
    read -p "如需修改请输入新的Selenium运行端口(留空则使用默认的4444)：" port
    if [ "$port" = "" ]; then
      port=4444
    fi
    read -p "请输入分配的内存(e.g. 512m 或 2g)：" memory
    read -p "请输入最大进程数：" number
    echo -e "${RED}为防止Selenium受到未授权的调用，您必须为其设置用户名和密码${PLAIN}"
    echo -e "${BLUE}请输入用户名：${PLAIN}"
    read username
    echo -e "${BLUE}请输入密码：${PLAIN}"
    read password
    docker run -d --name=webdriver -p $port:4444 --shm-size="$memory" --restart=always \
      -e SE_NODE_MAX_SESSIONS=$number -e SE_NODE_OVERRIDE_MAX_SESSIONS=true -e SE_SESSION_RETRY_INTERVAL=1 \
      -e SE_START_VNC=false -e SE_OPTS="--username $username --password $password" \
      --log-opt max-size=1m --log-opt max-file=1 $docker_standalone
    echo -e "${BLUE}Standalone部署完毕${PLAIN}"
  fi
}

mac=false # 判断是否为macOS
delete=false # 判断是否删除旧镜像
docker_hub="selenium/hub" # 默认x86 Hub镜像
docker_node="selenium/node-chrome" # 默认x86 Node镜像
docker_standalone="selenium/standalone-chrome" # 默认x86 Standalone镜像

# 判断系统架构
arch=$(uname -m)
if [ $arch == "x86_64" ]; then
  echo -e "${BLUE}已检测到系统架构为${YELLOW}x86_64${PLAIN}"
  elif [ $arch == "aarch64" ]; then
    docker_hub="seleniarm/hub" # arm64 Hub镜像
    docker_node="seleniarm/node-chromium" # arm64 Node镜像
    docker_standalone = "seleniarm/standalone-chromium" # arm64 Standalone镜像
    echo -e "${BLUE}已检测到系统架构为${YELLOW}arm64 ${BLUE}已自动切换到arm镜像${PLAIN}"
  elif [ $arch == "armv7l" ]; then
    docker_hub="seleniarm/hub" # arm32 Hub镜像
    docker_node="seleniarm/node-chromium" # arm32 Node镜像
    docker_standalone = "seleniarm/standalone-chromium" # arm32 Standalone镜像
    echo -e "${BLUE}已检测到系统架构为${YELLOW}arm32 ${BLUE}已自动切换到arm镜像${PLAIN}"
  else
    echo -e "${BLUE}已检测到系统架构为${YELLOW}$arch${PLAIN}"
    echo -e "${RED}脚本不支持当前系统架构！退出脚本${PLAIN}"
    exit 1
fi
echo -e "Hub镜像：${YELLOW}$docker_hub${PLAIN} | Node镜像：${YELLOW}$docker_node${PLAIN} | Standalone镜像：${YELLOW}$docker_standalone${PLAIN}"

# 判断用户是否有权限执行docker命令
current_user=$(whoami)
if [ $current_user != "root" ]; then # 判断当前用户是否为root
  if [[ $(uname) == "Darwin" ]]; then # 判断当前用户是否为macOS
    echo -e "${BLUE}已检测到系统为${YELLOW}macOS${PLAIN}"
    mac=true
    if [ "$(docker info > /dev/null 2>&1; echo $?)" != "0" ]; then
      echo -e "${RED}当前无法连接到Docker进程${PLAIN}"
      echo -e "${YELLOW}请检查是否已安装Docker Desktop以及Docker Desktop服务是否已启动！${PLAIN}"
      echo -e "${RED}如果您确信Docker Desktop已在运行，请尝试使用root(sudo)运行此脚本！${PLAIN}"
      exit 1
    else
      not_root
    fi
  else
    echo -e "${BLUE}已检测到系统为${YELLOW}Linux${PLAIN}"
    if test -z "$(groups $current_user | grep docker)"; then # 判断当前用户是否在docker用户组中(仅适用于Linux)
      echo -e "${RED}当前用户非root且不在docker用户组中，没有使用docker的权限${PLAIN}"
      echo -e "${YELLOW}解决方法：${PLAIN}"
      echo -e "1.${BLUE}将当前用户加入docker用户组并重新进入终端${YELLOW}(sudo gpasswd -a 用户名 docker)${PLAIN}"
      echo -e "2.${BLUE}直接使用root(sudo)运行此脚本！${PLAIN}"
      exit 1
    else
      not_root
    fi
  fi
  else
    echo -e "${BLUE}已检测到当前用户为${YELLOW}root${PLAIN}"
fi

echo -e "${BLUE}欢迎使用${PLAIN}Selenium Grid${BLUE}自动部署脚本${YELLOW}V2.1${PLAIN}"
if [[ $(curl -m 10 -Ls https://ipapi.co/json | grep 'China') != "" ]]; then
  echo -e "${BLUE}当前IP可能${RED}在中国大陆${BLUE}，暂不获取运行次数${PLAIN}"
else
  count=$(curl -Ls https://tian-shen.me/wd/count)
  echo -e "${YELLOW}脚本已被运行${PLAIN}$count${YELLOW}次${PLAIN}"
fi
echo -e "${BLUE}作者：${YELLOW}天神${PLAIN}"

echo -e "${GREEN}正在检查${BLUE}Docker${GREEN}环境...${PLAIN}"
if docker >/dev/null 2>&1; then
    echo -e "${BLUE}Docker${GREEN}已安装${PLAIN}"
else
  if [ $mac = true ]; then
    echo -e "${RED}Docker未安装${PLAIN}"
    echo -e "${YELLOW}请先安装Docker Desktop并启动Docker Desktop服务！${PLAIN}"
    exit 1
  else
    read -p "Docker未安装，是否要安装？(y/N):" install
    if [ "$install" != "y" ] ;then
      echo -e "${RED}已取消安装${PLAIN}"
      exit 1
    else
      echo -e "${BLUE}开始安装...${PLAIN}"
      docker version > /dev/null || curl -fsSL get.docker.com | bash
      systemctl enable docker && systemctl restart docker
      echo -e "${BLUE}Docker${GREEN}安装完成${PLAIN}"
    fi
  fi
fi

show_menu() {
  echo -e "${GREEN}请选择模式：${PLAIN}"
  echo -e "${BLUE}1.${YELLOW} 初始部署${PLAIN}WebDriver Hub(中心管理)"
  echo -e "${BLUE}2.${YELLOW} 初始部署${PLAIN}WebDriver Node(节点)"
  echo -e "${BLUE}3.${YELLOW} 初始部署${PLAIN}WebDriver Standalone(单机版)"
  echo -e "${BLUE}4.${YELLOW} 一键更新${PLAIN}WebDriver Hub(使用WatchTower镜像实现)"
  echo -e "${BLUE}5.${YELLOW} 一键更新${PLAIN}WebDriver Node(使用WatchTower镜像实现)"
  echo -e "${BLUE}6.${YELLOW} 一键更新${PLAIN}WebDriver Standalone(使用WatchTower镜像实现)"
  echo -e "${BLUE}7.${YELLOW} 删除${PLAIN}WebDriver Hub"
  echo -e "${BLUE}8.${YELLOW} 删除${PLAIN}WebDriver Node"
  echo -e "${BLUE}9.${YELLOW} 删除${PLAIN}WebDriver Standalone"
  echo -e "${BLUE}10.${YELLOW} 重新安装${PLAIN}WebDriver Hub"
  echo -e "${BLUE}11.${YELLOW} 重新安装${PLAIN}WebDriver Node"
  echo -e "${BLUE}12.${YELLOW} 重新安装${PLAIN}WebDriver Standalone"
  echo -e "${BLUE}0.${YELLOW} 退出脚本${PLAIN}"
  echo -e "${RED}请注意：${BLUE}如果您选择4~12(更新、删除、重装)"
  echo -e "请确保您Hub的容器名是${YELLOW}wd-hub${BLUE}/Node的容器名是${YELLOW}wd${BLUE}/Standalone的容器名是${YELLOW}webdriver${PLAIN}"
  echo -e "否则将无法正确识别容器，可能导致出现异常！${PLAIN}"
  read -p "请输入数字：" mode
  case $mode in
  "1")
  # 安装Hub
    clear
    hub
    exit 0
  ;;
  "2")
  # 安装Node
    clear
    node
    exit 0
  ;;
  "3")
  # 安装Standalone
    clear
    standalone
    exit 0
  ;;
  "4")
  # 更新Hub
    clear
    echo -e "${BLUE}正在拉取${YELLOW}WatchTower${BLUE}镜像...${PLAIN}"
    docker pull containrrr/watchtower
    echo -e "${BLUE}正在更新${YELLOW}WebDriver Hub${BLUE}...(可能需要一点时间，请耐心等待)${PLAIN}"
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once --cleanup wd-hub
    echo -e "${YELLOW}WatchTower${BLUE}运行完毕，接下来将显示Hub容器运行状态，如果是几秒前则表示已更新至最新版本${PLAIN}"
    docker ps --filter "name=wd-hub" --format "{{.Status}}"
    echo -e "如果时间没有变化则有可能是您的镜像已经是最新版本，如果没有显示则表示您的容器名不是${YELLOW}wd-hub${PLAIN}"
    exit 0
  ;;
  "5")
  # 更新Node
    clear
    echo -e "${BLUE}正在拉取${YELLOW}WatchTower${BLUE}镜像...${PLAIN}"
    docker pull containrrr/watchtower
    echo -e "${BLUE}正在更新${YELLOW}WebDriver Node${BLUE}...(可能需要一点时间，请耐心等待)${PLAIN}"
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once --cleanup wd
    echo -e "${YELLOW}WatchTower${BLUE}运行完毕，接下来将显示Node容器运行状态，如果是几秒前则表示已更新至最新版本${PLAIN}"
    docker ps --filter "name=wd" --format "{{.Status}}"
    echo -e "如果时间没有变化则有可能是您的镜像已经是最新版本，如果没有显示则表示您的容器名不是${YELLOW}wd${PLAIN}"
    exit 0
  ;;
  "6")
  # 更新Standalone
    clear
    echo -e "${BLUE}正在拉取${YELLOW}WatchTower${BLUE}镜像...${PLAIN}"
    docker pull containrrr/watchtower
    echo -e "${BLUE}正在更新${YELLOW}WebDriver Standalone${BLUE}...(可能需要一点时间，请耐心等待)${PLAIN}"
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once --cleanup webdriver
    echo -e "${YELLOW}WatchTower${BLUE}运行完毕，接下来将显示webdriver容器运行状态，如果是几秒前则表示已更新至最新版本${PLAIN}"
    docker ps --filter "name=webdriver" --format "{{.Status}}"
    echo -e "如果时间没有变化则有可能是您的镜像已经是最新版本，如果没有显示则表示您的容器名不是${YELLOW}webdriver${PLAIN}"
    exit 0
  ;;
  "7")
  # 删除Hub
    echo -e "${RED}删除当前容器...${PLAIN}"
    docker stop wd-hub && docker rm wd-hub
    exit 0
  ;;
  "8")
  # 删除Node
    echo -e "${RED}删除当前容器...${PLAIN}"
    docker stop wd && docker rm wd
    exit 0
  ;;
  "9")
  # 删除Standalone
    echo -e "${RED}删除当前容器...${PLAIN}"
    docker stop webdriver && docker rm webdriver
    exit 0
  ;;
  "10")
  # 重装Hub
    clear
    echo -e "${RED}删除当前容器...${PLAIN}"
    docker stop wd-hub && docker rm wd-hub
    delete=true
    hub
    exit 0
  ;;
  "11")
  # 重装Node
    clear
    echo -e "${RED}删除当前容器...${PLAIN}"
    docker stop wd && docker rm wd
    delete=true
    node
    exit 0
  ;;
  "12")
  # 重装Standalone
    clear
    echo -e "${RED}删除当前容器...${PLAIN}"
    docker stop webdriver && docker rm webdriver
    delete=true
    standalone
    exit 0
  ;;
  "0")
    echo -e "${BLUE}退出脚本${PLAIN}"
    exit 0
  ;;
  *)
    echo -e "${RED}输入错误，请重新运行脚本${PLAIN}"
    exit 1
  ;;
  esac
}


if [ $# = 0 ] ;then
  show_menu
else
  case $1 in
  "hub")
    case $2 in
    "update")
      echo -e "${BLUE}正在拉取${YELLOW}WatchTower${BLUE}镜像...${PLAIN}"
      docker pull containrrr/watchtower
      echo -e "${BLUE}正在更新${YELLOW}WebDriver Hub${BLUE}...(可能需要一点时间，请耐心等待)${PLAIN}"
      docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once --cleanup wd-hub
      echo -e "${YELLOW}WatchTower${BLUE}运行完毕，接下来将显示Hub容器运行状态，如果是几秒前则表示已更新至最新版本${PLAIN}"
      docker ps --filter "name=wd-hub" --format "{{.Status}}"
      echo -e "如果时间没有变化则有可能是您的镜像已经是最新版本，如果没有显示则表示您的容器名不是${YELLOW}wd-hub${PLAIN}"
      exit 0
    ;;
    "delete")
      echo -e "${RED}删除当前容器...${PLAIN}"
      docker stop wd-hub && docker rm wd-hub
      exit 0
    ;;
    "install")
      hub $@
      exit 0
    ;;
    *)
      echo -e "${RED}参数错误，请重新运行脚本${PLAIN}"
      exit 1
    ;;
    esac
  ;;
  "node")
    case $2 in
    "update")
      echo -e "${BLUE}正在拉取${YELLOW}WatchTower${BLUE}镜像...${PLAIN}"
      docker pull containrrr/watchtower
      echo -e "${BLUE}正在更新${YELLOW}WebDriver Node${BLUE}...(可能需要一点时间，请耐心等待)${PLAIN}"
      docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once --cleanup wd
      echo -e "${YELLOW}WatchTower${BLUE}运行完毕，接下来将显示Node容器运行状态，如果是几秒前则表示已更新至最新版本${PLAIN}"
      docker ps --filter "name=wd" --format "{{.Status}}"
      echo -e "如果时间没有变化则有可能是您的镜像已经是最新版本，如果没有显示则表示您的容器名不是${YELLOW}wd${PLAIN}"
      exit 0
    ;;
    "delete")
      echo -e "${RED}删除当前容器...${PLAIN}"
      docker stop wd && docker rm wd
      exit 0
    ;;
    "install")
      node $@
      exit 0
    ;;
    *)
      echo -e "${RED}参数错误，请重新运行脚本${PLAIN}"
      exit 1
    ;;
    esac
  ;;
  *)
    echo -e "${RED}参数错误，请重新运行脚本${PLAIN}"
    exit 1
  ;;
  esac
fi