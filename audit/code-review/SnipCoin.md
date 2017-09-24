# SnipCoin

Source file [../../contracts/SnipCoin.sol](../../contracts/SnipCoin.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.15;

// BK Ok
contract Token {

    /// @return total amount of tokens
    // function totalSupply() public constant returns (uint supply);
    // `totalSupply` is defined below because the automatically generated
    // getter function does not match the abstract function above
    // BK Ok
    uint public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    // BK Ok
    function balanceOf(address _owner) public constant returns (uint);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    // BK Ok
    function transfer(address _to, uint _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    // BK Ok
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    // BK Ok
    function approve(address _spender, uint _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    // BK Ok
    function allowance(address _owner, address _spender) public constant returns (uint remaining);

    // BK Next 2 Ok
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

}

// BK Ok
contract StandardToken is Token {

    // BK NOTE - Does not throw
    // BK Ok
    function transfer(address _to, uint _value) public returns (bool success) {
        // BK Ok
        if (balances[msg.sender] >= _value &&          // Account has sufficient balance
            // BK Ok
            balances[_to] + _value >= balances[_to]) { // Overflow check
            // BK Next 2 Ok
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            // BK Ok - Log event
            Transfer(msg.sender, _to, _value);
            // BK Ok
            return true;
        // BK Ok
        } else { throw; }
    }

    // BK NOTE - Does not throw
    // BK Ok
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        // BK Ok
        if (balances[_from] >= _value &&                // Account has sufficient balance
            // BK Ok
            allowed[_from][msg.sender] >= _value &&     // Amount has been approved
            // BK Ok
            balances[_to] + _value >= balances[_to]) {  // Overflow check
            // BK Ok
            balances[_from] -= _value;
            // BK Ok
            allowed[_from][msg.sender] -= _value;
            // BK Ok
            balances[_to] += _value;
            // BK Ok - Log event
            Transfer(_from, _to, _value);
            // BK Ok
            return true;
        // BK Ok
        } else { throw; }
    }

    // BK Ok - Constant function
    function balanceOf(address _owner) public constant returns (uint balance) {
        // BK Ok
        return balances[_owner];
    }

    // BK NOTE - Do not have to set non-0 to 0 before modifying to non-0
    // BK Ok
    function approve(address _spender, uint _value) public returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        // BK Ok
        allowed[msg.sender][_spender] = _value;
        // BK Ok - Log rvent
        Approval(msg.sender, _spender, _value);
        // BK Ok
        return true;
    }

    // BK Ok - Constant function
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
      // BK Ok
      return allowed[_owner][_spender];
    }

    // BK Ok
    mapping (address => uint) balances;
    // BK Ok
    mapping (address => mapping (address => uint)) allowed;
}

// Based on TokenFactory(https://github.com/ConsenSys/Token-Factory)

