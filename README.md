# fabacus
test task for fabacus

**Objective**
 The main goal is to create a fully available web service using Terraform, running on AWS ECS.

**Description**
As the new DevOps engineer joining the team, you have been requested to create an environment
for our latest application, Hello World!, this application is fully containerised and already available
at:
https://hub.docker.com/r/nginxdemos/hello
the application does not require other resources to run.

  Your mission is to create a Terraform script that will create the environment for the application to
run, the script should also deploy the application.
Your script should:
* Create a basic secure VPC to contain your instances.
* Set up the required systems to run the container on ECS.
* Set up a load balancer on front of ECS to guarantee redundancy.     
  **Optionally:**
* Logs to CloudWatch
* Use ECR instead of Docker Hub as the image registry
