# 00 - Getting Started


- [00 - Getting Started](#00---getting-started)
    - [Azure Cloud Shellを立ち上げる](#azure-cloud-shellを立ち上げる)
    - [Azureサブスクリプションの選択（複数ある場合のみ）](#azureサブスクリプションの選択複数ある場合のみ)
    - [Azureリソースプロバイダの登録](#azureリソースプロバイダの登録)


## Azure Cloud Shellを立ち上げる

このハンズオンラボでは[Azure Cloud Shell (Bashモード)](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)を使用して進めます。よって、まず最初にAzure Cloud ShellをBashモードで立ち上げてください

![](../../assets/cloud-shell-open-bash.png)

>[NOTE]: https://shell.azure.com/ にアクセスすることでフルスクリーンのAzure Cloud Shellを使うことができます

もしAzure Cloud Shellへのアクセスが初めての場合は、次のようなデータ永続化のためのAzure Fileの設定のためのプロンプトが表示されます

![](../../assets/cloud-shell-welcome.png)

"Bash (Linux)"オプションをクリックして、Azureサブスクリプションを選択して、"Create Storage"をクリックします

![](../../assets/cloud-shell-no-storage-mounted.png)

数秒後にストレージアカウントが作成されます。これでAzure Cloud Shellを使う準備が整いました。

## Azureサブスクリプションの選択（複数ある場合のみ）

次のコマンドを実行してAzureサブスクリプション一覧を表示します

```
az account list -o table
```
> Output
```
Name                             CloudName    SubscriptionId                        State    IsDefault
-------------------------------  -----------  ------------------------------------  -------  -----------
Visual Studio Premium with MSDN  AzureCloud   xxxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx  Enabled  True
Another sub1                     AzureCloud   xxxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx  Enabled  False
Another sub2                     AzureCloud   xxxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx  Enabled  False
Another sub3                     AzureCloud   xxxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx  Enabled  False
```

もし、複数のサブスクリプションを持っている場合は、次のように利用したいサブスクリプション名をデフォルトに設定ください

```
az account set -s 'Visual Studio Premium with MSDN'
```

## Azureリソースプロバイダの登録

このハンズオンラボではAzureのNetwork, Storage, Compute と ContainerSerivcesのリソースを管理しますが、もしお使いのサブスクリプションにおいてこれらリソース管理が初めての場合は次のコマンドを実行してリソースプロバイダーを登録ください

```sh
az provider register -n Microsoft.Network
az provider register -n Microsoft.Storage
az provider register -n Microsoft.Compute
az provider register -n Microsoft.ContainerService
```

---
[Top](../../README.md) | [Next](../01-setup-terraform/README.md)