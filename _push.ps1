$env:HTTPS_PROXY='http://127.0.0.1:17891'
Set-Location C:\Users\admin\wow-mobile
$ga = @"
# 统一换行，避免 Windows 上写出的 CRLF 破坏 CI 里的 shell 脚本
* text=auto eol=lf
*.png binary
*.jpg binary
*.obj binary
*.ogg binary
*.gz binary
*.pck binary
*.zip binary
"@
[System.IO.File]::WriteAllText((Join-Path (Get-Location) '.gitattributes'), ($ga -replace "`r`n","`n"), (New-Object System.Text.UTF8Encoding($false)))

foreach ($f in @('.gitignore','.github\workflows\ios.yml','README.md','docs\IOS-BUILD.md','docs\PROGRESS.md')) {
  $p = Join-Path (Get-Location) $f
  $t = [System.IO.File]::ReadAllText($p)
  $t = $t -replace "`r`n","`n"
  [System.IO.File]::WriteAllText($p, $t, (New-Object System.Text.UTF8Encoding($false)))
}

git add -A
git commit -q -m "docs: record the working iOS pipeline + published unsigned .ipa

- docs/IOS-BUILD.md: how the .ipa is produced (GitHub Actions macOS runner), how to sideload it
- README: results table, iPhone install steps, repo slimming notes
- docs/PROGRESS.md: round 17 - task complete, verification evidence
- .gitattributes: force LF so shell steps in workflows survive Windows edits"
git log --oneline -2
git push origin main
Write-Output "PUSH_EXIT=$LASTEXITCODE"
