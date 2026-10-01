# Windows entry point for tools/dev.sh (the commands are documented there): runs it with Git Bash.
#   powershell -File tools\dev.ps1 <command> [args]
$bash = @("$env:ProgramFiles\Git\bin\bash.exe", "${env:ProgramFiles(x86)}\Git\bin\bash.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $bash) { Write-Error "Git Bash not found: install Git for Windows, or run tools/dev.sh from any bash."; exit 2 }
& $bash (Join-Path $PSScriptRoot "dev.sh") @args
exit $LASTEXITCODE
