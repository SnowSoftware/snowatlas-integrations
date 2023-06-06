#Connect to Atlas
    $client_id = 'XXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXX'
    $client_secret = 'XXXXXXXXXXXXXXXXXXXXXXXXX' 
    $Region = "XXXXXXXXXXXXXXX"
    $CSVPath  = "ComputerExport.csv"

#Get Token
    $TokenContentType = 'application/x-www-form-urlencoded' 
    $Body = @{grant_type = 'client_credentials'
            client_id = $client_id 
            client_secret = $client_secret
        } 
    $Tokenuri =  "https://$Region.snowsoftware.io/idp/api/connect/token"
    $Tokendata = Invoke-WebRequest -Uri $Tokenuri -ContentType $TokenContentType -Method Post -Body $body
    if($Tokendata.Statuscode -eq "200"){
        Write-host "Token Aquired"
        $Token = ($TokenData.Content  | ConvertFrom-Json).access_token
    }

   
#Set Content type and header
    $ContentType = 'application/json' 
    $headers = @{Authorization = ("Bearer {0}" -f $Token) } 

#Get Computers(Paginated)
    $Page = 1
    $itemnumber = 1
    $ComputerObjects = @()

    Do{
        $ComputersUri = "https://$Region.snowsoftware.io/api/sam/estate/v1/computers?page_size=100&page_number=$page"
        $ComputerData = Invoke-RestMethod $ComputersUri -Method 'GET' -Headers $headers -ContentType $ContentType
        $Content = $ComputerData.items
        $Count = $ComputerData.items.count 
    
        $Content | ForEach-Object {           
        $Computerobject = [PSCustomObject]@{ 
            itemNumber = $itemnumber
            domain = $_.domain
            hostname = $_.hostName
            id = $_.id
            ipAddress = $_.ipAddress
            isPortable = $_.isPortable
            isServer = $_.isServer
            isVDI = $_.isVDI
            isVirtual = $_.isVirtual
            lastScanDate = $_.lastScanDate
            links = $_.links.href
            manufacturer = $_.manufacturer
            model = $_.model
            operatingSystem = $_.operatingSystem
            organizationId = $_.organizationId
            status = $_.status
        }
        $ComputerObjects += $Computerobject
        $itemnumber++
    }
    $page++ 
    }  
    while ($Count -ge 100) 

$ComputerObjects | Export-Csv -Path $CSVPath -Force
