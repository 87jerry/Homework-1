// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* Problem 1 Interface & Contract */
contract StudentV1 {
    // Note: You can declare some state variable
	bool private isEnrolled;
    function register() external returns (uint256) {
        // TODO: please add your implementaiton here
		if(isEnrolled)
			return 123;
		else
		{
			isEnrolled = true;
			return 1000;
		}
			
    }
}

/* Problem 2 Interface & Contract */
interface IClassroomV2 {
    function isEnrolled() external view returns (bool);
}

contract StudentV2 {
    function register() external view returns (uint256) {
        // TODO: please add your implementaiton here
		if(IClassroomV2(msg.sender).isEnrolled())
			return 123;
		else
			return 1000;
		
    }
}

/* Problem 3 Interface & Contract */
contract StudentV3 {
	error gas_left(uint256);
    function register() external view returns (uint256) {
        // TODO: please add your implementaiton here
		//revert gas_left(gasleft());
		if(gasleft()<7000)
			return 123;
		else
			return 1000;
    }
}
