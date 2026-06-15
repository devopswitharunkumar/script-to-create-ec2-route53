# Create Ec2 and route53 All Roboshop instance throuh shell script 

# #!/bin/bash
# #Create roboshop Ec2 instance through Shell script
# AMI_ID=ami-0220d79f3f480ecf5
# SG_ID=sg-0356688fc6f675992

# INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "cart" "user" "shipping" "payment" "dispatch" "web")
# HOSTED_ZONE_ID=Z02149386QBAC23T25TA
# DOMAIN_NAME=devopswitharun.online

# VALIDATE(){
# if [ $i != "web" ]
# then 
#     echo 'Instances[0].PrivateIpAddress'
# else
#     echo 'Instances[0].PublicIpAddress'
# fi
# }

# for i in "${INSTANCES[@]}"
# do
#     echo "Instance is : $i"
#     if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
# then
#     INSTANCE_TYPE="t3.small"
# else
#     INSTANCE_TYPE="t3.micro"
# fi
#     IP_ADDRESS=$(aws ec2 run-instances --region us-east-1 --image-id $AMI_ID --instance-type $INSTANCE_TYPE --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query "$(VALIDATE)" --output text)

#     echo "$i : $IP_ADDRESS"


# # Creates route 53 records based on env name

#     aws route53 change-resource-record-sets \
#     --hosted-zone-id $HOSTED_ZONE_ID \
#     --change-batch '
#     {
#         "Comment": "creating a route53 record"
#         ,"Changes": [{
#         "Action"              : "UPSERT"
#         ,"ResourceRecordSet"  : {
#             "Name"              : "'$i'.'$DOMAIN_NAME'"
#             ,"Type"             : "A"
#             ,"TTL"              : 1
#             ,"ResourceRecords"  : [{
#                 "Value"         : "'$IP_ADDRESS'"
#             }]
#         }
#         }]
#     }
#     '

# done

# run : sh robooshop.sh

# "Action": "CREATE"
# Problem:

# If record does not exist → creates ✅
# If record already exists → fails ❌

# "Action": "UPSERT" 
# UPSERT ---> UPDATE + INSERT

# If record does not exist → creates ✅
# If record already exists → update with new ip address

# "Action": "DELETE" 
# Remove existing record







# #===================================================

# #!/bin/bash

# # Create roboshop EC2 instances if not present ..if present update same ip in route53

# AMI_ID=ami-0220d79f3f480ecf5
# SG_ID=sg-0356688fc6f675992

# INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "cart" "user" "shipping" "payment" "dispatch" "web")

# HOSTED_ZONE_ID=Z02149386QBAC23T25TA
# DOMAIN_NAME=devopswitharun.online


# GET_IP(){

# if [ "$i" != "web" ]
# then
#     echo "Instances[0].PrivateIpAddress"
# else
#     echo "Instances[0].PublicIpAddress"
# fi

# }


# for i in "${INSTANCES[@]}"
# do

# echo "Instance is : $i"


# # Decide instance type

# if [ "$i" == "mongodb" ] || [ "$i" == "mysql" ] || [ "$i" == "shipping" ]
# then
#     INSTANCE_TYPE="t3.small"
# else
#     INSTANCE_TYPE="t3.micro"
# fi



# # Check EC2 instance already exists

# INSTANCE_ID=$(aws ec2 describe-instances \
# --region us-east-1 \
# --filters "Name=tag:Name,Values=$i" "Name=instance-state-name,Values=running" \
# --query "Reservations[0].Instances[0].InstanceId" \
# --output text)



# if [ "$INSTANCE_ID" != "None" ]
# then

#     echo "$i already exists"

#     IP_ADDRESS=$(aws ec2 describe-instances \
#     --region us-east-1 \
#     --instance-ids $INSTANCE_ID \
#     --query "$(GET_IP)" \
#     --output text)


# else

#     echo "$i not found creating instance"


#     IP_ADDRESS=$(aws ec2 run-instances \
#     --region us-east-1 \
#     --image-id $AMI_ID \
#     --instance-type $INSTANCE_TYPE \
#     --security-group-ids $SG_ID \
#     --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" \
#     --query "$(GET_IP)" \
#     --output text)

# fi


# echo "$i : $IP_ADDRESS"



# # If IP empty skip Route53

# if [ -z "$IP_ADDRESS" ]
# then
#     echo "$i IP not found, skipping Route53"
#     continue
# fi



# # Create or Update Route53

# aws route53 change-resource-record-sets \
# --hosted-zone-id $HOSTED_ZONE_ID \
# --change-batch '
# {
#     "Comment": "Creating or Updating record",
#     "Changes": [{
#         "Action": "UPSERT",
#         "ResourceRecordSet": {
#             "Name": "'$i'.'$DOMAIN_NAME'",
#             "Type": "A",
#             "TTL": 1,
#             "ResourceRecords": [{
#                 "Value": "'$IP_ADDRESS'"
#             }]
#         }
#     }]
# }
# '

# done