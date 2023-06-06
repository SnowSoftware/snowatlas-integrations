#Connect to Atlas
    $client_id = 'XXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXX'
    $client_secret = 'XXXXXXXXXXXXXXXXXXXXXXXXX' 
    $Region = "XXXXXXXXXXXXXXX"
    $CSVPath  = "UserExport.csv"

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

#Get users (Paginated)
    $Page = 1
    $itemnumber = 1
    $userObjects = @()

    Do {
        #w/Filter     $usersUri = "https://$Region.snowsoftware.io/api/sam/estate/v1/user-accounts?page_size=100&page_number=$page&filter=status -ne 'active'"    
        $usersUri = "https://$Region.snowsoftware.io/api/sam/estate/v1/user-accounts?page_size=100&page_number=$page"
        $userData = Invoke-RestMethod $usersUri -Method 'GET' -Headers $headers -ContentType $ContentType
        $userobject = $Content = $Count = $null
        $Content = $userData.items
        $Count = $userData.items.count 
        
        $Content | ForEach-Object {           
            $userobject = [PSCustomObject]@{ 
                itemNumber = $itemnumber
                id         = $_.id
                email      = $_.email
                userName   = $_.userName
                fullName   = $_.fullName
                status     = $_.status
            }
            $userObjects += $userobject
            $itemnumber++
        }
        $page++ 
        Write-Debug "Page Number: $page, Count: $count, Item Number: $itemnumber"
    }  
    while ($Count -ge 100) 

#Export to CSV
    $userObjects | Export-Csv -Path $CSVPath -Force 
