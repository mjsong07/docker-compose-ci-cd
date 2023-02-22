# 1.运行 
## 1. docker-compose
docker-compose -f docker-compose-runner.yml up

## 2. docker run
docker run -it -v /data/gitlab-runner/config:/etc/gitlab-runner  gitlab/gitlab-runner:v14.9.0

## 注意
# 启动提示下面信息是正常的，需要开始配置
  ERROR: Failed to load config stat /etc/gitlab-runner/config.toml: no such file or directory  builds=0

# 进入容器执行命令
docker exec -it [id] bash
# 执行gitlab-runner register注册
gitlab-runner register

根据提示依次输入 url 和 token ，
由于已经把外部宿主服务器的docker 传到runner，
所以执行类型选择shell 方式既可以操作docker

# 注册完，需要执行run
gitlab-runner run

# 常用命令 
gitlab-runner register  #默认交互模式下使用，非交互模式添加 --non-interactive
gitlab-runner list      #此命令列出了保存在配置文件中的所有运行程序
gitlab-runner verify    #此命令检查注册的runner是否可以连接，但不验证GitLab服务是否正在使用runner。  

# 删除配置  记得如果删除失败，必须在原有项目的CI/CD 移除关联的配置
gitlab-runner verify --delete --name=node2
 

# 优化生成的配置 config.toml
vi /home/gitlab-runner/config/config.toml
# 添加 挂载了宿主机的docker缓存，提高效率
volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
# 防止Runner重复拉取镜像
pull_policy = "if-not-present"
# 进入容器 重启
docker exec it runner  gitlab-runner restart

# 全局配置关键字
default 工作关键字的自定义默认值。
stages 流水线阶段的名称和顺序。
variables 为管道中的所有作业定义 CI/CD 变量。
workflow 控制运行什么类型的管道。
before_script 覆盖在作业之前执行的一组命令。

# 使用作业关键字配置的作业：

before_script 覆盖在作业之前执行的一组命令。
cache 应在后续运行之间缓存的文件列表。
image 使用 Docker 镜像。
only 控制何时创建工作。
script 由运行程序执行的 Shell 脚本。
stage 定义作业阶段。
services 使用 Docker 服务镜像。
variables 在工作级别定义工作变量。
tags  用于选择跑步者的标签列表。 

# 注意
only 不支持变量 否则会一直Checking pipeline status 无限等待