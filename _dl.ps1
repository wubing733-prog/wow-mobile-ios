$env:HTTPS_PROXY='http://127.0.0.1:17891'
Set-Location C:\Users\admin\wow-mobile
Remove-Item -Recurse -Force build\ci-artifact -ErrorAction SilentlyContinue
gh run download 38165940798 -n WoWMobile-ios -D build\ci-artifact
Write-Output "EXIT=$LASTEXITCODE"
Get-ChildItem build\ci-artifact -Recurse -File | Select-Object FullName,Length | Format-Table -AutoSize
