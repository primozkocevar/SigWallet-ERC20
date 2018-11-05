pragma solidity ^0.4.24;
import "./Forwarder.sol";
import "./ERC20Interface.sol";
/**
 *
 * WalletSimple
 * ============
 *
 * Basic multi-signer wallet converted to a simpler one where only one signer can withdraw all the funds! 
 *
 */
contract WalletSimple {
  // Events
  event Deposited(address from, uint value, bytes data);
  event SafeModeActivated(address msgSender);
  event ForwarderCreated(address forwarderAddress);
  event Transacted(
    address msgSender, // Address of the sender of the message initiating the transaction
    address toAddress, // The address the transaction was sent to
    uint value // Amount of Wei sent to the address
  );

  // Public fields
  address[] public signers; // The addresses that can co-sign transactions on the wallet
  bool public safeMode = false; // When active, wallet may only send to signer addresses
 

  /**
   * Set up a simple multi-sig wallet by specifying the signers allowed to be used on this wallet.
   * 2 signers will be required to send a transaction from this wallet.
   * Note: The sender is NOT automatically added to the list of signers.
   * Signers CANNOT be changed once they are set
   *
   * @param allowedSigners An array of signers on the wallet
   */
  constructor(address[] allowedSigners) public {
    if (allowedSigners.length != 3) {
      // Invalid number of signers
      revert();
    }
    signers = allowedSigners;
  }

  /**
   * Determine if an address is a signer on this wallet
   * @param signer address to check
   * returns boolean indicating whether address is signer or not
   */
  function isSigner(address signer) public view returns (bool) {
    // Iterate through all signers on the wallet and
    for (uint i = 0; i < signers.length; i++) {
      if (signers[i] == signer) {
        return true;
      }
    }
    return false;
  }

  /**
   * Modifier that will execute internal code block only if the sender is an authorized signer on this wallet
   */
  modifier onlySigner {
    if (!isSigner(msg.sender)) {
      revert();
    }
    _;
  }

  /**
   * Gets called when a transaction is received without calling a method
   */
  function() public payable {
    if (msg.value > 0) {
      // Fire deposited event if we are receiving funds
      emit Deposited(msg.sender, msg.value, msg.data);
    }
  }
  /**
   * Create a new contract (and also address) that forwards funds to this contract
   * returns address of newly created forwarder address
   */
  function createForwarder() public payable returns (address) {
    Forwarder f = new Forwarder();
    emit ForwarderCreated(address(f));
  }

  /**
   * Execute a multi-signature transaction from this wallet using 2 signers: one from msg.sender and the other from ecrecover.
   * Sequence IDs are numbers starting from 1. They are used to prevent replay attacks and may not be repeated.
   *
   * @param toAddress the destination address to send an outgoing transaction
   * @param value the amount in Wei to be sent
   * @param data the data to send to the toAddress when invoking the transaction
   */
  function sendMultiSig(
      address toAddress,
      uint value,
      bytes data
  ) public onlySigner {
    // Success, send the transaction
    if (!(toAddress.call.value(value)(data))) {
      // Failed executing transaction
      revert();
    }
    emit Transacted(msg.sender, toAddress, value);
  }
  
    /**
   * Change the parent wallet to which all the funds are transfered, this function is very sensitive and could be a security risk
   *
   * @param forwarderAddress the address of the forwarder address we want to change the parent of
   * @param newParentAddress address of a new walletsimple contract to which all the incoming funds will be sent to from now on.
   */
  function changeForwarderParent(
    address forwarderAddress, 
    address newParentAddress
  ) public onlySigner {
    Forwarder forwarder = Forwarder(forwarderAddress);
    forwarder.changeParent(newParentAddress);
  }
      
  
  /**
   * Execute a multi-signature token transfer from this wallet using 2 signers: one from msg.sender and the other from ecrecover.
   * Sequence IDs are numbers starting from 1. They are used to prevent replay attacks and may not be repeated.
   *
   * @param toAddress the destination address to send an outgoing transaction
   * @param value the amount in tokens to be sent
   * @param tokenContractAddress the address of the erc20 token contract
   */
  function sendMultiSigToken(
      address toAddress,
      uint value,
      address tokenContractAddress
  ) public onlySigner {
      
    ERC20Interface instance = ERC20Interface(tokenContractAddress);
    if (!instance.transfer(toAddress, value)) {
        revert();
    }
  }
  
  /**
   * Execute a token flush from one of the forwarder addresses. This transfer needs only a single signature and can be done by any signer
   *
   * @param forwarderAddress the address of the forwarder address to flush the tokens from
   * @param tokenContractAddress the address of the erc20 token contract
   */
  function flushForwarderTokens(
    address forwarderAddress, 
    address tokenContractAddress
  ) public onlySigner {
    Forwarder forwarder = Forwarder(forwarderAddress);
    forwarder.flushTokens(tokenContractAddress);
  }

  /**
   * Irrevocably puts contract into safe mode. When in this mode, transactions may only be sent to signing addresses.
   */
  function activateSafeMode() public onlySigner {
    safeMode = true;
    emit SafeModeActivated(msg.sender);
  }
}

