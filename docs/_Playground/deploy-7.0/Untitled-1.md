
---
- service: nginx_ha
  componentList:
    - component: server
      hostList: ["qadnode2.local","qadnode3.local"]
  configList:
    keepalived_common:
      default_virtual_ip_address: "172.30.3.46"

- service: kerberos
  componentList:
    - component: master
      hostList: ["qadnode2.local"]
    - component: slave
      hostList: ["qadnode3.local"]
    - component: client
      # 所有机器都安装client
      hostList: ["*"]

- service: ldap
  componentList:
    - component: server
      hostList: ["qadnode2.local", "qadnode3.local"]
    - component: client
      hostList: ["*"]

- service: easy_ranger
  componentList:
    - component: admin
      hostList: ["qadnode2.local","qadnode3.local"]

- service: zookeeper
  componentList:
    - component: server
      hostList: ["qadnode2.local","qadnode3.local", "qadnode4.local"]
    - component: client
      # 所有机器都安装client
      hostList: ["*"]

- service: kafka
  componentList:
    - component: manager
      hostList: ["qadnode2.local"]
    - component: broker
      hostList: ["qadnode2.local", "qadnode3.local", "qadnode4.local"]

- service: elasticsearch
  componentList:
    - component: master
      hostList: ["qadnode2.local", "qadnode3.local", "qadnode4.local"]
    - component: data
      hostList: ["qadnode2.local", "qadnode3.local", "qadnode4.local"]
  configList:
    data_jvm:
      jvm_heap_size: "2g"
    master_jvm:
      jvm_heap_size: "2g"

- service: ntsdb
  componentList:
    - component: master
      hostList: ["qadnode4.local", "qadnode2.local", "qadnode3.local"]
    - component: shardserver
      hostList: ["qadnode4.local", "qadnode2.local", "qadnode3.local"]

- service: neo4j
  componentList:
    - component: server
      hostList: ["qadnode4.local", "qadnode2.local", "qadnode3.local"]

- service: grafana
  componentList:
    - component: server
      hostList: ["qadnode2.local"]
- service: redis_sentinel
  componentList:
    - component: server
      hostList: ["qadnode2.local"]
    - component: slave
      hostList: ["qadnode3.local","qadnode4.local"]
    - component: sentinel
      hostList: ["qadnode4.local","qadnode2.local","qadnode3.local"]

- service: ds_agent
  componentList:
    # 部署在所有nodemanager节点
    - component: agent
      hostList: ["qadnode2.local","qadnode3.local", "qadnode4.local"]

- service: logstash
  componentList:
    - component: server
      hostList: ["qadnode3.local"]

- service: hdfs
  componentList:
    # zkfc 必须和 namenode 在相同机器
    - component: zkfc
      hostList: ["qadnode3.local", "qadnode2.local"]
    - component: namenode
      hostList: ["qadnode3.local", "qadnode2.local"]
    - component: journalnode
      hostList: ["qadnode2.local","qadnode3.local", "qadnode4.local"]
    - component: datanode
      hostList: ["qadnode2.local","qadnode3.local", "qadnode4.local"]
    - component: client
      # 所有机器都安装client
      hostList: ["*"]

- service: yarn
  componentList:
    - component: client
      # 所有机器都安装client
      hostList: ["*"]
    - component: nodemanager
      hostList: ["qadnode2.local","qadnode3.local", "qadnode4.local"]
    - component: resourcemanager
      hostList: ["qadnode3.local", "qadnode2.local"]
    - component: historyserver
      hostList: ["qadnode2.local"]
  configList:
    yarn_site:
      "yarn.scheduler.minimum-allocation-mb": "512"
      "yarn.scheduler.maximum-allocation-mb": "14096"
      "yarn.nodemanager.resource.memory-mb": "44096"
    mapred_site:
      "mapreduce.map.memory.mb": "512"
      "mapreduce.map.java.opts": "-Xmx819m"
      "mapreduce.reduce.memory.mb": "1024"
      "mapreduce.reduce.java.opts": "-Xmx1638m"
    mapred_env:
      HADOOP_JOB_HISTORYSERVER_HEAPSIZE: 900

- service: hive
  componentList:
    - component: client
      # 所有机器都安装client
      hostList: ["*"]
    - component: hiveserver
      hostList: ["qadnode3.local"]
    - component: metastore
      hostList: ["qadnode4.local"]

