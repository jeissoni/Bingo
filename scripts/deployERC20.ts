

import { ethers } from "hardhat";
import { BigNumber } from "ethers"


const deployUSDT = async() => {

    const nameERC20: string = "USDT"
    const symbolERC20: string = "USDT"
    const decimals = 8
    const totalValue = BigNumber.from(100).mul(10).pow(8)

    console.log(totalValue.toString())

    // const [deployer] = await ethers.getSigners();
    // console.log('Deploying contrat with the account: ', deployer.address)

    // const ERC20Factory = await ethers.getContractFactory("ERC20")
    // const ERC20Deploy = await ERC20Factory.deploy(
    //     nameERC20,
    //     symbolERC20,
    //     decimals,
    //     totalValue
    // )

    // console.log("RandomNumberConsumer isdeployed at:", ERC20Deploy.address)
}


deployUSDT().then(()=> process.exit(0)).catch(error => {
    console.log(error);
    process.exit(1);
});