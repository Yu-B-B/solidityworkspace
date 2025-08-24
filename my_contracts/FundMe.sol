// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 1、收款函数
// 2、记录投资人且能查看
// 3、在锁定期哪，达到目标值，可提款
// 4、规定期间内，未完成筹款，释放返还

contract FundMe{

    mapping (address => uint256) internal funderMap;

    // eth 最小单位,设置为常量，任何位置都无法改变
    uint256 constant MINIMUM_VALUE = 1 * 10 ** 10;
    // usd 最小单位，100USD
    uint256 constant MINIMUM_USD_VALUE = 100 * 10 ** 18;

    // 替换阈值
    // uint256 MAXMUM_VALUE = 1000 * 10 ** 18; //UDS
    uint256 MAXMUM_VALUE = 4 * 10 ** 10; //UDS

    // 窗口期，期间内只能fund
    uint256 deploymentTimestamp;
    uint256 lockTime;

    AggregatorV3Interface internal dataFeed;

    address owner;

    constructor(){
        owner = msg.sender;
        // 初始化dataFeed，一次初始化后续将不再new。注意：调用三方合约时，需要确保合约部署到链上（测试），才能进行调用, ！！这里的地址为线上地址
        dataFeed = AggregatorV3Interface(owner);
        
    } 

    // 1、收款函数，address uint
    function fund() external payable {
        require(msg.value < MINIMUM_USD_VALUE, "it's too "); // 如果使用链上数量判断，不符合实际使用者体感
        // require(calculateUsdPrice(msg.value) < MINIMUM_USD_VALUE, "it's too "); // 如果使用链上数量判断，不符合实际使用者体感
        funderMap[msg.sender] = msg.value;
    }
    
    // 查询捐款人捐款数量
    function found(address _user) public view returns(uint256) {
        return funderMap[_user];
    }

    // 提款
    function getFund() external isOwner{
        // address(this) 返回当前合约
        require(address(this).balance >= MAXMUM_VALUE, "target is not reached");
        // require(calculateUsdPrice(address(this).balance) >= MAXMUM_VALUE, "target is not reached");
        // 将合约中balance转移给owner,转账方式：transfer（只有转账操作）、send）、call（任何情况下都可使用，纯转账、转账中存在其他操作）
        // transfer，将eth发送到另一个地址，失败将返还
        payable(msg.sender).transfer(address(this).balance);
        // sender，最终还是transfer,成功放回true，失败返回false
        // call，
    }

    // 退款
    function refund() external {
        // 已经筹满时，不允许退款
        require(address(this).balance < MAXMUM_VALUE, "target is reached");
        // 为所有捐款人退款
        uint256 amount = found(msg.sender);
        require(amount != 0,"there is no fund for you");
        bool success;
        (success,) = payable(msg.sender).call{value: amount}("");
        require(success, "transfer is failed");
        // 成功后需要将地址清掉,防止能重复调用
        funderMap[msg.sender] = 0;
    }

    //
    function foundContractUser() public view returns(address) {
        return owner; 
    }

    // 合约所有权转移
    function transferOwnerShip(address _newOwner) public  isOwner{
        owner = _newOwner;
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

    modifier isOwner() {
        require(msg.sender == owner, "you don't have permission");
        _;
    }

}