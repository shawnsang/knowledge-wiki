---
published: true
keywords: Ubuntu, Configuration, Devops, Share, Automation, Culture, Mindset
descriptions: agai server configuration
title: Ubuntu Configuration
---

# 时区更改为中国时区（`Asia/Shanghai`）

---

## 使用 `timedatectl` 命令（推荐）

### 步骤：
1. **查看当前时区**
   运行以下命令查看当前时区：
   ```bash
   timedatectl
   ```
   输出示例：
   ```
   Local time: Wed 2023-10-04 12:34:56 UTC
   Universal time: Wed 2023-10-04 12:34:56 UTC
   RTC time: Wed 2023-10-04 12:34:56
   Time zone: Etc/UTC (UTC, +0000)
   ```

2. **列出所有可用时区**
   查找中国时区（`Asia/Shanghai`）：
   ```bash
   timedatectl list-timezones | grep Shanghai
   ```

3. **设置时区为中国时区**
   运行以下命令更改时区：
   ```bash
   sudo timedatectl set-timezone Asia/Shanghai
   ```

4. **验证时区更改**
   再次运行 `timedatectl` 命令，确认时区已更改：
   ```bash
   timedatectl
   ```
   输出示例：
   ```
   Local time: Wed 2023-10-04 20:34:56 CST
   Universal time: Wed 2023-10-04 12:34:56 UTC
   RTC time: Wed 2023-10-04 12:34:56
   Time zone: Asia/Shanghai (CST, +0800)
   ```

---



# Mount 额外的磁盘分区

---

### 1. **查看已连接的磁盘和分区**
在挂载之前，需要知道磁盘的设备名称（如 `/dev/sdb1`）。可以使用以下命令查看：

```bash
lsblk
```

或者：

```bash
sudo fdisk -l
```

输出示例：
```
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0   100G  0 disk
├─sda1   8:1    0    50G  0 part /
└─sda2   8:2    0    50G  0 part /home
sdb      8:16   0   500G  0 disk
└─sdb1   8:17   0   500G  0 part
```

这里，`sdb1` 是未挂载的分区。

---

### 2. **创建挂载点**
挂载点是一个目录，用于访问挂载设备的内容。可以创建一个新目录作为挂载点：

```bash
sudo mkdir /mnt/mydisk
```

---

### 3. **挂载磁盘分区**
使用 `mount` 命令将分区挂载到挂载点。例如，将 `/dev/sdb1` 挂载到 `/mnt/mydisk`：

```bash
sudo mount /dev/sdb1 /mnt/mydisk
```

---

### 4. **验证挂载**
使用以下命令查看挂载是否成功：

```bash
df -h
```

或者：

```bash
lsblk
```

如果挂载成功，`/mnt/mydisk` 会显示为挂载点。

---

### 5. **设置开机自动挂载**
如果希望每次系统启动时自动挂载磁盘，需要编辑 `/etc/fstab` 文件。

1. 获取分区的 UUID：
   ```bash
   sudo blkid /dev/sdb1
   ```
   输出示例：
   ```
   /dev/sdb1: UUID="1234-5678-90AB-CDEF" TYPE="ext4"
   ```

2. 编辑 `/etc/fstab` 文件：
   ```bash
   sudo nano /etc/fstab
   ```

3. 添加一行配置（以 UUID 为例）：
   ```
   UUID=1234-5678-90AB-CDEF /mnt/mydisk ext4 defaults 0 2
   ```
   其中：
   - `UUID`：分区的唯一标识符。
   - `/mnt/mydisk`：挂载点。
   - `ext4`：文件系统类型。
   - `defaults`：挂载选项。
   - `0 2`：dump 和 fsck 选项。

4. 保存并退出编辑器（在 `nano` 中按 `Ctrl+O` 保存，`Ctrl+X` 退出）。

5. 测试配置是否正确：
   ```bash
   sudo mount -a
   ```
   如果没有错误，说明配置正确。

---

### 6. **卸载磁盘**
如果不再需要访问磁盘，可以使用 `umount` 命令卸载：

```bash
sudo umount /mnt/mydisk
```

---

### 7. **挂载其他文件系统**
- **挂载 ISO 文件**：
  ```bash
  sudo mount -o loop /path/to/image.iso /mnt/iso
  ```

