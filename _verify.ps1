Set-Location C:\Users\admin\wow-mobile\build\ci-artifact
Get-ChildItem -Recurse -File | Select-Object @{n='MB';e={[math]::Round($_.Length/1MB,2)}},FullName | Format-Table -AutoSize
Write-Output "=== sha256 file ==="
Get-Content build\ios\WoWMobile-unsigned.ipa.sha256
Write-Output "=== actual sha256 ==="
(Get-FileHash build\ios\WoWMobile-unsigned.ipa -Algorithm SHA256).Hash.ToLower()
Write-Output "=== ipa zip listing (first 30) ==="
Add-Type -AssemblyName System.IO.Compression.FileSystem
$z=[System.IO.Compression.ZipFile]::OpenRead((Resolve-Path build\ios\WoWMobile-unsigned.ipa))
$z.Entries | Select-Object -First 30 | ForEach-Object { "{0,12} {1}" -f $_.Length, $_.FullName }
Write-Output ("total entries = " + $z.Entries.Count)
$z.Dispose()
Write-Output "=== gametest.log ==="
Get-Content gametest.log
