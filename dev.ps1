[CmdletBinding()]
param(
    # If user supplies -Reload on the command line, $Reload = $true
    [switch]$Reload
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sourceCodeDir = Get-Location

# Get absolute path of the project directory (parent of current dir)
$projectDir = Split-Path -Path $sourceCodeDir -Parent

$jdkDir    = Join-Path $projectDir 'jdk8'
$jdkBinDir = Join-Path $jdkDir 'bin'
$javaExe   = Join-Path $jdkBinDir 'java.exe'

if (Test-Path $javaExe) {
    # Set JAVA_HOME for the current session
    $env:JAVA_HOME = $jdkDir
    Write-Host "JAVA_HOME has been set to $env:JAVA_HOME"
    $env:Path = "$jdkBinDir;$env:Path"
} else {
    Write-Host "java.exe not found at $javaExe"
}

# Build the uvicorn arguments
$reloadArg = @()
if ($Reload) { $reloadArg += '--reload' }

uv run uvicorn app.main:app @reloadArg --host 0.0.0.0 --port 8000
