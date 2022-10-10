#!/bin/bash

## This will execute the terraform upgrader instance file
echo "Please choose the option  from below list :"
echo "1 : Preupgrade to create new upgrade instance"
echo "2 : Preupgrade to destroy upgrader instance"
echo "3 : Upgrade to create autoscaling"
echo "4 : Upgrader to destroy autoscaling"

PS3='Please enter your choice: '
options=("1" "2" "3" "4")
select opt in "${options[@]}"
do
    case $opt in
        "1")
	    terraform apply -target=module.upgrader[0].aws_instance.upgrader
	    break
            ;;
        "2")
	    terraform destroy -target=module.upgrader[0].aws_instance.upgrader
	    break
            ;;
        "3")
	    terraform apply -target module.autoscaling_cp[0].aws_autoscaling_group.autoscaled_group -target module.autoscaling_dp[0].aws_autoscaling_group.autoscaled_group
	    break
            ;;
        "4")
	    terraform destroy -target module.autoscaling_cp[0].aws_autoscaling_group.autoscaled_group -target module.autoscaling_dp[0].aws_autoscaling_group.autoscaled_group
            break
            ;;
        *) echo "invalid option"
		break
		;;
    esac
done
