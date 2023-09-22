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
    <img src="https://img.shields.io/badge/version-1.6-blue" alt="current version"/>
</p>
<h3 align="center"><a href="README.md">中文文档</a> | English </h3>
<h3 align="center">A convenient and quick Selenium WebDriver Docker deployment script </h3>
<h4 align="center">System supported: Linux, macOS</h4>
<h4 align="center">Architecture supported: x86_64, arm64, arm32v7</h4>

## How to use：
```shell
bash <(curl -Ls https://tian-shen.me/file/wd_en.sh)
```
or
```shell
bash <(curl -Ls https://raw.githubusercontent.com/sahuidhsu/selenium-grid-docker/main/wd_en.sh)
```
If the above syntax is not working, please try the following method:
```shell
curl -Ls https://tian-shen.me/file/wd_en.sh | bash
```

## To Do List
- [x] Install Docker
- [x] Quickly deploy Selenium Grid Hub or Node
- [x] Automatically detect the system architecture and use the corresponding image
- [x] Quickly update Selenium Grid Hub or Node (provided that it is deployed using this script)
- [x] Quickly uninstall Selenium Grid Hub or Node (provided that it is deployed using this script)
- [x] Automatically obtain IP as default address
- [x] Automatically determine the location of the IP and select appropriate API
- [x] Custom Publish and Subscribe ports
- [x] Custom Hub port
- [x] docker permission recognition
  - [x] Recognize system (Linux and macOS)
  - [x] Determine whether the user has permission to use the docker command
- [x] Automatically delete expired images
- [x] Add English support
- [x] Add preserve-arguments option to update(provided by WatchTower)
- [ ] Run with parameters to achieve non-interactive deployment
- [ ] Support Windows (seems unnecessary)

## Usage example (initial version screenshot only, may be different from the latest version)
![Usage example display image](wd-demo.png "Usage example")

## Buy me a coffee
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/ltyckts)