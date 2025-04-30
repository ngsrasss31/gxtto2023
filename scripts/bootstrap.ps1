# Şifreyi ayarla
$adminUser = "Administrator"
$adminPass = ConvertTo-SecureString "{{PASSWORD}}" -AsPlainText -Force
Set-LocalUser -Name $adminUser -Password $adminPass

# RDP aç
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Chrome Kur
Invoke-WebRequest "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile "$env:TEMP\chrome_installer.exe"
Start-Process -FilePath "$env:TEMP\chrome_installer.exe" -ArgumentList "/silent /install" -Wait

# ChromeDriver Versiyon belirle
$ChromeVersion = (Get-ItemProperty "HKLM:\Software\Google\Chrome\BLBeacon").version
$MajorVersion = $ChromeVersion.Split('.')[0]
$DriverVersion = Invoke-RestMethod -Uri "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$MajorVersion"
Invoke-WebRequest "https://chromedriver.storage.googleapis.com/$DriverVersion/chromedriver_win32.zip" -OutFile "$env:TEMP\chromedriver.zip"
Expand-Archive "$env:TEMP\chromedriver.zip" -DestinationPath "C:\WebDrivers"
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\WebDrivers", [EnvironmentVariableTarget]::Machine)

# Test script'ini indirip çalıştır
Invoke-WebRequest "https://raw.githubusercontent.com/<kullanıcı>/<repo>/<branch>/tests/test.ps1" -OutFile "C:\test.ps1"
powershell -ExecutionPolicy Bypass -File "C:\test.ps1"
