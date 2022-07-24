// SPDX-License-Identifier: MIT
// ATSUSHI MANDAI CRDIT Faucet Contracts

pragma solidity ^0.8.0;

import "./interfaces/ICRDIT.sol";
import "./helpers/Ownable.sol";

/// @title CRDIT Faucet
/// @author Atsushi Mandai
/// @notice A simple faucet contract for CRDIT.
contract CRDITFaucet is Ownable {

    event MintedCRDIT(uint256 amount);

    /**
     * @dev Address of CRDIT.
     */
    address public CRDITAddress = 0x9Ef046a7AF1B2e456D7b619da2e469BaBA018193;

    /**
     * @dev Amount of CREDIT this faucet gives to a user.
     */
    uint256 public faucetAmount = 95 * (10**18);

    /**
     * @dev Amount of CREDIT this faucet gives to an agent.
     */
    uint256 public agentRewards = 5 * (10**18);

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
     * @dev Let the contract owner change the faucetAmount.
     */ 
    function changeFaucetAmount(uint256 _amount) public onlyOwner returns(bool) {
        faucetAmount = _amount;
        return true;
    }

    /**
     * @dev Let the contract owner change the agentRewards.
     */ 
    function changeAgentRewards(uint256 _amount) public onlyOwner returns(bool) {
        agentRewards = _amount;
        return true;
    }

    /**
     * @dev Adds 1 day to addressToTime[_msgSender()], then mints fixed amount of CRDIT for _msgSender().
     */
    function mintFixedCRDIT(address _agent) public returns(uint256) {
        require(block.timestamp > addressToTime[_msgSender()], "24 hours have not passed since the last mint");
        ICRDIT crdit = ICRDIT(CRDITAddress);
        require(crdit.mintLimitOf(address(this)) > faucetAmount + agentRewards, "This contract has reached its mint limit");
        addressToTime[_msgSender()] = block.timestamp + 1 days;
        bool minted = crdit.issuerMint(_msgSender(), faucetAmount);
        crdit.issuerMint(_agent, agentRewards);
        if (minted == true) {
            emit MintedCRDIT(faucetAmount);
            return faucetAmount;
        } else {
            emit MintedCRDIT(0);
            return 0;
        }
    }

    /**
     * @dev Adds 1 day to addressToTime[_msgSender()], then mints random amount of CRDIT for _msgSender().
     */
    function mintRandomCRDIT(address _agent) public returns(uint256) {
        require(block.timestamp > addressToTime[_msgSender()], "24 hours have not passed since the last mint");
        ICRDIT crdit = ICRDIT(CRDITAddress);
        require(crdit.mintLimitOf(address(this)) > (faucetAmount * 120 / 100) + agentRewards, "This contract has reached its mint limit");
        addressToTime[_msgSender()] = block.timestamp + 1 days;
        uint256 rand = uint256(keccak256(abi.encodePacked(_msgSender(), block.number, crdit.totalSupply()))) % 3;
        uint256 value = faucetAmount;
        bool minted;
        if (rand == 1) {
            value = faucetAmount * 80 / 100;
            minted = crdit.issuerMint(_msgSender(), value);
        } else if (rand == 2) {
            minted = crdit.issuerMint(_msgSender(), value);
        } else {
            value = faucetAmount * 120 / 100;
            minted = crdit.issuerMint(_msgSender(), value);
        }
        crdit.issuerMint(_agent, agentRewards);
        if (minted = true) {
            emit MintedCRDIT(value);
            return value;
        } else {
            emit MintedCRDIT(0);
            return 0;
        }
    }
}