# selenium-grid-docker
一个方便快捷的Selenium WebDriver Docker部署脚本

## 使用方法：
```shell
bash <(curl -Ls https://tian-shen.me/file/wd.sh)
```
或
```shell
bash <(curl -Ls https://raw.githubusercontent.com/sahuidhsu/selenium-grid-docker/main/wd.sh)
```

## 功能列表 - To Do List
- [x] 快速部署Selenium Grid Hub或Node
- [x] 快速更新Selenium Grid Hub或Node(前提是使用本脚本部署的)
- [x] 快速卸载Selenium Grid Hub或Node(前提是使用本脚本部署的)
- [x] 自动获取IP作为默认地址
- [x] 自定义Publish和Subscribe端口
- [x] 自定义Hub端口
- [x] docker权限识别
  - [x] 识别系统(Linux和macOS)
  - [x] 判断用户是否有使用docker指令的权限
- [ ] 运行时添加参数实现免交互式部署
- [ ] 支持Windows(好像没啥必要)
- [ ] 自动删除过期的镜像

## 使用样例

![使用样例的展示图片](wd-demo.png "使用样例")