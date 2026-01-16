
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * FakeVoteDetection - Demo smart contract for storing votes 
 * with simple on-chain duplicate/fake detection rules.
 *
 * ⚠️ Real fake-vote detection must use machine learning off-chain.
 * This contract only shows basic validation for demonstration.
 */

contract FakeVoteDetection {
    address public admin;

    struct Vote {
        uint256 voteId;
        address voter;
        string choice;
        bool isFake;      // Flag based on simple pattern checks
        uint256 timestamp;
    }

    // Mapping voteId -> Vote data
    mapping(uint256 => Vote) public votes;

    // Track if an address has voted before
    mapping(address => bool) public hasVotedBefore;

    event VoteSubmitted(
        uint256 indexed voteId,
        address indexed voter,
        string choice,
        bool isFake,
        uint256 timestamp
    );

    constructor() {
        admin = msg.sender;
    }

    /*
     * Submit a vote
     * Basic fake vote detection rules:
     * - If voter has voted before → mark as fake
     * - If voteId already exists → mark as fake
     */
    function submitVote(uint256 _voteId, string memory _choice) public {
        require(votes[_voteId].voteId == 0, "Vote ID already used");

        bool flaggedFake = false;

        // Rule 1: Duplicate user voting
        if (hasVotedBefore[msg.sender]) {
            flaggedFake = true;
        }

        // Store vote
        votes[_voteId] = Vote({
            voteId: _voteId,
            voter: msg.sender,
            choice: _choice,
            isFake: flaggedFake,
            timestamp: block.timestamp
        });

        // Mark user as having voted
        hasVotedBefore[msg.sender] = true;

        emit VoteSubmitted(
            _voteId,
            msg.sender,
            _choice,
            flaggedFake,
            block.timestamp
        );
    }

    // Admin can reset user vote history (demo)
    function resetVoter(address user) public {
        require(msg.sender == admin, "Only admin");
        hasVotedBefore[user] = false;
    }

    // Receive ETH (optional)
    receive() external payable {}
}
