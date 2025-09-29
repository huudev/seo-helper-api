<#
.SYNOPSIS
  install.ps1 - Install and set up seo-helper-api on Windows (PowerShell).
  powershell -ExecutionPolicy Bypass -File .\install.ps1
#>

[CmdletBinding()]
param(
    [switch]$Clone  # add this switch to choose git clone instead of zip download
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$currentDir = Get-Location
$currentDirName = Split-Path -Leaf $currentDir
$projectDirName = "seo-helper-api"
$projectDir = Join-Path $currentDir $projectDirName
$sourceCodeDirName = "seo-helper-api-main"
$sourceCodeDir = Join-Path $projectDir $sourceCodeDirName

function Stop-ScriptWithError {
    param([string]$message)
    Write-Host "Error: $message" -ForegroundColor Red
    exit 1
}

function New-DirectoryIfMissing {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Get-FileFromUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$url,

        [Parameter(Mandatory = $true)]
        [string]$destinationPath
    )

    # Nếu file đã tồn tại thì xoá trước
    if (Test-Path $destinationPath) {
        Remove-Item -Path $destinationPath -Force
    }

    Write-Host "Downloading from $url to $destinationPath..."
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($Url, $DestinationPath)
        Write-Host "Download completed!"
    }
    catch {
        Stop-ScriptWithError "Error downloading: $($_.Exception.Message)"
    }
}

function Test-ProcessUsingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
   
    Write-Host "Checking for processes using path: $Path"
   
    try {
        $processes = Get-Process | Where-Object {
            try {
                $_.Path -and $_.Path.StartsWith($Path, [System.StringComparison]::OrdinalIgnoreCase)
            } catch {
                $false
            }
        }
       
        if ($processes) {
            Write-Host "Found $($processes.Count) processes that may be using the path:"
            $processes | ForEach-Object {
                Write-Host "Process: $($_.Name) (PID: $($_.Id))"
            }
            return $processes
        }
        else {
            Write-Host "No processes found using the path"
            return $null
        }
    }
    catch {
        Write-Host "Could not check for processes using path: $($_.Exception.Message)"
        return $null
    }
}

function Install-Jdk8 {
    Write-Host "=== Running Install-Jdk8..."
    $targetDir = Join-Path $projectDir "jdk8"
    $javaPath = Join-Path $targetDir "bin\java.exe"
    if (Test-Path $javaPath) {
        Write-Host "Java found in $javaPath"
        return
    }

    $downloadUrl = "https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u462-b08/OpenJDK8U-jdk_x64_windows_hotspot_8u462b08.zip"

    try {
        $javaVersion = cmd /c "java -version 2>&1"
        if ($javaVersion -match 'version "1\.8') {
            Write-Host "JDK 1.8 already installed. Skipping download."
            return
        }
        else {
            Write-Host "Java found but not 1.8. Downloading JDK 1.8..."
        }
    }
    catch {
        Write-Host "Java not found: $($_.Exception.Message)"
        Write-Host "Downloading JDK 1.8..."
    }

    $zipPath = Join-Path $projectDir "jdk8.zip"

    Get-FileFromUrl $downloadUrl $zipPath

    try {
        Expand-Archive -Path $zipPath -DestinationPath $projectDir -Force
        Remove-Item $zipPath -Force
        Write-Host "Extracted JDK 1.8 to $projectDir"
    }
    catch {
        Stop-ScriptWithError "Error extracting JDK: $($_.Exception.Message)"
    }

    $jdk8ExtractDir = Join-Path $projectDir "jdk8u462-b08"
    Test-ProcessUsingPath -Path $jdk8ExtractDir  
    Rename-Item -Path $jdk8ExtractDir -NewName $targetDir
}

function Install-Python310 {
    Write-Host "=== Running Install-Python310..."
    irm https://astral.sh/uv/install.ps1 | iex
    $env:Path = "$HOME\.local\bin;$env:Path"
    uv venv --python 3.10 --directory $sourceCodeDir
    uv pip install -r requirements.txt --directory $sourceCodeDir
}

function Get-SeoHelperApiSource {
    Write-Host "=== Getting seo-helper-api source..."

    if (Test-Path $sourceCodeDir) {
        Remove-Item -Recurse -Force $sourceCodeDir
        Write-Host "Removed old '$sourceCodeDir'"
    }

    if ($Clone) {
        Write-Host "Cloning seo-helper-api from GitHub..."
        git clone https://github.com/huudev/seo-helper-api.git $sourceCodeDir
        Write-Host "Cloned repo to '$sourceCodeDir'"
    }
    else {
        $zipUrl = "https://github.com/huudev/seo-helper-api/archive/refs/heads/main.zip"
        $zipPath = Join-Path $projectDir "seo-helper-api-main.zip"

        Get-FileFromUrl $zipUrl $zipPath

        Write-Host "Extracting source code..."
        Expand-Archive -Path $zipPath -DestinationPath $projectDir -Force
        Remove-Item $zipPath -Force

        Write-Host "Source code ready at '$projectDirName'"
    }
}

Write-Host "Starting installation..."

# Prevent running inside seo-helper-api itself
if (($currentDirName -ieq $projectDirName) -or ($currentDirName -ieq $sourceCodeDirName)) {
    Stop-ScriptWithError "You are already inside '$projectDirName'. Please run this script from another folder."
}

New-DirectoryIfMissing $projectDir

Get-SeoHelperApiSource
Install-Jdk8
Install-Python310

Write-Host "All done!"



