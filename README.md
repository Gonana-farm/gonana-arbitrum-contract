# Marketplace Smart Contract Documentation

## Overview
This smart contract implements a decentralized marketplace where products can be listed, ordered, and managed through an escrow system. It allows for product creation, ordering, and release of funds, with built-in state management and access controls.

## Contract Details
- **SPDX-License-Identifier**: MIT
- **Solidity Version**: ^0.8.0
- **Contract Name**: Marketplace
- **Deployed Address**: 0x99fdeB581d61FDfCF19df461937B9Cc01c18bc2B

## Key Components

### State Variables
- `owner`: Address of the contract owner
- `products`: Mapping of product IDs to Product structs
- `orders`: Mapping of product IDs to Order structs

### Enums
- `ProductState`: Represents the current state of a product
  - `Listed`: Product is available for purchase
  - `Escrowed`: Product has been ordered and payment is in escrow
  - `Confirmed`: Order has been confirmed and payment released to seller
  - `Cancelled`: Product or order has been cancelled

### Structs
1. `Product`
   - `productID`: Unique identifier for the product
   - `amount`: Price of the product
   - `wallet`: Address of the seller
   - `merchantID`: Identifier for the merchant
   - `state`: Current state of the product

2. `Order`
   - `productID`: ID of the ordered product
   - `amount`: Amount paid for the order
   - `buyerAddress`: Address of the buyer
   - `buyerID`: Identifier for the buyer

3. `Redeem` (unused in current implementation)
   - `id`: Address identifier
   - `gas`: Gas amount

### Events
- `ProductCreated`: Emitted when a new product is created
- `ProductListed`: Emitted when a product is listed for sale
- `ProductUnlisted`: Emitted when a product is removed from listing
- `OrderPlaced`: Emitted when an order is placed
- `OrderConfirmed`: Emitted when an order is confirmed and payment released

### Modifiers
- `onlySeller`: Ensures the caller is the seller of a specific product
- `onlyBuyer`: Ensures the caller is the buyer of a specific order
- `onlyOwner`: Restricts function access to the contract owner

## Main Functions

### `createProduct`
```solidity
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

- Creates a new product listing
- Parameters: product ID, amount, merchant ID, creator address
- Access: Only owner
- Emits: `ProductListed`

### `removeProduct`
```solidity
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
```
- Removes a product from listing
- Parameters: product ID
- Access: Only owner
- Emits: `ProductUnlisted`

### `orderProduct`
```solidity
function orderProduct(
    string memory _productID,
    uint256 _amount,
    string memory _buyerID
) external payable {
    if(products[_productID].state != ProductState.Listed) {revert Errors.InvalidProductState();}
    if(products[_productID].amount != _amount){ revert Errors.InvalidPrice();}
    if(msg.value <= _amount){ revert Errors.InsufficientFunds();}
    orders[_productID] = Order(_productID, _amount, msg.sender, _buyerID);
    products[_productID].state = ProductState.Escrowed;
    emit OrderPlaced(_productID, _amount, msg.sender);
}
```
- Places an order for a product
- Parameters: product ID, amount, buyer ID
- Requires payment to be sent with the transaction
- Emits: `OrderPlaced`

### `releaseEscrow`
```solidity
function releaseEscrow(string memory _productID) external onlyOwner {
    if(products[_productID].state != ProductState.Escrowed) {
        revert Errors.InvalidProductState();
    }
    products[_productID].state = ProductState.Confirmed;
    uint256 amount = products[_productID].amount;
    (bool success,) = products[_productID].wallet.call{value:amount}("");
    if (!success) {
        revert Errors.TransacationWasNotSuccessful();
    }
    emit OrderConfirmed(_productID, orders[_productID].buyerAddress);
}
```
- Releases funds from escrow to the seller
- Parameters: product ID
- Access: Only owner
- Emits: `OrderConfirmed`

### `cancelOrder`
```solidity
function cancelOrder(string memory _productID) external onlyBuyer(_productID) {
    if(products[_productID].state != ProductState.Escrowed) {
        revert Errors.InvalidProductState();
    }
    payable(msg.sender).transfer(orders[_productID].amount); 
    delete orders[_productID];
    products[_productID].state = ProductState.Cancelled;
}
```
- Cancels an order and refunds the buyer
- Parameters: product ID
- Access: Only the buyer of the order

### `changeOwner`
```solidity
function changeOwner(address _owner) public onlyOwner {
    assembly {
        sstore(0x00, _owner)
    }
}
```
- Changes the owner of the contract
- Parameters: new owner address
- Access: Only current owner
- Note: Uses assembly for direct storage manipulation

### View Functions
- `viewOrder`: Returns order details for a given product ID
- `viewProduct`: Returns product details for a given product ID
- `Owner`: Returns the current owner's address



## Conclusion
This Marketplace smart contract provides a basic framework for a decentralized marketplace with escrow functionality. It includes essential features for product management, order placement, and fund release, with room for further enhancements and security improvements.


