#!/bin/bash
###
# Selenium Grid 自动部署脚本
# 作者：天神
# 日期：2023-03-01
# 更新日期：2023-03-02
# Copyright © 2023 by 天神, All Rights Reserved.
###
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'
BLUE="\033[36m"

current_user=$(whoami)
if [ $current_user != "root" ]; then
    echo -e "${RED}请使用root用户运行此脚本!${PLAIN}"
    exit 1
fi

echo -e "${BLUE}欢迎使用${PLAIN}Selenium Grid${BLUE}自动部署脚本${PLAIN}"
echo -e "${BLUE}作者：${YELLOW}天神${PLAIN}"

echo -e "${GREEN}开始检查${BLUE}docker${GREEN}环境...${PLAIN}"
if docker >/dev/null 2>&1; then
    echo -e "${BLUE}Docker${GREEN}已安装${PLAIN}"
else
    echo -e "${BLUE}Docker${RED}未安装，开始安装……${PLAIN}"
    docker version > /dev/null || curl -fsSL get.docker.com | bash
    systemctl enable docker && systemctl restart docker
    echo -e "${BLUE}Docker${GREEN}安装完成${PLAIN}"
fi

hub() {
  echo -e "${BLUE}开始准备部署${RED}Hub${BLUE}，即将开始拉取最新版本Hub镜像${PLAIN}"
  sleep 2
  docker pull selenium/hub
  echo -e "${BLUE}拉取完毕！${PLAIN}"
  port1=4442
  echo -e "${BLUE}默认使用${YELLOW}4442${BLUE}端口作为${RED}第一个节点连接端口${PLAIN}"
  read -p "如需修改请输入新的第一个节点连接端口(留空则使用默认的4442)：" port1_enter
  if [ "$port1_enter" ] ;then
    port1=$port1_enter
    echo -e "已修正${RED}连接端口1${PLAIN}为：${BLUE}" $port1 "${PLAIN}"
  fi
  port2=4443
  echo -e "${BLUE}默认使用${YELLOW}4443${BLUE}端口作为${RED}第二个节点连接端口${PLAIN}"
  read -p "如需修改请输入新的第二个节点连接端口(留空则使用默认的4443)：" port2_enter
  if [ "$port2_enter" ] ;then
    port2=$port2_enter
    echo -e "已修正${RED}连接端口2${PLAIN}为：${BLUE}" $port2 "${PLAIN}"
  fi
  portUI=4444
  echo -e "${BLUE}默认使用${YELLOW}4444${BLUE}端口作为${RED}WebUI端口${PLAIN}"
  read -p "如需修改请输入新的WebUI端口(留空则使用默认的4444)：" portUI_enter
  if [ "$portUI_enter" ] ;then
    portUI=$portUI_enter
    echo -e "已修正${RED}WebUI端口${PLAIN}为：${BLUE}" $portUI "${PLAIN}"
  fi
  docker run -d -p $port1:4442 -p $port2:4443 -p $portUI:4444 --name wd-hub --log-opt max-size=1m --log-opt max-file=1 --restart=always selenium/hub
  echo -e "${BLUE}Hub部署完毕${PLAIN}"
}

node() {
  echo -e "${BLUE}开始准备部署${RED}Node${BLUE}，即将开始拉取最新版本Node镜像${PLAIN}"
  sleep 2
  docker pull selenium/node-chrome
  echo -e "拉取完毕！"
  address=$(curl -Ls -4 ip.sb)
  echo -e "当前服务器IP/域名：${BLUE}" $address "${PLAIN}"
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
  echo -e "${BLUE}默认使用${YELLOW}4442${BLUE}端口作为${RED}第一个节点连接端口${PLAIN}"
  read -p "如您的Hub已修改请输入正确的端口(留空则使用默认的4442)：" port1_enter
  if [ "$port1_enter" ] ;then
    port1=$port1_enter
    echo -e "已修正${RED}连接端口1${PLAIN}为：${BLUE}" $port1 "${PLAIN}"
  fi
  port2=4443
  echo -e "${BLUE}默认使用${YELLOW}4443${BLUE}端口作为${RED}第二个节点连接端口${PLAIN}"
  read -p "如您的Hub已修改请输入正确的端口(留空则使用默认的4443)：" port2_enter
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
  echo -e "${BLUE}开始部署！${PLAIN}"
  docker run -d --name=wd -p $node_port:$node_port -p 5919:5900 -e SE_NODE_HOST=$address -e SE_EVENT_BUS_HOST=$hub_address -e SE_EVENT_BUS_PUBLISH_PORT=$port1 -e SE_EVENT_BUS_SUBSCRIBE_PORT=$port2 -e SE_NODE_PORT=$node_port -e SE_NODE_MAX_SESSIONS=$number -e SE_NODE_OVERRIDE_MAX_SESSIONS=true -e SE_SESSION_RETRY_INTERVAL=1 -e SE_VNC_VIEW_ONLY=1 --log-opt max-size=1m --log-opt max-file=1 --shm-size="$memory" --restart=always selenium/node-chrome
  echo -e "${BLUE}Node部署完毕${PLAIN}"
}

echo -e "${GREEN}请选择模式：${PLAIN}"
echo -e "${BLUE}1.${GREEN} 初始部署${PLAIN}WebDriver Hub(中心管理)"
echo -e "${BLUE}2.${GREEN} 初始部署${PLAIN}WebDriver Node(节点)"
echo -e "${BLUE}3.${GREEN} 更新${PLAIN}WebDriver Hub"
echo -e "${BLUE}4.${GREEN} 更新${PLAIN}WebDriver Node"
echo -e "${BLUE}5.${YELLOW} 删除${PLAIN}WebDriver Hub容器"
echo -e "${BLUE}6.${YELLOW} 删除${PLAIN}WebDriver Node容器"
echo -e "${BLUE}0.${YELLOW} 退出脚本${PLAIN}"
echo -e "${RED}请注意：${BLUE}如果您选择3,4(更新脚本)或5,6(删除脚本)"
echo -e "请确保您Hub的容器名是${YELLOW}wd-hub${BLUE}/Node的容器名是${YELLOW}wd${BLUE}"
echo -e "否则本脚本可能无法正确删除容器，可能导致出现异常！${PLAIN}"
read -p "请输入数字：" mode
if [ $mode == "1" ]; then
  hub
  exit 0
elif [ $mode == "2" ]; then
  node
  exit 0
elif [ $mode == "3" ]; then
  echo -e "${RED}删除当前容器...${PLAIN}"
  docker stop wd-hub && docker rm wd-hub
  hub
  exit 0
elif [ $mode == "4" ]; then
  echo -e "${RED}删除当前容器...${PLAIN}"
  docker stop wd && docker rm wd
  node
  exit 0
elif [ $mode == "5" ]; then
  echo -e "${RED}删除当前容器...${PLAIN}"
  docker stop wd-hub && docker rm wd-hub
  exit 0
elif [ $mode == "6" ]; then
  echo -e "${RED}删除当前容器...${PLAIN}"
  docker stop wd && docker rm wd
  exit 0
elif [ $mode == "0" ]; then
  echo -e "${BLUE}退出脚本${PLAIN}"
  exit 0
else
  echo -e "${RED}输入错误，请重新运行脚本${PLAIN}"
  exit 1
fi