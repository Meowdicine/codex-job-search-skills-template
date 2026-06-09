param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("set", "get", "list", "remove")]
    [string]$Action,

    [string]$Site = "",
    [string]$Username = "",
    [string]$Password = "",
    [switch]$CopyPasswordToClipboard,
    [switch]$ConfirmRemove
)

$ErrorActionPreference = "Stop"

$vaultRoot = Join-Path $env:LOCALAPPDATA "CodexJobSearch\credentials"

function Convert-ToSiteKey {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "Site is required for this action."
    }
    $key = $Value.ToLowerInvariant()
    $key = $key -replace "^https?://", ""
    $key = $key -replace "[^a-z0-9.-]+", "-"
    $key = $key.Trim("-")
    if ([string]::IsNullOrWhiteSpace($key)) {
        throw "Site key could not be derived."
    }
    return $key
}

function Get-CredentialPath {
    param([string]$SiteValue)
    $siteKey = Convert-ToSiteKey -Value $SiteValue
    return Join-Path $vaultRoot "$siteKey.json"
}

function Protect-Password {
    param([string]$PlainText)
    $secure = ConvertTo-SecureString -String $PlainText -AsPlainText -Force
    return ConvertFrom-SecureString -SecureString $secure
}

function Unprotect-Password {
    param([string]$Encrypted)
    $secure = ConvertTo-SecureString -String $Encrypted
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}

function Read-SecretFromConsole {
    $secure = Read-Host -Prompt "Enter isolated job-site password" -AsSecureString
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}

New-Item -ItemType Directory -Force -Path $vaultRoot | Out-Null

switch ($Action) {
    "set" {
        if ([string]::IsNullOrWhiteSpace($Username)) { throw "Username is required for set." }
        if ([string]::IsNullOrWhiteSpace($Password)) { $Password = Read-SecretFromConsole }
        $path = Get-CredentialPath -SiteValue $Site
        [pscustomobject]@{
            site = (Convert-ToSiteKey -Value $Site)
            username = $Username
            encryptedPassword = (Protect-Password -PlainText $Password)
            updatedAt = (Get-Date).ToString("o")
        } | ConvertTo-Json -Depth 4 | Set-Content -Path $path -Encoding UTF8
        [pscustomobject]@{ action = "set"; site = (Convert-ToSiteKey -Value $Site); passwordDisplayed = $false } | ConvertTo-Json
    }
    "get" {
        $path = Get-CredentialPath -SiteValue $Site
        if (-not (Test-Path -LiteralPath $path)) { throw "No stored credential found for site '$Site'." }
        $record = Get-Content -Raw -LiteralPath $path | ConvertFrom-Json
        $plain = Unprotect-Password -Encrypted ([string]$record.encryptedPassword)
        if ($CopyPasswordToClipboard) {
            Set-Clipboard -Value $plain
        }
        [pscustomobject]@{
            action = "get"
            site = $record.site
            username = $record.username
            passwordCopiedToClipboard = [bool]$CopyPasswordToClipboard
            passwordDisplayed = $false
        } | ConvertTo-Json
    }
    "list" {
        Get-ChildItem -Path $vaultRoot -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object {
            $record = Get-Content -Raw -LiteralPath $_.FullName | ConvertFrom-Json
            [pscustomobject]@{ site = $record.site; username = $record.username; updatedAt = $record.updatedAt }
        } | ConvertTo-Json -Depth 4
    }
    "remove" {
        if (-not $ConfirmRemove) { throw "Pass -ConfirmRemove to remove a stored credential." }
        $path = Get-CredentialPath -SiteValue $Site
        if (Test-Path -LiteralPath $path) {
            Remove-Item -LiteralPath $path
            [pscustomobject]@{ action = "removed"; site = (Convert-ToSiteKey -Value $Site) } | ConvertTo-Json
        }
        else {
            [pscustomobject]@{ action = "not-found"; site = (Convert-ToSiteKey -Value $Site) } | ConvertTo-Json
        }
    }
}
