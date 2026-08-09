resource "aws_iam_role" "ssm_role" {
  name = "ec2-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
      Effect    = "Allow"
    }]
  })
  tags = {
    Name = "ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ssm_role.name

  tags = {
    Name = "ssm-profile"
  }
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
rm -f /etc/httpd/conf.d/welcome.conf
echo "<h1>Hello from Alexis' private EC2 behind an ALB!</h1>" > /var/www/html/index.html
EOF
  )

  tags = {
    Name = "app-launch-template"
  }

  depends_on = [aws_iam_instance_profile.ssm_profile]
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "app-asg"
  vpc_zone_identifier       = [aws_subnet.private["a"].id, aws_subnet.private["b"].id]
  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 3
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  tag {
    key                 = "Name"
    value               = "app-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
}
