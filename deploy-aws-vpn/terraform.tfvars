aws_region     = "ap-east-1"
vpc_cidr       = "10.0.0.0/16"
subnet_cidr    = "10.0.1.0/24"
# availability_zone = ""
instance_type  = "t3.micro"
ami_id         = "ami-0397c5400028b418c"  # 替换为你的目标AMI
key_pair_name  = "mac-mini"            # 替换为你的Key Pair名称
tag = "vpn-ec2"