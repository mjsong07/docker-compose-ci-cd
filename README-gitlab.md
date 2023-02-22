# 1.运行 
## 1. docker-compose
docker-compose -f docker-compose-gitlab.yml up

## 2.docker run 
docker run \
 -itd  \
 -p 7881:80 \
 -p 7882:22 \
 -v /home/gitlab/etc:/etc/gitlab  \
 -v /home/gitlab/log:/var/log/gitlab \
 -v /home/gitlab/opt:/var/opt/gitlab \
 --restart always \
 --privileged=true \
gitlab/gitlab-ce:14.9.0-ce.0

## 注意
### 启动慢 记得查看日志
运行 gitlab 启动需要比较长的时间  通过docker logs -f id 

###  一定要给文件夹 设置权限
chmod 777 /home/gitlab 

### 有时候绑定的http 端口 变化，不一定是80
7881:80 
7881:8080
7881:3000



# 2.其他版本
- gitlab/gitlab-ce:14.9.0-ce.0
- drud/gitlab-ce
- bitnami/gitlab-runner 

# 3.配置调整 
## 1.修改容器配置
docker exec -it gitlab /bin/bash

### 修改gitlab.rb
```sh
vi /etc/gitlab/gitlab.rb
## 加入如下
# gitlab访问地址，可以写域名。如果端口不写的话默认为80端口
external_url 'http://xx.xx.xx.xx:7881'
# ssh主机ip
gitlab_rails['gitlab_ssh_host'] = 'xx.xx.xx.xx'
# ssh连接端口
gitlab_rails['gitlab_shell_ssh_port'] = 7882
```

### 让配置生效
gitlab-ctl reconfigure

### 注意不要重启，/etc/gitlab/gitlab.rb文件的配置会映射到gitlab.yml这个文件，由于咱们在docker中运行，在gitlab上生成的http地址应该是http://101.133.225.166:3000,所以，要修改下面文件

## 2.修改http和ssh配置
```sh

vi /opt/gitlab/embedded/service/gitlab-rails/config/gitlab.yml

  gitlab:
    host: 101.133.225.166
    port: 3000 # 这里改为3000
    https: false
# 重启
gitlab-ctl restart
# 退出容器
exit
```

# 4.查询与修密码

## 方法1 直接查密码
```sh
# 账号
root 
# 密码
cat /home/gitlab/config/initial_root_password

```

## 方法2 修改密码
```sh
docker exec -it gitlab /bin/bash
# 进入控制台
gitlab-rails console -e production
# 查询id为1的用户，id为1的用户是超级管理员
user = User.where(id:1).first
# 修改密码为mj
user.password='qwe123456'
# 保存
user.save!
# 退出
exit
```