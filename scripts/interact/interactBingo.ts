import {  BigNumber, ethers, Wallet } from "ethers";

import {abi} from '../../artifacts/contracts/Bingo.sol/Bingo.json'

require("dotenv").config();

async function balance() {

    const address = "0xaad3F120Ba8DEbaF068AaDCF0470dB383F3cdFD2"

    const cartonPrice: BigNumber = BigNumber.from(1).mul(10).pow(8)

    const projeId = process.env.INFURA_PROJECT_ID

    const privateKey : string = process.env.USER2 as string


    var provider = new ethers.providers.JsonRpcProvider(`https://rinkeby.infura.io/v3/${projeId}`)

    const signer = new ethers.Wallet(privateKey , provider);

    
    var contractBingo  = new ethers.Contract( address , abi , signer  )
    
    //var detailBingo = await contractBingo.getPlayDetail(1)

    
    const resultado  = await contractBingo.buyCartonsPlay(
        2,
        1,
        cartonPrice
    )  
    
   


    return { detailBingo }
} 

 balance().then((x)=> console.log(x.detailBingo.toString())).catch(function(e){console.log(e)})