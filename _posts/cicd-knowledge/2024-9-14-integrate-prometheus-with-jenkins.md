---
published: true
keywords: jenkins prometheus ai
descriptions: 集成 Jenkins 日志到 Prometheus中
---

Jenkins 的状态和各种Job运行的情况是比较分散的，如果将Jenkins的这些信息集成到 Prometheus 中，就可以进一步使用 PromQL 对这些信息进行查询和分类汇总。

进一步考虑，可以使用 LLM 的 Agent 通过 Function Calling 来从 Prometheus 中获得相应的信息，并结合 Python的统计分析，就非常方便的获得了 Jenkins的各种统计数据。 

这里先介绍一下 Jenkins 和 Prometheus 的集成步骤。 

默认，Jenkins 和 Prometheus 已经安装完毕，并且正常运行了。


## 安装 Jenkins plugins for Prometheus

在 Jenkins Plugins 管理界面，选择 “可用安装” 列表，输入 “Prometheus”， 就可以看到该插件，直接安装即可。

此时，Jenkins如果没有正在执行的job，可以考虑重启一下 Jenkins服务。不重启，也没有问题。



## 配置 Prometheus in Jenkins

进入到 Jenkins的管理界面，找到 “Prometheus” 部分，确认还有哪些 metric 是需要被收集的，都勾选上。

![](/knowledge-wiki/assets/images/posts/cicd_devops/prometheus/configuration_in_jenkins.png)

注意，默认path是 “prometheus”，这个值要和 prometheus.yml 中的 metrics_path 路径一致。 



## 配置 prometheus.yml in Prometheus

在 Prometheus根目录中，找到 prometheus.yml，并添加 Jenkins地址

```
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "jenkins"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.
    metrics_path: '/prometheus/'
    static_configs:
      - targets: ["221.128.226.173:8080"]
        labels:
            group: 'production'       
```


## 启动 Prometheus 

检查 Jenkins连接信息是否正常。 在 Prometheus 的 Target 分类里，应当能看到 Jenkins的地址，并且 Status 是 绿色的 “Up” 状态。

![](/knowledge-wiki/assets/images/posts/cicd_devops/prometheus/successful_connect.png)


这个时候，在 检索页面就可以看到 Jenkins 相关的 metrics 了。 



## 后续，AI Agent 跟进

.......