# 需要部署在hdfs-client hive-client的节点上
- service: impala
  componentList:
    - component: client
      # 所有机器都安装client
      hostList: ["*"]
    - component: catalogd
      hostList: ["qadnode2.local"]
    - component: impalad
      hostList: ["qadnode3.local"]
    - component: statestored
      hostList: ["qadnode2.local"]
  configList:
    statestored:
      "mem_limit": "2g"
    impalad:
      "mem_limit": "2g"
    catalogd:
      "mem_limit": "2g"

- service: spark2
  componentList:
    - component: client
      # 所有机器都安装client
      # 需要部署在yarn的client节点
      hostList: ["*"]
    - component: jobhistoryserver
      hostList: ["qadnode3.local"]
  configList:
    conf_spark_defaults:
      "spark.driver.memory": "2g"
      "spark.executor.memory": "2g"

- service: kyuubi
  componentList:
    - component: service
      hostList: ["qadnode2.local"]
  configList:
    common:
      "spark.driver.memory": "4g"
      "spark.executor.memory": "4g"
      "spark.yarn.am.memory": "2g"

- service: hbase
  componentList:
    - component: client
      # client 需要部署在hdfs的client节点
      # 所有机器都安装client
      hostList: ["*"]
    - component: master
      # master 需要部署在hdfs的client节点
      hostList: ["qadnode2.local", "qadnode3.local"]
    - component: regionserver
      # 需要部署在datanode的节点
      hostList: ["qadnode2.local", "qadnode3.local"]

- service: knox
  componentList:
    - component: server
      hostList: ["qadnode3.local", "qadnode2.local"]
  configList:
    global:
    # 可以按需求调整成不同端口，以规避Nginx和Knox同时部署在一台主机上时监听端口冲突
    # nginx 单点模式通过nginx ip 地址访问 不通过主机名访问
      domain: "<nginx对外域名或ip>:8889"

- service: meta_worker
  componentList:
    - component: api_server
      hostList: ["qadnode3.local"]
    - component: meta_server
      hostList: ["qadnode3.local"]
      
- service: easyeagle
  componentList:
  # 选择任意一个节点，仅安装一个backend
  - component: backend
    hostList: ["qadnode2.local"]
  # 选择default_yarn实例下任意一个装有yarn client组件的节点，仅安装一个parseservice,如果没有defalt_yarn，请咨询部署开发
  - component: parseservice
    hostList: ["qadnode2.local"]
  # 选择default_yarn实例下所有装有yarn nodemanager组件的节点，如果没有defalt_yarn，请咨询部署开发
  - component: collector
    hostList: ["qadnode2.local","qadnode3.local", "qadnode4.local"]
    
- service: smilodon_fsimage_audit
  componentList:
    - component: fsimage_oiv
      hostList: ["qadnode2.local"]
    - component: upload_audit
      hostList: ["qadnode3.local", "qadnode2.local"]
    - component: upload_fsimage
      hostList: ["qadnode3.local", "qadnode2.local"]

- service: hadoop_meta
  componentList:
    - component: service
      # 需要部署在安装hdfs-client
      hostList: ["qadnode4.local"]
    - component: scheduler
      # 部署在YARN ResourceManager节点上
      hostList: ["qadnode3.local", "qadnode2.local"]
    - component: kdc
      # 需要部署在kerberos的master节点, 且要安装hdfs-client
      hostList: ["qadnode2.local"]

# 更改服务配置组中的meta.hadoop.clusters，保持和HDFS中fs.defaultFS定义的一致
- service: meta_service
  componentList:
    - component: service
      # 需要部署在安装hdfs-client
      hostList: ["qadnode4.local"]

- service: bdms_meta
  componentList:
    - component: server
      hostList: ["qadnode4.local"]

# 需要部署在安装hdfs-client
- service: mammut
  componentList:
    - component: executor
      hostList: ["qadnode4.local"]
    - component: webserver
      hostList: ["qadnode4.local"]

# 安装的机器需要有hdfs_client,hive_client,spark_client
- service: azkaban
  componentList:
    - component: exec
      hostList: ["qadnode2.local", "qadnode3.local"]
    - component: fc
      hostList: ["qadnode2.local", "qadnode3.local"]
    - component: web
      hostList: ["qadnode2.local", "qadnode3.local"]
    - component: lib
      hostList: ["qadnode2.local", "qadnode3.local"]

- service: easy_account
  version: 3.7.5.4
  componentList:
    - component: server
      hostList: ["qadnode4.local"]

- service: prometheus
  componentList:
    - component: server
      hostList: ["qadnode3.local"]

- service: easy_alert
  componentList:
    - component: server
      hostList: ["qadnode3.local"]

