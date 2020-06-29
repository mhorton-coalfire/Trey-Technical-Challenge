# Terraform Technical Challenge

## Overview
Began the implementation by drawing out the scenario in Lucidchart.

![Image of Scenario implementation]
(https://storage.googleapis.com/sample-documentation/scenario.png)

* Structured the terraform project with a series of modules to clean up the main.tf file.
* Several of the instructions in the scenario referred to AWS terminology, they were translated to Google Cloud as follows:
  * Google Cloud VPCs do not define a CIDR. Those will be defined by the required subnets.
  * Subnets are divided into two zones (us-central1-a and us-central1-c)
  * Layer 7 Load Balancer is Cloud HTTP(S) Load Balancer

Resources used:
* Terraform documentation
* Terrafor Registry (pulled several modules from here, sticking with those created by Google)

Screenshots:
* Subnet 1 instance SSH:
![Image of ssh screenshot]
()

## Deployment Instructions
* Set desired Google Cloud Project ID, Region, and Default Zone in terraform.tfvars

### Deploy to Google Cloud
Initialize Terraform:
```
$ terraform init
```

View Terraform plans:
```
$ terraform plan
```

Use Terraform to provision Google Cloud resources:
```
$ terraform apply
```
