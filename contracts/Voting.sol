// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Voting {
    struct candidate {
        string candidateName;
        uint voteCount;
        uint candidateID;
    }

    struct contest {
        string contestName;
        candidate[]  candidates;
        uint candidateCount;
        address[] admins;
        uint voteCount;
        bool completed;
        uint contestsID;
    }

    mapping(uint => mapping(address => bool)) public voters;
    contest[] public contests;
    uint public  contestsID= 0;

    function onlyAdmin(address[] memory admin) private view returns (bool){
       for (uint i = 0; i < admin.length - 1; i++) {
            if (admin[i] == msg.sender) {
                return true;
            }
       } 
       return false;    
    }


    function createContest(string memory _contestName) public  {
        contest storage newContest = contests.push();
        newContest.contestName= _contestName;
        newContest.voteCount= 0;
        newContest.candidateCount= 0;
        newContest.completed= false;
        newContest.contestsID= contestsID;
        newContest.admins.push(msg.sender);

        voters[contestsID][address(0)] = true;
        contestsID = contestsID + 1;
    }

    function getContest(uint _contestsID) public view returns (contest memory){
        return contests[_contestsID];
    }

    function getContestAll() public view returns (contest[] memory){
        return contests;
    }

    function getContestCandidate(uint _contestsID, uint _candidateID) public view returns (candidate memory){
        contest storage existingContest= contests[_contestsID];
        return existingContest.candidates[_candidateID];
    }

    function getContestCandiddateAll(uint _contestsID) public view returns (candidate[] memory){
        contest storage existingContest= contests[_contestsID];
        return existingContest.candidates;
    }

    function createContestCandidate(uint  _contestsID, string memory _candidateName) public {
        contest storage existingContest= contests[_contestsID];
        require(!(existingContest.candidateCount > 5), "You cannot add more candidate");

        candidate memory newCandidate;
        newCandidate.candidateName= _candidateName;
        newCandidate.voteCount= 0;
        newCandidate.candidateID= existingContest.candidateCount;
        existingContest.candidates.push(newCandidate);  
        existingContest.candidateCount++;
    } 

    function voteContestCandidate(uint  _contestsID, uint _candidateID, address _voter) public {
        contest storage existingContest= contests[_contestsID];
        require(!existingContest.completed, "Contest has ended");
        require(!voters[_contestsID][_voter], "You've voted before");

        existingContest.candidates[_candidateID].voteCount++;
        voters[_contestsID][_voter]= true;
    }

    function endContest(uint _contestID) public {
        contest storage existingContest= contests[_contestID];
        existingContest.completed= true;
    }

    function getContestWinner(uint _contestID) public view returns (string memory){
        contest memory existingContest= contests[_contestID];
        require(existingContest.completed, "Voting is still ongoing");
        require(!onlyAdmin(existingContest.admins), "You must be an admin to get contest winner");

        uint winningVote= 0;
        string memory winner;

        for (uint i = 0; i < existingContest.candidates.length - 1; i++) {
            if (existingContest.candidates[i].voteCount > winningVote){
                winner= existingContest.candidates[i].candidateName;
                winningVote= existingContest.candidates[i].voteCount;
            }
        }

        return winner;
    }
}