import { ethers } from "hardhat"
import { expect } from "chai"
import { BigNumber } from "ethers"


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

    const [ownerBingo, owenrERC20, user1, user2, user3, user4] = await ethers.getSigners();

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
      BingoDeploy
    }
    
 
  }

  describe("Bingo Owner", function (){

    it("The account that dsiplay is the owner of the contract", async () =>{

      const {ownerBingo , BingoDeploy} = await BingoData()

      const isOwner : boolean = await BingoDeploy.isOwner(ownerBingo.address)

      expect(isOwner).to.equals(true)

    })

    it ("Create new Play", async()=>{

      const {ownerBingo, BingoDeploy} = await BingoData()

      const lastBlockDate : BigNumber = await latest()

      const maxNumberCartons : number = 20
      const numberPlayer : number = 20
      const cartonsByPlayer : number = 1

      const cartonPrice : BigNumber = BigNumber.from(1).mul(10).pow(8)

      const endDate : BigNumber = lastBlockDate.add(duration.hours(BigNumber.from(1)))

      console.log(endDate.toString())

      await BingoDeploy.connect(ownerBingo).createPlay(
        maxNumberCartons,
        numberPlayer,
        cartonsByPlayer,
        cartonPrice,
        endDate
      )
    })

  })

})
