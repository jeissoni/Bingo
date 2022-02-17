//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./struct/strucs.sol";
import "./owner/ownerFunction.sol";
import "./utils/utils.sol";

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
