$u = $env:USERNAME
$p = "C:\Users\$u\Pictures\dl.jpg"

Invoke-WebRequest -Uri "https://cyble.com/wp-content/uploads/2021/08/Cyble-LOCKBIT-Ransomware-Windows-darkweb-LOCKBIT-2.0-Changing-Desktop-Background.png" -OutFile $p

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers" -Name BackgroundType -Value 1
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\" -Name Wallpaper -Value $p
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\" -Name WallpaperStyle -Value 2
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\" -Name TileWallpaper -Value 0

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class W {
    [DllImport("user32.dll")]
    public static extern int SystemParametersInfo(int a, int b, string c, int d);
}
"@
[W]::SystemParametersInfo(20, 0, $p, (0x01 -bor 0x02))
