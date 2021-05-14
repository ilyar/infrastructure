# Infrastructure

## Auth

```shell
gcloud config configurations create acme
gcloud config set project acme-123456
gcloud config set compute/region europe-west3
gcloud config set compute/zone europe-west3-a
gcloud auth login
gcloud info --run-diagnostics
```

## Get credentials K8s

```shell
gcloud container clusters get-credentials stage
kubectl config rename-context $(kubectl config current-context) ACMEStage
```

## Use K8s

```shell
kubectl --context ACMEStage get no
kubectl --context ACMEStage get namespaces
kubectl --context ACMEStage get -A svc
kubectl --context ACMEStage get -A po
```

### Sample

#### Echo service

```shell
kubectl --context ACMEStage apply -f sample/stage/echo.yaml
kubectl --context ACMEStage -n echo get all
open https://echo.stage.acme.com/
kubectl --context ACMEStage delete -f sample/stage/echo.yaml
```

## Note init

```shell
cd env/stage
terraform login
terraform init
terraform plan -out plan.local
terraform apply plan.local
terraform show
terraform destroy
```

## Links

- https://app.terraform.io/app/acme/workspaces
