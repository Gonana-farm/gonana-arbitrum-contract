// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {  Errors } from "./utils/Errors.sol";

// address: 0x99fdeB581d61FDfCF19df461937B9Cc01c18bc2B 

contract Marketplace {

    address public owner;

    enum ProductState { Listed, Escrowed, Confirmed, Cancelled }

    struct Product {
        string productID;
        uint256 amount;
        address wallet;
        string merchantID;
        ProductState state;
    }

    struct Order {
        string productID;
        uint256 amount;
        address buyerAddress;
        string buyerID;
        // bool paid;
    }

    struct Redeem {
        address id;
        uint256 gas;
    }

    mapping(string => Product) public products;
    mapping(string => Order) public orders;


    event ProductCreated(string productID, uint256 amount, address indexed seller);
    event ProductListed(string productID, uint256 amount);
    event ProductUnlisted(string productID);
    event OrderPlaced(string productID, uint256 amount, address buyer);
    event OrderConfirmed(string productID, address buyer);

   

    constructor(){
        owner = msg.sender;
    }

    modifier onlySeller(string memory _productID) {
        if (products[_productID].wallet == msg.sender){ 
            revert Errors.WrongSignature();
        }
        _;
    }

    modifier onlyBuyer(string memory _productID) {
        if(orders[_productID].buyerAddress == msg.sender){ 
            revert Errors.WrongSignature();
        }
        _;
    }

    modifier onlyOwner() {
        if(msg.sender != owner){
            revert Errors.NotOwner();
        }
        _;
    }


    function createProduct(
        string memory _productID, 
        uint256 _amount,
        string memory _merchantID,
        address creator
    ) external onlyOwner {
        if(products[_productID].wallet != address(0)){ 
            revert Errors.ProductAlreadyExists();
        }
        products[_productID] = Product(_productID, _amount, payable(creator), _merchantID, ProductState.Listed);
        emit ProductListed(_productID, _amount);
    }

    function removeProduct(string memory _productID) external onlyOwner {
        if(products[_productID].state != ProductState.Listed){ 
            revert Errors.InvalidProductState();
        }
        products[_productID].state = ProductState.Cancelled;
        emit ProductUnlisted(_productID);
    }

    function orderProduct(
        string memory _productID,
        uint256 _amount,
        string memory _buyerID
    ) external payable {
        if(products[_productID].state != ProductState.Listed) {revert Errors.InvalidProductState();}
        // ensure the value inputed is same as the product amount listed
        if(products[_productID].amount != _amount){ revert Errors.InvalidPrice();}
        // ensure the value sent is the amount listed
        if(msg.value <= _amount){ revert Errors.InsufficientFunds();}
        orders[_productID] = Order(_productID, _amount, msg.sender, _buyerID);
        products[_productID].state = ProductState.Escrowed;
        emit OrderPlaced(_productID, _amount, msg.sender);
    } 

    function releaseEscrow(string memory _productID) external onlyOwner {
        if(products[_productID].state != ProductState.Escrowed) {
            revert Errors.InvalidProductState();
        }
        // logic to release funds in escrow account to seller
        products[_productID].state = ProductState.Confirmed;
        uint256 amount = products[_productID].amount;
        (bool success,) = products[_productID].wallet.call{value:amount}("");
        if (!success) {
            revert Errors.TransacationWasNotSuccessful();
        }
        emit OrderConfirmed(_productID, orders[_productID].buyerAddress);
    }

    function cancelOrder(string memory _productID) external onlyBuyer(_productID) {
        if(products[_productID].state != ProductState.Escrowed) {
            revert Errors.InvalidProductState();
        }
        // Refund the buyer from escrow account
        payable(msg.sender).transfer(orders[_productID].amount); 
        delete orders[_productID];
        products[_productID].state = ProductState.Cancelled;
    }

    function changeOwner(address _owner) public onlyOwner {
        assembly {
            sstore(0x00, _owner)
        }
    }

    function viewOrder(string memory _productID) external view returns (Order memory) {
        return orders[_productID];
    }

    function viewProduct(string memory _productID) external view returns (Product memory) {
        return products[_productID];
    }

    function Owner() external view returns(address _owner) {
        _owner = owner ;
    }

}
