# Deploying Node to AWS with Terraform

# Overview

Docker is utilized to run a Terraform build container. The container mounts a local plan and temporary folders to share Terraform state and SSH Keys. The entry point initializes terraform. The `deploy` make command will use the build container to apply the terraform plan. The plan creates a typical VPC, with internet gateway, a route table, private and public subnets, security group allowing HTTP Port 80 traffic to the client IP, and IAM role with access to S3. The Node.JS server source code is uploaded to a private S3 bucket. When the EC2 instance is created, user data copies the Node JS source from S3, and installs the server as a service. During the EC2 instantiation, The user data script may take 30-60 seconds to install dependencies. Terraform will print the public IP address of the Node server when the plan is complete. Visit that url when the user data script finishes to view the response json.

# Prerequisites

- Debian based system (Ubuntu) recommended
- Make
- Docker

# Setup

Run `sudo make generate_key` to generate RSA Keys.

Create an AWS User with Programmatic access having an AdministratorAccess policy in the AWS Console. Specify the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in a `default.env` file at the folder root

```bash
echo "AWS_ACCESS_KEY_ID=YourAccessKey" > ./default.env
echo "AWS_SECRET_ACCESS_KEY=XXX" >> ./default.env
```

In a production environment, you will want to use [AWS Security Token Service's AssumeRole functionality](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html) to temporarily get credentials to different environments.

Example default.env:

```
AWS_ACCESS_KEY_ID=XXX
AWS_SECRET_ACCESS_KEY=XXX
```

## Setup for Debian Environment

Install Docker: 

```bash
apt-get update && apt install docker.io -y
```

# Testing

Run unit tests with `make test`

# Deployment

Run `sudo make deploy` to deploy AWS components. When the deployment is complete, you should be able to visit the address displayed in the `NodeServerAddress` output variable. It may take 30-60 seconds or more for the server to prepare.

# Cleanup

Run `sudo make teardown` to uninstall the deployment.

# Next Steps

Instead of relying on User Data for EC2 initialization, an [Ansible playbook](https://www.ansible.com/overview/how-ansible-works) can be used to remotely deploy the software.