- service: easy_access
  componentList:
    - component: backend
      hostList: ["qadnode3.local"]
    - component: frontend
      hostList: ["qadnode3.local"]
    - component: client
      hostList: ["qadnode2.local", "qadnode3.local"]

#  1）hbase配置 登录一个安装了hbase client的机器（使用hbase 1.2.6 版本）
#  2）es相关 确认下metahub使用的索引是否存在，例如
- service: easy_metahub
  componentList:
    - component: backend
      hostList: ["qadnode4.local"]

- service: easy_transfer
  componentList:
    - component: backend
      hostList: ["qadnode4.local"]
    - component: frontend
      hostList: ["qadnode4.local"]
    - component: client
      # 所有机器都安装client
      hostList: ["qadnode2.local", "qadnode3.local"]

- service: easy_dmap
  componentList:
    - component: backend
      hostList: ["qadnode4.local"]
    - component: frontend
      hostList: ["qadnode4.local"]

- service: easy_design
  componentList:
    - component: backend
      hostList: ["qadnode3.local"]
    - component: frontend
      hostList: ["qadnode3.local"]

- service: easy_coop
  version: 1.2.2.5.1
  componentList:
    - component: backend
      hostList: ["qadnode3.local"]
    - component: frontend
      hostList: ["qadnode3.local"]

- service: easy_index
  componentList:
    - component: backend
      hostList: ["qadnode3.local"]
    - component: frontend
      hostList: ["qadnode3.local"]

- service: easy_tag
  componentList:
    - component: backend
      hostList: ["qadnode4.local"]
    - component: frontend
      hostList: ["qadnode4.local"]

- service: easy_taskops
  componentList:
    - component: backend
      hostList: ["qadnode4.local"]
    - component: frontend
      hostList: ["qadnode4.local"]

- service: easy_dqc
  componentList:
    - component: backend
      hostList: ["qadnode4.local"]
    - component: frontend
      hostList: ["qadnode4.local"]
    - component: client
      # 所有机器都安装client
      hostList: ["qadnode2.local", "qadnode3.local"]

- service: easy_test
  componentList:
    - component: backend
      hostList: ["qadnode4.local"]
    - component: frontend
      hostList: ["qadnode4.local"]
    - component: client
      hostList: ["qadnode2.local", "qadnode3.local"]

- service: easy_qa
  componentList:
    - component: backend
      hostList: ["qadnode3.local"]
    - component: frontend
      hostList: ["qadnode3.local"]

- service: easy_aac
  componentList:
    - component: server
      hostList: ["qadnode3.local"]

- service: easy_ddl
  componentList:
    - component: server
      hostList: ["qadnode3.local"]

- service: easy_dataservice
  componentList:
    - component: backend
      hostList: ["qadnode3.local"]
    - component: frontend
      hostList: ["qadnode3.local"]
    - component: server
      hostList: ["qadnode3.local"]
    - component: monitor
      hostList: ["qadnode3.local"]
    - component: orcserver
      hostList: ["qadnode3.local"]
- service: kong
  componentList:
    - component: cassandra
      hostList: ["qadnode3.local","qadnode2.local"]
    - component: kong
      hostList: ["qadnode3.local","qadnode2.local"]
    - component: konga
      hostList: ["qadnode2.local"]

- service: easy_console
  componentList:
    - component: backend
      hostList: ["qadnode2.local"]
    - component: frontend
      hostList: ["qadnode2.local"]

- service: easy_webmaster
  componentList:
    - component: frontend
      hostList: ["qadnode2.local"]

- service: easy_standard
  componentList:
    - component: backend
      hostList: ["qadnode2.local"]
    - component: frontend
      hostList: ["qadnode2.local"]

- service: easy_metaweb
  componentList:
    - component: frontend
      hostList: ["qadnode2.local"]

- service: easy_openapi
  componentList:
    - component: backend
      hostList: ["qadnode2.local"]

- service: easy_flow
  componentList:
    - component: backend
      hostList: ["qadnode4.local"]
    - component: frontend
      hostList: ["qadnode4.local"]
    - component: engine
      hostList: ["qadnode4.local"]

- service: easy_static
  componentList:
    - component: frontend
      hostList: ["qadnode4.local"]
      
- service: easy_submit
  componentList:
    - component: backend
      hostList: ["qadnode4.local"]
    - component: frontend
      hostList: ["qadnode4.local"]
      
- service: easy_udf
  componentList:
    - component: backend
      hostList: ["qadnode4.local"]
    - component: frontend
      hostList: ["qadnode4.local"]

