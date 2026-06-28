$ia = "C:\Program Files\Amazon\Photon\ConsoleImageBuilder\image-assistant.exe"
Write-Host "Registered applications:"
& $ia list-applications
Write-Host "`nSnapshotting into image 'digico-offline-v1'."
Write-Host "This disconnects your session and runs ~30-45 min. That is expected."
& $ia create-image --name digico-offline-v1 --display-name "DiGiCo Offline V2242"
