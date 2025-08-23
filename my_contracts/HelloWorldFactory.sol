// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {HelloWorld} from "./HelloWorld.sol";

contract HelloWorldFactory{
    HelloWorld hw;
    HelloWorld[] hws;

    function createHWcontract() public {
        hw = new HelloWorld();
        hws.push(hw);
    }

    function getHelloWorldByIndex(uint64 _index) public view returns(HelloWorld){
        return hws[_index];
    }

    function sayHelloFromContract(uint64 _index, uint64 _id) public view returns(string memory) {
        return getHelloWorldByIndex(_index).sayHello(_id);
    }

    function setHelloPhrase(uint64 _index,uint64 _id,string memory _str) public {
        getHelloWorldByIndex(_index).setHello(_str,_id);
    }

}