# Warehouse Management System (WMS) - Comprehensive Verification Test Suite
# Tests all requirements from SCRUM-8, SCRUM-9, SCRUM-10, and SCRUM-11 using .NET HttpWebRequest

$ErrorActionPreference = "Continue"

$BaseUrl = "http://localhost:8080/wms/api"
$Results = @()

function Execute-Test {
    param (
        [string]$TestId,
        [string]$Module,
        [string]$Description,
        [string]$Method,
        [string]$Endpoint,
        [string]$JsonBody,
        [int]$ExpectedStatus,
        [string]$ExpectedSubstr
    )

    $url = "$BaseUrl$Endpoint"
    $actualStatus = 0
    $actualBody = ""

    try {
        $req = [System.Net.HttpWebRequest]::Create($url)
        $req.Method = $Method
        $req.ContentType = "application/json; charset=utf-8"
        $req.Timeout = 10000

        if ($JsonBody) {
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($JsonBody)
            $req.ContentLength = $bytes.Length
            $reqStream = $req.GetRequestStream()
            $reqStream.Write($bytes, 0, $bytes.Length)
            $reqStream.Close()
        }

        $resp = $req.GetResponse()
        $actualStatus = [int]$resp.StatusCode
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream(), [System.Text.Encoding]::UTF8)
        $actualBody = $reader.ReadToEnd()
        $reader.Close()
        $resp.Close()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $webResp = [System.Net.HttpWebResponse]$_.Exception.Response
            $actualStatus = [int]$webResp.StatusCode
            $reader = New-Object System.IO.StreamReader($webResp.GetResponseStream(), [System.Text.Encoding]::UTF8)
            $actualBody = $reader.ReadToEnd()
            $reader.Close()
            $webResp.Close()
        } else {
            $actualBody = $_.Exception.Message
        }
    } catch {
        $actualBody = $_.Exception.Message
    }

    $statusMatch = ($actualStatus -eq $ExpectedStatus)
    $bodyMatch = if ($ExpectedSubstr) { ($actualBody -like "*$ExpectedSubstr*") } else { $true }
    $passed = ($statusMatch -and $bodyMatch)

    $color = if ($passed) { "Green" } else { "Red" }
    $mark = if ($passed) { "[PASS]" } else { "[FAIL]" }

    Write-Host "$mark $TestId ($Module): $Description" -ForegroundColor $color
    Write-Host "       HTTP: $actualStatus (Expected: $ExpectedStatus) | Substring match: $bodyMatch" -ForegroundColor DarkGray
    if (-not $passed) {
        Write-Host "       Actual Body: $actualBody" -ForegroundColor Yellow
        Write-Host "       Expected to contain: $ExpectedSubstr" -ForegroundColor Yellow
    }

    $ResultObj = [PSCustomObject]@{
        TestId         = $TestId
        Module         = $Module
        Description    = $Description
        Method         = $Method
        Endpoint       = $Endpoint
        ExpectedStatus = $ExpectedStatus
        ActualStatus   = $actualStatus
        ExpectedSubstr = $ExpectedSubstr
        StatusMatch    = $statusMatch
        BodyMatch      = $bodyMatch
        Passed         = $passed
        ActualBody     = $actualBody
    }

    return $ResultObj
}

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "      WAREHOUSE MANAGEMENT SYSTEM (WMS) - COMPREHENSIVE TEST SUITE     " -ForegroundColor Cyan
Write-Host "      Testing SCRUM-8, SCRUM-9, SCRUM-10, SCRUM-11 Execution          " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

# ----------------- MODULE 1: PRODUCT MANAGEMENT (SCRUM-8) -----------------
Write-Host "`n>>> [SCRUM-8] Product Creation and Listing Tests" -ForegroundColor Yellow

$Results += Execute-Test -TestId "TC-01" -Module "SCRUM-8" `
    -Description "Create new product with valid required fields" `
    -Method "POST" -Endpoint "/products" `
    -JsonBody '{"productId":"PRD-801","name":"Barcode Handheld Terminal","category":"Barcode & Scanning","unitPrice":"349.50","description":"Rugged Android scanner"}' `
    -ExpectedStatus 201 -ExpectedSubstr "created successfully"

$Results += Execute-Test -TestId "TC-02" -Module "SCRUM-8" `
    -Description "Reject creation when Product ID is missing" `
    -Method "POST" -Endpoint "/products" `
    -JsonBody '{"productId":"","name":"Barcode Scanner","category":"Barcode & Scanning","unitPrice":"349.50"}' `
    -ExpectedStatus 400 -ExpectedSubstr "Product ID is required"