// BK Ok
contract SnipCoin is StandardToken {

    // BK Next 3 Ok
    string public constant name = "SnipCoin";         // Token name
    string public symbol = "SNIP";                    // Token identifier
    uint8 public constant decimals = 18;              // Decimal points for token
    // BK Next 2 Ok
    uint public totalEthReceivedInWei;                // The total amount of Ether received during the sale in WEI
    uint public totalUsdReceived;                     // The total amount of Ether received during the sale in USD terms
    // BK Ok
    string public version = "1.0";                    // Code version
    // BK NOTE - Safer that this is different to accountWithUpdatePermissions or contractOwner
    // BK Ok
    address public saleWalletAddress;                 // The wallet address where the Ether from the sale will be stored

    // BK Next 2 Ok
    mapping (address => bool) public uncappedBuyerList;      // The list of buyers allowed to participate in the sale without a cap
    mapping (address => uint) public cappedBuyerList;        // The list of buyers allowed to participate in the sale, with their updated payment sum

    // BK Ok
    uint public snipCoinToEtherExchangeRate = 300000; // This is the ratio of SnipCoin to Ether, could be updated by the owner
    // BK Next 2 Ok
    bool public isSaleOpen = false;                   // This opens and closes upon external command
    bool public transferable = false;                 // Tokens are transferable

    // BK Ok
    uint public ethToUsdExchangeRate = 285;           // Number of USD in one Eth

    // BK Ok
    address public contractOwner;                     // Address of the contract owner
    // Address of an additional account to manage the sale without risk to the tokens or eth. Change before the sale
    // BK Ok
    address public accountWithUpdatePermissions = 0x686f152daD6490DF93B267E319f875A684Bd26e2;

    // BK Ok
    uint public constant DECIMALS_MULTIPLIER = 10**uint(decimals);   // Multiplier for the decimals
    // BK Ok
    uint public constant SALE_CAP_IN_USD = 8000000;                  // The total sale cap in USD
    // BK Ok
    uint public constant MINIMUM_PURCHASE_IN_USD = 50;               // It is impossible to purchase tokens for more than $50 in the sale.
    // BK Ok
    uint public constant USD_PURCHASE_AMOUNT_REQUIRING_ID = 4500;    // Above this purchase amount an ID is required.

    // BK Ok
    modifier onlyPermissioned() {
        // BK Ok
        require((msg.sender == contractOwner) || (msg.sender == accountWithUpdatePermissions));
        // BK Ok
        _;
    }

    // BK Ok
    modifier verifySaleNotOver() {
        // BK Ok
        require(isSaleOpen);
        // BK Ok
        require(totalUsdReceived < SALE_CAP_IN_USD); // Make sure that sale isn't over
        // BK OK
        _;
    }

    // BK Ok
    modifier verifyBuyerCanMakePurchase() {
        // BK Ok
        uint currentPurchaseValueInUSD = uint(msg.value / getWeiToUsdExchangeRate()); // The USD worth of tokens sold
        // BK Ok
        uint totalPurchaseIncludingCurrentPayment = currentPurchaseValueInUSD +  cappedBuyerList[msg.sender]; // The USD worth of all tokens this buyer bought

        // BK Ok
        require(currentPurchaseValueInUSD > MINIMUM_PURCHASE_IN_USD); // Minimum transfer is of $50

        // BK Ok
        uint EFFECTIVE_MAX_CAP = SALE_CAP_IN_USD + 1000;  // This allows for the end of the sale by passing $8M and reaching the cap
        // BK Ok
        require(EFFECTIVE_MAX_CAP - totalUsdReceived > currentPurchaseValueInUSD); // Make sure that there is enough usd left to buy.

        // BK Ok
        if (!uncappedBuyerList[msg.sender]) // If buyer is on uncapped white list then no worries, else need to make sure that they're okay
        {
            // BK Ok
            require(cappedBuyerList[msg.sender] > 0); // Check that the sender has been initialized.
            // BK Ok
            require(totalPurchaseIncludingCurrentPayment < USD_PURCHASE_AMOUNT_REQUIRING_ID); // Check that they're not buying too much
        }
        _;
    }

    // BK OK - Constructor
    function SnipCoin() public {
        // BK Next 3 Ok
        initializeSaleWalletAddress();
        initializeEthReceived();
        initializeUsdReceived();

        // BK Ok
        contractOwner = msg.sender;                      // The creator of the contract is its owner
        // BK Ok
        totalSupply = 10000000000 * DECIMALS_MULTIPLIER; // In total, 10 billion tokens
        // BK Ok
        balances[contractOwner] = totalSupply;           // Initially give owner all of the tokens 
        // BK Ok - Log event 
        Transfer(0x0, contractOwner, totalSupply);
    }

    // BK Ok - Internal function
    function initializeSaleWalletAddress() internal {
        // BK Ok
        saleWalletAddress = 0x686f152daD6490DF93B267E319f875A684Bd26e2; // Change before the sale
    }

    // BK Ok - Internal function
    function initializeEthReceived() internal {
        // BK Ok
        totalEthReceivedInWei = 14500 * 1 ether; // Ether received before public sale. Verify this figure before the sale starts.
    }

    // BK Ok - Internal function
    function initializeUsdReceived() internal {
        // BK Ok
        totalUsdReceived = 4000000; // USD received before public sale. Verify this figure before the sale starts.
    }

    // BK NOTE - ethToUsdExchangeRate should be set to a sensible value and not be 0, or this will cause a division by 0 error
    // BK Ok
    function getWeiToUsdExchangeRate() public constant returns(uint) {
        // BK Ok
        return 1 ether / ethToUsdExchangeRate; // Returns how much Wei one USD is worth
    }

    // BK Ok - Only permissioned accounts can execute this function
    function updateEthToUsdExchangeRate(uint newEthToUsdExchangeRate) public onlyPermissioned {
        // BK Ok
        ethToUsdExchangeRate = newEthToUsdExchangeRate; // Change exchange rate to new value, influences the counter of when the sale is over.
    }

    // BK Ok - Only permissioned accounts can execute this function
    function updateSnipCoinToEtherExchangeRate(uint newSnipCoinToEtherExchangeRate) public onlyPermissioned {
        // BK Ok
        snipCoinToEtherExchangeRate = newSnipCoinToEtherExchangeRate; // Change the exchange rate to new value, influences tokens received per purchase
    }

    // BK NOTE - The sale will initially need to be opened (isSaleOpen set to true)
    // BK NOTE - The sale will have to be closed (isSaleOpen set to false)
    // BK NOTE - The token can then be transferable (transferable set to true)
    // BK Ok - Only permissioned accounts can execute this function
    function openOrCloseSale(bool saleCondition) public onlyPermissioned {
        // BK Ok
        require(!transferable);
        // BK Ok
        isSaleOpen = saleCondition; // Decide if the sale should be open or closed (default: closed)
    }

    // BK NOTE - This function can only be executed when the sale is closed (isSaleOpen set to false)
    // BK Ok - Only permissioned accounts can execute this function
    function allowTransfers() public onlyPermissioned {
        // BK Ok
        require(!isSaleOpen);
        // BK Ok
        transferable = true;
    }

    // BK Ok - Only permissioned accounts can execute this function
    function addAddressToCappedAddresses(address addr) public onlyPermissioned {
        // BK Ok
        cappedBuyerList[addr] = 1; // Allow a certain address to purchase SnipCoin up to the cap (<4500)
    }

    // BK Ok - Only permissioned accounts can execute this function
    function addMultipleAddressesToCappedAddresses(address[] addrList) public onlyPermissioned {
        // BK Ok
        for (uint i = 0; i < addrList.length; i++) {
            // BK Ok
            addAddressToCappedAddresses(addrList[i]); // Allow a certain address to purchase SnipCoin up to the cap (<4500)
        }
    }

    // BK Ok - Only permissioned accounts can execute this function
    function addAddressToUncappedAddresses(address addr) public onlyPermissioned {
        // BK Ok
        uncappedBuyerList[addr] = true; // Allow a certain address to purchase SnipCoin above the cap (>=$4500)
    }

    // BK Ok - Only permissioned accounts can execute this function
    function addMultipleAddressesToUncappedAddresses(address[] addrList) public onlyPermissioned {
        // BK Ok
        for (uint i = 0; i < addrList.length; i++) {
            // BK Ok
            addAddressToUncappedAddresses(addrList[i]); // Allow a certain address to purchase SnipCoin up to the cap (<4500)
        }
    }

    // BK Ok
    function transfer(address _to, uint _value) public returns (bool success) {
        // BK Ok
        require(transferable);
        // BK Ok
        return super.transfer(_to, _value);
    }

    // BK Ok
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        // BK Ok
        require(transferable);
        // BK Ok
        return super.transferFrom(_from, _to, _value);
    }

    // BK Ok
    function () public payable verifySaleNotOver verifyBuyerCanMakePurchase {
        // BK Ok
        uint tokens = snipCoinToEtherExchangeRate * msg.value;
        // BK Next 2 Ok
        balances[contractOwner] -= tokens;
        balances[msg.sender] += tokens;
        // BK Ok - Log event
        Transfer(contractOwner, msg.sender, tokens);

        // BK Next 2 Ok
        totalEthReceivedInWei = totalEthReceivedInWei + msg.value; // total eth received counter
        uint usdReceivedInCurrentTransaction = uint(msg.value / getWeiToUsdExchangeRate());
        totalUsdReceived = totalUsdReceived + usdReceivedInCurrentTransaction; // total usd received counter

        // BK Ok
        if (cappedBuyerList[msg.sender] > 0)
        {
            // BK Ok
            cappedBuyerList[msg.sender] = cappedBuyerList[msg.sender] + usdReceivedInCurrentTransaction;
        }

        // BK Ok
        saleWalletAddress.transfer(msg.value); // Transfer ether to safe sale address
    }
}
```
