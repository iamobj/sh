#!/bin/sh
### 示例：
### update-docker-deploy.sh -R ****.com -U iamobj --password 123456 -T "****:123" -A "--restart=always"
### 参数：
###   -R, --registry-url              docker 私库地址
###   -U, --user-name                 私库登录用户名
###   -P, --password                  私库登录密码
###   -T, --image-tag                 最新的镜像tag
###   -N, --container-name            容器名称
###   -A, --docker-run-args           容器启动参数
set -e

help() {
	awk -F'### ' '/^###/ { print $2 }' "$0"
}

if [[ $# == 0 ]] || [[ "$1" == "-h" ]]; then
	help
	exit 1
fi

ARGS=`getopt -o R:U:P:T:A: -l registry-url:,user-name:,password:,image-tag:,docker-run-args: -n "$0" -- "$@"`
if [ $? != 0 ]; then
    echo "终止..."
    exit 1
fi

# docker 私库地址
opt_registry_url=""
# 私库登录用户名
opt_user_name=""
# 私库登录密码
opt_password=""
# 镜像tag
opt_image_tag=""
# 容器名称
opt_container_name=""
# docker run 参数
opt_docker_run_args=""

# 获取参数
while [ -n "$1" ]
do
  case "$1" in
    -R|--registry-url) opt_registry_url=$2; shift 2;;
    -U|--user-name) opt_user_name=$2; shift 2;;
    -P|--password) opt_password=$2; shift 2;;
    -T|--image-tag) opt_image_tag=$2; shift 2;;
    -N|--container-name) opt_container_name=$2; shift 2;;
    -A|--docker-run-args) opt_docker_run_args=$2; shift 2;;
    --) break ;;
    *) echo $1,$2,$show_usage; break ;;
  esac
done

# 停止容器并删除容器
docker stop $opt_container_name || true && docker rm $opt_container_name || true

# 登录镜像私库
docker login $opt_registry_url -u $opt_user_name -p $opt_password

# 拉取镜像
docker pull $opt_image_tag

# 退出私库
docker logout $opt_registry_url

# 启动
docker run --name $opt_container_name $opt_docker_run_args -d $image_tag

printf -- '\n'