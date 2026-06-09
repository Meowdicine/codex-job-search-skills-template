param(
    [Parameter(Mandatory = $true)]
    [string]$JsonPath,

    [Parameter(Mandatory = $true)]
    [string]$Id,

    [Parameter(Mandatory = $true)]
    [string]$Status,

    [string]$Next = "",
    [string]$Feedback = ""
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $JsonPath)) {
    throw "JsonPath not found: $JsonPath"
}

$data = Get-Content -Raw -LiteralPath $JsonPath | ConvertFrom-Json
if (-not $data.pipeline) {
    throw "Expected a top-level pipeline array."
}

$found = $false
foreach ($item in $data.pipeline) {
    if ([string]$item.id -eq $Id) {
        $item.status = $Status
        if ($Next) { $item.next = $Next }
        if ($Feedback) { $item.feedback = $Feedback }
        $found = $true
        break
    }
}

if (-not $found) {
    throw "No pipeline item found with id '$Id'."
}

$data | ConvertTo-Json -Depth 20 | Set-Content -Path $JsonPath -Encoding UTF8
[pscustomobject]@{ id = $Id; status = $Status; updated = $true } | ConvertTo-Json
