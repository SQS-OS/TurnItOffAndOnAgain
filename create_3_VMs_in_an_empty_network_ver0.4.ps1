﻿#  BEFORE this is run you need to ensure that your PS session is connected to your Azure account by running
#Add-AzureAccount
# this will select the family and image and asign it to the variable $image
$family="Windows Server 2012 R2 Datacenter"
$image=Get-AzureVMImage | where { $_.ImageFamily -eq $family } | 
sort PublishedDate -Descending | select -ExpandProperty ImageName -First 1

# this asignes values to the $vmname and $vmsize
$vmname1="ts1"
$vmsize="Small"
$vm1=New-AzureVMConfig -Name $vmname1 -InstanceSize $vmsize -ImageName $image

# set user as 'any text'  and password as 'any text'  for this VM    n.b. do NOT select admin or and varient as it is blocked
$User = “spencert”
$Pass = ConvertTo-SecureString “TTT001$$” -AsPlainText -Force
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User,$Pass
$vm1 | Add-AzureProvisioningConfig -Windows -AdminUsername $cred.GetNetworkCredential().Username -Password $cred.GetNetworkCredential().Password



# this asignes values to the $vmname and $vmsize
$vmname2="ts2"
$vmsize="Small"
$vm2=New-AzureVMConfig -Name $vmname2 -InstanceSize $vmsize -ImageName $image
$vm2 | Add-AzureProvisioningConfig -Windows -AdminUsername $cred.GetNetworkCredential().Username -Password $cred.GetNetworkCredential().Password

# repeat of the above block for an additional vm
$vmname3="ts3"
$vmsize="Small"
$vm3=New-AzureVMConfig -Name $vmname3 -InstanceSize $vmsize -ImageName $image
$vm3 | Add-AzureProvisioningConfig -Windows -AdminUsername $cred.GetNetworkCredential().Username -Password $cred.GetNetworkCredential().Password


#  Front End was the name i gave to the subnet
$vm1 | Set-AzureSubnet -SubnetNames "Front End"
#$vm1 | Set-AzureStaticVNetIP -IPAddress 10.0.1.1

# assign the values for the EXISTING Cloud Service  and  network that were created earlier MANUALLY
$svcname="timscloudsvc"
$vnetname = "tsvnet"

#  this creates the new VMs  Provisions and Starts them   -    as 3 jobs running in parallel

$task1 = {New-AzureVM –ServiceName $svcname -VMs $vm1 -VNetName $vnetname }
$task2 = .{New-AzureVM –ServiceName $svcname -VMs $vm2 }
$task3 = .{New-AzureVM –ServiceName $svcname -VMs $vm3 }

#$Timsnewjob1 = Invoke-Command -ScriptBlock $task1 
$job1 = Start-Job -ScriptBlock $task1
$job2 = Start-Job -ScriptBlock $task2
$job3 = Start-Job -ScriptBlock $task3


#  this code workes for me without error or worning to create additional VMs associated to my existing network and Cloud service.