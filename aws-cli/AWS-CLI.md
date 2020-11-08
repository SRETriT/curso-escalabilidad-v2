# AWS CLI

Created: Nov 7, 2020 2:19 PM
Tags: Training

How-to set up a basic configuration for aws-cli to ease basic operations for training courses

Have a decent shell is a MUST 🤣
**Linux, MacOS** → Bash, ZSH
**Windows →** WLS → Bash, ZSH

## Install AWSCLI

[Installing, updating, and uninstalling the AWS CLI version 2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

Rule of thumb:

- If you can install local software, install it locally
- If you can't and have docker, go for docker

Trick for docker installations → Make an alias for the docker run command
alias awsdocker=`docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli`

## Configure AWSCLI

Log in the AWS console and go to "My Security Credentials" section and create a Acces Key. You can download the configuration as a CSV file (this file should be stored securely).

![img/Screen_Shot_2020-11-07_at_14.31.14.png](img/Screen_Shot_2020-11-07_at_14.31.14.png)

![img/Screen_Shot_2020-11-07_at_14.33.29.png](img/Screen_Shot_2020-11-07_at_14.33.29.png)

AWSCLI works with profiles, to use different configurations, to avoid clashing with other configurations this manual will create a profile called `sre`

```bash
$ aws configure --profile sre
AWS Access Key ID [None]: # Access Key ID
AWS Secret Access Key [None] # Access Secret Key
Default region name [None]: eu-west-3
Default output format [None]: json
```

## Handling Key Pairs

We need a Key-Pair to access any EC2 instance. To create one

```bash
$ aws ec2 create-key-pair --profile sre --key-name sre-kp
{
    "KeyFingerprint": "62:65:83:13:d9:2b:bc:47:49:a9:dd:98:38:d5:bc:38:38:6a:9f:fc",
    "KeyMaterial": "-----BEGIN RSA PRIVATE KEY-----\nMIIEow...vu/93cvy0lYG3g\n-----END RSA PRIVATE KEY-----",
    "KeyName": "sre",
    "KeyPairId": "key-00e5efc6ae267d763"
}

# To create directly a PEM file
$ aws ec2 create-key-pair --profile sre \
  --key-name sre-kp \
  --query "KeyMaterial" \
  --output text > sre-kp.pem

# Even a KeyPair has no cost, to delete it
$ aws ec2 delete-key-pair --profile sre --key-name sre-kp
```

## Launching EC2 instances

First we need to find the base image to launch, to find by name:

```bash
$ aws ec2 describe-images --profile sre \
  --filters "Name=name,Values=pinchito*" \
  --query "Images[*].[Name,ImageId]"
[
    [
        "pinchito-loadtest-2020-11-07",
        "ami-0b1caa1a26cd41f9d"
    ],
    [
        "pinchito-loadtest-2020-11-06",
        "ami-0f845d0a891816ce6"
    ]
]
```

With that ID to launch an instance:

```bash
# Instance types: t2.small t2.micro t3.micro t3.small ...
# Keep the InstaceId to delete the instance after use :)
$ aws ec2 run-instances --profile sre \
  --image-id ami-0b1caa1a26cd41f9d \
  --count 1 \
  --instance-type t3.micro \
  --key-name sre-kp \
  --query "Instances[*].[InstanceId]"
[
    [
        "i-029f38af0b66790b4"
    ]
]
```

To delete an instance

```bash
$ aws ec2 terminate-instances --profile sre \
  --instance-ids i-013b7622be52e823f
```

To check if we have any instance running

```bash
# Watch out any non terminaed instance
$ aws ec2 describe-instances --profile sre \
  --query "Reservations[].Instances[].[InstanceId,State.Name]"
[
    [
        "i-029f38af0b66790b4",
        "terminated"
    ],
    [
        "i-013b7622be52e823f",
        "terminated"
    ],
    [
        "i-00ba20a1ecc0fd606",
        "terminated"
    ]
]
```
