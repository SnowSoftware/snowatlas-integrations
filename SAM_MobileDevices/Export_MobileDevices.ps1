#Connect to Atlas
    $client_id = 'XXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXX'
    $client_secret = 'XXXXXXXXXXXXXXXXXXXXXXXXX' 
    $Region = "XXXXXXXXXXXXXXX"
    $CSVPath  = "MobileDevices_Export.csv"

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

#Get Mobile devices(Paginated)
    $Page = 1
    $itemnumber = 1
    $mobileObjects = @()

    Do {
        # w/Filter     $mobileUri = "https://$Region.snowsoftware.io/api/sam/estate/v1/mobiledevices?page_size=100&page_number=$page&filter=status -eq 'active'"  
        $mobileUri = "https://$Region.snowsoftware.io/api/sam/estate/v1/mobiledevices?page_size=100&page_number=$page"
        $mobileData = Invoke-RestMethod $mobileUri -Method 'GET' -Headers $headers -ContentType $ContentType -Usebasicparsing
        $Content = $mobileData.items
        $Count = $mobileData.items.count 
            
        $Content | ForEach-Object {           
            $mobileobject = [PSCustomObject]@{ 
                itemNumber      = $itemnumber
                id              = $_.id
                isTablet        = $_.isTablet
                manufacturer    = $_.manufacturer
                model           = $_.model
                operatingSystem = $_.operatingSystem 
                organizationId  = $_.organizationId
                phoneNumber     = $_.phoneNumber
                name            = $_.name
                status          = $_.status
            }
            $mobileObjects += $mobileobject
            $itemnumber++
        }
        $page++ 
        Write-debug "Page Number: $page, Count: $count, Item Number: $itemnumber"
    }  
    while ($Count -ge 100) 

#Export to CSV
    $mobileObjects | Export-Csv -Path $CSVPath -Force  
