// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.7;

import "./IFlashLoanRecipient.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


interface Balancer {

    function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;
}


contract BalancerFlashloan is IFlashLoanRecipient {
    
    using SafeMath for uint256;
    
    address internal constant balancerAddress = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant mimaticAddress = 0xa3Fa99A148fA48D14Ed51d610c367C61876997F1;

    ERC20 mimatic = ERC20(mimaticAddress);
    Balancer balancer = Balancer(balancerAddress);

    address public admin;

    constructor()  {   
        admin = msg.sender;
    }

     /**
        This function is called after your contract has received the flash loaned amount
     */
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    )
        external
        override
    {
        userData; //do nothing -- clear warning

        
        // Approve the LendingPool contract allowance to *pull* the owed amount
        // i.e. AAVE V2's way of repaying the flash loan
        for (uint i = 0; i < tokens.length; i++) {
            uint amountOwing = amounts[i].add(feeAmounts[i]);
            IERC20(tokens[i]).transfer(balancerAddress, amountOwing);
        }

    }

    /*
    * This function is manually called to commence the flash loans sequence
    * 
    */
    function executeFlashLoan(uint256 _amount) public {

        // the various assets to be flashed
        //we are borrowing mimatic from Balancer
        IERC20[] memory assets = new IERC20[](1);
        assets[0] = mimatic;

        // the amount to be flashed for each asset
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _amount ;


        balancer.flashLoan(
            this,
            assets,
            amounts,
            ""
        );

        
    }

}
