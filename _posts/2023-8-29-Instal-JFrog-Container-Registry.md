---
published: true
---

JFrog Artifactory有多种安装方法，相对简单，易于配置、升级对主机影响小的方式就是 Docker 安装方式。本文详细介绍了这种安装方法的脚本，以及可能遇到的问题和解决方法。



JFrog 有多重版本，考虑到 docker.io 每日下载 image 的次数限制，最优方案是先安装 JFrog Container Registry，通过remote repo 来缓存 image，便于今后的维护和测试使用。



# Installation Steps

Complete the following steps to install the product.



*   Set JFROG\_HOME path

```bash
export JFROG_HOME=/srv/jfrog/
```



*   Create related folder for JFrog save data and configuration file.



```bash
mkdir -p $JFROG_HOME/artifactory-jcr/var/etc/
cd $JFROG_HOME/artifactory-jcr/var/etc/
touch ./system.yaml
chown -R 1030:1030 $JFROG_HOME/artifactory-jcr/var

```



*   Add correct permission.

```bash
chmod -R 777 $JFROG_HOME/artifactory-jcr/var

```



*   Install artifactory-jcr



```bash

Artifactory Container registry
docker run --name artifactory-jcr -v $JFROG_HOME/artifactory-jcr/var/:/var/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 releases-docker.jfrog.io/jfrog/artifactory-jcr:latest


Artifactory Open Source
docker run --name artifactory-oss -v $JFROG_HOME/artifactory-oss/var/:/var/opt/jfrog/artifactory -d -p 8083:8081 -p 8084:8082 releases-docker.jfrog.io/jfrog/artifactory-oss:latest

Artifactory Community Edition for C/C++
docker run --name artifactory -v $JFROG_HOME/artifactory/var/:/var/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 releases-docker.jfrog.io/jfrog/artifactory-cpp-ce:latest

Artifactory Pro
docker run --name artifactory -v $JFROG_HOME/artifactory/var/:/var/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 releases-docker.jfrog.io/jfrog/artifactory-pro:latest

```



*   Exposing Multiple Ports

    The Docker run command exposes more than one port: 8081 for Artifactory REST APIs and 8082 for all other uses.

*   Manage Artifactory using native Docker commands.

    ```bash
    docker ps
    docker stop artifactory-jcr
    ```



*   Access Artifactory from your browser at:

    `http://SERVER_HOSTNAME:8082/ui/`

    \*. \*For example, on your local machine: `http://localhost:8082/ui/` *.*



*   Check the Artifactory log.

    ```bash
    docker logs -f artifactory
    ```

*   Configure log rotation of the console log

    The `console.log` file can grow quickly since all services write to it. For more information, see [configure the log rotation](javascript:;).



# Artifactory Post-Installation Steps



Once the installation is complete, complete the following tasks.

*   Change the [default admin password](javascript:;). The default user will have the following credentials predefined in the system:

    *   **User**: admin, **Password**: password

## login current docker container registry

[Docker Hub and Docker Registries: A Beginner’s Guide | JFrog](https://jfrog.com/devops-tools/article/docker-hub-and-docker-registries-a-beginners-guide/#:\~:text=How%20to%20proxy%20Docker%20Hub%20with%20JFrog%20Container,newly%20created%20account%20and%20pull%20an%20image%20)

Podman 3.0.0+ 版本配置文件格式发生了变化，

```bash
 vi /etc/containers/registries.conf

# enable insecure and save them
[[registry]]
prefix = "9.30.166.115:8082"
location = "9.30.166.115:8082"
insecure = true


podman login 9.30.166.115:8082
podman pull 9.30.166.115:8082/docker-remote/gitlab/gitlab-ce

# now, we can get download successful and also found the image from docker-remote repo

```

Podman 3.0 之前的配置格式如下

```ruby
[registries.search]
registries = ['docker.io']
[registries.insecure]
registries = ['9.30.166.115:8082']
```

# Setup Docker service to use insecure(http) registry instead of https

Docker 客户端将 https 请求更改为 http 请求，更改配置文件为 /etc/docker/daemon.json

```json
{ "insecure-registries":["9.30.166.115:8082"] }
```

配置文件修改后，需要重启 docker服务

```bash
service docker restart

or 

systemctl daemon-reload
systemctl restart docker

```

**In ubuntu**\
edit the file /etc/default/docker and update DOCKER\_OPTS e.g

```
DOCKER_OPTS='--insecure-registry 15.206.81.210:9000'

```

where 15.206.81.210 is ipaddress of registry and 9000 is your port on which registry is configured.

**In Centos**\
Edit the file /etc/docker/daemon.json e.g.

    $ vi /etc/docker/daemon.json

    {
    "insecure-registries" : ["15.206.81.210:9001"]
    }

    $ service docker restart

where 15.206.81.210 is ipaddress of registry and 9001 is your port on which registry is configured.


** Using Rancher Desktop In MacOS **\

```
rdctl shell
```

Modify latest line in  **/etc/conf.d/docker**

```
sudo vi /etc/conf.d/docker
DOCKER_OPTS="--insecure-registry=9.30.166.115:8082"
```
Restart Rancher Desktop



# Reference

<https://jfrog.com/help/r/jfrog-installation-setup-documentation/install-artifactory-single-node-with-docker>

[Docker Hub and Docker Registries: A Beginner’s Guide | JFrog](https://jfrog.com/devops-tools/article/docker-hub-and-docker-registries-a-beginners-guide/)

<https://juejin.cn/post/7134695229893902349>

Docker login docker registry will get error&#x20;

<https://blog.csdn.net/jinli5621/article/details/117449201>

/etc/docker/daemon.json

/etc/containers/registries.conf
