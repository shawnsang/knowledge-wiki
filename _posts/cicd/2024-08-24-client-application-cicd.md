
# Client Application CICD

虽然Cloud 的应用程序越来越多，但是 Client 应用依旧不少，尤其是还有不少是依赖 OS 平台的应用程序。 下面就简单介绍一个基于 Client 应用的 CICD 流程，其中会包含不少 Tips.


## 基本工具

Source code 管理，现在基本都是 git 为基础，要么是 Github， 要么是 Gitlab, 这里以 Github 为例了。

Jenkins： 作为 CICD 的调度管理工具，是整个 CICD的核心。 虽然， Github Actions， Gitlab runner 也可以做一些自动触发，编译等功能，但是缺少一些灵活性，例如，build installer 这类集成任务，不需要 Code changes的。 所以，为了减少整个系统的复杂度，直接用 Jenkins 比较简单。

Maven/Junit/Jacoco/Sonarqube： 假设这是一个 Java 程序，这些是常规的开发工具。

Jforg Artifactory： artifact 管理，可以管理中间的 components，也可以管理最后的 installer。当然，这个 installer不要太大，例如 1G以上，会导致网络负担的。太大的 installer 可以考虑其他策略，如果 ftp server等。 类似管理工具还有 Harbor.

通知提醒，包括邮件，slack 等，作为Jenkins的基本操作，不在这里单独描述。

## 开发管理

Code commit: Github main branch 受保护，代码不能直接提交到 main, 需要以 PR 的形式提交。 在 PR 上有Jenkins 的约束检查job，包括基本的代码编译，单元测试，代码覆盖率检查，以及静态代码扫描，所有过程均正确，该 PR 可以被 merge 到 main branch。

Artifact 管理： 区分 Dev 和 Release repo， Dev repo 仅保存开发过程中的临时结果，可以随时被清理。 Release Repo 保存经过测试的 components 和 installers。


## 详细流程

### PR 流程
![](/knowledge-wiki/assets/images/posts/cicd_devops/client-app-cicd/PR.png)

Github PR 创建后，通过 Jenkins 的 Webhook 启动 Jenkins job，对 PR branch 进行编译， maven 编译后，根据实际情况，可以保存 snaphost 到 artifactory，也可以不保存，大部分情况下，不太会用的上，不保存可以节省网络资源和 Artifactory 的磁盘空间。调用 junit做单元测试，jacoco做代码覆盖率测试，最后通过 sonarqube 得到代码覆盖率是否达标，以及一些代码的静态检查，如果复杂逻辑检查，如果不过关，则 Jenkins job failed，PR会被阻挡，不能 merge。 开发人员通过 Jenkins job 的日志可以查看具体的问题。




### Code merged to main
![](/knowledge-wiki/assets/images/posts/cicd_devops/client-app-cicd/main.png)

当PR merge 到 main branch， jenkins job 可以直接对 main 监控，启动编译工作，编译release 版本的 jar 文件，如果觉得需要，仍然可以添加 单元测试的工作。覆盖率测试需要 jar的debug版本，所以，这里就不用了。 编译好的 component 可以保存到 Dev repo。

而后，另一个 jenkins job可以准备集成测试。 集成测试一般是共用的，不同的 components 都会触发集成测试，所以，这里可能存在集成测试排队的情况。需要酌情增加集成测试环境来减少排队的情况。

集成测试成功的 component 才会被推送到 release repo。


### integration
![](/knowledge-wiki/assets/images/posts/cicd_devops/client-app-cicd/installer.png)

client 应用程序必然都会有一个安装包，以便于用户下载和安装。 这里可以是 集成测试完成后自动触发，也可以是其他策略。总之，先将所有的依赖 components 和 必要的配置信息全部整理好，到一个 stage folder，然后打包成为 installer。 

这里还隐藏了一个关键任务，就是 installer 签名。 Windows上需要使用 CodeSign 做签名，MacOS 上需要完成 notarization。Linux上可以自签名。 Windows 和 MacOS上都是需要付费得到相应证书的。 

打包好的 installer ， 也是暂存 Dev repo，还需要进行 regression test。

### release 
![](/knowledge-wiki/assets/images/posts/cicd_devops/client-app-cicd/regressiontest.png)

完成regression test 的安装包，最后被放置到 release repo，随时可以发布到下载站点，供用户下载了。 