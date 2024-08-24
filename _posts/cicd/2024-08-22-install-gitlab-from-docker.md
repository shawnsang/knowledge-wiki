---
layout: "git-wiki-post"
---




<https://docs.gitlab.com/ee/install/docker.html>

## 设置卷位置

在设置其他所有内容之前，请配置一个新的环境变量 `$GITLAB_HOME`，指向配置、日志和数据文件所在的目录。 确保该目录存在并且已授予适当的权限。

对于 Linux 用户，将路径设置为 `/srv/gitlab`

```bash
export GITLAB_HOME=/srv/gitlab
```

prepare default folder

```bash
mkdir -p /srv/gitlab/data
mkdir -p /srv/gitlab/config
mkdir -p /srv/gitlab/logs
```

`GITLAB_HOME` 环境变量应该附加到您的 shell 的配置文件中，以便它应用于所有未来的终端会话：

*   Bash：`~/.bash_profile`
*   ZSH：`~/.zshrc`

```bash
vim ~/.bash_profile

```

### 使用 Docker Engine 安装GitLab-ce

注意 gitlab-ce 的 registry 地址

```bash
sudo docker run --detach \
  --hostname testing-docker1.fyre.ibm.com \
  --publish 443:443 --publish 8085:80 --publish 28:22 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m \
  registry.hub.docker.com/gitlab/gitlab-ce:latest

```

使用用户名 root 和来自以下命令的密码登录：

```bash
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

清理 docker container

```
docker rm -f $(docker ps -aq)

```

docker 进入 容器

    docker run -it gitlab /bin/bash

