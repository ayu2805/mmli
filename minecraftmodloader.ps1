$ProgressPreference = 'SilentlyContinue'

function Check-Java {
  try {
  Get-Command -Name java 2>$null
  return $true
  }
  catch {
    return $false
  }
}

if (-not (Check-Java)) {
  Write-Host "Java is not installed. Please install Java before running this script."
  exit
}

function Install-Forge {
  $url = "https://files.minecraftforge.net/net/minecraftforge/forge/"
  $htmlContent = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
  $targetUrl = ($htmlContent.Content -match 'https://adfoc.us/serve/sitelinks/\?id=271228&url=([^"]*)') | Out-Null
  $targetUrl = $matches[1]
  Invoke-WebRequest -Uri $targetUrl -OutFile "forge-installer.jar"
  if (Test-Path -Path $env:APPDATA\.minecraft -PathType Container) {
    & java -jar forge.jar --installClient $env:APPDATA\.minecraft
  }
  $confirmRegistry = Read-Host "Do you want to install Fabric Server? (y/N)"
  if ($confirmRegistry -match '^(yes|y)$') {
    if ($(Get-Location).Path -notlike "*\forge-server") {
      New-Item -Path "forge-server" -ItemType Directory -Force
      Move-Item -Path .\forge-installer.jar -Destination .\forge-server\
      Set-Location -Path "forge-server"
    }
    & java -jar forge-installer.jar --installServer
    Set-Location -Path ..
  }
  Remove-Item "forge-installer.jar", "forge-installer.jar.log" -ErrorAction SilentlyContinue
  Invoke-Expression "./run.bat --initSettings"
}

function Install-Fabric {
  $metadataUrl = "https://maven.fabricmc.net/net/fabricmc/fabric-installer/maven-metadata.xml"
  $baseJarUrl = "https://maven.fabricmc.net/net/fabricmc/fabric-installer"
  $xml = [xml](Invoke-WebRequest -Uri $metadataUrl -UseBasicParsing -ErrorAction Stop).Content
  $latestVersion = $xml.metadata.versioning.latest
  $jarUrl = "$baseJarUrl/$latestVersion/fabric-installer-$latestVersion.jar"
  Invoke-WebRequest -Uri $jarUrl -OutFile "fabric-installer.jar" -UseBasicParsing -ErrorAction Stop
  if (Test-Path -Path $env:APPDATA\.minecraft -PathType Container) {
    & java -jar .\fabric-installer.jar client
  }
  $confirmRegistry = Read-Host "Do you want to install Fabric Server? (y/N)"
  if ($confirmRegistry -match '^(yes|y)$') {
    if ($(Get-Location).Path -notlike "*\fabric-server") {
      New-Item -Path "fabric-server" -ItemType Directory -Force
      Move-Item -Path .\fabric-installer.jar -Destination .\fabric-server\
      Set-Location -Path "fabric-server"
    }
    & java -jar .\fabric-installer.jar server -downloadMinecraft
    & java -jar .\fabric-server-launch.jar --initSettings
    Remove-Item "fabric-installer.jar" -ErrorAction SilentlyContinue
    Set-Location -Path ..
  }
  & java -jar .\fabric-installer.jar server -downloadMinecraft
  & java -jar .\fabric-server-launch.jar --initSettings
  Remove-Item "fabric-installer.jar" -ErrorAction SilentlyContinue
}

do {
  Write-Host "0. Exit"
  Write-Host "1. Install Forge"
  Write-Host "2. Install Fabric"
    
  $choice = Read-Host "Enter your choice "

  switch ($choice) {
    '0' {Write-Host "Exiting the menu. Goodbye!"; return}
    '1' {Install-Forge}
    '2' {Install-Fabric}
    default {Write-Host "Invalid choice. Please try again."}
    }
} while ($true)
