$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
cd $scriptPath

$currentDir = (Get-Location).Path
$wslPath = wsl.exe --exec wslpath -a -u "$currentDir"

Write-Host "Setting up..."

if ((Test-Path ".\temp") -eq $false) { New-Item -ItemType Directory -Path ".\temp" }

if ((Test-Path -Path "\\wsl.localhost\Ubuntu\") -eq $false) {
    Write-Error "Ubuntu does not look to be installed or setup, Run Ubuntu from the start menu"
    Read-Host "Press Return to Exit"
    throw "No Ubuntu Found"
}

$userName = (Get-ChildItem -Path \\wsl.localhost\Ubuntu\home\ | Select -First 1).Name

Write-Host "Hello, $userName"

#﻿# Refer to https://github.com/vgmstream/vgmstream/blob/master/src/meta/hca_keys.h (Line 1177 in the comment not the code)
## The keys from there are backwards so the first 8 HEX are key1 and the last 8 HEX are key0


if ((Test-Path -Path "\\wsl.localhost\Ubuntu\home\$userName\wcri\") -eq $false) {
    Write-Host "This is your first time? Setting up Linux ENV..."
    wsl.exe -u root --exec apt update -y
    wsl.exe -u root --exec apt install ffmpeg python3 python3-pip -y
    wsl.exe --exec bash -c "cd ~ && git clone https://github.com/donmai-me/WannaCRI wcri && cd wcri && python3 -m pip install -r requirements.txt"
}
Copy-Item -Path .\encrypt.py -Destination \\wsl.localhost\Ubuntu\home\$userName\wcri\encrypt.py -Force -Confirm:$false

if ((Test-Path ".\scaleform\") -eq $false) {
    if ((Test-Path -Path ".\download") -eq $false) { New-Item -Path ".\download" -ItemType Directory }
    if (Test-Path ".\download\scaleform\") {
        Remove-Item -Path ".\download\scaleform\" -Recurse -Force -Confirm:$false
    }
    $url = "https://static.xzy.cloud/dennis-public/tekken/Scaleform_Video_Encoder.zip"
    New-Item -ItemType Directory -Path ".\download\scaleform" -ErrorAction SilentlyContinue
    Invoke-WebRequest -UseBasicParsing -Uri $url  -OutFile ".\download\scaleform\out.zip"
    Expand-Archive -Path ".\download\scaleform\out.zip" -DestinationPath ".\download\scaleform\out-zip"
    Move-Item -Path ".\download\scaleform\out-zip" -Destination ".\scaleform"
}

if (Test-Path -Path ".\download") { Remove-Item -Path ".\download" -Recurse -Force -Confirm:$false }

if ((Test-Path -Path ".\*.mp4") -eq $false) {
    Write-Error "No MP4 File was found, please copy at least 1 file in the folder"
    Read-Host "Press Return to Exit"
    throw "No Input"
}

Get-ChildItem -Path ".\*.mp4" | ForEach-Object {
    Write-Host "=== Encode Video $($_.BaseName) ==="
    Copy-Item -Path "$($_.FullName)" -Destination ".\temp\input.mp4" -ErrorAction Stop
    Write-Host "Encode MP4 -> MPEG4 + PCM..."
    & wsl.exe --exec ffmpeg -y -loglevel warning -hide_banner -stats -i ${wslPath}/temp/input.mp4 -vf "scale=720:408,crop=720:408" -c:v mpeg4 -c:a pcm_s16le ${wslPath}/temp/input-video.avi -vn -c:a pcm_s16le ${wslPath}/temp/input-audio.wav
    Write-Host "Encode MPEG4 + PCM -> Softdec.Prime @ 360000kbps..."
    & ".\scaleform\medianoche.exe" -preview=off -gop_closed=on -gop_i=1 -gop_p=4 -gop_b=2 -video00="temp/input-video.avi" -output="temp/input-video.usm" -bitrate=36000000 -audio00="temp/input-audio.wav"
    Sleep -Seconds 5
    While ((Get-Process -Name medianoche -ErrorAction SilentlyContinue | Measure-Object -Line).Lines -gt 0) { Sleep -Seconds 5 }    
    if ((Test-Path -Path ".\temp\input-video.usm") -eq $false) {
        Write-Error "No output was generated... maybe encode it manually in Scaleform"
        Read-Host "Press Return to Exit"
        throw "No Output"
    }
    Write-Host "Encrypting Video (Time depends on file size)..."
    & wsl.exe --exec bash -c "cd ~/wcri/ && python3 encrypt.py ${wslPath}/temp"
    if ((Test-Path -Path ".\temp\video.enc") -eq $false) {
        Write-Error "No output was generated... maybe encode it manually in the commandline?"
        Read-Host "Press Return to Exit"
        throw "No Output Encrypted"
    }
    Copy-Item -Path ".\temp\video.enc" -Destination ".\$($_.BaseName).enc" -Force -Confirm:$false
    Remove-Item -Path ".\temp\*" -Recurse -Force -Confirm:$false
    Write-Host "=== Complete $($_.BaseName) ==="
}

Remove-Item -Path ".\temp" -Recurse -Force -Confirm:$false