- id: ne-flink-1.10.0
  name: ne-flink-1.10.0
  service: flink
  version: ne-flink-1.10.0-1.1.8-scala-2.12
  componentList:
    - component: client
      hostList: ["qadnode2.local"]
- id: ne-flink-1.12.4
  name: ne-flink-1.12.4
  service: flink
  version: ne-flink-1.12.4-1.1.7.1-scala-2.12
  componentList:
    - component: client
      hostList: ["qadnode2.local"]
- id: ne-flink-1.13.3
  name: ne-flink-1.13.3
  service: flink
  version: ne-flink-1.13.3-1.0.1-scala-2.11
  componentList:
    - component: client
      hostList: ["qadnode2.local"]
- id: ne-flink-1.14.0
  name: ne-flink-1.14.0
  service: flink
  version: ne-flink-1.14.0-1.0.4-scala-2.12
  componentList:
    - component: client
      hostList: ["qadnode2.local"]
      
- id: plugin_cdc_ne-flink-1.13.3
  name: plugin_cdc_ne-flink-1.13.3
  service: flink_plugin
  version: cdc_ne-flink-1.13.3-1.0.1_scala2.11-release-3.9.4-2.1.7
  componentList:
    - component: client
      hostList: ["qadnode2.local"]

- id: plugin_ne-flink-1.10.0
  name: plugin_ne-flink-1.10.0
  service: flink_plugin
  version: ne-flink-1.10.0-1.1.8_scala2.12_hive2.1.1-release-3.9.4-1.4.5
  componentList:
    - component: client
      hostList: ["qadnode2.local"]

- id: plugin_ne-flink-1.12.4
  name: plugin_ne-flink-1.12.4
  service: flink_plugin
  version: ne-flink-1.12.4-1.1.7.1_scala2.12_hive2.1.1-release-3.9.4-1.4.5
  componentList:
    - component: client
      hostList: ["qadnode2.local"]

- id: plugin_ne-flink-1.14.0
  name: plugin_ne-flink-1.14.0
  service: flink_plugin
  version: ne-flink-1.14.0-1.0.4_scala2.12_hive2.1.1-release-3.9.4-1.4.5.2
  componentList:
    - component: client
      hostList: ["qadnode2.local"]

- id: ndi_ne-flink-1.13.3
  name: ndi_ne-flink-1.13.3
  service: flink_plugin
  version: ndi_ne-flink-1.13.3-1.0.1_scala2.11-release-3.0.0-1.0.0
  componentList:
    - component: client
      hostList: ["qadnode2.local"]

- service: sloth
  componentList:
    - component: server
      hostList: ["qadnode2.local"]
    - component: develop_web
      hostList: ["qadnode2.local"]
  dependenceList:
    - ne-flink-1.10.0
    - ne-flink-1.12.4
    - ne-flink-1.13.3
    - ne-flink-1.14.0     
    - plugin_cdc_ne-flink-1.13.3
    - plugin_ne-flink-1.10.0
    - plugin_ne-flink-1.12.4
    - plugin_ne-flink-1.14.0
    - ndi_ne-flink-1.13.3

- service: realtime_submitter
  componentList:
    - component: submitter
      hostList: ["qadnode2.local"]
  dependenceList:
    - ne-flink-1.10.0
    - ne-flink-1.12.4
    - ne-flink-1.13.3
    - ne-flink-1.14.0     
    - plugin_cdc_ne-flink-1.13.3
    - plugin_ne-flink-1.10.0
    - plugin_ne-flink-1.12.4
    - plugin_ne-flink-1.14.0
    - ndi_ne-flink-1.13.3

- service: realtime_debugger
  componentList:
    - component: plugin_server
      hostList: ["qadnode2.local"]
  dependenceList:
    - ne-flink-1.10.0
    - ne-flink-1.12.4
    - ne-flink-1.13.3
    - ne-flink-1.14.0     
    - plugin_cdc_ne-flink-1.13.3
    - plugin_ne-flink-1.10.0
    - plugin_ne-flink-1.12.4
    - plugin_ne-flink-1.14.0
    - ndi_ne-flink-1.13.3

- service: realtime_ops
  componentList:
    - component: ops
      hostList: ["qadnode2.local"]
    - component: web
      hostList: ["qadnode2.local"]
      
- service: realtime_monitor
  componentList:
    - component: monitor
      hostList: ["qadnode2.local"]


- service: realtime_portal
  componentList:
    - component: portal
      hostList: ["qadnode2.local"]
