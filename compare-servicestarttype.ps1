<#
.SYNOPSIS
    Simple script which will check if your services are in desired startup action.
    Script will not stop any service, you should. Maybe run Get-Service -Name service1, service2 | Stop-service -Force

.NOTES
    File Name      : compare-servicestarttype.ps1
    Author         : K. Bartolic (bkarlo@posteo.net)
    
.LINK
    Script posted over:
    
.EXAMPLE
   Compare-ServiceStartType
#>


function Compare-ServiceStartType {

    #First we need to initialaze array, since you want key-value comparrison you need
    #To use Hash table. 
    #Also i defined some empty arrays to store "bad" and services without change
    #So we can troubleshoot it after.
    Begin{
        $badServices = @()
        $noChange = @()
        $services = @{
          'RpcSs' = "Disabled" 
          'RemoteRegistry' = "Disabled" 
          'LanmanServer'= "Disabled" 
          'Winmgmt' = "Disabled" 
          'CcmExec' = "Automatic" 
          'masvc' = "Automatic"
          'mfefire' = "Manual" 
          'gpsvc'  = "Disabled"
        }
    }

    #We have foreach loop which trys to get service, then try's to stop it.
    Process{
        foreach ($service in $services.Keys){

            #I've used seperated try catch block for get-service and start-service
            #Because i wanted a different errors from them. This has better
            #Way to do it, but since this is not heavy script, this is ok.
            try{
               $serviceObject =  Get-Service -Name $service -ErrorAction Stop
            }
            catch{
                $badServices += $service
            }
            #If statement which compares services startup type, and checks if
            #this service is in $badService array.
            if(($serviceObject).StartType -ne $services[$service] -and $badServices -notcontains $service){
                try{
                    Write-Output "Changing $service service state from $($serviceObject.StartType) to $($services[$service])"
                    Set-Service -Name $service -StartupType $services[$service] -ErrorAction Stop
                }
                catch{
                    $noChange += $service
                }
            }

        }
    }

    End {
         #Quick error handling. 
        If ($badServices[0] -ne $null){
            Write-Output "Could not find one or more services : $badServices"
        }
        elseIf ($noChange[0] -ne $null){
             Write-Output "Could not change start type on one or more services, maybe they are at running state? `n Services : $noChange"
        }
        else{
            Write-Output "All done."
        }
    }
}

Compare-ServiceStartType