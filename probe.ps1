$names = "SD7Q.exe","Quantum2.exe","Quantum3.exe","Quantum5.exe","Quantum8.exe","SD5.exe","SD5CS.exe","SD7.exe","SD8.exe","SD9.exe","SD10.exe","SD11.exe","SD12.exe"
Write-Host "=== Searching C:\ for the editor exes (give it a minute) ==="
Get-ChildItem C:\ -Recurse -Include $names -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
Write-Host "`n=== DiGiCo/Quantum/SD folders at common roots ==="
Get-ChildItem C:\,"C:\Program Files","C:\Program Files (x86)" -Directory -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -match 'DiGiCo|Quantum|^SD' } | Select-Object -ExpandProperty FullName
Write-Host "`n=== Start Menu shortcuts (and their targets) ==="
$sh = New-Object -ComObject WScript.Shell
Get-ChildItem "C:\ProgramData\Microsoft\Windows\Start Menu\Programs","$env:APPDATA\Microsoft\Windows\Start Menu\Programs" -Recurse -Filter *.lnk -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -match 'DiGiCo|Quantum|SD|Offline' } |
  ForEach-Object { $t=$sh.CreateShortcut($_.FullName).TargetPath; "{0}  ->  {1}" -f $_.Name,$t }
Write-Host "`n=== Done ==="
