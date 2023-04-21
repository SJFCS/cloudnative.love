https://sentinelguard.io/zh-cn/


OpenTelemetry Operator: 这是一个用于部署OpenTelemetry Collector的Operator，可以自动注入Java agent。您可以参考它的代码实现，了解如何使用Operator来注入Java agent。

https://github.com/Contrast-Security-OSS/agent-operator

https://github.com/electronicarts/ea-agent-loader

Jaeger Operator: 这是一个用于部署Jaeger的Operator，也可以自动注入Java agent。您可以参考它的代码实现，了解如何使用Operator来注入Java agent。


Fabric8 Maven Plugin: 这是一个Maven插件，可以帮助您在构建应用程序时自动注入Java agent。它不是Operator，但您可以参考它的代码实现，了解如何注入Java agent。

Prometheus JMX Exporter Operator：这是一个用于将Java应用程序的JMX指标发送到Prometheus的Operator。它使用Java Agent来暴露JMX指标，并将其发送到Prometheus。



## 通过k8s operator 实现通过pod注释注入java agent  的开源项目或者示例代码


以下是一个示例代码，用于在Pod创建时注入Java Agent：
```go
func (r *MyControllerReconciler) Reconcile(req ctrl.Request) (ctrl.Result, error) {
    // Fetch the Pod instance
    pod := &corev1.Pod{}
    err := r.Client.Get(context.TODO(), req.NamespacedName, pod)
    if err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // Check if the Pod has a specific annotation
    if _, ok := pod.ObjectMeta.Annotations["mycompany.com/java-agent"]; !ok {
        // Add the Java Agent to the Pod's annotations
        pod.ObjectMeta.Annotations["mycompany.com/java-agent"] = "/path/to/java/agent.jar"
        if err := r.Client.Update(context.TODO(), pod); err != nil {
            return ctrl.Result{}, err
        }
    }

    return ctrl.Result{}, nil
}
```
在上面的代码中，我们检查Pod是否具有mycompany.com/java-agent注释。如果没有，我们将注释添加到Pod的注释中，并将Java Agent的路径设置为注释值。然后，我们使用Kubernetes API更新Pod对象，以便注入Java Agent。

最后，你需要使用Docker构建一个包含Java Agent的镜像，并在Pod中使用该镜像。在Pod启动时，Kubernetes将使用控制器注释中指定的Java Agent路径启动Java应用程序。


## 以下是一个使用Java Agent在Pod下线时从Nacos服务发现中删除实例的示例：

首先，你需要编写一个Java Agent，该代理将在Java应用程序启动时自动注入并在应用程序关闭时执行某些操作。在这种情况下，我们希望在Java应用程序关闭时从Nacos服务发现中删除实例。
以下是一个示例Java Agent代码：

```java
import java.lang.instrument.Instrumentation;
import java.net.InetAddress;
import java.net.UnknownHostException;

public class NacosAgent {
    public static void premain(String args, Instrumentation inst) {
        // Get the instance's metadata from system properties
        String serviceName = System.getProperty("nacos.service.name");
        String groupName = System.getProperty("nacos.service.group", "DEFAULT_GROUP");
        String clusterName = System.getProperty("nacos.service.cluster", "DEFAULT");
        String ip = System.getProperty("nacos.instance.ip", getLocalIpAddress());
        int port = Integer.parseInt(System.getProperty("nacos.instance.port"));

        // Create a NacosDiscoveryClient instance
        NacosDiscoveryClient client = NacosDiscoveryClient.getInstance();

        // Register the instance with Nacos
        client.registerInstance(serviceName, groupName, clusterName, ip, port);

        // Add a shutdown hook to remove the instance from Nacos
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            try {
                // Remove the instance from Nacos
                client.deregisterInstance(serviceName, groupName, clusterName, ip, port);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }));
    }

    /**
     * Get the IP address of the local host.
     */
    private static String getLocalIpAddress() {
        try {
            return InetAddress.getLocalHost().getHostAddress();
        } catch (UnknownHostException e) {
            throw new RuntimeException("Failed to get local IP address", e);
        }
    }
}
```
在上面的代码中，我们使用系统属性来获取实例的元数据信息，例如服务名、组名、集群名、IP地址和端口。如果未设置组名或集群名，则使用默认值。然后，我们使用这些元数据信息注册实例并在应用程序关闭时从Nacos服务发现中删除实例。


## 直接使用operator 可否实现无侵入式的优雅下线
使用Operator可以实现无侵入式的优雅下线，它可以监视Kubernetes集群中的Pod，并在Pod下线时进行一些操作。

首先，你需要编写一个Operator，该Operator将监视Kubernetes集群中的Pod，并在Pod下线时执行一些操作。在这种情况下，我们希望在Pod关闭之前从Nacos服务发现中删除实例。
```go
public class NacosOperator extends AbstractOperator<Deployment> {

    private static final Logger log = LoggerFactory.getLogger(NacosOperator.class);

    private final NacosDiscoveryClient client;

    public NacosOperator(KubernetesClient kubernetesClient, NacosDiscoveryClient client) {
        super(kubernetesClient);
        this.client = client;
    }

    @Override
    protected boolean handleEvent(Watcher.Action action, Deployment deployment) {
        if (action == Watcher.Action.DELETED) {
            // Get the instance's IP address and port from metadata
            String ipAddress = deployment.getMetadata().getAnnotations().get("instance.ip");
            int port = Integer.parseInt(deployment.getMetadata().getAnnotations().get("instance.port"));

            // Remove the instance from Nacos
            try {
                client.deregisterInstance(ipAddress, port);
            } catch (Exception e) {
                log.error("Failed to deregister instance from Nacos", e);
            }
        }

        return true;
    }
}
```
在上面的代码中，我们使用Kubernetes Operator的抽象类AbstractOperator来实现Kubernetes集群中Deployment的监视。在handleEvent方法中，我们在Deployment被删除时从Nacos服务发现中删除实例。

