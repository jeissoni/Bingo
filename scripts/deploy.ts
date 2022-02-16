import { ethers } from "hardhat"


const deploy = async () =>{
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contrat with the account: ', deployer.address)

  const RandomNumberConsumer = await ethers.getContractFactory("RandomNumberConsumer")

  const deployed = await RandomNumberConsumer.deploy(249)

  console.log("RandomNumberConsumer isdeployed at:", deployed.address )

}

deploy().then(()=> process.exit(0)).catch(error => {
  console.log(error);
  process.exit(1);
});

