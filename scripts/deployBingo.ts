import { ethers } from "hardhat";

const deploy = async() => {    

    const addressERC20 : string = "0xB9755Cde6e9d606a6468e4e4439Df46C89e844d0"
    const addressRandom : string = "0xA9E78D6Fa9D67a8903F8Cad473fA2e3CFc09103b"   

    const [deployer] = await ethers.getSigners();
    console.log('Deploying contrat with the account: ', deployer.address)

    const BingoFactory = await ethers.getContractFactory("Bingo");
    const BingoDeploy = await BingoFactory.deploy(addressERC20, addressRandom);
   
    console.log("Bingoisdeployed at:", BingoDeploy.address )
}



deploy().then(()=> process.exit(0)).catch(error => {
    console.log(error);
    process.exit(1);
});
