// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GrantVault {
    struct Grant {
        uint256 grantID;
        address donor;
        uint256 amount;
        uint256 releaseTime;
        bool claimed;
    }

    uint256 grantID;
    mapping(address => Grant[]) public grants;


    event GrantCreated(address donor, address beneficiary, uint256 amount, uint256 releaseTime);
    event GrantClaimed(address beneficiary, uint256 amount);
    event ReceivedEther(uint256 amount);

    function createGrant(address beneficiary, uint256 _releaseDay) public payable {
        uint256 releaseDay= block.timestamp + (_releaseDay * 1 days);
        require(releaseDay > block.timestamp, "Release time must be in the future");

        grants[beneficiary].push(Grant(grantID, msg.sender, msg.value, releaseDay, false));
        emit GrantCreated(msg.sender, beneficiary, msg.value, releaseDay);
        grantID= grantID + 1;
    }

    function claimGrant(uint256 _id) public {
        Grant[] storage grantArray = grants[msg.sender];
        require(grantArray.length > 0, "You are not a beneficiary");
        require(_id < grantArray.length, "Not a valid array ID");

        Grant storage grant= grantArray[_id];
        require(grant.claimed == false, "Grant already claimed");
        require(block.timestamp >= grant.releaseTime, "Grant release time not reached");

        grant.claimed = true;
        payable(msg.sender).transfer(grant.amount);

        emit GrantClaimed(msg.sender, grant.amount);
    }

    function checkGrantAmount(address beneficiary, uint256 _id) external view returns(uint256){
        Grant[] memory grantArray = grants[beneficiary];
        require(grantArray.length > 0, "This user is not a beneficiary");
        require(_id < grantArray.length, "Not a valid array ID");

        return grantArray[_id].amount;
    }
}