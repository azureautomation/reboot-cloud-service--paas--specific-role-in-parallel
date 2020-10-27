$serviceName = "CloudServiceName"
#Production or Staging
$slot = "Production"
$role = "RoleName"

$deployment = Get-AzureDeployment -ServiceName $serviceName -Slot $slot
$instanceList = @()

foreach($instance in $deployment.RoleInstanceList.InstanceName)
{
if($instance -like "$role*")
{ 
$instanceList += $instance 

}
} 


$instanceList | %{
$ScriptBlock = {
param($name,$serviceName,$slot) 
if($name -like "$role*")
{ 
Reset-AzureRoleInstance -ServiceName $serviceName -Slot $slot -InstanceName $name -Reboot
}
Start-Sleep 5
}
Write-Host "processing $_..."
Start-Job $ScriptBlock -ArgumentList $_,$serviceName,$slot
}

# Wait for all to complete
While (Get-Job -State "Running") { Start-Sleep 2 }

# Display output from all jobs
Get-Job | Receive-Job

# Cleanup
Remove-Job *