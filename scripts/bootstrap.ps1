# Admin şifresini ayarla
net user Administrator "{{PASSWORD}}"

# RDP etkinleştir
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Chrome yükle
Invoke-WebRequest "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile "$env:TEMP\chrome.exe"
Start-Process "$env:TEMP\chrome.exe" -ArgumentList "/silent /install" -Wait

# ChromeDriver otomatik versiyona göre indir
$chromeVer = (Get-ItemProperty "HKLM:\Software\Google\Chrome\BLBeacon").version
$majorVer = $chromeVer.Split(".")[0]
$driverVer = Invoke-RestMethod "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$majorVer"
Invoke-WebRequest "https://chromedriver.storage.googleapis.com/$driverVer/chromedriver_win32.zip" -OutFile "$env:TEMP\cd.zip"
Expand-Archive "$env:TEMP\cd.zip" -DestinationPath "C:\Tools\ChromeDriver"
$env:Path += ";C:\Tools\ChromeDriver"

# İsteğe bağlı: Selenium testlerini buradan tetikleyebilirsin
