resource "aws_autoscaling_group" "k3s_masters_asg" {
  name                      = "k3s_masters"
  wait_for_capacity_timeout = "5m"
  vpc_zone_identifier       = var.vpc_subnets

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers, target_group_arns]
  }

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 20
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.k3s_master.id
        version            = "$Latest"
      }

      override {
        instance_type     = "t3.large"
        weighted_capacity = "1"
      }

      override {
        instance_type     = "t2.large"
        weighted_capacity = "1"
      }

      override {
        instance_type     = "m4.large"
        weighted_capacity = "1"
      }

      override {
        instance_type     = "t3a.large"
        weighted_capacity = "1"
      }
    }
  }

  desired_capacity          = 3
  min_size                  = 3
  max_size                  = 7
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "k3s-master"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "k3s_workers_asg" {
  name                = "k3s_workers"
  vpc_zone_identifier = var.vpc_subnets

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 20
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.k3s_worker.id
        version            = "$Latest"
      }

      override {
        instance_type     = "t3.large"
        weighted_capacity = "1"
      }

      override {
        instance_type     = "t2.large"
        weighted_capacity = "1"
      }

      override {
        instance_type     = "m4.large"
        weighted_capacity = "1"
      }

      override {
        instance_type     = "t3a.large"
        weighted_capacity = "1"
      }
    }
  }

  desired_capacity          = 3
  min_size                  = 3
  max_size                  = 7
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "k3s-worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value               = ""
    propagate_at_launch = true
  }
}
