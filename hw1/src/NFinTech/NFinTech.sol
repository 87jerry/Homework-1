// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}

interface IERC721TokenReceiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4);
}

contract NFinTech is IERC721 {
    // Note: I have declared all variables you need to complete this challenge
    string private _name;
    string private _symbol;

    uint256 private _tokenId;

    mapping(uint256 => address) private _owner;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => bool) private isClaim;
    mapping(address => mapping(address => bool)) _operatorApprovals;

    error ZeroAddress();
    error ERC721InvalidOperator(address operator);
    error ERC721InvalidApprover(address auth);
    error ERC721InvalidReceiver(address);
    error ERC721IncorrectOwner(address from,uint256 tokenId,address previousOwner);
    error ERC721InsufficientApproval(address spender,uint256 tokenId);

    constructor(string memory name_, string memory symbol_) payable {
        _name = name_;
        _symbol = symbol_;
    }

    function claim() public {
        if (isClaim[msg.sender] == false) {
            uint256 id = _tokenId;
            _owner[id] = msg.sender;

            _balances[msg.sender] += 1;
            isClaim[msg.sender] = true;

            _tokenId += 1;
        }
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address owner) public view returns (uint256) {
        if (owner == address(0)) revert ZeroAddress();
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owner[tokenId];
        if (owner == address(0)) revert ZeroAddress();
        return owner;
    }

    function setApprovalForAll(address operator, bool approved) external {
        // TODO: please add your implementaiton here
        address owner=msg.sender;
        if (operator == address(0)) {
            revert ERC721InvalidOperator(operator);
        }
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        // TODO: please add your implementaiton here
        return _operatorApprovals[owner][operator];
    }

    function approve(address to, uint256 tokenId) public {
        // TODO: please add your implementaiton here
        address auth=msg.sender;
        bool emitEvent=true;
        if (emitEvent || auth != address(0)) {
            address owner = ownerOf(tokenId);

            // We do not use _isAuthorized because single-token approvals should not be able to call approve
            if (auth != address(0) && owner != auth && !isApprovedForAll(owner, auth) &&auth!=getApproved(tokenId)) {
                revert ERC721InvalidApprover(auth);
            }

            if (emitEvent) {
                emit Approval(owner, to, tokenId);
            }
        }

        _tokenApprovals[tokenId] = to;
    }

    function getApproved(uint256 tokenId) public view returns (address operator) {
        // TODO: please add your implementaiton here
        return _tokenApprovals[tokenId];

    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        // TODO: please add your implementaiton here
        emit Transfer(from, to, tokenId);
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.
        address owner = ownerOf(tokenId);
        address spender=msg.sender;

        // Perform (optional) operator check
        if (spender != address(0)) {
            if(!(owner == spender || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender))
                revert ERC721InsufficientApproval(spender, tokenId);
            
        }
        // Execute the update
        if (owner != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            approve(address(0), tokenId);
            unchecked {
                _balances[owner] -= 1;
            }
        }

        if (to != address(0)) {
            unchecked {
                _balances[to] += 1;
            }
        }

        _owner[tokenId] = to;
        
        if (owner != from) {
            revert ERC721IncorrectOwner(from, tokenId, owner);
        }
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        // TODO: please add your implementaiton here
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        // TODO: please add your implementaiton here
        transferFrom(from, to, tokenId);
        address operator=msg.sender;
        bytes4 retval=IERC721TokenReceiver(to).onERC721Received(operator, from, tokenId, data);
        if (retval != IERC721TokenReceiver.onERC721Received.selector) {
            // Token rejected
            revert ERC721InvalidReceiver(to);
        }
    }

    
}
