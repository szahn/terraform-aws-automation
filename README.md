# miniproject-ZAHN-STUART

# Prerequisites

- Debian based system (Ubuntu) recommended
- Make
- Docker

# First Time Setup

Run `make generate_key` to generate RSA Keys.

Create an AWS User with Full Admin Access role having Programmatic Access in the AWS Console.
Specify the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in a `default.env` file at the folder root

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

# How to Deploy

Run `make deploy` to deploy AWS components. When the deployment is complete, you should be able to visit the address displayed in the `NodeServerAddress` output variable. It may take 30-60 seconds or more for the server to prepare.

# How to Remove

Run `make teardown` to uninstall deployment.
