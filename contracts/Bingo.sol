//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract Bingo is VRFConsumerBase {
    bytes32 private s_keyHash;
    uint256 private s_fee;

    uint256 public randomResult;

    mapping(bytes32 => address) private s_rollers;
    mapping(address => uint256) private s_results;

    constructor(
        address vrfCoordinator,
        address link,
        bytes32 keyHash,
        uint256 fee
    ) VRFConsumerBase(vrfCoordinator, link) {
        s_keyHash = keyHash;
        s_fee = fee;
    }

     function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }

    // constructor() 
    //     VRFConsumerBase(
    //         0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
    //         0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
    //     )
    // {
}
