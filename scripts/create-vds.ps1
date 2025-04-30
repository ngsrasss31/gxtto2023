param (
    [string]$InstanceType = "t2.medium",
    [string]$Password
)

$Region = "us-east-1"

# 1. Dinamik IP adresini al
$MyIP = (Invoke-RestMethod -Uri "https://checkip.amazonaws.com").Trim()

# 2. Güvenlik grubu oluştur
$SGName = "rdp-access-$((Get-Random).ToString())"
$SG = aws ec2 create-security-group `
    --group-name $SGName `
    --description "RDP Access Only from GitHub Action IP" `
    --vpc-id $(aws ec2 describe-vpcs --region $Region --query "Vpcs[0].VpcId" --output text) `
    --region $Region | ConvertFrom-Json

$SG_ID = $SG.GroupId

aws ec2 authorize-security-group-ingress `
    --group-id $SG_ID `
    --protocol tcp `
    --port 3389 `
    --cidr "$MyIP/32" `
    --region $Region

# 3. Windows Server 2019 AMI ID
$AMI = $(aws ec2 describe-images `
    --owners "801119661308" `
    --filters "Name=name,Values=Windows_Server-2019-English-Full-Base*" "Name=state,Values=available" `
    --query 'Images[*].[ImageId,CreationDate]' `
    --region $Region `
    --output json | ConvertFrom-Json | Sort-Object -Property @{Expression={[datetime]$_[1]}} -Descending | Select-Object -First 1)[0]

# 4. bootstrap.ps1 içeriğini oku
$UserData = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(
    (Get-Content -Raw "./scripts/bootstrap.ps1").Replace("{{PASSWORD}}", $Password)
))

# 5. EC2 başlat
$Instance = aws ec2 run-instances `
    --image-id $AMI `
    --instance-type $InstanceType `
    --key-name $null `
    --security-group-ids $SG_ID `
    --user-data $UserData `
    --tag-specifications "ResourceType=instance,Tags=[{Key=DeleteAfter,Value=$(Get-Date).AddHours(24).ToString('yyyy-MM-ddTHH:mm:ss')}]" `
    --region $Region `
    --output json | ConvertFrom-Json

$InstanceId = $Instance.Instances[0].InstanceId
Write-Output "Oluşturulan EC2 Instance ID: $InstanceId"

# 6. Durum kontrolü
aws ec2 wait instance-status-ok --instance-ids $InstanceId --region $Region
Write-Output "VDS hazır."

# 7. Bilgileri kaydet (gerekiyorsa)
Set-Content -Path "instance_id.txt" -Value $InstanceId
