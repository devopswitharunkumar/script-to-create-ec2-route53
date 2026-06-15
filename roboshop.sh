#!/bin/bash
#Create roboshop Ec2 instance through Shell script
AMI_ID=ami-0220d79f3f480ecf5
SG_ID=sg-0356688fc6f675992

INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "cart" "user" "shipping" "payment" "dispatch" "web")
HOSTED_ZONE_ID=Z02149386QBAC23T25TA
DOMAIN_NAME=devopswitharun.online

VALIDATE(){
if [ $i != "web" ]
then 
    echo 'Instance[0].PrivateIpAddress'
else
    echo 'Instance[0].PublicIpAddress'
fi
}

for i in "${[INSTANCES[@]]}"
do
    echo "Instance is : $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
then
    INSTANCE_TYPE="t3.small"
else
    INSTANCE_TYPE="t3.micro"
fi
    IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI_ID --instance-type $INSTANCE_TYPE --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{key=Name,Value=$i}]" --query "$VALIDATE" --output text)

    echo "$i : $IP_ADDRESS"


# Creates route 53 records based on env name

    aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE_ID \
    --change-batch '
    {
        "Comment": "creating a route53 record"
        ,"Changes": [{
        "Action"              : "CREATE"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
    '

done