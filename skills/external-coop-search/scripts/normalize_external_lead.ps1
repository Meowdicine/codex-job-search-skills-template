param(
    [Parameter(Mandatory = $true)]
    [string]$Company,

    [Parameter(Mandatory = $true)]
    [string]$Role,

    [string]$Location = "",
    [string]$SourceUrl = "",
    [string]$RequisitionId = "",
    [string]$Date = (Get-Date -Format "yyyyMMdd"),
    [string]$JobHuntingPath = ""
)

$ErrorActionPreference = "Stop"

function Convert-ToSlug {
    param([string]$Value)
    $slug = $Value.ToLowerInvariant()
    $slug = $slug -replace "&", " and "
    $slug = $slug -replace "[^a-z0-9]+", "-"
    $slug = $slug.Trim("-")
    if ([string]::IsNullOrWhiteSpace($slug)) {
        return "unknown"
    }
    return $slug
}

function Get-TokenSet {
    param([string]$Value)
    $stop = @("the","and","for","with","coop","co-op","intern","student","developer","engineer","engineering")
    $tokens = @()
    foreach ($token in ((Convert-ToSlug $Value) -split "-")) {
        if ($token.Length -ge 3 -and $stop -notcontains $token -and $token -notmatch "^\d+$") {
            $tokens += $token
        }
    }
    return @($tokens | Select-Object -Unique)
}

$companySlug = Convert-ToSlug $Company
$roleSlug = Convert-ToSlug $Role
$locationSlug = if ([string]::IsNullOrWhiteSpace($Location)) { "unknown-location" } else { Convert-ToSlug $Location }
$reqSlug = if ([string]::IsNullOrWhiteSpace($RequisitionId)) { $locationSlug } else { Convert-ToSlug $RequisitionId }
$stableId = "public-$companySlug-$roleSlug-$reqSlug-$Date"

$duplicates = @()
if ($JobHuntingPath -and (Test-Path -LiteralPath $JobHuntingPath)) {
    $queue = Get-Content -Raw -LiteralPath $JobHuntingPath | ConvertFrom-Json
    $items = @($queue.pipeline)
    $candidateTokens = @(Get-TokenSet $Role)

    foreach ($item in $items) {
        $sameId = [string]$item.id -eq $stableId
        $sameUrl = $SourceUrl -and ([string]$item.sourceUrl -eq $SourceUrl)
        $sameCompany = (Convert-ToSlug ([string]$item.company)) -eq $companySlug
        $itemTokens = @(Get-TokenSet ([string]$item.role))
        $overlap = @($candidateTokens | Where-Object { $itemTokens -contains $_ }).Count
        $similarRole = $candidateTokens.Count -gt 0 -and $overlap -ge [Math]::Min(3, $candidateTokens.Count)

        if ($sameId -or $sameUrl -or ($sameCompany -and $similarRole)) {
            $duplicates += [pscustomobject]@{
                id = $item.id
                company = $item.company
                role = $item.role
                status = $item.status
                reason = if ($sameId) { "same-id" } elseif ($sameUrl) { "same-url" } else { "same-company-similar-role" }
            }
        }
    }
}

[pscustomobject]@{
    id = $stableId
    company = $Company
    role = $Role
    location = $Location
    sourceUrl = $SourceUrl
    requisitionId = $RequisitionId
    duplicateHints = $duplicates
} | ConvertTo-Json -Depth 6
