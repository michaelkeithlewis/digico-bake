$ErrorActionPreference="Stop"
$b="https://raw.githubusercontent.com/michaelkeithlewis/digico-bake/master"
Set-Location $env:USERPROFILE\Desktop
Invoke-WebRequest "$b/install-digico.ps1" -OutFile install-digico.ps1 -UseBasicParsing
Invoke-WebRequest "$b/manifest.json" -OutFile manifest.json -UseBasicParsing
powershell -ExecutionPolicy Bypass -File .\install-digico.ps1 -ManifestPath .\manifest.json
