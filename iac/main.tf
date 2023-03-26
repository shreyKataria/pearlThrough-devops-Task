terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}



## TASK defination
resource "aws_ecs_task_definition" "my-task" {
  family                   = "my-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "my-container",
    "image": "shreykataria/pearl-devops-task-node:3",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
        {
            "name": "test-80-tcp",
            "containerPort": 80,
            "hostPort": 80,
            "protocol": "tcp",
            "appProtocol": "http"
        }
    ]
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}


## ECS cluster
resource "aws_ecs_cluster" "my-cluster" {
  name = "my-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


## ECS Service


resource "aws_ecs_service" "my-service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my-cluster.id
  task_definition = aws_ecs_task_definition.my-task.arn
  desired_count   = 1

  launch_type = "FARGATE"


  network_configuration {
    subnets = [ "subnet-0228dc92ce34199f0","subnet-061a876ac03e8ffcd" ]
    assign_public_ip = true
  }


}