<#
  Run this ON the AppStream Image Builder (connect in as Administrator, open
  PowerShell). It reads manifest.json and, for each editor:
    1. downloads the installer ZIP from digico.biz,
    2. extracts it (each zip = an NSIS .exe installer + 2 PDFs),
    3. runs the .exe silently (silentArgs, default /S),
    4. locates the installed editor binary (payloadExe) and registers it with the
       AppStream Image Assistant so it becomes a launchable app.
  The broker then picks which to launch per session via ?app=<key>.

  Copy BOTH this script and manifest.json onto the box, then:
     powershell -ExecutionPolicy Bypass -File .\install-digico.ps1 -ManifestPath .\manifest.json
#>

param(
  [string]$ManifestPath = ".\manifest.json"
)

$ErrorActionPreference = "Stop"
$work = "C:\digico-install"
New-Item -ItemType Directory -Force -Path $work | Out-Null

$manifest = Get-Content -Raw $ManifestPath | ConvertFrom-Json
$ia = "C:\Program Files\Amazon\Photon\ConsoleImageBuilder\image-assistant.exe"

$installed = @()
$failed    = @()

foreach ($ed in $manifest.editors) {
  Write-Host "`n=== $($ed.displayName)  [$($ed.key)] ==="

  if ($ed.installerUrl -like "*PASTE-*") {
    Write-Warning "  installerUrl not set for '$($ed.key)' - skipping."
    $failed += $ed.key; continue
  }

  try {
    $zip = Join-Path $work ([System.IO.Path]::GetFileName(($ed.installerUrl -split '\?')[0]))
    Write-Host "  Downloading $($ed.installerUrl)"
    Invoke-WebRequest -Uri $ed.installerUrl -OutFile $zip -UseBasicParsing

    # Extract the zip into its own folder.
    $exdir = Join-Path $work ($ed.key + "_ex")
    if (Test-Path $exdir) { Remove-Item -Recurse -Force $exdir }
    Write-Host "  Extracting"
    Expand-Archive -Path $zip -DestinationPath $exdir -Force

    # The installer is the .exe inside (ignore PDFs).
    $installer = Get-ChildItem $exdir -Recurse -Filter *.exe |
                 Where-Object { $_.Name -match 'Installer' } |
                 Select-Object -First 1 -ExpandProperty FullName
    if (-not $installer) {
      $installer = Get-ChildItem $exdir -Recurse -Filter *.exe |
                   Select-Object -First 1 -ExpandProperty FullName
    }
    if (-not $installer) { throw "no .exe found inside $zip" }

    $args = if ($ed.silentArgs) { $ed.silentArgs } else { "/S" }
    Write-Host "  Installing silently: $installer $args"
    Start-Process $installer -ArgumentList ($args -split '\s+') -Wait

    # Locate the installed editor binary by its known name (payloadExe).
    # DiGiCo editors install to C:\<model>\ (NOT Program Files), so scan the C:\ root too.
    $needle = if ($ed.payloadExe) { $ed.payloadExe } else { "*.exe" }
    $exe = Get-ChildItem "C:\","C:\Program Files","C:\Program Files (x86)" -Depth 3 -Filter $needle -File -ErrorAction SilentlyContinue |
           Select-Object -First 1 -ExpandProperty FullName

    if (-not $exe) {
      Write-Warning "  Installed but could not find $needle under Program Files. Register '$($ed.appId)' manually in Image Assistant."
      $failed += $ed.key; continue
    }

    Write-Host "  Editor exe: $exe"
    if (Test-Path $ia) {
      & $ia add-application --name $ed.appId --absolute-app-path "$exe" --display-name "$($ed.displayName)"
      Write-Host "  Registered app id '$($ed.appId)'."
      $installed += $ed.appId
    } else {
      Write-Warning "  image-assistant.exe not found; add '$($ed.appId)' via the Image Builder UI."
    }
  }
  catch {
    Write-Warning "  FAILED '$($ed.key)': $($_.Exception.Message)"
    $failed += $ed.key
  }
}

Write-Host "`n========================================"
Write-Host "Registered app ids: $($installed -join ', ')"
if ($failed.Count) { Write-Warning "Needs attention: $($failed -join ', ')" }
Write-Host "Launch each once to confirm it opens, then in Image Assistant:"
Write-Host "  Save settings -> Optimize -> Build image (name it your IMAGE_NAME)."
Write-Host "The deploy step reads manifest.json to build the runtime allowlist automatically."
