param(
    [Parameter(Mandatory = $true)]
    [string]$Root,

    [Parameter(Mandatory = $true)]
    [string]$PostingId,

    [Parameter(Mandatory = $true)]
    [string]$Company,

    [Parameter(Mandatory = $true)]
    [string]$Role
)

$ErrorActionPreference = "Stop"

function Convert-ToSlug {
    param([string]$Value)
    $slug = $Value.ToLowerInvariant()
    $slug = $slug -replace "&", " and "
    $slug = $slug -replace "[^a-z0-9]+", "-"
    $slug = $slug.Trim("-")
    if ([string]::IsNullOrWhiteSpace($slug)) { return "unknown" }
    return $slug
}

$folder = "{0}-{1}-{2}" -f (Convert-ToSlug $PostingId), (Convert-ToSlug $Company), (Convert-ToSlug $Role)
$packagePath = Join-Path $Root $folder

$dirs = @(
    "",
    "resume",
    "resume\archive",
    "cover-letter",
    "layout-qa",
    "chrome-evidence",
    "submission"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path (Join-Path $packagePath $dir) | Out-Null
}

$files = @{
    "JD.md" = "# JD`n`nStatus: pending extraction.`n"
    "fit-gate-verdict.md" = "# Fit / Gate Verdict`n`nStatus: pending.`n"
    "keyword-map.md" = "# Keyword Map`n`nStatus: pending.`n"
    "resume-change-summary.md" = "# Resume Change Summary`n`nStatus: pending.`n"
    "truthfulness-notes.md" = "# Truthfulness Notes`n`nStatus: pending.`n"
    "submit-checklist.md" = "# Submit Checklist`n`nStatus: pending.`n"
    "prep-notes.md" = "# Prep Notes`n`n"
    "approval-log.md" = "# Approval Log`n`nFinal submit clicked: no`nSecrets logged: no`n"
}

foreach ($name in $files.Keys) {
    $path = Join-Path $packagePath $name
    if (-not (Test-Path -LiteralPath $path)) {
        Set-Content -Path $path -Value $files[$name] -Encoding UTF8
    }
}

$posting = [pscustomobject]@{
    postingId = $PostingId
    company = $Company
    role = $Role
    createdAt = (Get-Date).ToString("o")
}
$posting | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $packagePath "posting.json") -Encoding UTF8

[pscustomobject]@{
    packagePath = $packagePath
    postingId = $PostingId
    company = $Company
    role = $Role
} | ConvertTo-Json -Depth 5
