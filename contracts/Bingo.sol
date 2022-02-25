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

    struct cartonsDetail {
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

    //numeros posibles del bingo
    mapping(words => uint256[]) private numbersOfBingo;

    //events
    event CreateNewPlay(address owner, uint256 idPlay);

    //modifier
    modifier onlyOwner() {
        require(owner[msg.sender] == true, "Exclusive function of the Owner");
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

    function createAllNumberOfBingo() external onlyOwner returns (bool) {
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

        emit CreateNewPlay(msg.sender, _idPlay);
        return true;
    }
   

     function getSlice(
        uint256 begin,
        uint256 end,
        string memory text)
        public pure returns (string memory) {

        bytes memory a = bytes(text);

        bytes memory b = new bytes(end-begin+1);

        for(uint i=0;i<=end-begin;i++){
            b[i] = a[i];
        }

        return string(b);    
    }

    function generateNumberRamdom(
        uint256 _min,
        uint256 _max,
        string memory _seed
    ) internal view returns (uint256) {
        //uint256 seed = Ramdom.s_requestId();

        return
            (uint256(
                keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed))
            ) % (_max - _min + 1)) + 1;

        //_seed % (_max - _min + 1) + 1;
    }

    function createNewCartons(uint256 _idPlay) external returns (bool) {
        require(
            isUserOwnerPlay(msg.sender, _idPlay),
            "you do not have permissions to create cards"
        );
        require(_createNewCartons(_idPlay), "Could not create game cards");
        return true;
    }

    function _createNewCartons(uint256 _idPlay) internal returns (bool) {

        string memory seed = Strings.toString(Ramdom.s_requestId());

        //crear nueva semilla
        uint256 numberCartons = play[_idPlay].maxNumberCartons;

        if (numberCartons == 0) {
            return false;
        }

        //numbers of cartons
        for (uint256 i = 0; i < numberCartons; i++) {
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
                uint256[] memory possibleNumber;

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

                possibleNumber = numbersOfBingo[wordCarton];

                cartons[idCarton].idCarton = idCarton;
                cartons[idCarton].idPlay = _idPlay;
                //llena el carton
                //sacar a una funcion?
                for (uint256 x = 0; x < 5; x++) {

                    console.log("length ", possibleNumber.length);

                    uint256 ramdonIndex = generateNumberRamdom(
                        0,
                        possibleNumber.length,
                        getSlice(0, idCarton, seed)                    
                    );

                    console.log("index ", ramdonIndex);

                    cartons[idCarton].number[wordCarton].push(
                        possibleNumber[ramdonIndex]
                    );

                    delete possibleNumber[ramdonIndex];
                }
            }

            currentIdCartons.increment();
        }

        return true;
    }

    constructor(address usd, address _random) {
        owner[msg.sender] = true;

        USD = IERC20(usd);

        Ramdom = RandomNumberConsumer(_random);
    }
}
