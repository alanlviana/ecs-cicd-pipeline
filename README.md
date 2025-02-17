## ECS CI/CD Pipeline Example

This repository provides an automated way to deploy a docker application running as an ECS Service using Github actions and terraform.

# Features
- **AWS Authentication**: Uses OpenID Connect (OICD) for secure AWS Access.
- **Infraestructure as code**: Deploy AWS resources using Terraform.
- **Automated cleanup**: Supports automatic resource destruction via a configuration file.
- **Multi-Environment Deployment**: Uses git branches to manage different environments.

## Prerequisites
- AWS Account with IAM permissions for OICD Authentication.