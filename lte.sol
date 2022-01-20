// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract LTE is ERC20, Ownable {


    uint public transferFee = 1;
    mapping(address=>bool) public excludedAddress; 
    address private feeWallet;
    


    constructor(address _owner,address _feeWallet, uint _totalSupply) ERC20("LikeToEarn", "LTE") {
        feeWallet =_feeWallet;
        excludedAddress[_owner] = true;
        excludedAddress[_feeWallet] = true;
        _mint(_owner,_totalSupply);
    }


    function setTransferFee(uint _fee) external onlyOwner {
        require(_fee>=0 && _fee<=5);
        transferFee = _fee;
    }

    function setFeeWallet(address _feeWallet) external onlyOwner {
        feeWallet = _feeWallet;
        excludedAddress[feeWallet] = true;
    }

    function getFeeWallet() external view onlyOwner returns(address) {
        return feeWallet;
    }


    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        uint fee;

        if (excludedAddress[recipient] || excludedAddress[sender]){

            fee = 0;
        }
        else {
            fee = amount*transferFee/100;
            super._transfer(sender,feeWallet,fee);
        }
        super._transfer(sender,recipient,amount - fee);
    }

    //Address not paying tax
    function excludeAddress(address _address) external onlyOwner {
        require(!excludedAddress[_address]);
        excludedAddress[_address] = true;
    }

    //Address paying tax
    function includeAddress(address _address) external onlyOwner{
        require(excludedAddress[_address]);
        excludedAddress[_address] = false;
    }


}