- **挂载 USB 驱动器**：
  ```bash
  sudo mount /dev/sdc1 /mnt/usb
  ```

- **挂载网络文件系统（NFS）**：
  ```bash
  sudo mount -t nfs 192.168.1.100:/shared /mnt/nfs
  ```

---

### 注意事项
- 确保挂载点目录存在且为空。
- 如果挂载失败，检查设备名称、文件系统类型和权限。
- 使用 `sudo` 执行挂载命令，因为需要管理员权限。


# 为 Jenkins 用户添加 Docker 运行权限

---

### 1. **将 Jenkins 用户添加到 `docker` 组**
Docker 的 Unix 套接字（`/var/run/docker.sock`）默认由 `docker` 组拥有。将 Jenkins 用户添加到 `docker` 组后，Jenkins 就可以访问 Docker。

#### 步骤：
1. 检查 Jenkins 用户是否已存在：
   ```bash
   id jenkins
   ```

2. 将 Jenkins 用户添加到 `docker` 组：
   ```bash
   sudo usermod -aG docker jenkins
   ```

3. 验证是否添加成功：
   ```bash
   id jenkins
   ```
   输出中应包含 `docker` 组：
   ```
   uid=1001(jenkins) gid=1001(jenkins) groups=1001(jenkins),999(docker)
   ```

---

### 2. **重启 Jenkins 服务**
修改用户组后，需要重启 Jenkins 服务以应用更改。

#### 步骤：
```bash
sudo systemctl restart jenkins
```

---

### 3. **验证 Docker 权限**
确保 Jenkins 用户能够执行 Docker 命令。

#### 步骤：
1. 切换到 Jenkins 用户：
   ```bash
   sudo su - jenkins
   ```

2. 运行 Docker 命令测试：
   ```bash
   docker ps
   ```
   如果配置正确，会显示当前运行的容器列表。

---

### 4. **解决权限问题**
如果 Jenkins 仍然无法执行 Docker 命令，可能是以下原因：

#### 4.1 **Docker 套接字权限问题**
检查 `/var/run/docker.sock` 的权限：
```bash
ls -l /var/run/docker.sock
```
输出示例：
```
srw-rw---- 1 root docker 0 Jan  1 00:00 /var/run/docker.sock
```
确保 `docker` 组具有读写权限。如果权限不正确，可以修复：
```bash
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock
```

#### 4.2 **SELinux 或 AppArmor 限制**
如果系统启用了 SELinux 或 AppArmor，可能会限制 Jenkins 用户访问 Docker。

- **检查 SELinux 状态**：
  ```bash
  sestatus
  ```
  如果 SELinux 处于 `Enforcing` 模式，可以尝试临时禁用：
  ```bash
  sudo setenforce 0
  ```

- **检查 AppArmor 状态**：
  ```bash
  aa-status
  ```
  如果 AppArmor 限制了操作，可以尝试禁用相关配置文件。

---

### 5. **在 Jenkins 任务中使用 Docker**
在 Jenkins 任务中，可以直接调用 Docker 命令或使用 Docker 插件（如 **Docker Pipeline**）。

