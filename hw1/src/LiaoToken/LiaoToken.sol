// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LiaoToken is IERC20 {
    // TODO: you might need to declare several state variable here
    mapping(address account => uint256) private _balances;
    mapping(address account => mapping(address spender => uint256)) private _allowances;
    mapping(address account => bool) isClaim;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    event Claim(address indexed user, uint256 indexed amount);
    error ERC20InsufficientBalance(address sender,uint256 fromBalance,uint256 amount);
    error ERC20InsufficientAllowance(address spender,uint256 currentAllowance,uint256 value);

    constructor(string memory name_, string memory symbol_) payable {
        _name = name_;
        _symbol = symbol_;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function claim() external returns (bool) {
        if (isClaim[msg.sender]) revert();
        _balances[msg.sender] += 1 ether;
        _totalSupply += 1 ether;
        emit Claim(msg.sender, 1 ether);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        // TODO: please add your implementaiton here
        return transferFrom(msg.sender,to,amount);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        // TODO: please add your implementaiton here
        emit Transfer(from,to,value);
        if(from!=msg.sender)
        {
            uint256 currentAllowance = allowance(from, msg.sender);
            if (currentAllowance != type(uint256).max) {
                if (currentAllowance < value) {
                    revert ERC20InsufficientAllowance(msg.sender, currentAllowance, value);
                }
                unchecked {
                    _allowances[from][msg.sender] = currentAllowance - value;
                    //approve(owner, spender, currentAllowance - value, false);
                }
            }
        }
        
        uint256 fromBalance = _balances[from];
        
        if (fromBalance < value) {
            revert ERC20InsufficientBalance(from, fromBalance, value);
        }
        unchecked {
            // Overflow not possible: value <= fromBalance <= totalSupply.
            _balances[from] = fromBalance - value;
            // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
            _balances[to] += value;
        }
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        // TODO: please add your implementaiton here
        address owner=msg.sender;
        emit Approval(owner, spender, value);
        _allowances[owner][spender] = value;
        return true;
        

    }

    function allowance(address owner, address spender) public view returns (uint256) {
        // TODO: please add your implementaiton here
        return _allowances[owner][spender];
    }
}
