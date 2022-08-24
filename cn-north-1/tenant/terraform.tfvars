vpc_id = "vpc-021e6dcd6a26ec708"
subnet_config = [
	{cidr_block="10.0.201.0/28",availability_zone="cn-north-1a"},
	{cidr_block="10.0.202.0/28",availability_zone="cn-north-1b"},
	{cidr_block="10.0.203.0/28",availability_zone="cn-north-1d"},
]
swa_tenant = "rockwell"
launch_config_dp = [
	{ami_id = "ami-0bc7f87a4c4f1ec7c" ,instance_type = "c5.xlarge", desired = 2}
]
launch_config_cp = [
        {ami_id = "ami-0d43482ef886ba3d5" ,instance_type = "c5.xlarge" , desired = 3}
]
upgrade = 1
upgrade_version = "10.0"
swa_domain = "rockwell.cn"
