//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.7;
contract SlotMachine {

	uint public price;	// 최고 입찰액
    uint public numManagers; // 등록된 매니저 수
    bool private play;
    mapping (address => bool) public managers;

	/// 생성자
	constructor () payable {
		price = 0;
        numManagers = 0;
        play = false;
	}

    /// 관리자 등록
	function register() public returns (bool){
		// 아직 사용되지 않은 이름이면 신규 등록
		if (managers[msg.sender] == false) {
			managers[msg.sender] = true;
			numManagers++;
			return true;
		} else {
			return false;
		}
	}

    /// 관리자가 기본 상금 넣기
    function setPrize() public payable {
        // 입력값이 0.1ETH 이상인지 확인
        require(msg.value >= 0.1 ether && managers[msg.sender] == true);
        price += msg.value;
    }
    
    /// 사용요금 처리 함수
	function playGame() public payable {
		// 사용 요금이 0.1ETH인지 확인
		require(msg.value == 0.1 ether);
        price += 100000000000000000;
		play = true;
	}
	
    /// 배당금 처리 함수
	function withdraw(uint result) public{
		// 플레이를 한 사용자인지 확인
        // 0: 꽝, 1: 원금, 2: 1.5배, 3: 2배, 4: 3배, 5: 잭팟
		require(play);
		
        uint refundAmount = 0;
        if(result == 1) {
            refundAmount = 0.1 ether;
        } else if(result == 2) {
            refundAmount = 0.15 ether;
        } else if(result == 3) {
            refundAmount = 0.2 ether;
        } else if(result == 4) {
            refundAmount = 0.3 ether;
        } else if(result == 5) {
            refundAmount = price;
        }
		
		// 배당금 반환 처리
		if(!payable(msg.sender).send(refundAmount)) {
			revert();
		}
        /// 배당금 처리가 완료됐다면 플레이 종료 및 price 반영
        price -= refundAmount;
        play = false;
	}
}
