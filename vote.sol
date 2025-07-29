// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

contract Vote {

    string[5] public candidates = ["A", "B", "C", "D", "E"];

    mapping(uint => uint) public votes;

    mapping(address => bool) public voted;

    struct VoteInfo {
        address voter;
        uint timestamp;
    }
    VoteInfo[] public voters;

    uint public duration;
    uint public endTime;

    // event : 블록체인 로그를 생성하여 외부 서비스가 특정 상태 변화를 감지할 수 있게 함.
    // indexed : 해당 값으로 필터링 및 검색이 가능하게 하는 기능
    event Voted(address indexed voter, uint indexed candidateId);

    constructor(uint _duration) {
        duration = _duration;
        endTime = block.timestamp + duration;
    }

    // modifier : 함수의 실행을 제한하거나 확장하는 데 사용되는 조건 블록.
    // _ : modifier를 사용하는 함수 본문이 해당 위치에 삽입됨.
    modifier onlyInDuration() {
        require(block.timestamp <= endTime);
        _;
    }

    // require : 조건이 충족되지 않으면 트랜잭션을 중단시킴.
    modifier onlyOnce() {
        require(!voted[msg.sender]);
        _;
    }

    function vote(uint candidateId) external onlyInDuration onlyOnce {
        votes[candidateId]++;
        voted[msg.sender] = true;

        voters.push(VoteInfo(msg.sender, block.timestamp));

        emit Voted(msg.sender, candidateId);
    }

    function getVotersCount() external view returns (uint) {
        return voters.length;
    }
}