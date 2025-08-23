// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 1、收款函数
// 2、记录投资人且能查看
// 3、在锁定期哪，达到目标值，可提款
// 4、规定期间内，未完成筹款，释放返还

contract FundMe{

    mapping (address => uint256) internal funderMap;

    // eth 最小单位
    uint256 MINIMUM_VALUE = 1 * 10 ** 10;
    // usd 最小单位，100USD
    uint256 MINIMUM_USD_VALUE = 100 * 10 ** 18;

    AggregatorV3Interface internal dataFeed;

    address owner;

    constructor(){
        owner = msg.sender;
        // 初始化dataFeed，一次初始化后续将不再new。注意：调用三方合约时，需要确保合约部署到链上（测试），才能进行调用, ！！这里的地址为线上地址
        dataFeed = AggregatorV3Interface(owner);
    } 

    // 1、收款函数，address uint
    function fund() external payable {
        require(calculateUsdPrice(msg.value) < MINIMUM_USD_VALUE, "it's too "); // 如果使用链上数量判断，不符合实际使用者体感
        funderMap[msg.sender] = msg.value;
    }
    
    // 查询捐款人捐款数量
    function found(address _user) public view returns(uint256) {
        return funderMap[_user];
    }

    //
    function foundContractUser() public view returns(address) {
        return owner;
    }

    // chain link data feed
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    // calculate usd price use eth price and eth amount
    function calculateUsdPrice(uint256 _amount) internal view returns(uint256){
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        // 确保交易对的两个参数精度一致，_amount 是eth的精度，ethPrice是USD精度
        return _amount * ethPrice / (10 ** 8);
    }

}