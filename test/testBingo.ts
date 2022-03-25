import { ethers } from "hardhat"
const hre = require("hardhat");
import { expect } from "chai"
import { BigNumber } from "ethers"
import { abi } from "../artifacts/contracts/RandomNumberConsumer.sol/RandomNumberConsumer.json" 
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";


interface numberCartons {
  b: BigNumber[];
  i: BigNumber[];
  n: BigNumber[];
  g: BigNumber[];
  o: BigNumber[];
};

const duration = {
  seconds: function (val: BigNumber) { return (BigNumber.from(val)); },
  minutes: function (val: BigNumber) { return val.mul(this.seconds(BigNumber.from(60))) },
  hours: function (val: BigNumber) { return val.mul(this.minutes(BigNumber.from(60))) },
  days: function (val: BigNumber) { return val.mul(this.hours(BigNumber.from(24))) },
  weeks: function (val: BigNumber) { return val.mul(this.days(BigNumber.from(7))) },
  years: function (val: BigNumber) { return val.mul(this.days(BigNumber.from(365))) },
};



async function latest() {
  const blockNumBefore: number = await ethers.provider.getBlockNumber();
  const blockBefore = await ethers.provider.getBlock(blockNumBefore);
  const timestampBefore: BigNumber = BigNumber.from(blockBefore.timestamp);
  return (timestampBefore);
}



const BingoData = async () => {

  const nameERC20: string = "USDT"
  const symbolERC20: string = "USDT"
  const decimals = 8
  const totalValue = BigNumber.from(100).mul(10).pow(8)

  const [ownerBingo, owenrERC20, user1, user2, user3, user4] = await ethers.getSigners()
  
  const account1 = await ethers.getSigner("0x9A8D3f1D52a8018D4f01f04DB8845C8a58Cc6d4a")

  const linkAddress: string = "0x01BE23585060835E02B77ef475b0Cc51aA1e0709";

  const ramdonAddress: string = "0xF502DCCd41962d62B2f49D5342e4219812a64392"

  const ERC20 = await ethers.getContractFactory("ERC20")


  const ERC20Deploy = await ERC20.connect(owenrERC20).deploy(
    nameERC20,
    symbolERC20,
    decimals,
    totalValue
  )


  const Bingo = await ethers.getContractFactory("Bingo")

  const BingoDeploy = await Bingo.connect(ownerBingo).deploy(ERC20Deploy.address, ramdonAddress)

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

const addOwner = async (newAddress : string) =>{  

  const addressContract : string = '0xF502DCCd41962d62B2f49D5342e4219812a64392'

  await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x9A8D3f1D52a8018D4f01f04DB8845C8a58Cc6d4a"],
  });  

  await ethers.provider.send('hardhat_impersonateAccount', ['0x2d4bb9a783583875f8b0b86cbcad09ce87523497']);

  const account1 = await ethers.getSigner("0x9A8D3f1D52a8018D4f01f04DB8845C8a58Cc6d4a")

  var contrato  = await ethers.getContractAt(abi, addressContract);

  await contrato.connect(account1).addNewOwner(newAddress)
  
}

// const generateWinningNumbers = async (
//   _contract : any,
//   _owner : SignerWithAddress,
//   _manyNumber: number) => {  
// }


const createNewPlay = async (
  _contract : any,
  _owner : SignerWithAddress,
  _maxNumberCartons : number,
  _numberPlayer :number,
  _cartonsByPlayer:number,
  _cartonPrice:number) => {

  const lastBlockDate: BigNumber = await latest()
  await _contract.connect(_owner).createPlay(
    _maxNumberCartons,
    _numberPlayer,
    _cartonsByPlayer,
    BigNumber.from(_cartonPrice).mul(10).pow(8),
    lastBlockDate.add(duration.hours(BigNumber.from(1)))
  )
}


