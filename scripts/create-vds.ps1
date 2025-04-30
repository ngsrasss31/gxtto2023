param (
    [string]$InstanceType = "t2.micro",
    [string]$Password
)

$Region = "us-east-1"
$AMI = "ami-0b2f6494ff0b07a0e" # Windows Server 2019 Free Tier (us-east-1)
$KeyName = "github-actions-key"
$SecurityGroupName = "github-actions-sg"

# Güvenlik grubu oluştur
$SG_ID = aws ec2 create-security-group --group-name $SecurityGroupName --description "RDP erişimi" --region $Region | ConvertFrom-Json | Select-Object -ExpandProperty GroupId

# RDP portu aç (Sadece GitHub IP'si için istersen kısıtlayabilirim)
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol tcp `
  --port 3389 `
  --cidr 0.0.0.0/0 `
  --region $Region

# bootstrap.ps1 içeriğini base64'e çevir (password değişimi dahil)
$UserDataRaw = (Get-Content "./scripts/bootstrap.ps1" -Raw).Replace("{{PASSWORD}}", $Password)
$UserData = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserDataRaw))

# EC2 başlat
$Instance = aws ec2 run-instances `
  --image-id $AMI `
  --instance-type $InstanceType `
  --key-name $KeyName `
  --security-group-ids $SG_ID `
  --user-data $UserData `
  --region $Region `
  --output json | ConvertFrom-Json

$InstanceId = $Instance.Instances[0].InstanceId
Set-Content -Path "instance_id.txt" -Value $InstanceId

Write-Output "Başarıyla başlatıldı: $InstanceId"
