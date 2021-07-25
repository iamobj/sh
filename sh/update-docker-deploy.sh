#!/bin/sh
set -e

# docker 私库地址
registry_url=$1
# 私库登录用户名
user_name=$2
# 私库登录密码
password=$3
# 镜像tag
image_tag=$4
# 容器名称
container_name=$5
# docker run 参数
docker_run_params=$6

# 停止容器并删除容器
docker stop $container_name || true && docker rm $container_name || true

# 登录镜像私库
docker login $registry_url -u $user_name -p $password

# 拉取镜像
docker pull $image_tag

# 退出私库
docker logout $registry_url

# 启动2
docker run --name $container_name $docker_run_params -d $image_tag
