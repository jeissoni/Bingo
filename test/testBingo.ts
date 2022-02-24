import { ethers } from "hardhat"
import { expect } from "chai"
import { BigNumber } from "ethers"
import { Provider } from "@ethersproject/abstract-provider";


const duration = {
  seconds: function (val : BigNumber) { return (BigNumber.from(val)); },
  minutes: function (val : BigNumber) { return val.mul(this.seconds(BigNumber.from(60)))},
  hours: function (val : BigNumber) { return  val.mul(this.minutes(BigNumber.from(60)))},
  days: function (val : BigNumber) { return val.mul(this.hours(BigNumber.from(24)))},
  weeks: function (val : BigNumber) { return val.mul(this.days(BigNumber.from(7)))},
  years: function (val : BigNumber) { return val.mul(this.days(BigNumber.from(365)))},
};



async function latest () {
  const blockNumBefore : number = await ethers.provider.getBlockNumber();
  const blockBefore = await ethers.provider.getBlock(blockNumBefore);
  const timestampBefore : BigNumber = BigNumber.from(blockBefore.timestamp);
  return (timestampBefore);
}




describe("Test smart contract Bingo.sol", function () {

  const BingoData = async () => {

    const nameERC20: string = "USDT"
    const symbolERC20: string = "USDT"
    const decimals = 8
    const totalValue = BigNumber.from(100).mul(10).pow(8)

    const [ownerBingo, owenrERC20, user1, user2, user3, user4] = await ethers.getSigners()

    const account1 = await ethers.getSigner("0x9A8D3f1D52a8018D4f01f04DB8845C8a58Cc6d4a")

    const linkAddress : string = "0x01BE23585060835E02B77ef475b0Cc51aA1e0709";

    const ERC20 = await ethers.getContractFactory("ERC20")


    const ERC20Deploy = await ERC20.connect(owenrERC20).deploy(
      nameERC20,
      symbolERC20,
      decimals,
      totalValue      
    )

   
    const Bingo = await ethers.getContractFactory("Bingo")

    const BingoDeploy = await Bingo.connect(ownerBingo).deploy(ERC20Deploy.address)
   

    return {
      ownerBingo,
      owenrERC20,
      user1, user2, user3, user4,
      ERC20Deploy,
      BingoDeploy,
      account1,
      linkAddress
    }
    
 
  }

  describe("Bingo Owner", function (){

    it("The account that dsiplay is the owner of the contract", async () =>{

      const {ownerBingo , BingoDeploy} = await BingoData()

      const isOwner : boolean = await BingoDeploy.isOwner(ownerBingo.address)

      expect(isOwner).to.equals(true)

    })

    it ("Create new Play", async()=>{



      const {ownerBingo, BingoDeploy, account1} = await BingoData()

      const balnace : BigNumber = await ethers.provider.getBalance(account1.address)

      console.log(balnace.toString())

      const lastBlockDate : BigNumber = await latest()

      const maxNumberCartons : number = 20
      const numberPlayer : number = 20
      const cartonsByPlayer : number = 1

      const cartonPrice : BigNumber = BigNumber.from(1).mul(10).pow(8)

      const endDate : BigNumber = lastBlockDate.add(duration.hours(BigNumber.from(1)))

      await BingoDeploy.connect(ownerBingo).createPlay(
        maxNumberCartons,
        numberPlayer,
        cartonsByPlayer,
        cartonPrice,
        endDate
      )

      const currentIdPlay : BigNumber = await BingoDeploy.getCurrentIdPLay()

      const getLastPlay = await BingoDeploy.getPlayDetail(currentIdPlay.sub(1))

      expect(getLastPlay.maxNumberCartons).to.equals(maxNumberCartons)
      expect(getLastPlay.numberPlayer).to.equals(numberPlayer)
      expect(getLastPlay.cartonsByPlayer).to.equals(cartonsByPlayer)
      expect(getLastPlay.catonPrice).to.equals(cartonPrice)
      expect(getLastPlay.endPlayDate).to.equals(endDate)

    })

    it("Create all number of Bingo" , async () => {

      const {ownerBingo, BingoDeploy} = await BingoData()

      await BingoDeploy.connect(ownerBingo).createAllNumberOfBingo()

      for (var i = 0 ; i < 5 ; i++){

        const numberOfWord = await BingoDeploy.connect(ownerBingo).getNumberOfWord(i)
        
        for (var j = 0 ; j < 15 ; j++){
         
          let numero : number = j + 1

          if (i === 0){
            expect(numberOfWord[j]).to.equals(BigNumber.from(numero))
          }
          if (i === 1){
            expect(numberOfWord[j]).to.equals(BigNumber.from(numero + 15))
          }
          if (i === 2){
            expect(numberOfWord[j]).to.equals(BigNumber.from(numero + 30))
          }
          if (i === 3){
            expect(numberOfWord[j]).to.equals(BigNumber.from(numero + 45))
          }
          if (i === 4){
            expect(numberOfWord[j]).to.equals(BigNumber.from(numero + 60))
          }         
           
        }
      }      

    })

    it("Create play cartons" , async () => {

      const {ownerBingo, BingoDeploy, user1} = await BingoData()

      //create new play
      const lastBlockDate : BigNumber = await latest()
      const maxNumberCartons : number = 20
      const numberPlayer : number = 20
      const cartonsByPlayer : number = 1  
      const cartonPrice : BigNumber = BigNumber.from(1).mul(10).pow(8)
      const endDate : BigNumber = lastBlockDate.add(duration.hours(BigNumber.from(1)))

      await BingoDeploy.connect(user1).createPlay(
        maxNumberCartons,
        numberPlayer,
        cartonsByPlayer,
        cartonPrice,
        endDate
      )

      const currentIdPlay : BigNumber = await BingoDeploy.getCurrentIdPLay()

      await BingoDeploy.connect(ownerBingo).createAllNumberOfBingo()
      //create all cartons
      await BingoDeploy.connect(user1).createNewCartons(currentIdPlay.sub(1))     

      const cartonsCreated = await BingoDeploy.getIdCartonsPlay(currentIdPlay.sub(1))

      expect(maxNumberCartons).to.equals(cartonsCreated.length)

  })

  })

})
