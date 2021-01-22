# coding-test-tf
A repository containing my submission for the Terraform Coding Test used to filter candidates for the role of Platform Engineer.

This Terraform will, as instructed in the test, deploy three loadbalanced EC2 virtual machines in resilient availability zones. This solution utilises auto scaling groups to ensure even balance and powerful lifecycle management for the virtual machines resulting in zero downtime deployments.

To demonstrate the solution works, an Nginx docker container is deployed on the VMs and can be accessed at the loadbalancer DNS url. Ticking auto-refresh will demonstrate the different containers being used as the server id changes.

# Available customisations (variables.tf)

## Instance count
The variables ```minimum_instance_count``` and ```maximum_instance_count``` can be used to adjust the scale of the deployment.

## Application Deployed
You can also adjust the application deployed by providing a custom deploy.sh script or replacing deploy.sh with a cloud-init configuration.

## Networking
Subnet allocations can also be tweaked for example if the default allocation collides with another VPC it is required to communicate with.

## Default tags
This script also contains a map of default tags which are propagated to all resources created. This is facilitated by the ```merge()``` function which combines the default tags with a map of additional resource specific tags.