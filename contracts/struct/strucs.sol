//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

library structBingo{

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
        uint256 totalPrize;
        uint256 startDate;
        uint256 endDate;
        uint256[] carton;
        statePlay state;
        mapping(words => uint[4]) winerNumber;
    }


    struct cartonsDetail{
        uint256 idCarton;
        uint256 idPlay;
        mapping(words => uint[4]) number;
    }


}