describe("1 - Test smart contract Bingo.sol", function () {   

  describe("Bingo Owner", function () {

    it("1 - The account that dsiplay is the owner of the contract", async () => {

      const { ownerBingo, BingoDeploy } = await BingoData()

      const isOwner: boolean = await BingoDeploy.isOwner(ownerBingo.address)

      expect(isOwner).to.equals(true)

    })



    it("2 - Create new Play", async () => {

      const { ownerBingo, BingoDeploy, owenrERC20, ERC20Deploy } = await BingoData()

      const lastBlockDate: BigNumber = await latest()
      const maxNumberCartons: number = 20
      const numberPlayer: number = 20
      const cartonsByPlayer: number = 1
      const cartonPrice: BigNumber = BigNumber.from(1).mul(10).pow(8)
      const endDate: BigNumber = lastBlockDate.add(duration.hours(BigNumber.from(1)))

      await BingoDeploy.connect(ownerBingo).createPlay(
        maxNumberCartons,
        numberPlayer,
        cartonsByPlayer,
        cartonPrice,
        endDate
      )

      const currentIdPlay: BigNumber = await BingoDeploy.getCurrentIdPLay()

      const getLastPlay = await BingoDeploy.getPlayDetail(currentIdPlay.sub(1))

      expect(getLastPlay.maxNumberCartons).to.equals(maxNumberCartons)
      expect(getLastPlay.numberPlayer).to.equals(numberPlayer)
      expect(getLastPlay.cartonsByPlayer).to.equals(cartonsByPlayer)
      expect(getLastPlay.cartonPrice).to.equals(cartonPrice)
      expect(getLastPlay.endPlayDate).to.equals(endDate)

    })

    it("3 - Create all number of Bingo", async () => {

      const { ownerBingo, BingoDeploy } = await BingoData()      

      const numberOfWord = await BingoDeploy.connect(ownerBingo).getNumberOfWord()        

      for ( let i : number = 1 ; i <= 75 ; i ++){
        expect(numberOfWord[i-1]).to.equals(i)
      }  
      
    })
  })


  describe("Bingo User", function () {

    it("1 - Not being able to buy if the game does not exist", async () => {
      const {
        BingoDeploy,
        user1
      } = await BingoData()

      await expect(BingoDeploy.connect(user1).buyCartonsPlay(
        5,
        2,
        BigNumber.from(1).mul(10).pow(8)
      )).to.be.revertedWith("the id play not exists")
    })

    it("2 - Not being able to buy if the end date of the game has already passed", async () => {
      const {
        BingoDeploy,
        user1
      } = await BingoData()

      //create new play
      const lastBlockDate: BigNumber = await latest()
      const maxNumberCartons: number = 20
      const numberPlayer: number = 20
      const cartonsByPlayer: number = 1
      const cartonPrice: BigNumber = BigNumber.from(1).mul(10).pow(8)
      const endDate: BigNumber = lastBlockDate.add(duration.hours(BigNumber.from(1)))

      await BingoDeploy.connect(user1).createPlay(
        maxNumberCartons,
        numberPlayer,
        cartonsByPlayer,
        cartonPrice,
        endDate
      )

      await ethers.provider.send("evm_increaseTime",
        //[(60 * 60 * 24 * 7) + 1] // una semana + 1 segundo
        [60 * 60 * 4] // 4 horas
      )

      const currentIdPlay: BigNumber = await BingoDeploy.getCurrentIdPLay()

      await expect(BingoDeploy.connect(user1).buyCartonsPlay(
        currentIdPlay.sub(1),
        2,
        BigNumber.from(1).mul(10).pow(8)
      )).to.be.revertedWith("the endgame date has already happened")
    })


    it("3 - The number of cards to buy must be greater than 0", async () => {
      const {
        ownerBingo,
        BingoDeploy,
        owenrERC20,
        ERC20Deploy,
        user1
      } = await BingoData()

      //create new play
      const lastBlockDate: BigNumber = await latest()
      const maxNumberCartons: number = 20
      const numberPlayer: number = 20
      const cartonsByPlayer: number = 1
      const cartonPrice: BigNumber = BigNumber.from(1).mul(10).pow(8)
      const endDate: BigNumber = lastBlockDate.add(duration.hours(BigNumber.from(1)))

      await BingoDeploy.connect(user1).createPlay(
        maxNumberCartons,
        numberPlayer,
        cartonsByPlayer,
        cartonPrice,
        endDate
      )

      const currentIdPlay: BigNumber = await BingoDeploy.getCurrentIdPLay()

      await expect(BingoDeploy.connect(user1).buyCartonsPlay(
        currentIdPlay.sub(1),
        0,
        BigNumber.from(1).mul(10).pow(8)
      )).to.be.revertedWith("the number of cards to buy must be greater than 0")
    })

    it("4 - Do not have the necessary funds of USD", async () => {
      const {
        BingoDeploy,
        user1,
        ERC20Deploy,
        owenrERC20
      } = await BingoData()

      //create new play
      const lastBlockDate: BigNumber = await latest()
      const maxNumberCartons: number = 20
      const numberPlayer: number = 20
      const cartonsByPlayer: number = 1
      const cartonPrice: BigNumber = BigNumber.from(1).mul(10).pow(8)
      const endDate: BigNumber = lastBlockDate.add(duration.hours(BigNumber.from(1)))

      await BingoDeploy.connect(user1).createPlay(
        maxNumberCartons,
        numberPlayer,
        cartonsByPlayer,
        cartonPrice,
        endDate
      )

      const currentIdPlay: BigNumber = await BingoDeploy.getCurrentIdPLay()


      await ERC20Deploy.connect(owenrERC20).transfer(
        user1.address,
        cartonPrice
      )

      await expect(BingoDeploy.connect(user1).buyCartonsPlay(
        currentIdPlay.sub(1),
        2,
        cartonPrice.mul(2)
      )).to.be.revertedWith("Do not have the necessary funds of USD")
    })

    it("5 - You do not send the amount of USD necessary to make the purchase", async () => {
      const {
        BingoDeploy,
        user1,
        ERC20Deploy,
        owenrERC20
      } = await BingoData()

      //create new play
      const lastBlockDate: BigNumber = await latest()
      const maxNumberCartons: number = 20
      const numberPlayer: number = 20
      const cartonsByPlayer: number = 1
      const cartonPrice: BigNumber = BigNumber.from(1).mul(10).pow(8)
      const endDate: BigNumber = lastBlockDate.add(duration.hours(BigNumber.from(1)))

      await BingoDeploy.connect(user1).createPlay(
        maxNumberCartons,
        numberPlayer,
        cartonsByPlayer,
        cartonPrice,
        endDate
      )

      const currentIdPlay: BigNumber = await BingoDeploy.getCurrentIdPLay()


      await ERC20Deploy.connect(owenrERC20).transfer(
        user1.address,
        cartonPrice.mul(3)
      )

      await expect(BingoDeploy.connect(user1).buyCartonsPlay(
        currentIdPlay.sub(1),
        2,
        cartonPrice
      )).to.be.revertedWith("you do not send the amount of USDT necessary to make the purchase")
    })



    it("6 - The number of cards to buy must be less than or equal to the maximum allowed",
      async () => {

        const {
          BingoDeploy,
          ERC20Deploy,
          owenrERC20,
          user1
        } = await BingoData()

        //create new play
        const lastBlockDate: BigNumber = await latest()
        const maxNumberCartons: number = 20
        const numberPlayer: number = 20
        const cartonsByPlayer: number = 1
        const cartonPrice: BigNumber = BigNumber.from(1).mul(10).pow(8)
        const endDate: BigNumber = lastBlockDate.add(duration.hours(BigNumber.from(1)))

        await BingoDeploy.connect(user1).createPlay(
          maxNumberCartons,
          numberPlayer,
          cartonsByPlayer,
          cartonPrice,
          endDate
        )

        const currentIdPlay: BigNumber = await BingoDeploy.getCurrentIdPLay()

        await ERC20Deploy.connect(owenrERC20).transfer(
          user1.address,
          cartonPrice.mul(4)
        )

        await expect(BingoDeploy.connect(user1).buyCartonsPlay(
          currentIdPlay.sub(1),
          2,
          cartonPrice.mul(4)
        )).to.be.revertedWith("can not buy that quantity of cartons")

      })

    //pendiente 
    it("7 - There are no cards to buy", async () => {

      const {        
        BingoDeploy,
        owenrERC20,
        ERC20Deploy,
        user1
      } = await BingoData()
      
      
      const cartonPrice: BigNumber = BigNumber.from(1).mul(10).pow(8)

      await addOwner(BingoDeploy.address)

      //create new play
      
      await createNewPlay(
        BingoDeploy,
        user1,
        20, // total Carton
        20, // number player
        20, // cartons by player
        1,  //price cartons in dolars
      )

      const currentIdPlay: BigNumber = await BingoDeploy.getCurrentIdPLay()

      await ERC20Deploy.connect(owenrERC20).transfer(
        user1.address,
        cartonPrice.mul(21)
      )

      await ERC20Deploy.connect(user1).approve(
        BingoDeploy.address,
        cartonPrice.mul(21)
      )

      await BingoDeploy.connect(user1).buyCartonsPlay(
        currentIdPlay.sub(1),
        20,
        cartonPrice.mul(20)
      )


      await expect(BingoDeploy.connect(user1).buyCartonsPlay(
        currentIdPlay.sub(1),
        1,
        cartonPrice.mul(1)
      )).to.be.revertedWith("there are no cards to buy")

    })

  })


  describe("strat play", function () {

    //set timeOut de todas las pruebas del describe
    
    this.timeout(50000);

    
    it("1 - generate number", async () =>{
      
      const {        
        BingoDeploy,     
        user1
      } = await BingoData()

      await addOwner(BingoDeploy.address)

      await createNewPlay(
        BingoDeploy,
        user1,
        20, // total Carton
        20, // number player
        20, // cartons by player
        1, //price cartons in dolars
      )
    
      const currentIdPlay: BigNumber = await BingoDeploy.getCurrentIdPLay()

      await BingoDeploy.connect(user1).changeStatePlayToInitiated(currentIdPlay.sub(1))
            
      await BingoDeploy.connect(user1).generateWinningNumbers(currentIdPlay.sub(1))

      const numero  = await BingoDeploy.getNumbersPlayedByPlay(currentIdPlay.sub(1))

      expect(numero.length).to.equals(1)      

    })

    it("2 - generate all number", async () => {
          
      const {        
        BingoDeploy,     
        user1
      } = await BingoData()

      await addOwner(BingoDeploy.address)

      await createNewPlay(
        BingoDeploy,
        user1,
        20, // total Carton
        20, // number player
        20, // cartons by player
        1, //price cartons in dolars
      )
    
      const currentIdPlay: BigNumber = await BingoDeploy.getCurrentIdPLay()
      
      await BingoDeploy.connect(user1).changeStatePlayToInitiated(currentIdPlay.sub(1))



      for(let i = 0 ; i < 75 ; i++){

        await BingoDeploy.connect(user1).generateWinningNumbers(currentIdPlay.sub(1))

      }         

      const getNumbersPlay : [BigNumber] = await BingoDeploy.getNumbersPlayedByPlay(currentIdPlay.sub(1))
    
      expect(getNumbersPlay.length).to.equals(75)
     
    })

    it("3 - fails to generate the winning number 76", async () =>{

      const {        
        BingoDeploy,
        ERC20Deploy,
        owenrERC20,     
        user1,
        user2
      } = await BingoData()

      await addOwner(BingoDeploy.address)

      const cartonPriceNumber : number = 1 

      const cartonPrice: BigNumber = BigNumber.from(cartonPriceNumber).mul(10).pow(8)

      await createNewPlay(
        BingoDeploy,
        user1,
        20, // total Carton
        20, // number player
        20, // cartons by player
        cartonPriceNumber //price cartons in dolars
      )
      
      const currentIdPlay: BigNumber = await BingoDeploy.getCurrentIdPLay()
            
      await ERC20Deploy.connect(owenrERC20).transfer(
        user2.address,
        cartonPrice.mul(20)
      )

      await ERC20Deploy.connect(user2).approve(
        BingoDeploy.address,
        cartonPrice.mul(20)
      )
    
      await BingoDeploy.connect(user2).buyCartonsPlay(
        currentIdPlay.sub(1),
        20,
        cartonPrice.mul(20)
      )

      await BingoDeploy.connect(user1).changeStatePlayToInitiated(currentIdPlay.sub(1))

      for(let i = 0 ; i < 75 ; i++){

        await BingoDeploy.connect(user1).generateWinningNumbers(currentIdPlay.sub(1))

      }

      await expect(BingoDeploy.connect(user1).generateWinningNumbers(
        currentIdPlay.sub(1)       
      )).to.be.revertedWith("All the numbers for this game will be generated")


    })

    it("4 - is full carton", async () =>{

      const {        
        BingoDeploy,
        ERC20Deploy,
        owenrERC20,     
        user1,
        user2
      } = await BingoData()

      await addOwner(BingoDeploy.address)

      const cartonPriceNumber : number = 1 

      const cartonPrice: BigNumber = BigNumber.from(cartonPriceNumber).mul(10).pow(8)

      await createNewPlay(
        BingoDeploy,
        user1,
        20, // total Carton
        20, // number player
        20, // cartons by player
        cartonPriceNumber //price cartons in dolars
      )
      
      const currentIdPlay: BigNumber = await BingoDeploy.getCurrentIdPLay()
            
      await ERC20Deploy.connect(owenrERC20).transfer(
        user2.address,
        cartonPrice.mul(20)
      )

      await ERC20Deploy.connect(user2).approve(
        BingoDeploy.address,
        cartonPrice.mul(20)
      )
    
      await BingoDeploy.connect(user2).buyCartonsPlay(
        currentIdPlay.sub(1),
        20,
        cartonPrice.mul(20)
      )

      await BingoDeploy.connect(user1).changeStatePlayToInitiated(currentIdPlay.sub(1))

      for(let i = 0 ; i < 70 ; i++){

        await BingoDeploy.connect(user1).generateWinningNumbers(currentIdPlay.sub(1))

      }

      await ethers.provider.send("evm_increaseTime",
      //[(60 * 60 * 24 * 7) + 1] // una semana + 1 segundo
        [60 * 60 * 4] // 4 horas
      )

      // for (let i = 1 ; i <= 20 ; i ++){

      //   console.log( i + " " + await BingoDeploy.isfullCarton(1,i) )

      // }

      await BingoDeploy.connect(user2).claimPrize(1 , 8)

      const balanceAfter : BigNumber = await ERC20Deploy.balanceOf(user2.address)

      expect(balanceAfter).to.equals(cartonPrice.mul(20))


    })

  })

})


