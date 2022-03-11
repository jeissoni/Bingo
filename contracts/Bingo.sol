//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./struct/strucs.sol";
import "./utils/Counters.sol";
import "./utils/String.sol";

import "./token/IERC20.sol";

import "./RandomNumberConsumer.sol";

import "hardhat/console.sol";

contract Bingo {
    IERC20 public USD;

    RandomNumberConsumer public Ramdom;

    using Counters for Counters.Counter;

    enum statePlay {
        CREATED,
        INITIATED,
        FINALIZED
    }

    enum words {
        B,
        I,
        N,
        G,
        O
    }

    struct playDetail {
        uint256 idPlay;
        uint256 maxNumberCartons;
        uint256 cartonsSold;
        uint256 numberPlayer;
        uint256 cartonsByPlayer;
        uint256 cartonPrice;
        uint256 startPlayDate;
        uint256 endPlayDate;  
        uint256 amountUSDT;
        uint256[] totalNumbers;
        uint256[] numbersPlayed;      
        address ownerPlay;
        statePlay state;
    }

    struct cartonsDetail {
        uint256 idCarton;
        uint256 idPlay;
        mapping(words => uint256[]) number;
        address userOwner;        
    }    

    Counters.Counter private currentIdPlay;
    Counters.Counter private currentIdCartons;

    mapping(uint256 => playDetail) private play;
    mapping(uint256 => uint256[]) private PlayCartons;
    mapping(uint256 => uint256[]) private playCartonWins;
    mapping(address => uint256[]) private userOwnerPlay;

    mapping(uint256 => cartonsDetail) private cartons;

    //En donde esta comprando el usuario
    //mapping(address => uint256[]) public userPlay;
    mapping(address => uint256[]) private userCartons;

    mapping(address => bool) private owner;




    //numeros posibles del bingo
    mapping(words => uint256[]) private numbersOfBingo;

    //events
    event CreateNewPlay(address owner, uint256 idPlay);

    //modifier
    modifier onlyOwner() {
        require(owner[msg.sender] == true, 
            "Exclusive function of the Owner");
        _;
    }

    function isOwner(address _account) external view returns (bool) {
        return owner[_account];
    }

    function getCurrentIdPLay() external view returns (uint256) {
        return currentIdPlay.current();
    }

    function getCurrentIdCartons() external view returns (uint256) {
        return currentIdCartons.current();
    }

    function getPlayDetail(uint256 _idPLay)
        external
        view
        returns (playDetail memory)
    {
        return play[_idPLay];
    }

    function getRamdonNumber() external view returns (uint256) {
        return Ramdom.s_requestId();
    }

    function createAllNumberOfBingo() private onlyOwner returns (bool) {
        for (uint256 i = 1; i <= 15; i++) {
            numbersOfBingo[words.B].push(i);
            numbersOfBingo[words.I].push(i + 15);
            numbersOfBingo[words.N].push(i + 30);
            numbersOfBingo[words.G].push(i + 45);
            numbersOfBingo[words.O].push(i + 60);
        }
        return true;
    }

    function getNumberOfWord(words _word)
        external
        view
        returns (uint256[] memory)
    {
        return numbersOfBingo[_word];
    }

    function getIdCartonsPlay(uint256 _idPlay)
        external
        view
        returns (uint256[] memory)
    {
        return PlayCartons[_idPlay];
    }

    function getNumersCartons(uint256 _idCartons, words _word)
        external
        view
        returns (uint256[] memory)
    {
        return cartons[_idCartons].number[_word];
    }

    function getNumbersPlayedByPlay(uint256 _idPlay)
    external
    view
    returns (uint256[] memory){
        return play[_idPlay].numbersPlayed;
    }


   
    function isUserOwnerPlay(address _account, uint256 _idPlay)
        internal
        view
        returns (bool)
    {
        bool playReturn = false;
        if (userOwnerPlay[_account].length > 0) {
           
            for (uint256 i = 0; i < userOwnerPlay[_account].length; i++) {
                if (userOwnerPlay[_account][i] == _idPlay) {
                    playReturn = true;
                }
            }
        }
        return playReturn;
    }
    function changeStatePlayToInitiated(uint256 _idPlay)
    external
    returns(bool){

        require(isUserOwnerPlay(msg.sender, _idPlay),
            "you don't own the game");

        require(play[_idPlay].endPlayDate > block.timestamp, 
            "the end date of has already happened");

        play[_idPlay].state = statePlay.INITIATED;

        return true;
    }


    function isPlay(uint256 _idPlay)
    internal
    view
    returns(bool){
        bool exists = false;

        if (_idPlay > 0 &&
            play[_idPlay].idPlay == _idPlay){
            exists = true;
        }
        return exists;
    }

    function isCartonPlay(uint256 _idPlay, uint256 _idCarton)
    internal
    view
    returns(bool){
        bool exists = false;

        if(PlayCartons[_idPlay].length > 0){
        
            for (uint256 i = 0; i < PlayCartons[_idPlay].length; i++) {
                if(PlayCartons[_idPlay][i] == _idCarton){
                   exists = true; 
                }
            }
        }

        return exists;

    }

    function getPlayOwnerUser()
    external
    view 
    returns (uint256[] memory){
        return userOwnerPlay[msg.sender];
    }

    function createPlay(
        uint256 _maxNumberCartons,
        uint256 _numberPlayer,
        uint256 _cartonsByPlayer,
        uint256 _cartonPrice,
        uint256 _endDate
    ) external returns (bool) {
        require(
            block.timestamp < _endDate,
            "The game end date must be greater than the current date"
        );

        require(
            _cartonPrice > 0,
            "The price of the carton must be greater than zero"
        );

        uint256 _idPlay = currentIdPlay.current();

        play[_idPlay].idPlay = _idPlay;
        play[_idPlay].maxNumberCartons = _maxNumberCartons;
        play[_idPlay].numberPlayer = _numberPlayer;
        play[_idPlay].cartonsByPlayer = _cartonsByPlayer;
        play[_idPlay].cartonPrice = _cartonPrice;
        play[_idPlay].startPlayDate = block.timestamp;
        play[_idPlay].endPlayDate = _endDate;
        play[_idPlay].state = statePlay.CREATED;
        play[_idPlay].ownerPlay = msg.sender;
        play[_idPlay].amountUSDT = 0;
        play[_idPlay].cartonsSold = 0;
        play[_idPlay].ownerPlay = address(0);

        for (uint i = 1 ; i < 76 ; ++i){
            play[_idPlay].totalNumbers.push(i);
        }

        userOwnerPlay[msg.sender].push(_idPlay);

        currentIdPlay.increment();

        emit CreateNewPlay(msg.sender, _idPlay);

        return true;
    }

    
    function removeIndexArray(uint256[] memory array, uint256 index)
        internal
        pure
        returns(uint256[] memory) {          

        uint[] memory arrayNew = new uint[](array.length-1);
        for (uint i = 0; i<arrayNew.length; i++){
            if(i != index && i<index){
                arrayNew[i] = array[i];
            } else {
                arrayNew[i] = array[i+1];
            }
        }
        return arrayNew;
    }

    function generateNumberRamdom(
        uint256 _idPlayOrCarton,
        uint256 _min,
        uint256 _max,
        uint256 _seed
    ) internal pure returns (uint256) {

        //uint256 _seed = Ramdom.s_requestId();

        require(_seed != 0 , "seed cannot be 0");

        uint256 _seedTemp = uint256(
            keccak256(
                abi.encodePacked(
                    _idPlayOrCarton, _seed
                    ))) % _max;

        _seedTemp = _seedTemp + _min;            

        return (_seedTemp);
    }

    function getNumberCarton(uint256 _idPlay, uint256 _idCarton, words _word)
    external 
    view 
    returns(uint256[] memory){

        require(play[_idPlay].idPlay > 0, "the play not exists");

        require(isCartonPlay(_idPlay, _idCarton), "the carton no existes in the play");

        require(cartons[_idCarton].idCarton > 0, "the carton no existe"); 

        return cartons[_idCarton].number[_word];

    }
   
    function _buyCartonsPlay(
        uint256 _idPlay, 
        uint256 _cartonsNumber,
        address _user
        ) 
    internal 
    returns (bool) {     


        //llamar para generar nueva cemilla
        uint256 _seed = Ramdom.s_requestId();

        require(_seed != 0 , "seed cannot be 0");

        uint256 valueCartonsBuy = play[_idPlay].cartonPrice * _cartonsNumber;

        require(USD.transferFrom(_user, address(this), valueCartonsBuy));  

        play[_idPlay].amountUSDT += valueCartonsBuy;

        for (uint256 i = 0; i < _cartonsNumber; i++) {
            uint256 idCarton = currentIdCartons.current();
            PlayCartons[_idPlay].push(idCarton);

            // j = 0 --> B
            // j = 1 --> I
            // j = 2 --> N
            // j = 3 --> G
            // j = 4 --> O
            for (uint256 j = 0; j < 5; j++) {
                uint256 min;
                uint256 max;
                words wordCarton;

                //index Words B
                if (j == 0) {
                    min = 1;
                    max = 15;
                    wordCarton = words.B;
                }

                //index Words I
                if (j == 1) {
                    min = 16;
                    max = 30;
                    wordCarton = words.I;
                }

                //index Words N
                if (j == 2) {
                    min = 31;
                    max = 45;
                    wordCarton = words.N;
                }

                //index Words G
                if (j == 3) {
                    min = 46;
                    max = 60;
                    wordCarton = words.G;
                }

                //index Words O
                if (j == 4) {
                    min = 61;
                    max = 75;
                    wordCarton = words.O;
                }

                uint256[] memory possibleNumber = numbersOfBingo[wordCarton];
                cartons[idCarton].idCarton = idCarton;
                cartons[idCarton].idPlay = _idPlay;
                

                //llena el carton
                //sacar a una funcion?
                for (uint256 x = 0; x < 5; x++) {                    
                    
                    uint256 ramdonIndex = generateNumberRamdom(
                        i,
                        0,
                        possibleNumber.length,
                        _seed                        
                    );                    

                    cartons[idCarton].number[wordCarton].push(
                        possibleNumber[ramdonIndex]
                    );

                    possibleNumber = removeIndexArray(possibleNumber, ramdonIndex);
                    
                }              

            }           
           

            cartons[idCarton].userOwner = _user;
            userCartons[_user].push(idCarton);
            play[_idPlay].cartonsSold ++;
            currentIdCartons.increment();
            
        }

        return true;

    }


    function buyCartonsPlay(
        uint256 _idPlay,
        uint256 _cartonsToBuy,
        uint256 _amount
        )
    external
    returns(bool){
        
        require(
            isPlay(_idPlay) && play[_idPlay].state == statePlay.CREATED, 
            "the id play not exists"
        );  
 
        require(
            play[_idPlay].endPlayDate > block.timestamp,
            "the endgame date has already happened"
        );

        require(
            _cartonsToBuy > 0 ,
            "the number of cards to buy must be greater than 0"
        );

        require(
            USD.balanceOf(msg.sender) >= _amount,
            "Do not have the necessary funds of USD"
        );        

        require(
            play[_idPlay].cartonPrice * _cartonsToBuy <= _amount, 
            "you do not send the amount of USDT necessary to make the purchase"
        );

        require(
            play[_idPlay].cartonsByPlayer >= _cartonsToBuy, 
            "can not buy that quantity of cartons"
        );
      
        require(
            play[_idPlay].maxNumberCartons > play[_idPlay].cartonsSold,
            "there are no cards to buy"
        );       


        bool isBuyCartons = _buyCartonsPlay(
            _idPlay,
            _cartonsToBuy,
            msg.sender            
        );

        return isBuyCartons;

    }


    function _generateWinningNumbers(uint256 _idPlay, uint256 _seed)
    internal
    returns (bool){

        
        uint256 randomNumer = generateNumberRamdom(
            _idPlay,
            0,
            play[_idPlay].totalNumbers.length,
            _seed
        );

        play[_idPlay].numbersPlayed.push(
            play[_idPlay].totalNumbers[randomNumer]
        );       

        play[_idPlay].totalNumbers = removeIndexArray(
            play[_idPlay].totalNumbers,
            randomNumer
        );

        return true;

    }

    function generateWinningNumbers(uint256 _idPlay)
    external 
    returns (bool){

        require(isPlay(_idPlay),"the number is not a play");

        require(isUserOwnerPlay(msg.sender, _idPlay),
            "you don't own the game");

        require(
            play[_idPlay].state == statePlay.INITIATED, 
            "the play is not INITIATED"
        );       

        require(
            play[_idPlay].endPlayDate > block.timestamp,
            "the endgame date has already happened"
        );

        //**********/
        //debemos genera una nueva clave 
        Ramdom.requestRandomWords();    
        
        require(Ramdom.s_requestId() != 0 , "seed cannot be 0");

        require (_generateWinningNumbers(_idPlay,  Ramdom.s_requestId()), 
        "An error has occurred");          

        return true;      

    }

    constructor(address usd, address _random) {
        
        owner[msg.sender] = true;

        USD = IERC20(usd);

        Ramdom = RandomNumberConsumer(_random);

        currentIdPlay.increment();

        currentIdCartons.increment();

        createAllNumberOfBingo();
    }
}
