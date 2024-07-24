// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;


library Errors{
    error NotOwner();
    error TransacationWasNotSuccessful();
    error DepositDoesNotMatchAmount();
    error ProductNotFound();
    error ProductAlreadyExists();
    error OrderNotFound();
    error OrderAlreadyExists();
    error InvalidProductState();
    error InsufficientFunds();
    error InvalidPrice();
    // error NonceAlreadyUsed();
    // error WrongContract();
    error Expired();
    error WrongFunctionCall();
    error WrongSignature();
    error DoNotHaveGasSpent();
    


}
