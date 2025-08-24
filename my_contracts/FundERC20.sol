// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./FundMe.sol";

contract FundERC20 is ERC20{
    FundMe fundMe;
    constructor (address fundAddress) ERC20("FundToken","FT"){
        fundMe = FundMe(fundAddress);
    }

    // mint 与 claim 需要在筹款活动被发起人提取后开始，如何得知筹款内容被提取呢？
    // 在FundMe中，调用提取方法后，给定一个状态标记已被提取

    function mint(uint256 mintAmount) public isFundSuccess{
        require(fundMe.found(msg.sender) > mintAmount, "there is not hava enough TOKEN");
        _mint(msg.sender, mintAmount);
        fundMe.amountMintDecrease(msg.sender, fundMe.found(msg.sender) - mintAmount);
    }

    // 投资人 / 发起人 拿到/发放，相应匹配金额的内容后，调用claim销毁
    function claim(uint256 amount) public isFundSuccess{
        require(balanceOf(msg.sender) >= amount,"thers is not have enough token");
        _burn(msg.sender, amount);
    }

    modifier isFundSuccess {
        require(fundMe.isFundSuccess(), "the fund is not success yet");
        _;
    }
}