# Register the already-installed DiGiCo editors with the AppStream Image Assistant,
# using the real install paths (C:\<model>\<exe>). No re-download / re-install.
$ia = "C:\Program Files\Amazon\Photon\ConsoleImageBuilder\image-assistant.exe"
$apps = @(
  @{ id="DiGiCoQuantum7";   name="DiGiCo Quantum 7 / 112 Offline";   path="C:\Quantum7\SD7Q.exe" },
  @{ id="DiGiCoQuantum5";   name="DiGiCo Quantum 5 Offline";         path="C:\Quantum5\Quantum5.exe" },
  @{ id="DiGiCoQuantum852"; name="DiGiCo Quantum 852 Offline";       path="C:\Quantum8\Quantum8.exe" },
  @{ id="DiGiCoQuantum338"; name="DiGiCo Quantum 326 and 338 Offline"; path="C:\Quantum3\Quantum3.exe" },
  @{ id="DiGiCoQuantum225"; name="DiGiCo Quantum 225 Offline";       path="C:\Quantum2\Quantum2.exe" },
  @{ id="DiGiCoSD5";   name="DiGiCo SD5 Offline";    path="C:\SD5\SD5.exe" },
  @{ id="DiGiCoSD5CS"; name="DiGiCo SD5 CS Offline"; path="C:\SD5CS\SD5CS.exe" },
  @{ id="DiGiCoSD7";   name="DiGiCo SD7 Offline";    path="C:\SD7\SD7.exe" },
  @{ id="DiGiCoSD8";   name="DiGiCo SD8 Offline";    path="C:\SD8\SD8.exe" },
  @{ id="DiGiCoSD9";   name="DiGiCo SD9 Offline";    path="C:\SD9\SD9.exe" },
  @{ id="DiGiCoSD10";  name="DiGiCo SD10 Offline";   path="C:\SD10\SD10.exe" },
  @{ id="DiGiCoSD11";  name="DiGiCo SD11 Offline";   path="C:\SD11\SD11.exe" },
  @{ id="DiGiCoSD12";  name="DiGiCo SD12 Offline";   path="C:\SD12\SD12.exe" }
)
$ok=@(); $bad=@()
foreach ($a in $apps) {
  if (-not (Test-Path $a.path)) { Write-Warning "MISSING $($a.path)"; $bad+=$a.id; continue }
  & $ia remove-application --name $a.id 2>&1 | Out-Null
  $r = (& $ia add-application --name $a.id --absolute-app-path $a.path --display-name $a.name 2>&1) | Out-String
  if ($r -match '"status":\s*0') { Write-Host "OK   $($a.id)"; $ok+=$a.id }
  else { Write-Warning "FAIL $($a.id): $r"; $bad+=$a.id }
}
Write-Host "`n=== Registered $($ok.Count)/13: $($ok -join ', ') ==="
if ($bad.Count) { Write-Warning "Still failing: $($bad -join ', ')" }
Write-Host "`nVerify list:"; & $ia get-app-catalog
