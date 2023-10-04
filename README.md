<h1 align="center">Selenium Grid Docker</h1>
<p align="center">
    <a href="https://github.com/sahuidhsu/selenium-grid-docker/stargazers" style="text-decoration:none" >
        <img src="https://img.shields.io/github/stars/sahuidhsu/selenium-grid-docker.svg" alt="GitHub stars"/>
    </a>
    <a href="https://github.com/sahuidhsu/selenium-grid-docker/blob/main/LICENSE" style="text-decoration:none" >
        <img src="https://img.shields.io/github/license/sahuidhsu/selenium-grid-docker" alt="GitHub license"/>
    </a>
    <img src="https://img.shields.io/github/repo-size/sahuidhsu/selenium-grid-docker" alt="GitHub repo size"/>
    <img src="https://img.shields.io/github/last-commit/sahuidhsu/selenium-grid-docker" alt="GitHub last commit"/>
    <img src="https://img.shields.io/badge/version-1.7-blue" alt="current version"/>
</p>
<h3 align="center">中文文档 | <a href="README_EN.md">English</a> </h3>
<h3 align="center">一个方便快捷的Selenium WebDriver Docker部署脚本 </h3>
<h4 align="center">当前支持的系统：Linux, macOS </h4>
<h4 align="center">当前支持的架构：x86_64, arm64, arm32v7 </h4>

## 使用方法：
```shell
bash <(curl -Ls https://tian-shen.me/wd)
```
或
```shell
bash <(curl -Ls https://raw.githubusercontent.com/sahuidhsu/selenium-grid-docker/main/wd.sh)
```
如您的系统不支持以上语法，请尝试使用以下方法：
```shell
curl -Ls -o wd https://tian-shen.me/wd && chmod +x wd && ./wd
```

## 功能列表 - To Do List
- [x] 安装Docker
- [x] 快速部署Selenium Grid Hub或Node
- [x] 自动识别系统架构，使用对应镜像
- [x] 快速更新Selenium Grid Hub或Node(前提是使用本脚本部署的)
- [x] 快速卸载Selenium Grid Hub或Node(前提是使用本脚本部署的)
- [x] 自动获取IP作为默认地址
- [x] 自动判断IP所在地，选择获取IP的API
- [x] 自定义Publish和Subscribe端口
- [x] 自定义Hub端口
- [x] docker权限识别
  - [x] 识别系统(Linux和macOS)
  - [x] 判断用户是否有使用docker指令的权限
- [x] 自动删除过期的镜像
- [x] 脚本添加英文版
- [x] 支持一键更新并保留配置（使用WatchTower实现）
- [ ] 运行时添加参数实现免交互式部署
- [ ] 支持Windows(好像没啥必要)

## 使用样例(初版截图，跟最新版有所出入)

![使用样例的展示图片](wd-demo.png "使用样例")

## 给我买杯咖啡
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/ltyckts)