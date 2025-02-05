const fs = require('fs');
const path = require('path');
const https = require('https');
const { execSync } = require('child_process');

const SERVER_TYPE = process.env.SERVER_TYPE || 'paper';
const SERVER_VERSION = process.env.SERVER_VERSION || 'latest';
const BUILD_NUMBER = process.env.BUILD_NUMBER || 'latest';

function downloadFile(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https.get(url, (response) => {
      response.pipe(file);
      file.on('finish', () => {
        file.close(resolve);
      });
    }).on('error', (err) => {
      fs.unlink(dest, () => reject(err));
    });
  });
}

async function installServer() {
  let downloadUrl;
  let jarName;

  switch (SERVER_TYPE.toLowerCase()) {
    case 'paper':
      downloadUrl = `https://papermc.io/api/v2/projects/paper/versions/${SERVER_VERSION}/builds/${BUILD_NUMBER}/downloads/paper-${SERVER_VERSION}-${BUILD_NUMBER}.jar`;
      jarName = 'paper.jar';
      break;
    case 'forge':
      downloadUrl = `https://maven.minecraftforge.net/net/minecraftforge/forge/${SERVER_VERSION}-${BUILD_NUMBER}/forge-${SERVER_VERSION}-${BUILD_NUMBER}-installer.jar`;
      jarName = 'forge-installer.jar';
      break;
    case 'fabric':
      downloadUrl = `https://maven.fabricmc.net/net/fabricmc/fabric-installer/0.11.0/fabric-installer-0.11.0.jar`;
      jarName = 'fabric-installer.jar';
      break;
    case 'sponge':
      downloadUrl = `https://repo.spongepowered.org/maven/org/spongepowered/spongevanilla/${SERVER_VERSION}/spongevanilla-${SERVER_VERSION}.jar`;
      jarName = 'sponge.jar';
      break;
    case 'bungeecord':
      downloadUrl = 'https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar';
      jarName = 'bungeecord.jar';
      break;
    case 'bedrock':
      downloadUrl = `https://minecraft.azureedge.net/bin-linux/bedrock-server-${SERVER_VERSION}.zip`;
      jarName = 'bedrock-server.zip';
      break;
    default:
      console.error('Invalid server type specified');
      process.exit(1);
  }

  console.log(`Downloading ${SERVER_TYPE} server...`);
  await downloadFile(downloadUrl, jarName);

  if (SERVER_TYPE.toLowerCase() === 'fabric') {
    console.log('Installing Fabric server...');
    execSync(`java -jar ${jarName} server -mcversion ${SERVER_VERSION} -downloadMinecraft`);
    jarName = 'fabric-server-launch.jar';
  } else if (SERVER_TYPE.toLowerCase() === 'forge') {
    console.log('Installing Forge server...');
    execSync(`java -jar ${jarName} --installServer`);
    jarName = `forge-${SERVER_VERSION}-${BUILD_NUMBER}.jar`;
  } else if (SERVER_TYPE.toLowerCase() === 'bedrock') {
    console.log('Extracting Bedrock server...');
    execSync(`unzip ${jarName} -d bedrock-server && rm ${jarName}`);
    jarName = 'bedrock_server';
  }

  console.log('Setting up server.properties...');
  const serverProperties = `server-port=${process.env.SERVER_PORT}\nmotd=${process.env.SERVER_NAME}\n`;
  fs.writeFileSync('server.properties', serverProperties);

  console.log('Setting up startup command...');
  fs.writeFileSync('.startup_cmd', `java -Xms128M -Xmx${process.env.SERVER_MEMORY}M -jar ${jarName}`);

  console.log('Installation complete!');
}

installServer().catch(console.error);
