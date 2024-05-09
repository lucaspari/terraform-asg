provider "aws" {
  profile = "default"
  region  = "sa-east-1"
}
resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "example" {
  name            = "example-launch-configuration"
  instance_type   = "t2.micro"
  image_id        = var.linux-t3
  user_data       = file("user-data.sh")
  security_groups = [aws_security_group.instance_sg.id]
}

resource "aws_autoscaling_group" "example" {
  name                 = "example-autoscaling-group"
  launch_configuration = aws_launch_configuration.example.name
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  vpc_zone_identifier  = tolist(var.subnet)
  target_group_arns    = [aws_lb_target_group.tg_example.arn]
}
resource "aws_autoscaling_policy" "policy_example" {
  name                   = "example-asg-policy"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.example.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40.0
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_lb" "lb_example" {
  name               = "example-load-balancer"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.instance_sg.id]
  subnets            = tolist(var.subnet)
}

resource "aws_lb_target_group" "tg_example" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc
}

resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.lb_example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_example.arn
  }
}