$Results += Execute-Test -TestId "TC-03" -Module "SCRUM-8" `
    -Description "Reject creation when Product Name is missing" `
    -Method "POST" -Endpoint "/products" `
    -JsonBody '{"productId":"PRD-802","name":"","category":"Barcode & Scanning","unitPrice":"349.50"}' `
    -ExpectedStatus 400 -ExpectedSubstr "Product name is required"

$Results += Execute-Test -TestId "TC-04" -Module "SCRUM-8" `
    -Description "Reject creation when Category is missing" `
    -Method "POST" -Endpoint "/products" `
    -JsonBody '{"productId":"PRD-803","name":"Industrial Label Printer","category":"","unitPrice":"219.00"}' `
    -ExpectedStatus 400 -ExpectedSubstr "Category is required"

$Results += Execute-Test -TestId "TC-05" -Module "SCRUM-8" `
    -Description "Reject creation when Unit Price is missing" `
    -Method "POST" -Endpoint "/products" `
    -JsonBody '{"productId":"PRD-804","name":"Thermal Ribbon","category":"Packaging Supplies","unitPrice":""}' `
    -ExpectedStatus 400 -ExpectedSubstr "Unit price is required"

$Results += Execute-Test -TestId "TC-06" -Module "SCRUM-8" `
    -Description "Reject creation when Unit Price is zero or negative" `
    -Method "POST" -Endpoint "/products" `
    -JsonBody '{"productId":"PRD-805","name":"Packing Tape Roll","category":"Packaging Supplies","unitPrice":"-12.00"}' `
    -ExpectedStatus 400 -ExpectedSubstr "greater than zero"

$Results += Execute-Test -TestId "TC-07" -Module "SCRUM-8" `
    -Description "Reject creation when Unit Price is non-numeric" `
    -Method "POST" -Endpoint "/products" `
    -JsonBody '{"productId":"PRD-806","name":"Stretch Wrap Film","category":"Packaging Supplies","unitPrice":"cheap"}' `
    -ExpectedStatus 400 -ExpectedSubstr "valid number"

$Results += Execute-Test -TestId "TC-08" -Module "SCRUM-8" `
    -Description "Reject creation when Product ID already exists (Duplicate Check)" `
    -Method "POST" -Endpoint "/products" `
    -JsonBody '{"productId":"PRD-801","name":"Duplicate Scanner","category":"Barcode & Scanning","unitPrice":"400.00"}' `
    -ExpectedStatus 409 -ExpectedSubstr "already exists"

$Results += Execute-Test -TestId "TC-09" -Module "SCRUM-8" `
    -Description "Display all products (Catalog Listing)" `
    -Method "GET" -Endpoint "/products" `
    -JsonBody "" `
    -ExpectedStatus 200 -ExpectedSubstr "PRD-801"

$Results += Execute-Test -TestId "TC-10" -Module "SCRUM-8" `
    -Description "Retrieve single product details by ID" `
    -Method "GET" -Endpoint "/products?id=PRD-801" `
    -JsonBody "" `
    -ExpectedStatus 200 -ExpectedSubstr "Barcode Handheld Terminal"

# ----------------- MODULE 2: PRODUCT UPDATE (SCRUM-9) -----------------
Write-Host "`n>>> [SCRUM-9] Product Update Tests" -ForegroundColor Yellow

$Results += Execute-Test -TestId "TC-11" -Module "SCRUM-9" `
    -Description "Update existing product details (name, category, price, description)" `
    -Method "PUT" -Endpoint "/products" `
    -JsonBody '{"productId":"PRD-801","name":"Barcode Terminal Pro 5G","category":"Barcode & Scanning","unitPrice":"399.99","description":"Updated 5G enabled warehouse scanner"}' `
    -ExpectedStatus 200 -ExpectedSubstr "updated successfully"

$Results += Execute-Test -TestId "TC-12" -Module "SCRUM-9" `
    -Description "Reject update when Product Name is empty" `
    -Method "PUT" -Endpoint "/products" `
    -JsonBody '{"productId":"PRD-801","name":"","category":"Barcode & Scanning","unitPrice":"399.99"}' `
    -ExpectedStatus 400 -ExpectedSubstr "Product name is required"

$Results += Execute-Test -TestId "TC-13" -Module "SCRUM-9" `
    -Description "Reject update when Unit Price is negative" `
    -Method "PUT" -Endpoint "/products" `
    -JsonBody '{"productId":"PRD-801","name":"Barcode Terminal Pro","category":"Barcode & Scanning","unitPrice":"-50.00"}' `
    -ExpectedStatus 400 -ExpectedSubstr "greater than zero"

$Results += Execute-Test -TestId "TC-14" -Module "SCRUM-9" `
    -Description "Reject update for non-existent product ID" `
    -Method "PUT" -Endpoint "/products" `
    -JsonBody '{"productId":"NON-EXIST-999","name":"Ghost Scanner","category":"Tools & Hardware","unitPrice":"99.00"}' `
    -ExpectedStatus 404 -ExpectedSubstr "not found"

