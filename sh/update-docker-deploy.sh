#!/bin/sh
### 示例：
### update-docker-deploy.sh -R ****.com -U iamobj --password 123456 -T "****:latest" -A "--restart=always"
### 参数：
###   -R, --registry-url              docker私库地址
###   -U, --user-name                 私库登录用户名
###   -P, --password                  私库登录密码
###   -T, --image-url                 最新的镜像地址，仓库名加tag eg：node:14
###   -N, --container-name            容器名称
###   -A, --docker-run-args           容器启动参数
###   -S, --stock                     保存最新的几份镜像，值为0-不删除；默认3，保存最新的3份镜像，其余删掉
set -e

help() {
	awk -F'### ' '/^###/ { print $2 }' "$0"
}

if [[ $# == 0 ]] || [[ "$1" == "-h" ]]; then
	help
	exit 1
fi

ARGS=`getopt -o R:U:P:T:N:A:S: -l registry-url:,user-name:,password:,image-url:,container-name:,docker-run-args:,stock: -n "$0" -- "$@"`
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
# 镜像地址
opt_image_url=""
# 容器名称
opt_container_name=""
# docker run 参数
opt_docker_run_args=""
# 要保存的库存数
opt_stock=3

# 获取参数
while [ -n "$1" ]
do
  case "$1" in
    -R|--registry-url) opt_registry_url=$2; shift 2;;
    -U|--user-name) opt_user_name=$2; shift 2;;
    -P|--password) opt_password=$2; shift 2;;
    -T|--image-url) opt_image_url=$2; shift 2;;
    -N|--container-name) opt_container_name=$2; shift 2;;
    -A|--docker-run-args) opt_docker_run_args=$2; shift 2;;
    -S|--stock) opt_stock=$2; shift 2;;
    --) break ;;
    *) echo $1,$2,$show_usage; break ;;
  esac
done

echo "docker私库地址：$opt_registry_url"
echo "镜像地址：$opt_image_url"
echo "容器名称：$opt_container_name"
echo "docker run 参数：$opt_docker_run_args"
echo "要保存的库存数：$opt_stock"

# 停止容器并删除容器
docker stop $opt_container_name || true && docker rm $opt_container_name || true

# 登录镜像私库
docker login $opt_registry_url -u $opt_user_name -p $opt_password

# 拉取镜像
docker pull $opt_image_url

# 退出私库
docker logout $opt_registry_url

# 库存参数不等于0 就执行删除镜像逻辑
if [ $opt_stock -ne 0 ]; then
  # 获取镜像关键字 去除tag
  keyword=${opt_image_url/:*/}
  echo "通过镜像地址解析出的镜像关键字：$keyword"

  # 通过关键字列出镜像所有版本的镜像
  image_ids=`docker image ls -q $keyword`
  echo "查出镜像所有版本的id：$image_ids"
  
  # 循环用的下标
  i=0
  # 接收需要删除镜像的目标ids
  target_image_ids=""

  # 收集 opt_stock 之后的镜像 id
  for image_id in $image_ids; do
    if [ $i -ge $opt_stock ]; then
      target_image_ids="$target_image_ids $image_id"
    fi

    # 这里关闭 set -e ，因为只要命令返回结果非零，会让 set -e 捕捉到当错误处理，终止执行
    set +e
    let i++
    set -e
  done

  echo "需要删除的镜像id：$target_image_ids"

  # 删除
  if [ ${#target_image_ids} -gt 0 ]; then
    docker image rm $target_image_ids
  fi

fi

# 启动
docker run --name $opt_container_name $opt_docker_run_args -d $opt_image_url

printf -- '\n'