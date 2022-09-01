vpc_id = "vpc-05b20e67106641fd2"
subnet_config = [
	{cidr_block="10.12.211.0/28",availability_zone="cn-northwest-1a"},
	{cidr_block="10.12.212.0/28",availability_zone="cn-northwest-1b"},
	{cidr_block="10.12.213.0/28",availability_zone="cn-northwest-1c"},
]
swa_tenant = "philips"
launch_config_dp = [
	{ami_id = "ami-068eac39b6e230305" ,instance_type = "t3.xlarge", desired = 2}
]
launch_config_cp = [
        {ami_id = "ami-068eac39b6e230305" ,instance_type = "t3.xlarge" , desired = 3}
]
upgrade = 0
upgrade_version = "10.0"
swa_domain = "philips.cn"