# ----------------- MODULE 3: INVENTORY MANAGEMENT (SCRUM-10) -----------------
Write-Host "`n>>> [SCRUM-10] Inventory Management & Stock Operation Tests" -ForegroundColor Yellow

$Results += Execute-Test -TestId "TC-15" -Module "SCRUM-10" `
    -Description "View current warehouse inventory and stock levels" `
    -Method "GET" -Endpoint "/inventory" `
    -JsonBody "" `
    -ExpectedStatus 200 -ExpectedSubstr "PRD-801"

$Results += Execute-Test -TestId "TC-16" -Module "SCRUM-10" `
    -Description "Add stock quantity (Inward Receiving: +100 units)" `
    -Method "POST" -Endpoint "/inventory" `
    -JsonBody '{"action":"add","productId":"PRD-801","quantity":"100"}' `
    -ExpectedStatus 200 -ExpectedSubstr "Successfully added 100 unit"

$Results += Execute-Test -TestId "TC-17" -Module "SCRUM-10" `
    -Description "Reduce stock quantity (Outward Dispatch: -30 units)" `
    -Method "POST" -Endpoint "/inventory" `
    -JsonBody '{"action":"reduce","productId":"PRD-801","quantity":"30"}' `
    -ExpectedStatus 200 -ExpectedSubstr "Successfully reduced 30 unit"

$Results += Execute-Test -TestId "TC-18" -Module "SCRUM-10" `
    -Description "Reject stock adjustment with zero quantity" `
    -Method "POST" -Endpoint "/inventory" `
    -JsonBody '{"action":"add","productId":"PRD-801","quantity":"0"}' `
    -ExpectedStatus 400 -ExpectedSubstr "greater than zero"

$Results += Execute-Test -TestId "TC-19" -Module "SCRUM-10" `
    -Description "Reject stock adjustment with negative quantity" `
    -Method "POST" -Endpoint "/inventory" `
    -JsonBody '{"action":"add","productId":"PRD-801","quantity":"-25"}' `
    -ExpectedStatus 400 -ExpectedSubstr "greater than zero"

$Results += Execute-Test -TestId "TC-20" -Module "SCRUM-10" `
    -Description "Reject stock adjustment with non-numeric quantity" `
    -Method "POST" -Endpoint "/inventory" `
    -JsonBody '{"action":"add","productId":"PRD-801","quantity":"two-dozen"}' `
    -ExpectedStatus 400 -ExpectedSubstr "valid whole number"

$Results += Execute-Test -TestId "TC-21" -Module "SCRUM-10" `
    -Description "Prevent reductions greater than available stock (Negative Inventory Prevention)" `
    -Method "POST" -Endpoint "/inventory" `
    -JsonBody '{"action":"reduce","productId":"PRD-801","quantity":"500"}' `
    -ExpectedStatus 400 -ExpectedSubstr "Current stock is only 70"

$Results += Execute-Test -TestId "TC-22" -Module "SCRUM-10" `
    -Description "Handle inventory adjustment for non-existent product ID" `
    -Method "POST" -Endpoint "/inventory" `
    -JsonBody '{"action":"add","productId":"UNKNOWN-SKU-999","quantity":"10"}' `
    -ExpectedStatus 404 -ExpectedSubstr "not found"

# ----------------- FINAL REPORT -----------------
$Total = $Results.Count
$Passed = ($Results | Where-Object { $_.Passed }).Count
$Failed = $Total - $Passed

Write-Host "`n======================================================================" -ForegroundColor Cyan
Write-Host "                        FINAL TEST RESULTS                            " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host " Total Scenarios Tested:  $Total" -ForegroundColor White
Write-Host " Tests PASSED:            $Passed" -ForegroundColor Green
Write-Host " Tests FAILED:            $Failed" -ForegroundColor $(if ($Failed -gt 0) { "Red" } else { "Green" })
Write-Host "======================================================================" -ForegroundColor Cyan

$CsvPath = "c:\Users\vidhi\OneDrive\Desktop\Jira project\test\test_results.csv"
$Results | Select-Object TestId, Module, Description, Method, Endpoint, ExpectedStatus, ActualStatus, Passed, ActualBody | Export-Csv -Path $CsvPath -NoTypeInformation
Write-Host "Test results exported to: $CsvPath" -ForegroundColor DarkGray

if ($Failed -eq 0) {
    Write-Host "ALL 22 TESTS PASSED PERFECTLY! System meets all requirements." -ForegroundColor Green
} else {
    Write-Host "Some tests failed. Check actual body output above." -ForegroundColor Red
}
