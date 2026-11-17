# Assignment 8 — Terraform AWS Deployment (Krishna)

**Repository:** https://github.com/krishnaChandak044/tutedude-assignment-8-terraform

Includes variable-driven Terraform for three topologies: EC2 with Flask + Express on one host, a custom VPC/subnet with separated EC2 hosts, and ECR/ECS/VPC/ALB scaffolding. Both application source trees are in `app/`. Terraform resources are in `terraform/{single_ec2,separate_ec2,ecs}`.

## Validation and status
Terraform is not installed and no AWS CLI credentials are configured here. No `terraform plan/apply`, AWS deployment, ECR push, or ALB URL is claimed. The EC2 user-data scripts are safe bootstrap stubs that require app repository URLs and systemd unit setup. ECS task/service definitions require image URIs after publishing ECR images. Configure a remote S3 backend and lock table before shared use; S3 backend bucket must be created separately. Set real region/AMI/key/CIDR variables, run `terraform init` and inspect `terraform plan`; only then apply in an account with explicit budget controls. Stop/destroy resources afterward.
