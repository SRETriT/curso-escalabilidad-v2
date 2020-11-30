# Terraform code


This terraform code creates the following components:

- vpc for the turnomatic application.
- 3 public subnets and 3 private subnets.
- An Autoscaling group (ASG) and a launch configuration
- A network load balancer connected to the ASG.


By default it uses the AMI with the tag Name  "turnomatic-ami" and that the ami 
follows this regex "^sre-turnomatic-ami-.*". It only searches on the same
account it is running to avoid using a public image (check the [../ami](../ami/README.md) folder to see how to build it)

