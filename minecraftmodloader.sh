#!/bin/bash

check_java() {
  if command -v java &> /dev/null; then
    return 0
  else
    return 1
  fi
}

install_forge() {
  url="https://files.minecraftforge.net/net/minecraftforge/forge/"
  target_url=$(curl -s "$url" | \
            grep -o 'https://adfoc.us/serve/sitelinks/?id=271228&url=[^"]*' | \
            head -n 1 | \
            sed 's|https://adfoc.us/serve/sitelinks/?id=271228&url=||')
  curl -o "forge-installer.jar" "$target_url"
  
  read -r -p "Do you want to install Forge Client? (y/N)" response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    if [ -d "$HOME/.minecraft" ]; then
    java -jar forge-installer.jar --installClient "$HOME/.minecraft"
    fi
  fi
  
  read -r -p "Do you want to install Forge Server? (y/N)" response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    if [[ ! "$(pwd)" == *"forge-server"* ]]; then
      mkdir -p "forge-server"
      mv "forge-installer.jar" "forge-server"
      cd "forge-server"
    fi
    java -jar forge-installer.jar --installServer
    ./run.sh --initSettings
    rm -f forge-installer.jar forge-installer.jar.log
    cd ..
  fi
  
  rm -f forge-installer.jar forge-installer.jar.log
}

install_fabric() {
  metadata_url="https://maven.fabricmc.net/net/fabricmc/fabric-installer/maven-metadata.xml"
  base_jar_url="https://maven.fabricmc.net/net/fabricmc/fabric-installer"
  latest_version=$(curl -s "$metadata_url" | grep -oP '<latest>\K[^<]+')
  jar_url="$base_jar_url/$latest_version/fabric-installer-$latest_version.jar"
  curl "$jar_url" -o "fabric-installer.jar"
  
  read -r -p "Do you want to install Fabric Client? (y/N)" response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    if [ -d "$HOME/.minecraft" ]; then
      java -jar fabric-installer.jar client
    fi
  fi
  
  read -r -p "Do you want to install Fabric Server? (y/N)" response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    if [[ ! "$(pwd)" == *"fabric-server"* ]]; then
      mkdir -p "fabric-server"
      mv "fabric-installer.jar" "fabric-server"
      cd "fabric-server"
    fi
    java -jar fabric-installer.jar server -downloadMinecraft
    java -jar fabric-server-launch.jar --initSettings
    rm -f fabric-installer.jar
    cd ..
  fi
  
  rm -f fabric-installer.jar

}

while true; do
  echo "0. Exit"
  echo "1. Install Forge"
  echo "2. Install Fabric"
  
  read -p "Enter your choice: " choice

  case $choice in
    '0') echo "Exiting the menu. Goodbye!"; break;;
    '1') install_forge;;
    '2') install_fabric;;
    *) echo "Invalid choice. Please try again.";;
  esac
done
