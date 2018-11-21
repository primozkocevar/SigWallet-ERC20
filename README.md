# SigWallet
Everything is explained much more in depth here:  
https://medium.com/@primozkocevar/forwarder-contract-for-ether-and-erc-20-tokens-e257a621889d
# About
Wallet contracts for sending multiple ERC20 and ETH tokens at the same time to one wallet and setting off events when this happens.
This project is developed with help of an already existing repository https://github.com/BitGo/eth-multisig-v2

# How it works?
Wallet.sol includes a simple wallet contract that uses a Forwarder.sol contract to forward ERC20 tokens to a parent address that is specified when the Forwarder is created.
Important is that every Forwarder has its own unique ethereum address and thus a common Wallet contract can receive funds from multiple forwarders.
However forwarding is different for ERC20 tokens and Ether. Ether gets forwarded from a Forwarder contract to the main Wallet contract automatically and at this time emits an Ethereum event containing the information needed to record this transaction.
ERC20 tokens can not be forwarded under the ERC20 standard and thus an flushTokens() function needs to be called for each Forwarder if it has received a certain amount of tokens. When this is called an event is again emited.

# Where to use?
This mechanism can be used everywhere you need to receive tokens and Ether from different users to a single address and additionaly note which funds have been sent by a certain user. Thus you can give a deployed Forwarder contract to each user and record events when users send funds to this Forwarder that forwards them to the main Wallet contract that is usually controlled by your platform (exchange, cryptomarketplace, a crypto platform...)

# MultiSig Withdraw?
Doing a withdraw with multiple signatures can be more secure as the withdraw from the main Wallet contract needs signatures from multiple keys that can be owned by different entities. Smart contracts and tests for this use case can be found: https://github.com/BitGo/eth-multisig-v2 

# Future
This repository deals with Ether and ERC20 tokens. If your tokens are using different implementation standards (ERC-223, ERC-721) than forwarding is maybe done differently and you should look elsewhere for a more efficient solution.

With the development of Ethereum 2-layer solutions like Plasma (specifically Plasma Cash) the mechanisms implemented in this repository will probably become unefficient as needed solutions will be provided by Plasma (as it is envisioned now in October of 2018).
