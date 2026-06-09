param(
    [Parameter(Mandatory = $true)]
    [string]$QueuePath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $QueuePath)) {
    throw "QueuePath not found: $QueuePath"
}

$data = Get-Content -Raw -LiteralPath $QueuePath | ConvertFrom-Json
$items = @($data.pipeline)

function Get-Number {
    param($Value, [double]$Default = 0)
    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) { return $Default }
    try { return [double]$Value } catch { return $Default }
}

function Get-DeadlineUrgency {
    param($Value)
    if ([string]::IsNullOrWhiteSpace([string]$Value)) { return 2.5 }
    try {
        $deadline = [datetime]$Value
        $days = ($deadline.Date - (Get-Date).Date).TotalDays
        if ($days -lt 0) { return -2.0 }
        if ($days -le 1) { return 5.0 }
        if ($days -le 3) { return 4.2 }
        if ($days -le 7) { return 3.5 }
        return 2.5
    }
    catch {
        return 2.5
    }
}

function Get-LaneBoost {
    param($Value)
    switch -Regex ([string]$Value) {
        "priority|apply-now" { return 5.0 }
        "backup|fit-check" { return 3.5 }
        "practice|watch" { return 2.0 }
        default { return 3.0 }
    }
}

$scored = foreach ($item in $items) {
    $fit = Get-Number $item.fitScore 3.0
    $salary = Get-Number $item.salaryScore 3.0
    $deadlineUrgency = Get-DeadlineUrgency $item.deadline
    $laneBoost = Get-LaneBoost $item.status
    $friction = Get-Number $item.friction 0.0
    $score = [Math]::Round(($fit * 0.45) + ($salary * 0.20) + ($deadlineUrgency * 0.25) + ($laneBoost * 0.10) - $friction, 2)

    [pscustomobject]@{
        id = $item.id
        company = $item.company
        role = $item.role
        deadline = $item.deadline
        status = $item.status
        fitScore = $item.fitScore
        priorityScore = $score
        sourceUrl = $item.sourceUrl
        next = $item.next
    }
}

$scored | Sort-Object priorityScore -Descending | ConvertTo-Json -Depth 6
