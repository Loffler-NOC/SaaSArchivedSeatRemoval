Start-Transcript -Path "C:\Temp\SingleClientSaaSProtectionSeatUpdateTranscriptRun3.txt"
$count = 0
$totalSuccess = $true

$baseApiUrl = "https://api.datto.com/v1/saas/{0}/{1}/bulkSeatChange"

$username = "c5d25e"
$password = "69d74c924da390244f575d3e17063a8e"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("${username}:${password}")))
$headers = @{
    "Authorization" = "Basic $($base64AuthInfo)"
    "Content-Type"  = "application/json"
}

$csvPath = "C:\Temp\5387289_Export-ArchivedSeats_Loffler.csv"

$data = Import-Csv -Path $csvPath

foreach ($row in $data) {
    if ($row.seat_type -eq "User") {
        $count = $count + 1
        $customerID = $row.'SaaS Customer ID'
        $externalSubscriptionID = $row.externalSubscriptionId
        $seatID = $row.remoteId
        $seatType = $row.seat_type
        $apiUrl = $baseApiUrl -f $customerID, $externalSubscriptionID
    
        $body = @{
            seat_type   = "$seatType"
            action_type = "Unlicense"
            ids         = @("$seatID")
        }
    
        $body = $body | ConvertTo-Json
    
        $action = Invoke-RestMethod -Uri $apiUrl -Method 'Put' -Headers $headers -Body $body
        #Write-Output "Invoke-RestMethod -Uri $apiUrl -Method 'Put' -Headers $headers -Body $body"

        Write-Output "Action taken: $action"
        if ($action.status -ne "started") {
            Write-Output "Status other than success for: $seatID"
            $totalSuccess = $false
        }
        else {
            Write-Output "Success"
        }

    }

}
Write-Output "Updated $count items"
if ($totalSuccess) {
    Write-Output "Job went 100% smooth"
}
else {
    Write-Output "Job encountered some seats that may not have been deprovisioned, please run again."
}
Stop-Transcript
