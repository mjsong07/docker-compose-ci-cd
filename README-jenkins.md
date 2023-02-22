

# 1.运行

```sh
# 启动jenkis 
docker-compose -f docker-compose-jenkis up
# 先创建文件夹
mkdir -p /home/jenkins/
# 给文件夹赋权限 否则启动失败
chmod 777 -R /home/jenkins/
# 访问地址
xxx.xxx.xxx.xxx:8080/login
```


# 2.修改密码
```sh
# 第一次访问 控制台会输出 密码，也可以通过文件访问
cat  /home/jenkins/secrets/initialAdminPassword 
```
# 3.镜像加速
## 1. 插件安装，如果网速可以 可以直接使用默认的推荐，慢的话再选择自定义，登录后再修改源
## 2. 修改源
方式1： 启动后 关闭docker ，并修改源
```sh
cd /var/jenkins_home 
vi hudson.model.UpdateCenter.xml
# 修改为 ： 
http://mirror.xmission.com/jenkins/updates/update-center.json
# 保存退出
:wq
# 重新启动jenkis
```

方式2：修改源 同时下载忽略ssh插件 并上传
```sh
## 修改配置
cd /var/jenkins_home 
vi hudson.model.UpdateCenter.xml
http://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json
重启

# 网上说可能不生效  再修改 default.json
sed -i 's/https:\/\/updates.jenkins.io\/download/http:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins/g' /var/lib/jenkins/updates/default.json && sed -i 's/http:\/\/www.google.com/https:\/\/www.baidu.com/g' /var/lib/jenkins/updates/default.json


## 上传插件
下载 忽略ssh 插件
https://mirrors.tuna.tsinghua.edu.cn/jenkins/plugins/skip-certificate-check/1.0/skip-certificate-check.hpi

# Manage Jenkins > manage plugins > advance  
上传并重启


```


# 4.插件安装
Manage Jenkins > manage plugins > available pluins  > 搜索内容

- Role-based Authorization Strategy 权限分配
- List Git Branches Parameter   列出分支参数
- GitHub Integration
- Git
- GitLab
- SSH
- Publish Over SSH
- SSH Agent
- SSH Pipeline Steps
- nodejs
- Date Parameter plugin
- Docker
- Docker Pipeline
- Git Parameter 解析git参数，允许我们选择分支进行构建
- Active Choices 可以做到参数的级联选择
- Generic Webhook Trigger 通用的webhook触发器，构建更强大的webhook功能
- Build With Parameters  
- Blue Ocean 流水线图形化

# 5.其他
## 重启  由于docker部署 只能docker重启
docker restart jenkins 

## 修改语言
Dashboard->Manage Plugin > 可选插件 > 搜索 Localization: Chinese (Simplified)

安装成功后 在默认设置

