
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FundProduct{
    // 1、通证名称（TOKENNAME）
    // 2、通证简称
    // 3、通证总量
    // 4、拥有者
    // 5、个人拥有数量
    string public tokenName;
    string public tokenSimpleName;
    uint256 public tokenSupply;
    address owner;
    mapping(address => uint256) internal personSupply;

    // 初始化TOKEN
    constructor(string memory _tokenName, string memory _tokenSimpleName) {
        tokenName = _tokenName;
        tokenSimpleName = _tokenSimpleName;
        owner = msg.sender;
    }

    // 获取通证，因为TOKEN只是在当前合约中流转，不像转移eth那样由一个地址转移到另一个地址
    function mint(uint256 _totalSupply) public {
        personSupply[msg.sender] += _totalSupply;
        tokenSupply += _totalSupply;
    }

    // 转移通证
    function transfer(uint256 amount, address to) public {
        require(personSupply[msg.sender] >= amount, "you do not have enough token");
        personSupply[msg.sender] -= amount;
        personSupply[to] += amount;
    }

    // 查看通证数量
    function getTokenAmount(address addr) public view returns(uint256) {
        return personSupply[addr];
    }
}