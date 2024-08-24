---
layout: "git-wiki-post"
---


以下是Gitlab local 安装配置的一个步骤参考。


GitLab 有两个版本，ce（免费的社区版） 和 ee（付费的企业版）， 企业版安装之后，需要license激活，所以，下面以社区版为例来说明基础安装和配置。



## 安装 gitlab 的依赖包

```bash
sudo apt install curl openssh-server ca-certificates perl postfix

```

安装过程中一路确认就好，需要配置 Internet Site 和 mail name，默认就是当前机器的名称

## 添加 gitlab 仓库

```bash
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
```

## 安装 gitlab-ce

```bash
sudo apt install gitlab-ce
```

# 配置 gitlab

gitlab的配置文件默认位于 `/etc/gitlab/gitlab.rb` ， 用文本编译器可以打开编辑

配置访问地址

如果只是内部使用，则可以直接用 http 链接方式，设置 `external_url`

```ruby
external_url = http://xxxx.xxxx.com:8080
```

如果提供外部访问，最好还是配置 https。同时需要配置 ssl 证书，准备好有效的crt证书后，配置如下

```ruby
external_url = https://xxxx.xxxx.com:8080

nginx['enable'] = true
nginx['redirect_http_to_https'] = true
nginx['redirect_http_to_https_port'] = 80
nginx['ssl_certificate'] = "crt证书位置"
nginx['ssl_certificate_key'] = "证书密钥位置"

```

权限配置

默认gitlab 的普通用户可以创建组，根据使用规模，可以考虑这个权限关闭掉，找到`gitlab_rails['gitlab_default_can_create_group']`将其配置为false

邮箱配置

代码存放位置配置

没有特殊需要，这个可以使用默认值。 找到`git_data_dirs`，把其中的`path`改为自定义值

备份设置

```ruby
gitlab_rails['manage_backup_path'] = true
gitlab_rails['backup_path'] = "备份位置"
gitlab_rails['backup_keep_time'] = 604800
```

上述`gitlab_rails['backup_keep_time']`表示备份保留时长。备份设置没有特殊需要也可以不用修改。

配置及时起效

```ruby
sudo gitlab-ctl reconfigure
```

常用命令

```ruby
# 启动服务端
sudo gitlab-ctl start


# 停止服务端
sudo gitlab-ctl stop


# 重启服务端
sudo gitlab-ctl restart


# 重载配置
sudo gitlab-ctl reconfigure


# 查看状态
sudo gitlab-ctl status
```

# 管理员初始登录

启动完成之后，就可以访问服务器地址，登录了。管理员账户名默认为`root`，密码可以在`/etc/gitlab/initial_root_password`文件中找到，登录后记得修改管理员密码。

备份和恢复

手动创建备份：

```ruby
sudo gitlab-rake gitlab:backup:create
```

备份文件默认在`/var/opt/gitlab/backups`目录下。备份的文件为一个`tar`文件。

恢复则使用下列命令：

```ruby
sudo gitlab-rake gitlab:backup:restore BACKUP=备份编号
```

可以在备份目录查看自己的备份文件，如果备份文件名为：`1632904480_2021_09_29_14.3.0_gitlab_backup.tar`，那么备份编号就是`1632904480_2021_09_29_14.3.0`。

注意，备份和恢复时，必须保证gitlab是正在运行状态，并且备份文件必须和版本匹配，如果低版本备份文件恢复到高版本是不行的。

并且`/etc/gitlab`目录下的`gitlab.rb`和`gitlab-secrets.json`这两个文件是不会被备份的，需要手动复制出来，最后放回去。

# 更新

gitlab如果需要更新，执行`apt update`和`apt full-upgrade`即可更新。需要注意的是，更新时必须保证gitlab服务器是启动状态，否则可能失败。如果仍然更新失败，可能是版本跨太多了，可以先使用`apt list -a gitlab`命令查看gitlab的版本，然后一级一级地向上更新。

# 参考文档

<https://gitlab.cn/install/>

<https://docs.gitlab.com/omnibus/settings/?spm=a2c6h.12873639.article-detail.8.5e021518499duJ>

<https://developer.aliyun.com/article/114619?spm=a2c6h.12873639.article-detail.9.5e021518499duJ>
