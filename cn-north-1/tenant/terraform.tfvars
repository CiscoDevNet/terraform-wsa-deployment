vpc_id = "vpc-02c2696788eb37992"
subnet_config = [
	{cidr_block="10.110.12.0/28",availability_zone="ap-south-1a"},
	{cidr_block="10.110.13.0/28",availability_zone="ap-south-1b"}
]

swa_tenant = "tenant456"


launch_config_cp = [
        {ami_id = "ami-086610c4c94a02195" ,instance_type = "c5.xlarge" , desired = 3}
]


upgrade_version = "123.0"
env = "prod"
swa_domain = "tenant456.cn"

