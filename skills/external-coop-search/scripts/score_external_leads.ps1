param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $InputPath)) {
    throw "InputPath not found: $InputPath"
}

$data = Get-Content -Raw -LiteralPath $InputPath | ConvertFrom-Json
$leads = if ($data.pipeline) { @($data.pipeline) } else { @($data) }

function Get-Number {
    param($Value, [double]$Default = 0)
    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) { return $Default }
    try { return [double]$Value } catch { return $Default }
}

function Get-Status {
    param([double]$Score, [object[]]$HardGates)
    $gateText = ($HardGates -join " ").ToLowerInvariant()
    if ($gateText -match "closed|expired|senior-only|unpaid|blocked") { return "skip" }
    if ($gateText -match "manual|clearance|citizenship|relocation|work authorization|driver|license|mirror") { return "manual-review" }
    if ($Score -ge 4.2) { return "apply-now" }
    if ($Score -ge 3.7) { return "fit-check" }
    if ($Score -ge 3.2) { return "lead-inbox" }
    return "watch-only"
}

$scored = foreach ($lead in $leads) {
    $resumeFit = Get-Number $lead.resumeFit 3.0
    $coOpLegality = Get-Number $lead.coOpLegality 3.0
    $careerDirection = Get-Number $lead.careerDirection 3.0
    $salary = Get-Number $lead.salaryScore 3.0
    $city = Get-Number $lead.cityScore 3.0
    $brand = Get-Number $lead.brandOrReferral 3.0
    $friction = Get-Number $lead.friction 0.0

    $score = [Math]::Round(
        ($resumeFit * 0.35) +
        ($coOpLegality * 0.25) +
        ($careerDirection * 0.15) +
        ($salary * 0.10) +
        ($city * 0.05) +
        ($brand * 0.10) -
        $friction,
        2
    )

    $hardGates = @($lead.hardGates)
    [pscustomobject]@{
        id = $lead.id
        company = $lead.company
        role = $lead.role
        sourceUrl = $lead.sourceUrl
        fitScore = $score
        recommendedStatus = Get-Status -Score $score -HardGates $hardGates
        resumeVersion = $lead.resumeVersion
        hardGates = $hardGates
    }
}

$scored | Sort-Object fitScore -Descending | ConvertTo-Json -Depth 6
