# 1. Setup Terraform


- [Setup Terraform](#setup-terraform)
    - [Terraform インストール (Optional)](#terraform-インストール-optional)
    - [Service Principalの作成](#service-principalの作成)
    - [Terraformの環境変数の設定](#terraformの環境変数の設定)
    - [サンプルスクリプトの実行](#サンプルスクリプトの実行)

## 1.1. Terraform インストール (Optional)

Azure Cloud ShellにはデフォルトでTerraformがインストールされているのでTerraformをインストールする必要はありません。

もしご自分の環境で作業を行う場合は[こちら](https://www.terraform.io/downloads.html)よりご自分のOS環境にあったパッケージをダウンロードいただきTerraformをインストールしてください。

Terraformがインストールできたら次のようにterraformコマンドを実行して、Terraformのオプションが表示されることをご確認ください。
```
terraform
```
>出力結果
```
Usage: terraform [-version] [-help] <command> [args]

The available commands for execution are listed below.
The most common, useful commands are shown first, followed by
less common or more advanced commands. If you're just getting
started with Terraform, stick with the common commands. For the
other commands, please read the help and docs before usage.

Common commands:
    apply              Builds or changes infrastructure
    console            Interactive console for Terraform interpolations
    destroy            Destroy Terraform-managed infrastructure
    env                Workspace management
    fmt                Rewrites config files to canonical format
    get                Download and install modules for the configuration
    graph              Create a visual graph of Terraform resources
    import             Import existing infrastructure into Terraform
    init               Initialize a Terraform working directory
    output             Read an output from a state file
    plan               Generate and show an execution plan
    providers          Prints a tree of the providers used in the configuration
    push               Upload this Terraform module to Atlas to run
    refresh            Update local state file against real resources
    show               Inspect Terraform state or plan
    taint              Manually mark a resource for recreation
    untaint            Manually unmark a resource as tainted
    validate           Validates the Terraform files
    version            Prints the Terraform version
    workspace          Workspace management

All other commands:
    0.12checklist      Checks whether the configuration is ready for Terraform v0.12
    debug              Debug output management (experimental)
    force-unlock       Manually unlock the terraform state
    state              Advanced state management
```

## 1.2. Service Principalの作成

TerraformでAzureリソースをAzureにプロビジョンするためには、Azure AD Service Principal (以下 Service Principal)を作成する必要があります。Servide PrincipalによってTerraformスクリプトでご自分のサブスクリプション下にAzureリソースをプロビジョンすることができるようになります（権限が付与されます）。

まずは次のコマンドでご自分のサブスクリプションIDとTENANT IDを取得してください。
```bash
az account show --query "{subscriptionId:id, tenantId:tenantId}"
```

> 出力結果
```json
{
  "subscriptionId": "97c7c7f9-0c9f-47d1-a856-1305a0cbfd7a",
  "tenantId": "72f988bf-86f1-41af-91ab-2d7cd011db47"
}
```

続いて、次のコマンドでService Principalを作成してください。
[az ad sp create-for-rbac](https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create-for-rbac)を使ってスコープを自分のサブスクリプションに限定するようにします。`SUBSCRIPTION_ID`には上記で取得したサブスクリプションIDを指定ください。

```bash
SUBSCRIPTION_ID="97c7c7f9-0c9f-47d1-a856-1305a0cbfd7a"

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"
```

>出力結果

```
{
  "appId": "5907b285-3ac6-4156-8145-54b14da5d58c",
  "displayName": "azure-cli-2019-06-04-23-03-30",
  "name": "http://azure-cli-2019-06-04-23-03-30",
  "password": "e7d9bf9c-36bc-4141-b030-3afcefc43ebb",
  "tenant": "72f988bf-86f1-41af-91ab-2d7cd011db47"
}
```

上記出力結果の中で、`appId`と`password`はこの後の作業で必要になります。

## 1.3. Terraformの環境変数の設定

次のような環境情報設定用ファイル(`setenv.sh`)を作成して、`ARM_SUBSCRIPTION_ID`、`ARM_CLIENT_ID`、`ARM_CLIENT_SECRET`、`ARM_TENANT_ID`にそれぞれサブスクリプションID、Service Principal ID (上記のappId)、Service Principalパスワード (上記のpassword)、テナントIDを指定ください。

> `setenv.sh`
```bash
echo "Setting environment variables for Terraform"
export ARM_SUBSCRIPTION_ID="your_subscription_id"
export ARM_CLIENT_ID="your_appId"
export ARM_CLIENT_SECRET="your_password"
export ARM_TENANT_ID="your_tenant_id"

# Not needed for public, required for usgovernment, german, china
export ARM_ENVIRONMENT="public"
```

次のように`source`コマンドでsetenv.shを実行して、現在のshellプロセスに上記変数を読み込んでください。

```bash
source ./setenv.sh
```

## 1.4. サンプルスクリプトの実行

テスト実行ディレクトリを作成してそのディレクトリに移動してください
```sh
mkdir lab01
cd lab01
```

次のような内容の`test.tf`ファイルを作成してください。Azureリソースグループを作成するために`name`と`location`でそれぞれリソースグループ名と作成先リージョンを指定しています。
```
provider "azurerm" {
}
resource "azurerm_resource_group" "test" {
        name = "tflab_01"
        location = "japaneast"
}
```
次のコマンドでTerraformによるデプロイメントを初期化します。
```bash
terraform init
```
> 出力結果
```
Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "azurerm" (1.29.0)...

...
途中省略
...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

`terrafrom init`による初期化で`.terraform`ディレクトリが作成されたことが確認できます。リソース作成に必要なAzureのプラグインがインストールされているはずです。

```bash
$ find . 
.
./.terraform
./.terraform/plugins
./.terraform/plugins/linux_amd64
./.terraform/plugins/linux_amd64/lock.json
./.terraform/plugins/linux_amd64/terraform-provider-azurerm_v1.29.0_x4
./test.tf
```

続いて、`terraform plan`コマンドでデプロイメントの実行計画を作成します。

```bash
terraform plan
```

> 出力結果

```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.
------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + azurerm_resource_group.test
      id:       <computed>
      location: "japaneast"
      name:     "tflab_01"
      tags.%:   <computed>


Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------
Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```
上記出力結果から、リソースが１つ`add`され、`change`や`destory`は0であることがわかります。

次に、`terraform apply`で作成された実行計画を元にデプロイメントを実行します。途中でアクションを実行するかどうかを聞かれるので、実行する場合は`yes`と入力ください。

```bash
terraform apply
```

> 出力結果
```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + azurerm_resource_group.test
      id:       <computed>
      location: "japaneast"
      name:     "tflab_01"
      tags.%:   <computed>


Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.test: Creating...
  location: "" => "japaneast"
  name:     "" => "tflab_01"
  tags.%:   "" => "<computed>"
azurerm_resource_group.test: Creation complete after 3s (ID: /subscriptions/87c7c7f9-0c9f-47d1-a856-1305a0cbfd7a/resourceGroups/tflab_01)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

実際にリソースグループが作成されたかどうかを確認してください。下記のようにazコマンドで確認するか、もしくはAzureポータルからご確認ください。

```bash
az group list -o table |grep tflab_01
```
> 出力結果
```
tflab_01                                           japaneast       Succeeded
```

同一ディレクトリには`terraform.tfstate`という名前の状態管理ファイルが作成されています。これはTerraformで管理しているインフラの状態を管理しています。

```json
cat terraform.tfstate
{
    "version": 3,
    "terraform_version": "0.11.14",
    "serial": 1,
    "lineage": "33f66b08-63c9-3575-8691-c95224977898",
    "modules": [
        {
            "path": [
                "root"
            ],
            "outputs": {},
            "resources": {
                "azurerm_resource_group.test": {
                    "type": "azurerm_resource_group",
                    "depends_on": [],
                    "primary": {
                        "id": "/subscriptions/87c7c7f9-0c9f-47d1-a856-1305a0cbfd7a/resourceGroups/tflab_01",
                        "attributes": {
                            "id": "/subscriptions/87c7c7f9-0c9f-47d1-a856-1305a0cbfd7a/resourceGroups/tflab_01",
                            "location": "japaneast",
                            "name": "tflab_01",
                            "tags.%": "0"
                        },
                        "meta": {},
                        "tainted": false
                    },
                    "deposed": [],
                    "provider": "provider.azurerm"
                }
            },
            "depends_on": []
        }
    ]
}
```

> [NOTE]
> ちなみにこの実行計画は `-out`オプションでファイルをに保存することができます。保存した実行計画は次の`terraform apply`で明示的に指定して実行することが可能です。以下明示的に実行計画をファイル(`out.plan`)に保存して、実行時に実行計画ファイルを指定するやり方になります。
> ```
> terraform plan -out out.plan
> terraform apply ./out.plan
> ```

最後に`terraform destroy`で作成されたリソースを削除してください。apply時と同様に途中でアクションを実行するかどうかを聞かれるので、実行する場合は`yes`と入力ください。

```bash
terraform destroy
```

> 出力結果
```
Terraform will perform the following actions:

  - azurerm_resource_group.test


Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

azurerm_resource_group.test: Destroying... (ID: /subscriptions/87c7c7f9-0c9f-47d1-a856-1305a0cbfd7a/resourceGroups/tflab_01)
azurerm_resource_group.test: Still destroying... (ID: /subscriptions/87c7c7f9-0c9f-47d1-a856-1305a0cbfd7a/resourceGroups/tflab_01, 10s elapsed)
azurerm_resource_group.test: Still destroying... (ID: /subscriptions/87c7c7f9-0c9f-47d1-a856-1305a0cbfd7a/resourceGroups/tflab_01, 20s elapsed)
azurerm_resource_group.test: Still destroying... (ID: /subscriptions/87c7c7f9-0c9f-47d1-a856-1305a0cbfd7a/resourceGroups/tflab_01, 30s elapsed)
azurerm_resource_group.test: Still destroying... (ID: /subscriptions/87c7c7f9-0c9f-47d1-a856-1305a0cbfd7a/resourceGroups/tflab_01, 40s elapsed)
azurerm_resource_group.test: Still destroying... (ID: /subscriptions/87c7c7f9-0c9f-47d1-a856-1305a0cbfd7a/resourceGroups/tflab_01, 50s elapsed)
azurerm_resource_group.test: Destruction complete after 51s
```

---
[Top](../../README.md) | [Back](../00-gettingstarted/README.md) | [Next](../02-azure-vm-vnet/README.md)