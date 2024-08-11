# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.ts
```



Certainly! I'll provide the code snippets for the main functions along with a brief explanation for each.

1. createProduct
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
This function creates a new product listing. It checks if the product already exists and reverts if it does. Otherwise, it creates a new Product struct and emits a ProductListed event.

2. removeProduct
```solidity
function removeProduct(string memory _productID) external onlyOwner {
    if(products[_productID].state != ProductState.Listed){ 
        revert Errors.InvalidProductState();
    }
    products[_productID].state = ProductState.Cancelled;
    emit ProductUnlisted(_productID);
}
```
This function removes a product from listing by changing its state to Cancelled. It checks if the product is in the Listed state before proceeding.

3. orderProduct
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
This function allows a buyer to place an order. It checks the product state, price, and sent funds before creating an Order struct and updating the product state.

4. releaseEscrow
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
This function releases the escrowed funds to the seller. It checks the product state, updates it to Confirmed, and transfers the funds using a low-level call.

5. cancelOrder
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
This function allows a buyer to cancel their order. It checks the product state, refunds the buyer, deletes the order, and updates the product state to Cancelled.

6. changeOwner
```solidity
function changeOwner(address _owner) public onlyOwner {
    assembly {
        sstore(0x00, _owner)
    }
}
```
This function changes the contract owner. It uses inline assembly to directly modify the storage slot where the owner address is stored.

These main functions form the core functionality of the marketplace, handling product management, order placement, and fund transfers. Each function includes checks to ensure the operation is valid before proceeding, helping to maintain the integrity of the marketplace's state.