网卡配置文件中 NM_CONTROLLED 默认为 yes，这意味着在系统中运行 NetworkManager 服务时，该服务会对具有启用 NM_CONTROLLED 选项的网络接口进行管理。这包括更改其 IP 地址、子网掩码、网关、DNS 服务器以及其他网络配置。

如果您要手动配置网络接口并使用静态配置文件，建议将 NM_CONTROLLED 设置为 no，以便手动配置将替代 NetworkManager 的自动配置。如果 NM_CONTROLLED 已经为 no，则您可以直接更改网络接口配置文件，这将不会被 NetworkManager 覆盖。

您可以使用 nmcli 或 NetworkManager 的配置文件对网络接口进行配置。NetworkManager 的配置文件通常位于 /etc/NetworkManager/system-connections 目录下，每个网络接口对应一个配置文件，配置文件名通常与网络接口名相同。您可以使用任何编辑器打开这些配置文件，以便对网络接口进行更改。




在云计算环境中，一些 Linux 发行版会使用云初始化 (cloud-init) 工具来自动配置云实例。在此过程中，如果 NetworkManager 服务运行，它可能会干扰云初始化的操作，导致云实例的网络连接失败。

因此，在某些情况下，云提供商可能会要求将 NetworkManager 禁用，以确保云初始化工具能够正确配置网络。云初始化通常会通过静态配置文件来配置网络接口，而不是使用 NetworkManager 的动态配置。

需要注意的是，并非所有云提供商都需要禁用 NetworkManager 服务。具体要求可能因云提供商和使用的 Linux 发行版而异。因此，在设置云实例时，应参考提供商的文档和建议。





云提供商通常会提供一些自动配置工具和脚本来确保云实例网络的正确连接和配置。这些工具和脚本通常会忽略 NetworkManager 并直接配置网络接口。

例如，Amazon Web Services (AWS) 提供了 ECS 镜像，其中包含 Docker 和 ECS Agent。这些镜像已经预配置为使用 Docker 的网络命名空间来管理网络接口，因此它们不需要 NetworkManager 来管理网络配置。

类似地，Google Cloud 和 Microsoft Azure 等云提供商也提供了自己的虚拟网络管理服务，这些服务具有自己的网络配置接口和工具，并忽略或禁用 NetworkManager 服务。因此，使用这些云提供商的用户通常不需要禁用 NetworkManager 来使网络配置生效。


Amazon Web Services (AWS)
AWS 的云计算服务 ECS （Elastic Container Service）使用 Docker 容器时，通常需要在实例启动时自动配置和管理网络接口。这通常通过启动一个名为 ecs-agent 的服务来实现，该服务使用自己的网络命名空间（network namespace）来管理网络接口，而不使用 NetworkManager。

Google Cloud
Google Cloud 使用自己的虚拟网络服务来管理云实例的网络配置。用户可以在 Google Cloud Console 中管理网络设置，或使用 Google Cloud SDK 中的 gcloud 命令行工具配置网络接口。这些工具和服务不依赖于 NetworkManager，因此用户无需禁用 NetworkManager。

Microsoft Azure
在 Microsoft Azure 中，网络接口的配置通常通过 Azure 网络接口（Network Interface）管理。Azure 网络接口提供了自己的命名空间和接口来配置网络接口。与 Google Cloud 一样，Azure 不需要 NetworkManager 来管理网络接口。