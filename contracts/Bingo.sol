//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./struct/strucs.sol";
import "./owner/ownerFunction.sol";
import "./utils/utils.sol";
 

contract Bingo {

  
    mapping(uint256 => structBingo.playDetail) play;   

    mapping(uint256 => structBingo.cartonsDetail) cartons;

    mapping(address => uint256[]) userPlay;

    mapping(address => uint256[]) userCartons;

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