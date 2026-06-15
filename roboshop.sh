#!/bin/bash
#Create roboshop Ec2 instance if not present ..if present delete old instances and create new instances and update route53 with new ip addresss
AMI_ID=ami-0220d79f3f480ecf5
SG_ID=sg-0356688fc6f675992
REGION=us-east-1

INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "cart" "user" "shipping" "payment" "dispatch" "web")
HOSTED_ZONE_ID=Z02149386QBAC23T25TA
DOMAIN_NAME=devopswitharun.online

GET_IP(){
if [ $i != "web" ]
then 
    echo 'Instances[0].PrivateIpAddress'
else
    echo 'Instances[0].PublicIpAddress'
fi
}

for i in "${INSTANCES[@]}"
do
    echo "Processing Instance is : $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
then
    INSTANCE_TYPE="t3.small"
else
    INSTANCE_TYPE="t3.micro"
fi

# Check instance already exists

INSTANCE_ID=$(aws ec2 describe-instances --region $REGION --filters "Name=tag:Name,Values=$i" "Name=instance-state-name,Values=running,pending,stopped" --query "Reservations[*].Instances[*].InstanceId" --output text)

# If instance exists terminate

if [ -n "$INSTANCE_ID" ]       #if [ -z "$IP_ADDRESS" ] --> -n = check string is NOT empty
then

    echo "$i instance already exists and Instance ID is : $INSTANCE_ID and Deleting old instance..."

    aws ec2 terminate-instances --region $REGION --instance-ids $INSTANCE_ID

    echo "Waiting for termination..."

    aws ec2 wait instance-terminated --region $REGION --instance-ids $INSTANCE_ID

    echo "$i old instance deleted"
else
    echo "$i instance not available"

fi

echo "Creating new $i instance..."


# Create EC2 instance

IP_ADDRESS=$(aws ec2 run-instances --region $REGION --image-id $AMI_ID --instance-type $INSTANCE_TYPE --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query "$(GET_IP)" --output text)



# Validate EC2 creation

if [ -z "$IP_ADDRESS" ]        $-z --> check string is empty
then

    echo "ERROR: $i instance creation failed"
    echo "Skipping Route53 record"
    continue

fi



echo "$i IP Address: $IP_ADDRESS"



# Create or update Route53 record

echo "Updating Route53 record for $i"


aws route53 change-resource-record-sets \
--hosted-zone-id $HOSTED_ZONE_ID \
--change-batch '
{
    "Comment": "Creating or Updating Route53 record",
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$i'.'$DOMAIN_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                    {
                        "Value": "'$IP_ADDRESS'"
                    }
                ]
            }
        }
    ]
}
'

echo "$i setup completed"

done