Dashboard->Config System -> Locale (Default Language) 中设置为zh-CN(安装了Localization: Chinese (Simplified)

## 用户权限
Manage Jenkins > Configure Global Security

# 5.gitlab 集成
- 在gitlab,创建一个项目
- 设置目录里有一个集成选项，有一个web hooks
- 勾选 push events，取消ssl
- 把jenkins任务的urlhttp://192.168.239.130:8080/project/jenkins-demo填写进来
- 把上面生成的token填写进来，点击add webhook
- 报错（在同一服务器，但端口不一样）：进入管理中心>设置>网络（展开外发请求，勾选并保存） 

# 6.配置 pipeline 
## 选择SCM 
则使用服务端的Jenkinsfile构建流水线
注意：不要选择精确

## 选择脚本
否则实现输入的脚本
 

## jenkins 不同docker数据共享
### 方法1 设置reuseNode true
  agent { docker {  reuseNode true  }  }
### 方法2 使用不变的 环境变量 ${WORKSPACE} 
### 方法3 使用docker.image('node:14').inside { } 新语法自动同步数据


# 7.参考官方文档
https://www.jenkins.io/zh/

# 8. vue集成


nginx.conf
```sh
user www-data;
worker_processes 4;
pid /run/nginx.pid;
# daemon off;

events {
  worker_connections  2048;
  multi_accept on;
  use epoll;
}

http {
  server_tokens off;
  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  open_file_cache off; # Disabled for issue 619
  charset UTF-8;

  keepalive_timeout  65; # 加长时长
  keepalive_requests 10000;# 加长时长
  underscores_in_headers on; 
  log_format  main  'clientIp: $remote_addr - $remote_user [$time_local] "[$request]" '
                    '$status $body_bytes_sent "[$http_referer]" '
                    '"$http_user_agent" "$http_x_forwarded_for"'
                      '$upstream_addr [time::{$upstream_response_time || $request_time}] ';
  log_format log404 '$status [$time_local] $remote_addr $host$request_uri $sent_http_location';

  #打开 gzip
  gzip on;
  gzip_min_length 1k;
  gzip_buffers 4 16k;
  gzip_comp_level 5;
  gzip_types text/plain application/javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg 
              image/gif image/png;
  gzip_vary on;
  gzip_disable "MSIE [1-6]\.";
  gzip_static on;
  
  add_header Cache-Control no-cache;  # 这里是有配置ip才生效，域名需要单独配置
  index  index.html index.htm;

  error_page 401 402 403 404 /404.html;
  error_page 500 502 503 /50x.html;

  types_hash_max_size 2048;
  client_max_body_size 100M;
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  access_log  /var/log/nginx/access.log;
  error_log  /var/log/nginx/error.log;

  # ssl协议统一设置
  ssl_protocols TLSv1 TLSv1.2 TLSv1.3;
  ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:1m;
  ssl_session_timeout 5m;
  ssl_stapling on;
  ssl_stapling_verify on;
  ssl_verify_depth 10;

  # 实际读取的配置路径
  server {
      listen       8080;
      server_name localhost;  

          location / {
              root   /usr/share/nginx/html;
              try_files $uri $uri/ /index.html;
          } 
  }
}

```

Jenkinsfile
```sh
pipeline {
    agent any
    options {
        // 添加日志打印时间
        timestamps()
        // 设置全局超时
        timeout(time: 10, unit: 'MINUTES')
    }
    parameters {
        choice(name: 'GITHUB_BRANCH', choices: ['main', 'develop'], description: 'checkout github branch')
    }
    environment {
        GITHUB_USER_ID = '190356b3-d5e0-43b1-bd8e-02a170897900'
        GITHUB_URL = 'http://171.35.40.74:7881/root/testvue.git'
        // WS = "${WORKSPACE}"
        DOCKER_NAME = 'vue_test'  // 镜像名称
        DOCKER_IMAGE = 'vue_test:1.0' // 镜像完整版本
        DOCKER_REMOTE_IMAGE = 'localhost:5000/vue_test:1.0' //jenkins docker仓库在同一台设备  如果是其他机器 需要鉴权
        GITHUB_BRANCH = 'main'
    }
    stages {
        stage('checkout') {
            options {
                timeout(time: 2, unit: 'MINUTES')
            }
            steps {
                // sh "echo 当前ws：${WORKSPACE}, 全局ws：${WS} " 
                // sh "rm -rf ./* " //注意可能会有缓存 看实际情况 
                git (credentialsId: "${GITHUB_USER_ID}", url: "${GITHUB_URL}", branch: "${GITHUB_BRANCH}")
            }
        }
        stage('npm build') {
            agent {
                docker {
                    image  'node:14'
                    args  '-p 2000:8080 --privileged=true'
                    reuseNode true  //不单独容器，目录共享
                }
            }
            steps {
                script {
                    // sh "echo 当前ws：${WORKSPACE}, 全局ws：${WS} " 
                    sh "pwd && ls -l"
                    sh "npm -v"
                    sh 'npm config set registry https://registry.npmmirror.com'  //# 
                    sh 'npm install && npm run build'
                    sh "echo 构建完成"
                }
            }
        }
        stage('docker build') {
            steps {
                script {
                    // sh "echo 当前ws：${WORKSPACE}, 全局ws：${WS} "
                    sh "pwd && ls -l"
                    sh "docker build -t ${DOCKER_IMAGE} ."
                    sh "pwd && ls -l"
                }
            }
        }

        stage("deploy") {
            steps {
                script {
                //    sh "echo 当前ws：${WORKSPACE}, 全局ws：${WS} "
                   sh "pwd && ls -l"
                   sh "docker stop -f $DOCKER_NAME  || true "
                   sh "docker rm -f $DOCKER_NAME  || true "
                   sh "docker run --rm -it -d -p 8081:8080 --name=$DOCKER_NAME $DOCKER_IMAGE "
               }
            }
        }
        stage('docker push') {
            when {
                expression {
                    "${params.GITHUB_BRANCH}" == "main"
                }
            }
            steps {
                script {
                    //注意这里我使用刚好 jenkins docker仓库在同一台设备 所以直接提交 localhost
                    // withDockerRegistry(credentialsId: "${ALIYUN_USER_ID}", url: 'http://registry.cn-shenzhen.aliyuncs.com') {
                        sh "docker tag ${DOCKER_IMAGE} ${DOCKER_REMOTE_IMAGE}"
                        sh "docker push ${DOCKER_REMOTE_IMAGE}"
                    // }
                }
            }
        }
    }
}
```

Dockerfile
```sh
FROM nginx:alpine

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /usr/share/nginx/html

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories

RUN apk update \
    && apk upgrade \
    && apk --update add logrotate \
    && apk add --no-cache openssl \
    && apk add --no-cache bash

RUN apk add --no-cache curl

RUN set -x ; \
    addgroup -g 82 -S www-data ; \
    adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1

# ARG PHP_UPSTREAM_CONTAINER=php-fpm
# ARG PHP_UPSTREAM_PORT=9000

# Create 'messages' file used from 'logrotate'
RUN touch /var/log/messages

# Copy 'logrotate' config file
# COPY logrotate/nginx /etc/logrotate.d/

COPY ./dist /usr/share/nginx/html 
COPY ./nginx.conf /etc/nginx
# CMD ["nginx", "-g", "'daemon off;'"]
# ADD ./startup.sh /opt/startup.sh
# RUN sed -i 's/\r//g' /opt/startup.sh
# CMD ["/bin/bash", "/opt/startup.sh"]

EXPOSE 8080
```

# 9.node集成
Dockerfile
```sh
FROM node:11.6.0
RUN mkdir -p /home/Service
WORKDIR /home/Service
 
COPY . /home/Service
RUN yarn install
 
EXPOSE 3000
 
CMD [ "node", "index.js" ]
```
Jenkinsfile
```sh
pipeline {
    agent any
    options {
        // 添加日志打印时间
        timestamps()
        // 设置全局超时
        timeout(time: 10, unit: 'MINUTES')
    }
    parameters {
        choice(name: 'GITHUB_BRANCH', choices: ['main', 'develop'], description: 'checkout github branch')
    }
    environment {
        GITHUB_USER_ID = '190356b3-d5e0-43b1-bd8e-02a170897900'
        GITHUB_URL = 'http://171.35.40.74:7881/root/jenkins_node.git'
        DOCKER_NAME = 'node_test'  // 镜像名称
        DOCKER_IMAGE = 'node_test:1.0' // 镜像完整版本
        DOCKER_REMOTE_IMAGE = 'localhost:5000/node_test:1.0' //jenkins docker仓库在同一台设备  如果是其他机器 需要鉴权
        GITHUB_BRANCH = 'main'
    }
    stages {
        stage('checkout') {
            options {
                timeout(time: 2, unit: 'MINUTES')
            }
            steps {
                // sh "rm -rf ./* " //注意可能会有缓存 看实际情况 
                git (credentialsId: "${GITHUB_USER_ID}", url: "${GITHUB_URL}", branch: "${GITHUB_BRANCH}")
            }
        } 
        stage('docker+node build') {
            steps {
                script {
                    sh "pwd && ls -l"
                    sh "docker build -t ${DOCKER_IMAGE} ."
                    sh "pwd && ls -l"
                }
            }
        }

        stage("deploy") {
            steps {
                script {
                   sh "pwd && ls -l"
                   sh "docker stop -f $DOCKER_NAME  || true "
                   sh "docker rm -f $DOCKER_NAME  || true "
                   sh "docker run --rm -it -d -p 3330:3000 --name=$DOCKER_NAME $DOCKER_IMAGE "
               }
            }
        }
        stage('docker push') {
            when {
                expression {
                    "${params.GITHUB_BRANCH}" == "main"
                }
            }
            steps {
                script {
                    //注意这里我使用刚好 jenkins docker仓库在同一台设备 所以直接提交 localhost
                    // withDockerRegistry(credentialsId: "${ALIYUN_USER_ID}", url: 'http://registry.cn-shenzhen.aliyuncs.com') {
                        sh "docker tag ${DOCKER_IMAGE} ${DOCKER_REMOTE_IMAGE}"
                        sh "docker push ${DOCKER_REMOTE_IMAGE}"
                    // }
                }
            }
        }
    }
}
```
index.js
```sh
const express = require('express')
const app = express()
 
app.get('/', (req, res) => {
  res.send({a:1222})
})
 
app.listen(3000, () => {
  console.log("3000端口启动了")
})
```