vpc_id = "vpc-021e6dcd6a26ec708"
subnet_config = [
	{cidr_block="10.0.100.0/24",availability_zone="cn-north-1a"},
	{cidr_block="10.0.101.0/24",availability_zone="cn-north-1b"},
	{cidr_block="10.0.102.0/24",availability_zone="cn-north-1d"},
]
swa_tenant = "tesla"
launch_config_dp = [
	{ami_id = "ami-0e15556243efd8f0b" ,instance_type = "c5.xlarge", desired = 2}
]
launch_config_cp = [
        {ami_id = "ami-0e15556243efd8f0b" ,instance_type = "c5.xlarge" , desired = 3}
]

