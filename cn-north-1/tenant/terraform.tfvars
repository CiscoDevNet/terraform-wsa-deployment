vpc_id = "vpc-021e6dcd6a26ec708"
subnet_config = [
	{cidr_block="10.0.17.0/28",availability_zone="cn-north-1a"},
	{cidr_block="10.0.18.0/28",availability_zone="cn-north-1b"},
	{cidr_block="10.0.19.0/28",availability_zone="cn-north-1d"}
]
swa_tenant = "philips"
launch_config_dp = [
	{ami_id = "ami-0ae44bfe6d0fea138" ,instance_type = "t3.large", desired = 2}
]
launch_config_cp = [
        {ami_id = "ami-0ae44bfe6d0fea138" ,instance_type = "t3.large" , desired = 3}
]

lb-listner = [
    { port = "3128", protocol = "TCP" },
    { port = "8443", protocol = "TCP" }
]

upgrade_version = ""
env = ""
swa_domain = "orient.cn"
