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
  if ($(Get-Location).Path -notlike "*\forge-server") {
    New-Item -Path "forge-server" -ItemType Directory -Force
    Set-Location -Path "forge-server"
  }
  $url = "https://files.minecraftforge.net/net/minecraftforge/forge/"
  $htmlContent = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
  $targetUrl = ($htmlContent.Content -match 'https://adfoc.us/serve/sitelinks/\?id=271228&url=([^"]*)') | Out-Null
  $targetUrl = $matches[1]
  Invoke-WebRequest -Uri $targetUrl -OutFile "forge.jar"
  if (Test-Path -Path $env:APPDATA\.minecraft -PathType Container) {
    Invoke-Expression "java -jar forge.jar --installClient $env:APPDATA\.minecraft"
  }
  Invoke-Expression "java -jar forge.jar --installServer"
  Remove-Item "forge.jar", "forge.jar.log" -ErrorAction SilentlyContinue
  Invoke-Expression "./run.bat --initSettings"
  Set-Location -Path ..
}

function Install-Fabric {
  if ($(Get-Location).Path -notlike "*\fabric-server") {
    New-Item -Path "fabric-server" -ItemType Directory -Force
    Set-Location -Path "fabric-server"
  }
  $metadataUrl = "https://maven.fabricmc.net/net/fabricmc/fabric-installer/maven-metadata.xml"
  $baseJarUrl = "https://maven.fabricmc.net/net/fabricmc/fabric-installer"
  $xml = [xml](Invoke-WebRequest -Uri $metadataUrl -UseBasicParsing -ErrorAction Stop).Content
  $latestVersion = $xml.metadata.versioning.latest
  $jarUrl = "$baseJarUrl/$latestVersion/fabric-installer-$latestVersion.jar"
  Invoke-WebRequest -Uri $jarUrl -OutFile "fabric-installer.jar" -UseBasicParsing -ErrorAction Stop
  if (Test-Path -Path $env:APPDATA\.minecraft -PathType Container) {
    Invoke-Expression "java -jar .\fabric-installer.jar client"
  }
  Invoke-Expression "java -jar .\fabric-installer.jar server -downloadMinecraft"
  Invoke-Expression "java -jar .\fabric-server-launch.jar --initSettings"
  Remove-Item "fabric-installer.jar" -ErrorAction SilentlyContinue
  Set-Location -Path ..
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
