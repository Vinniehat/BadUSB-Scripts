$imageUrl = 'https://cyble.com/wp-content/uploads/2021/08/Cyble-LOCKBIT-Ransomware-Windows-darkweb-LOCKBIT-2.0-Changing-Desktop-Background.png'
$username = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[1])
$imagePath = "C:\Users\$username\Pictures\downloaded_image.jpg"

Invoke-WebRequest -Uri $imageUrl -OutFile $imagePath

# Set wallpaper mode to "Picture" (disable slideshow)
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers' -Name BackgroundType -Value 1

# Set the image as wallpaper
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'Wallpaper' -Value $imagePath
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'WallpaperStyle' -Value 2
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'TileWallpaper' -Value 0

# Force the update
Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class Wallpaper {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
"@

[Wallpaper]::SystemParametersInfo(20, 0, $imagePath, 0x01 | 0x02)
