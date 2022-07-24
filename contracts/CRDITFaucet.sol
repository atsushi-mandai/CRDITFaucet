// SPDX-License-Identifier: MIT
// ATSUSHI MANDAI CRDIT Contracts

pragma solidity ^0.8.0;

import "./interfaces/ICRDIT.sol";
import "./helpers/Ownable.sol";

/// @title CRDIT Faucet
/// @author Atsushi Mandai
/// @notice A simple faucet contract for CRDIT.
contract CRDITFaucet is Ownable {

    event MintedCRDIT(uint256 amount);

    ICRDIT crdit = ICRDIT(CRDITAddress);

    /**
     * @dev Address of CRDIT.
     */
    address public CRDITAddress = 0x9Ef046a7AF1B2e456D7b619da2e469BaBA018193;

    /**
     * @dev Amount of CREDIT this faucet gives to a user.
     */
    uint256 public faucetAmount = 100 * (10**18);

    /**
     * @dev Holds the next mint available time.
     */
    mapping(address => uint256) public addressToTime;

    /**
     * @dev Let the contract owner change the address of CRDIT.
     */ 
    function changeCRDITAddress(address _address) public onlyOwner returns(bool) {
        CRDITAddress = _address;
        return true;
    }

    /**
     * @dev Let the contract owner change the faucet Amount.
     */ 
    function changeFaucetAmount(uint256 _amount) public onlyOwner returns(bool) {
        faucetAmount = _amount;
        return true;
    }

    /**
     * @dev Adds 1 day to addressToTime[_msgSender()], then mints CRDIT for _msgSender().
     */
    function mintFixedCRDIT() public returns(uint256) {
        require(block.timestamp > addressToTime[_msgSender()]);
        addressToTime[_msgSender()] = addressToTime[_msgSender()] + 1 days;
        crdit.issuerMint(_msgSender(), faucetAmount);
        emit MintedCRDIT(faucetAmount);
        return faucetAmount;
    }

    function mintRandomCRDIT() public returns(uint256) {
        require(block.timestamp > addressToTime[_msgSender()]);
        uint256 rand = uint256(keccak256(abi.encodePacked(_msgSender(), block.timestamp, crdit.totalSupply()))) % 3;
        uint256 value = faucetAmount;
        if (rand == 1) {
            value = faucetAmount * 80 / 100;
            crdit.issuerMint(_msgSender(), value);
        } else if (rand == 2) {
            crdit.issuerMint(_msgSender(), value);
        } else {
            value = faucetAmount * 120 / 100;
            crdit.issuerMint(_msgSender(), value);
        }
        emit MintedCRDIT(value);
        return value;
    }


    

}