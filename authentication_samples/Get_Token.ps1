#Connect to Atlas
    $client_id = 'XXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXX'
    $client_secret = 'XXXXXXXXXXXXXXXXXXXXXXX' 
    $Region = "XXXXXXXXXX"

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

#Print Token
    Write-host $Token    