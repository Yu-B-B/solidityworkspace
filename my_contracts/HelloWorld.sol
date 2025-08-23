
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract HelloWorld{
    string str_global = "Hello";
    // strcut
    struct Info {
        uint64 id;
        string world;
        address add;
    }
    Info[] infos;

    mapping(uint64 => Info) maps;

    function setHello(string memory _str,uint64 _id) public{
        //str_global = _str;
        Info memory info = Info(_id, _str, msg.sender);
        infos.push(info);
        maps[_id] = info;
    }

    function sayHello(uint64 _id) public view returns (string memory){
        Info memory info = maps[_id];
        // V4 - 使用map结构保存不同用户信息，获取速度更快
        if(info.add==address(0x0)) {
            return appendSpeak(str_global);
        }else{
            return appendSpeak(info.world);
        }
        
        // V3 - 为不同对象设置不一样的内容，在调用时返回各个用户保存内容
        // for(uint256 i=0;i<infos.length;i++){
        //     if(infos[i].id == _id){
        //         return appendSpeak(infos[i].world);
        //     }
        // }

        // V2 - 在全局内容上追加新内容
        // return appendSpeak(str_global);
        // V1 - 返回静态内容
        // return str_global;
    }

    function appendSpeak(string memory _str) internal pure returns(string memory){
        return string.concat(_str," from remix message");
    }
}