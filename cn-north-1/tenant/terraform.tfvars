vpc_id = "vpc-021e6dcd6a26ec708"
subnet_config = [
	{cidr_block="10.0.124.0/28",availability_zone="cn-north-1a"},
	{cidr_block="10.0.125.0/28",availability_zone="cn-north-1b"},
	{cidr_block="10.0.127.0/28",availability_zone="cn-north-1d"}
]

swa_tenant = "tenant456"


launch_config_dp = [
	{ami_id = "ami-0a059ed0cc05f5e50" ,instance_type = "c5.xlarge", desired = 2}
]
launch_config_cp = [
        {ami_id = "ami-0a059ed0cc05f5e50" ,instance_type = "c5.xlarge" , desired = 3}
]


lb-listner = [
    { port = "3128", protocol = "TCP", tg = "proxy" },
    { port = "9001", protocol = "TCP", tg = "pac" }
]

upgrade_version = "123.0"
env = "prod"
swa_domain = "tenant456.cn"

