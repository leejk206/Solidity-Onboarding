// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Diary {

    enum Feeling { Happy, Sad, Angry } // int 형식으로 입력받음

    struct DiaryEntry{
        string title;
        string content;
        Feeling feeling;
        uint256 timestamp;
    }

    mapping(address => DiaryEntry[]) private userDiaries;

    function writeDiary(string memory _title, string memory _content, Feeling _feeling) public {
        DiaryEntry memory newEntry = DiaryEntry({
            title: _title,
            content: _content,
            feeling: _feeling,
            timestamp: block.timestamp
        });

        userDiaries[msg.sender].push(newEntry); // memory가 아니기 때문에 push 사용 가능
    }

    function getMyDiariesByFeeling(Feeling _feeling) public view returns (DiaryEntry[] memory){
        DiaryEntry[] memory allEntries = userDiaries[msg.sender];
        uint256 count = 0;

        for(uint256 i = 0; i < allEntries.length; i++){
            if(allEntries[i].feeling == _feeling){
                count++;
            }
        }

        DiaryEntry[] memory filtered = new DiaryEntry[](count); // memory 저장이기 때문에 push 사용 불가. 병신같은 문법
        uint256 j = 0;
        for (uint256 i = 0; i < allEntries.length; i++){ // for loop를 2개 사용해서 배열을 옮겨야 함.
            if(allEntries[i].feeling == _feeling) {
                filtered[j] = allEntries[i];
                j++;
            }
        }

        return filtered;
    }

    // 일기개수반환
    function getMyDiariesCount() public view returns (uint256){
        return userDiaries[msg.sender].length;

    } 

    // getDiariesByFeeling과 같은 로직으로 동작.
    function getDiariesByTimestamp(uint256 startTimestamp, uint256 endTimestamp) public view returns (DiaryEntry[] memory){
        DiaryEntry[] memory allEntries = userDiaries[msg.sender];
        uint256 count = 0;

        for(uint256 i = 0; i < allEntries.length; i++) {
            if(allEntries[i].timestamp >= startTimestamp && allEntries[i].timestamp <= endTimestamp) {
                count++;
            }
        }

        DiaryEntry[] memory targets = new DiaryEntry[](count);
        uint256 j = 0;
        for(uint256 i = 0; i < allEntries.length; i++) {
            if(allEntries[i].timestamp >= startTimestamp && allEntries[i].timestamp <= endTimestamp){
                targets[j] = allEntries[i];
                j++;
            }
        }

        return targets;
    }

    // string 타입에 내장된 includes 등 함수가 없기 때문에, byte로 바꾸어서 비교해야 함.
    // 심지어 push가 안 되기 때문에 그 짓거리를 2번 반복해야함.
    // 너무 비효율적임. 대안 필요
    function stringIncludesInTitle(string memory keyword) public view returns (DiaryEntry[] memory){
        DiaryEntry[] memory allEntries = userDiaries[msg.sender];
        
        bytes memory keywordInBytes = bytes(keyword);

        uint256 count = 0;
        for(uint256 i = 0; i < allEntries.length; i++){ // 모든 diary 값에 대해 검사
            bytes memory titleInBytes = bytes(allEntries[i].title);

            if (titleInBytes.length < keywordInBytes.length) continue;

            for(uint256 j = 0; j <= titleInBytes.length - keywordInBytes.length; j++) { // title에 대해 keyword의 길이만큼 검사
                bool matchFound = true;
                for(uint256 k = 0; k < keywordInBytes.length; k++) { // 각 keyword들의 bytes값이 일치하는지 확인
                    if(titleInBytes[j + k] != keywordInBytes[k]) {
                        matchFound = false;
                        break;
                    }
                }
                if(matchFound) {
                    count++;
                    break;
                }
            }
        }

        // 같은 반복문 한 번 더 반복, 실제로 배열을 만드는 과정
        DiaryEntry[] memory filtered = new DiaryEntry[](count);
        uint256 idx = 0;

        for (uint256 i = 0; i < allEntries.length; i++) {
            bytes memory titleInBytes = bytes(allEntries[i].title);

            if (titleInBytes.length < keywordInBytes.length) continue;

            for (uint256 j = 0; j <= titleInBytes.length - keywordInBytes.length; j++) {
                bool matchFound = true;

                for (uint256 k = 0; k < keywordInBytes.length; k++) {
                    if (titleInBytes[j + k] != keywordInBytes[k]) {
                        matchFound = false;
                        break;
                    }
                }

                if (matchFound) {
                    filtered[idx] = allEntries[i];
                    idx++;
                    break;
                }
            }
        }

        return filtered;

    }

}
    
