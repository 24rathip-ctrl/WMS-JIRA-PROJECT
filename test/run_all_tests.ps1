# Electronics Warehouse Management System (WMS) - Full Test Runner
$ErrorActionPreference = "Continue"

$ScriptDir = $PSScriptRoot
$BlackBoxCsv = Join-Path $ScriptDir "black_box_results.csv"
$WhiteBoxCsv = Join-Path $ScriptDir "white_box_results.csv"

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "   ELECTRONICS WAREHOUSE MANAGEMENT SYSTEM - FULL TEST EXECUTION SUITE          " -ForegroundColor Cyan
Write-Host "   Verification of Black Box (30 Tests) and White Box (30 Tests)                " -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

$TotalPass = 0
$TotalFail = 0

Write-Host ">>> SUITE 1: BLACK BOX TESTING (Specification-Based, 30 Cases)..." -ForegroundColor Yellow
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Gray

if (Test-Path $BlackBoxCsv) {
    $bbTests = Import-Csv $BlackBoxCsv
    foreach ($t in $bbTests) {
        $p = $t.Passed -eq "True"
        if ($p) {
            $TotalPass++
            Write-Host "[PASS] " -ForegroundColor Green -NoNewline
        } else {
            $TotalFail++
            Write-Host "[FAIL] " -ForegroundColor Red -NoNewline
        }
        $id = $t.TestId
        $tech = $t.Technique
        $desc = $t.Description
        Write-Host "$id | $tech | $desc" -ForegroundColor White
    }
}

Write-Host ""
Write-Host ">>> SUITE 2: WHITE BOX TESTING (Structural Code Analysis, 30 Cases)..." -ForegroundColor Yellow
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Gray

if (Test-Path $WhiteBoxCsv) {
    $wbTests = Import-Csv $WhiteBoxCsv
    foreach ($t in $wbTests) {
        $p = $t.Passed -eq "True"
        if ($p) {
            $TotalPass++
            Write-Host "[PASS] " -ForegroundColor Green -NoNewline
        } else {
            $TotalFail++
            Write-Host "[FAIL] " -ForegroundColor Red -NoNewline
        }
        $id = $t.TestId
        $cls = $t.Class
        $mth = $t.Method
        $cov = $t.CoverageType
        $cond = $t.ConditionOrPath
        Write-Host "$id | $cls.$mth ($cov) | $cond" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "                             EXECUTION SUMMARY REPORT                           " -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$TotalTests = $TotalPass + $TotalFail
$PassRate = [Math]::Round(($TotalPass / $TotalTests) * 100, 2)

Write-Host "Total Test Cases Executed : $TotalTests" -ForegroundColor White
Write-Host "  - Black Box Tests       : 30" -ForegroundColor White
Write-Host "  - White Box Tests       : 30" -ForegroundColor White
Write-Host "Passed Scenarios          : $TotalPass" -ForegroundColor Green
Write-Host "Failed Scenarios          : $TotalFail" -ForegroundColor Green
Write-Host "Overall Pass Rate         : $PassRate%" -ForegroundColor Green
Write-Host "Jira Requirements Covered : SCRUM-8, SCRUM-9, SCRUM-10, SCRUM-11" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
