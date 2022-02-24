//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./struct/strucs.sol";
import "./utils/Counters.sol";
import "./token/IERC20.sol";

import "./RandomNumberConsumer.sol";

contract Bingo {

    IERC20 public USD;
    RandomNumberConsumer public Ramdom;

    using Counters for Counters.Counter;

    enum statePlay{
        CREATED,
        INITIATED,
        FINALIZED
    }

    enum words{
        B,I,N,G,O
    }

    struct playDetail{
        uint256 idPlay;
        uint256 maxNumberCartons;
        uint256 numberPlayer;
        uint256 cartonsByPlayer;
        uint256 catonPrice;
        uint256 startPlayDate;
        uint256 endPlayDate;
        //uint256[] carton;
        statePlay state;
        address ownerPlay;
        //mapping(words => uint[4]) winerNumber;
    }


    struct cartonsDetail{
        uint256 idCarton;
        uint256 idPlay;
        mapping(words => uint256[]) number;
    }

  
    Counters.Counter private currentIdPlay;
    Counters.Counter private currentIdCartons;


    mapping(uint256 => playDetail) private play;   
    mapping(uint256 => uint256[]) private PlayCartons;
    mapping(uint256 => uint256[]) private playCartonWins;
    mapping(address => uint256[]) private userOwnerPlay;

    

    mapping(uint256 => cartonsDetail) private cartons;

    mapping(address => uint256[]) public userPlay;

    mapping(address => uint256[]) private userCartons;

    mapping(address => bool) private owner;


    //events


    //modifier
    modifier onlyOwner() {
        require(
            owner[msg.sender] == true,
            "Exclusive function of the Owner"
        );
        _;
    }

   

    function isOwner(address _account) external view returns (bool){
        return owner[_account];
    }


    function getCurrentIdPLay() external view returns (uint256){
        return currentIdPlay.current();   
    }


    function getPlayDetail(uint256 _idPLay) external view returns(playDetail memory){
        return play[_idPLay];
    }

    function getRamdonNumber() external view returns(uint256){
        return Ramdom.s_requestId();
    }

    function isUserOwnerPlay(address _account, uint256 _idPlay) 
    internal 
    view 
    returns (bool){

        bool playReturn = false;
        if (userOwnerPlay[_account].length > 0) {
            for (uint256 i = 0; i < userOwnerPlay[_account].length; i++) {
               if (userOwnerPlay[_account][i] == _idPlay){
                   playReturn = true;
               }
            }
        }
        return playReturn;
    }

    

    function createPlay(
        uint256 _maxNumberCartons,
        uint256 _numberPlayer,
        uint256 _cartonsByPlayer,
        uint256 _cartonPrice,
        uint256 _endDate
    )  external returns(bool){

        require(block.timestamp < _endDate,"The game end date must be greater than the current date");

        require(_cartonPrice > 0 ,"The price of the carton must be greater than zero");     

        uint256 _idPlay = currentIdPlay.current();           

        play[_idPlay].maxNumberCartons = _maxNumberCartons;
        play[_idPlay].numberPlayer = _numberPlayer;
        play[_idPlay].cartonsByPlayer = _cartonsByPlayer;
        play[_idPlay].catonPrice = _cartonPrice;
        play[_idPlay].startPlayDate = block.timestamp;
        play[_idPlay].endPlayDate = _endDate;
        play[_idPlay].state = statePlay.CREATED;
        play[_idPlay].ownerPlay = msg.sender;

        userOwnerPlay[msg.sender].push(_idPlay);

        currentIdPlay.increment();

        return true;

    }

    function generateNumberRamdom(uint256 _min, uint256 _max) internal view returns(uint256){

        uint256 seed = Ramdom.s_requestId();
        
        return uint256 (
            keccak256(abi.encodePacked(block.timestamp, msg.sender, seed ))
            ) % (_max - _min + 1) + 1 ;       

    }


    function createNewCartons(uint256 _idPlay) internal returns (bool){

        require(isUserOwnerPlay(msg.sender, _idPlay),"you do not have permissions to create cards");
        
        //crear nueva semilla 

        uint256 numberCartons = play[_idPlay].maxNumberCartons;

        if (numberCartons == 0){
            return false;
        }

        //numbers of cartons
        for(uint i = 0; i < numberCartons ; i++ ){

            uint256 currentIdCarton = currentIdCartons.current();

            // j = 0 --> B
            // j = 1 --> I
            // j = 2 --> N
            // j = 3 --> G
            // j = 4 --> O
            for( uint j = 0; j < 5 ; j++){

                uint256 min;
                uint256 max;
                words wordCarton;

                //index Words B
                if(j == 0 ){
                    min = 1;
                    max = 15;
                    wordCarton = words.B;                   
                }

                //index Words I
                if(j == 1 ){
                    min = 16;
                    max = 30;
                    wordCarton = words.I; 
                }

                //index Words N
                if(j == 2 ){
                    min = 31;
                    max = 45;
                    wordCarton = words.N; 
                }

                //index Words G
                if(j == 3 ){
                    min = 46;
                    max = 60;
                    wordCarton = words.G; 
                }

                //index Words O
                if(j == 4 ){
                    min = 61;
                    max = 75;
                    wordCarton = words.O; 
                }

                //llena el carton 
                while(true){

                    uint256 ramdonNumber = generateNumberRamdom(min, max);

                    if(numberExists[ramdonNumber] == false ){
                        
                        numberExists[ramdonNumber] = true;

                        cartons[currentIdCarton].idCarton = currentIdCarton;
                        cartons[currentIdCarton].idPlay = _idPlay;
                        cartons[currentIdCarton].number[wordCarton].push(ramdonNumber);
                    
                    }

                    if(cartons[currentIdCarton].number[wordCarton].length < 4){
                        continue;
                    }
                    break;
                }           

                //resetear los numeros usados
                for (uint x = 0 ; x <= cartons[currentIdCarton].number[wordCarton].length ; x ++ ){
                    numberExists[cartons[currentIdCarton].number[wordCarton][x]] = false;
                }

            }

        }

        return true;

    }



 

    constructor(address usd, address _random){

        owner[msg.sender] = true;

        USD = IERC20(usd);

        Ramdom = RandomNumberConsumer(_random);

    }

}