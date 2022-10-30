# Foreach hanzi word
#   Upload a list of images to DB
#   Move those images from local folder to a back up folder

# input images
# sort

# for all images
# parse out hanzi   i.e. split()[0]
# if list not empty and list[0]==hanzi
#   add to list
# else
#   if list not empty
#       push list to new doc in DB
#   add to new list


Add-Type -AssemblyName System.Web

Function Generate-MasterKeyAuthorizationSignature {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][String]$verb,
        [Parameter(Mandatory = $true)][String]$resourceLink,
        [Parameter(Mandatory = $true)][String]$resourceType,
        [Parameter(Mandatory = $true)][String]$dateTime,
        [Parameter(Mandatory = $true)][String]$key,
        [Parameter(Mandatory = $true)][String]$keyType,
        [Parameter(Mandatory = $true)][String]$tokenVersion
    )
    $hmacSha256 = New-Object System.Security.Cryptography.HMACSHA256
    $hmacSha256.Key = [System.Convert]::FromBase64String($key)
 
    If ($resourceLink -eq $resourceType) {
        $resourceLink = ""
    }
 
    $payLoad = "$($verb.ToLowerInvariant())`n$($resourceType.ToLowerInvariant())`n$resourceLink`n$($dateTime.ToLowerInvariant())`n`n"
    $hashPayLoad = $hmacSha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($payLoad))
    $signature = [System.Convert]::ToBase64String($hashPayLoad)
 
    [System.Web.HttpUtility]::UrlEncode("type=$keyType&ver=$tokenVersion&sig=$signature")
}

Function Post-CosmosDocuments {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][String]$EndPoint,
        [Parameter(Mandatory = $true)][String]$DBName,
        [Parameter(Mandatory = $true)][String]$CollectionName,
        [Parameter(Mandatory = $true)][String]$MasterKey,
        [String]$Verb = "POST",
        [Parameter(Mandatory = $true)][String]$JSON
    )
    $ResourceType = "docs";
    $ResourceLink = "dbs/$DBName/colls/$CollectionName"
    $partitionkey = "[""$(($JSON |ConvertFrom-Json).id)""]"
 
    $dateTime = [DateTime]::UtcNow.ToString("r")
    $authHeader = Generate-MasterKeyAuthorizationSignature -verb $Verb -resourceLink $ResourceLink -resourceType $ResourceType -key $MasterKey -keyType "master" -tokenVersion "1.0" -dateTime $dateTime
    $header = @{authorization = $authHeader; "x-ms-version" = "2015-12-16"; "x-ms-documentdb-partitionkey" = $partitionkey; "x-ms-date" = $dateTime }
    $contentType = "application/json"
    $queryUri = "$EndPoint$ResourceLink/docs"
    #$header
    #$queryUri
 
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $result = Invoke-RestMethod -Method $Verb -ContentType $contentType -Uri $queryUri -Headers $header -Body $JSON 
}



function Store() {
    param([Collections.Generic.List[string]]$list)

    $CosmosDBEndPoint = "https://personal-projects.documents.azure.com:443/"
    $DBName = "personal-projects"
    $CollectionName = "yabla-image"
    $MasterKey = "QA8z9C0PgsM94kE2hSwYTbqXgVZuS8vqTWFFJY5HnWNRsKpvcllPITXgRUDrvqgcNiZoKZCalsZZhmG2aV4v5w=="
    
    # HOW DO WE UPLOAD IMAGES?
    # HOW DO WE MAKE THIS JSON OBJECT? {id, list of images}

    #.....YOU NEED TO USE BLOB STORAGE


    Post-CosmosDocuments -EndPoint $CosmosDBEndPoint -MasterKey $MasterKey 
    -DBName $DBName -CollectionName $CollectionName -JSON ($SomeObject | ConvertTo-Json)
}

$images = Get-ChildItem -Exclude *.ps1
$list = New-Object 'Collections.Generic.List[string]' | Sort-Object
For ($i = 0; $i -lt $images.Length; $i++) {
    # get hanzi
    $hanzi = $images[$i].Split()[0];
    # if still the same hanzi as before
    if ($list.Length -gt 0) {
        if ($list[0].Equals($hanzi)) {
            $list.Add($hanzi); # add to list
        }
        if ($i -eq $images.Length - 1) {
            # we are done
            # add current list to DB

        }
    }
    else {
        if ($list.Length -gt 0) {
            # add current list to DB
        }
        $list.Clear();
    }
}
