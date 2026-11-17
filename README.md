# Assignment 8 — Terraform AWS Deployment (Krishna)

**Repository:** https://github.com/krishnaChandak044/tutedude-assignment-8-terraform

## Included

The package implements three Terraform root modules in `terraform/`: single EC2 (Flask + Express), split EC2 in a VPC/subnet with security groups, and ECR/ECS Fargate with VPC, ALB and `/api/*` routing. Each root has `main.tf`, `variables.tf`, `outputs.tf`, an S3 backend block, and `terraform.tfvars.example`. `app/` holds both services and Dockerfiles.

## Validation and live status
All three Terraform roots passed `terraform validate` in Assignment 8, and the corresponding Assignment 6 Terraform roots also passed validation. No `terraform plan/apply` or live AWS resources were created. AWS CloudShell is blocked while account verification is in progress; local AWS CLI credentials are not configured. The account dashboard shows $100 credits; EC2, Fargate, ALB, public IPv4, CloudWatch and storage can consume credits or incur costs.

## Deployment sequence

1. Install/configure Terraform and AWS CLI access with least privilege. Set `region=ap-southeast-2`, real AMI/key-pair/SSH CIDR where required, and create a private, versioned, encrypted S3 state bucket.
2. In each root module, copy the example tfvars and initialize the S3 backend using the flags shown in `terraform/README.md`.
3. Run `terraform validate`, inspect `terraform plan`, and only apply after reviewing cost estimates.
4. For ECS, keep `deploy_services=false` for the initial apply, push the two app images to the created ECR repositories with `terraform/ecs/push-ecr-images.sh`, then set `deploy_services=true` and apply again.
5. Record outputs and deployment evidence. Run `terraform destroy` in each root after capturing evidence; remove retained ECR images/state buckets only if no longer needed.

The package does not claim a deployed AWS URL or a successful plan/apply.