#### 示例：在 Jenkins Pipeline 中使用 Docker
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    docker.image('alpine:latest').inside {
                        sh 'echo "Hello from Docker!"'
                    }
                }
            }
        }
    }
}
```

---

### 6. **使用 Docker-in-Docker（DinD）**
如果 Jenkins 运行在 Docker 容器中，可以使用 Docker-in-Docker（DinD）技术，让 Jenkins 容器内部运行 Docker 命令。

#### 步骤：
1. 启动 Jenkins 容器时挂载 Docker 套接字：
   ```bash
   docker run -d \
     --name jenkins \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v jenkins_home:/var/jenkins_home \
     -p 8080:8080 \
     jenkins/jenkins:lts
   ```

2. 在 Jenkins 容器内部，直接使用 Docker 命令。

---

### 总结
- 将 Jenkins 用户添加到 `docker` 组。
- 重启 Jenkins 服务以应用更改。
- 验证 Jenkins 用户能否执行 Docker 命令。
- 如果 Jenkins 运行在容器中，可以使用 Docker-in-Docker 技术。


# 配置域名解析

需要在域名解析服务商处配置域名解析，将域名指向服务器 IP。

阿里云域名服务：
https://dc.console.aliyun.com/next/index?spm=5176.100251.111252.15.7c4c4f15vAFEJS&/#/domain-list/all

只有当域名解析生效后，才能生成证书。


---
# 配置域名证书

### 1. **使用 Let's Encrypt 创建证书**
在宿主机上使用 `certbot` 获取证书。

#### 步骤：
1. 安装 `certbot`：
   ```bash
   sudo apt update
   sudo apt install certbot
   ```

2. 获取证书：
   ```bash
   sudo certbot certonly --standalone -d agaistock.cn -d www.agaistock.cn
   ```
   - `--standalone`：表示 `certbot` 会启动一个临时的 Web 服务器来完成域名验证。
   - 确保域名 `agaistock.cn` 和 `www.agaistock.cn` 已经解析到当前服务器的 IP 地址。

3. 证书文件路径：
   - 证书文件：`/etc/letsencrypt/live/agaistock.cn/fullchain.pem`
   - 私钥文件：`/etc/letsencrypt/live/agaistock.cn/privkey.pem`

---

### 2. **将证书挂载到 Docker 容器**
在 Docker Compose 中，将宿主机上的证书文件挂载到 Nginx 容器中。

#### 修改 `docker-compose.yml`：
假设你的 `docker-compose.yml` 文件如下：
```yaml
version: '3'
services:
  nginx:
    image: nginx:latest
    container_name: nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - /etc/letsencrypt/live/agaistock.cn/fullchain.pem:/etc/letsencrypt/live/agaistock.cn/fullchain.pem
      - /etc/letsencrypt/live/agaistock.cn/privkey.pem:/etc/letsencrypt/live/agaistock.cn/privkey.pem
    restart: always
```

- `volumes` 部分将宿主机上的证书文件挂载到容器中。
- 确保 `nginx.conf` 文件中的路径与挂载路径一致。

---

### 3. **配置 Nginx 使用 SSL/TLS 证书**
你已经提供了 Nginx 的配置文件，确保路径和挂载路径一致即可。

#### 示例 Nginx 配置文件：
```nginx
server {
    listen 443 ssl;
    server_name agaistock.cn www.agaistock.cn;

    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/agaistock.cn/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/agaistock.cn/privkey.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}

server {
    listen 80;
    server_name agaistock.cn www.agaistock.cn;
    return 301 https://$host$request_uri;
}
```

- 确保 `ssl_certificate` 和 `ssl_certificate_key` 的路径与挂载路径一致。
- 将 HTTP 流量重定向到 HTTPS。

---

### 4. **启动 Docker Compose**
启动 Docker Compose 服务：
```bash
docker-compose up -d
```

---

### 5. **验证 HTTPS 配置**
1. 打开浏览器，访问 `https://agaistock.cn`。
2. 检查浏览器地址栏是否显示安全锁标志。
3. 使用 SSL 检查工具（如 [SSL Labs](https://www.ssllabs.com/ssltest/)）验证配置是否正确。

---

### 6. **自动续期 Let's Encrypt 证书**
Let's Encrypt 证书有效期为 90 天，需要定期续期。

#### 步骤：
1. 测试续期：
   ```bash
   sudo certbot renew --dry-run
   ```

2. 设置自动续期：
   `certbot` 会自动创建定时任务，但需要确保续期后重新加载 Nginx 配置。

   编辑 crontab：
   ```bash
   sudo crontab -e
   ```
   添加以下内容：
   ```bash
   0 12 * * * /usr/bin/certbot renew --quiet && docker exec nginx nginx -s reload
   ```
   - `docker exec nginx nginx -s reload`：在证书续期后，重新加载 Nginx 容器的配置。

---

### 总结
- 使用 `certbot` 获取 Let's Encrypt 证书。
- 在 Docker Compose 中挂载证书文件。
- 配置 Nginx 使用 SSL/TLS 证书。
- 启动 Docker Compose 并验证 HTTPS 配置。
- 设置自动续期证书并重新加载 Nginx。

按照以上步骤操作后，你的 Docker Compose 中的 Nginx 将支持 HTTPS。如果仍有问题，欢迎继续提问！