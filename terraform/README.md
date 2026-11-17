# Terraform module guide

Each directory is a separate root module and uses an S3 backend configured at `init` time. Copy `terraform.tfvars.example` to a private `terraform.tfvars` and replace the placeholders. Never commit secrets or real credentials.

## State backend
Create a private S3 bucket in the same region with versioning and server-side encryption enabled, then initialize with:

```sh
terraform init -backend-config="bucket=YOUR_UNIQUE_STATE_BUCKET" \
  -backend-config="key=tutedude/ASSIGNMENT/MODE/terraform.tfstate" \
  -backend-config="region=ap-southeast-2" \
  -backend-config="encrypt=true" -backend-config="use_lockfile=true"
```

## Run a module

```sh
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

Review the plan before apply. Destroy resources when the assignment evidence is captured with `terraform destroy`; ALBs, EC2, Fargate, public IPv4 addresses, logs, ECR storage and state storage can incur charges. The EC2 configurations use existing public Docker Hub images. The ECS module creates ECR repos; build and push both app images before enabling service tasks. See `push-ecr-images.sh` and the package README.
