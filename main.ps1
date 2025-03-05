# PowerShell script to establish SSH connection
$remoteHost = "remote_host_ip"
$username = "your_username"
$password = "your_password"

# Create a new SSH session
$session = New-SSHSession -ComputerName $remoteHost -Credential (New-Object System.Management.Automation.PSCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force)))

# Execute a command on the remote machine
Invoke-SSHCommand -SessionId $session.SessionId -Command "echo 'Connected to remote machine'"

# Close the session
Remove-SSHSession -SessionId $session.SessionId
