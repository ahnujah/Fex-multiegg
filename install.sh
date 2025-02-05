#!/bin/bash

# Czaractyl Installation Script

echo "Welcome to Czaractyl Installation"
echo "Please choose the server software you want to install:"
echo "1. Paper"
echo "2. Forge"
echo "3. Fabric"
echo "4. Sponge"
echo "5. BungeeCord"
echo "6. Bedrock"

read -p "Enter the number of your choice: " choice

case $choice in
    1)
        SERVER_TYPE="paper"
        ;;
    2)
        SERVER_TYPE="forge"
        ;;
    3)
        SERVER_TYPE="fabric"
        ;;
    4)
        SERVER_TYPE="sponge"
        ;;
    5)
        SERVER_TYPE="bungeecord"
        ;;
    6)
        SERVER_TYPE="bedrock"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "You have chosen to install $SERVER_TYPE"

read -p "Enter the server version (or press Enter for latest): " SERVER_VERSION
SERVER_VERSION=${SERVER_VERSION:-latest}

read -p "Enter the build number (or press Enter for latest): " BUILD_NUMBER
BUILD_NUMBER=${BUILD_NUMBER:-latest}

echo "Installing $SERVER_TYPE version $SERVER_VERSION build $BUILD_NUMBER"

case $SERVER_TYPE in
    paper)
        URL="https://papermc.io/api/v2/projects/paper/versions/${SERVER_VERSION}/builds/${BUILD_NUMBER}/downloads/paper-${SERVER_VERSION}-${BUILD_NUMBER}.jar"
        JAR_NAME="paper.jar"
        ;;
    forge)
        URL="https://maven.minecraftforge.net/net/minecraftforge/forge/${SERVER_VERSION}-${BUILD_NUMBER}/forge-${SERVER_VERSION}-${BUILD_NUMBER}-installer.jar"
        JAR_NAME="forge-installer.jar"
        ;;
    fabric)
        URL="https://maven.fabricmc.net/net/fabricmc/fabric-installer/0.11.0/fabric-installer-0.11.0.jar"
        JAR_NAME="fabric-installer.jar"
        ;;
    sponge)
        URL="https://repo.spongepowered.org/maven/org/spongepowered/spongevanilla/${SERVER_VERSION}/spongevanilla-${SERVER_VERSION}.jar"
        JAR_NAME="sponge.jar"
        ;;
    bungeecord)
        URL="https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar"
        JAR_NAME="bungeecord.jar"
        ;;
    bedrock)
        URL="https://minecraft.azureedge.net/bin-linux/bedrock-server-${SERVER_VERSION}.zip"
        JAR_NAME="bedrock-server.zip"
        ;;
esac

echo "Downloading server files..."
curl -o ${JAR_NAME} ${URL}

if [ "$SERVER_TYPE" == "fabric" ]; then
    echo "Installing Fabric server..."
    java -jar ${JAR_NAME} server -mcversion ${SERVER_VERSION} -downloadMinecraft
    JAR_NAME="fabric-server-launch.jar"
elif [ "$SERVER_TYPE" == "forge" ]; then
    echo "Installing Forge server..."
    java -jar ${JAR_NAME} --installServer
    JAR_NAME="forge-${SERVER_VERSION}-${BUILD_NUMBER}.jar"
elif [ "$SERVER_TYPE" == "bedrock" ]; then
    echo "Extracting Bedrock server..."
    unzip ${JAR_NAME} -d bedrock-server && rm ${JAR_NAME}
    JAR_NAME="bedrock_server"
fi

echo "Setting up server.properties..."
echo "server-port=${SERVER_PORT}" > server.properties
echo "motd=${SERVER_NAME}" >> server.properties

echo "Setting up startup command..."
if [ "$SERVER_TYPE" == "bedrock" ]; then
    echo "LD_LIBRARY_PATH=. ./bedrock_server" > .startup_cmd
else
    echo "java -Xms128M -Xmx${SERVER_MEMORY}M -jar ${JAR_NAME}" > .startup_cmd
fi

echo "Installation complete!"
