# 个人 sh 脚本集合

## 自动同步到七牛云

当脚本文件有新增、修改、重命名、删除操作，[action](https://github.com/iamobj/sh/blob/main/.github/workflows/sync-qiniu.yml) 采用增量方式自动同步到七牛云空间

> 注意：重命名操作，action 会把重命名后的文件上传上去，但旧文件还在七牛云空间里，因为没法获取到重命名文件之前的文件名，从而无法删除之前的旧文件

**为什么要同步到七牛云？**

就因一点，使用 `wget` 命令获取脚本的时候，可以使用 `-N` 参数，用了这个参数，命令会去判断远程文件有没有更新，没有更新就不会下载，这样就能节省重复下载文件的带宽，想要用上这个小细节的前提是，文件 url 的响应头要有 `Last-Modified` 这个字段，这个字段记录的是远程文件在远程机器上最新变更的时间。[详情点击查看 wget 命令时间戳说明](https://www.gnu.org/software/wget/manual/wget.html#:~:text=using%20%E2%80%98--timestamping%E2%80%99%20(%E2%80%98-N%E2%80%99))

github 的文件 url，没有那个字段，于是乎就想着自动同步到七牛云，国内服务器也方便下载。同时可以避免 github 被墙或慢导致下载一系列问题

## 脚本列表

### update-docker-deploy.sh
更新 docker 部署脚本，重拉镜像，重启容器
