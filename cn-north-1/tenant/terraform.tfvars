vpc_id = "vpc-0dffbecc5ad34415b"
subnet_config = [
	{cidr_block="10.4.115.0/28",availability_zone="cn-northwest-1a"},
	{cidr_block="10.4.116.0/28",availability_zone="cn-northwest-1b"},
	{cidr_block="10.4.117.0/28",availability_zone="cn-northwest-1c"},
]
swa_tenant = "orient"
launch_config_dp = [
	{ami_id = "ami-04689f7cae4c2bd2f" ,instance_type = "t3.large", desired = 2}
]
launch_config_cp = [
        {ami_id = "ami-04689f7cae4c2bd2f" ,instance_type = "t3.large" , desired = 3}
]

upgrade_version = ""
swa_domain = "orient.cn"
