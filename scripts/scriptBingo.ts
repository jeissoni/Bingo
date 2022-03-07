import { ethers } from "hardhat";

const deploy = async() => {    
    const [deployer] = await ethers.getSigners();
    console.log('Deploying contrat with the account: ', deployer.address)
    const RandomNumberConsumerFactory = await ethers.getContractFactory("RandomNumberConsumer");
    const RandomNumberConsumerFactoryDeploy = await RandomNumberConsumerFactory.deploy(249);
   
    console.log("RandomNumberConsumer isdeployed at:", RandomNumberConsumerFactoryDeploy.address )
}

deploy().then(()=> process.exit(0)).catch(error => {
    console.log(error);
    process.exit(1);
});


//0xF502DCCd41962d62B2f49D5342e4219812a64392