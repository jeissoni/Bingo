//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./struct/strucs.sol";
import "./utils/Counters.sol";
import "./token/IERC20.sol";

 

contract Bingo {

    IERC20 public USD;

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
        uint256[] carton;
        statePlay state;
        mapping(words => uint[4]) winerNumber;
    }


    struct cartonsDetail{
        uint256 idCarton;
        uint256 idPlay;
        mapping(words => uint[4]) number;
    }
  
    Counters.Counter private currentIdPlay;
    Counters.Counter private currentIdCartons;

    mapping(uint256 => playDetail) private play;   

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

    mapping(address => bool) owner;


    function createPlay(
        uint256 _idPlay,
        uint256 _maxNumberCartons,
        uint256 _numberPlayer,
        uint256 _cartonsByPlayer,
        uint256 _totalPrize,
        uint256 _startDate,
        uint256 _endDate,
        structBingo.statePlay _state
    ) external view returns(bool){
        bool result = ownerFunction._createPlay(_idPlay, _maxNumberCartons, _numberPlayer, _cartonsByPlayer, _totalPrize, _startDate, _endDate, _state);
    }

}