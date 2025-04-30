$Region = "us-east-1"
$InstanceId = Get-Content -Path "instance_id.txt"
aws ec2 terminate-instances --instance-ids $InstanceId --region $Region
