Add-Type -AssemblyName System.IO.Compression.FileSystem
$ipa = "C:\Users\admin\wow-mobile\build\ci-artifact\build\ios\WoWMobile-unsigned.ipa"
$z=[System.IO.Compression.ZipFile]::OpenRead($ipa)
$e=$z.Entries | Where-Object { $_.FullName -eq 'Payload/WoWMobile.app/WoWMobile' }
$ms=New-Object System.IO.MemoryStream
$st=$e.Open(); $st.CopyTo($ms); $st.Dispose()
$b=$ms.ToArray()
$magic=[BitConverter]::ToUInt32($b,0)
$cputype=[BitConverter]::ToUInt32($b,4)
$cpusub=[BitConverter]::ToUInt32($b,8)
"magic=0x{0:X8} cputype=0x{1:X8} cpusub=0x{2:X8}" -f $magic,$cputype,$cpusub
if ($cputype -eq 0x0100000C) { "ARCH = arm64 (iOS device) OK" } elseif ($cputype -eq 0x01000007) { "ARCH = x86_64" } else { "ARCH = unknown" }
$pl=$z.Entries | Where-Object { $_.FullName -eq 'Payload/WoWMobile.app/Info.plist' }
$sr=New-Object System.IO.StreamReader($pl.Open())
$txt=$sr.ReadToEnd(); $sr.Dispose()
Write-Output "=== Info.plist ==="
$txt
$z.Dispose()
