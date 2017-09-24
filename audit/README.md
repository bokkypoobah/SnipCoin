# SnipCoin Token Contract Audit

[https://www.snip.today/](https://www.snip.today/)

[https://www.snip.network/sale/signup/?next=/sale/](https://www.snip.network/sale/signup/?next=/sale/)

Status: Work in progress

Commits
[547c295](https://github.com/SnipToday/SnipCoin/commit/547c295895700ce44ab5d63cab506978e2f01634) and
[022fbf8](https://github.com/SnipToday/SnipCoin/commit/022fbf8f901cba0dcffe8121f97580bfdcc2ba0b).

<br />

## Summary

### Crowdsale And Token Contract

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
  * [Crowdsale And Token Contract](#crowdsale-and-token-contract)
* [Recommendations](#recommendations)
  * [First Review Recommendations](#first-review-recommendations)
  * [Second Review Recommendations](#second-review-recommendations)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Testing](#testing)
* [Code Review](#code-review)

<br />

<hr />

## Recommendations

### First Review Recommendations

* **LOW IMPORTANCE** Fix the compiler warnings - address not checksummed. Paste the address in the [https://etherscan.io](https://etherscan.io)
  search box and the checksummed address will be displayed. Use this checksummed address, e.g., `0x686f152daD6490DF93B267E319f875A684Bd26e2`.

  For an example, see [test/modifiedContracts/SnipCoin_firstreview_example.sol](test/modifiedContracts/SnipCoin_firstreview_example.sol)

      SnipCoin.sol:107:29: Warning: This looks like an address but has an invalid checksum. If this is not used as an address, please prepend '00'.
              saleWalletAddress = 0x686f152dad6490df93b267e319f875a684bd26e2; // Change before the sale
                                  ^----------------------------------------^

  * [X] Fixed in [022fbf8](https://github.com/SnipToday/SnipCoin/commit/022fbf8f901cba0dcffe8121f97580bfdcc2ba0b)

* **LOW IMPORTANCE** Fix the compiler warnings - unused variables. Replace the empty function body `{}` with a `;` for the
  *Token* interface to declare the functions as un-implemented functions that will be overridden in the derived contract.

  For an example, see [test/modifiedContracts/SnipCoin_firstreview_example.sol](test/modifiedContracts/SnipCoin_firstreview_example.sol)

      SnipCoin.sol:6:46: Warning: Unused local variable
          function totalSupply() constant returns (uint256 supply) {}
                                                   ^------------^
      SnipCoin.sol:10:24: Warning: Unused local variable
          function balanceOf(address _owner) constant returns (uint256 balance) {}
                             ^------------^
      SnipCoin.sol:10:58: Warning: Unused local variable
          function balanceOf(address _owner) constant returns (uint256 balance) {}
                                                               ^-------------^
      SnipCoin.sol:16:23: Warning: Unused local variable
          function transfer(address _to, uint256 _value) returns (bool success) {}
                            ^---------^
      SnipCoin.sol:16:36: Warning: Unused local variable
          function transfer(address _to, uint256 _value) returns (bool success) {}
                                         ^------------^
      SnipCoin.sol:16:61: Warning: Unused local variable
          function transfer(address _to, uint256 _value) returns (bool success) {}
                                                                  ^----------^
      SnipCoin.sol:23:27: Warning: Unused local variable
          function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
                                ^-----------^
      SnipCoin.sol:23:42: Warning: Unused local variable
          function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
                                               ^---------^
      SnipCoin.sol:23:55: Warning: Unused local variable
          function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
                                                            ^------------^
      SnipCoin.sol:23:80: Warning: Unused local variable
          function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
                                                                                     ^----------^
      SnipCoin.sol:29:22: Warning: Unused local variable
          function approve(address _spender, uint256 _value) returns (bool success) {}
                           ^--------------^
      SnipCoin.sol:29:40: Warning: Unused local variable
          function approve(address _spender, uint256 _value) returns (bool success) {}
                                             ^------------^
      SnipCoin.sol:29:65: Warning: Unused local variable
          function approve(address _spender, uint256 _value) returns (bool success) {}
                                                                      ^----------^
      SnipCoin.sol:34:24: Warning: Unused local variable
          function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
                             ^------------^
      SnipCoin.sol:34:40: Warning: Unused local variable
          function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
                                             ^--------------^
      SnipCoin.sol:34:76: Warning: Unused local variable
          function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
                                                                                 ^---------------^

  * [X] Fixed in [022fbf8](https://github.com/SnipToday/SnipCoin/commit/022fbf8f901cba0dcffe8121f97580bfdcc2ba0b) except for `totalSupply()`

* **HIGH IMPORTANCE** The statement `totalSupply = 10000000000;` in `SnipCoin.SnipCoin()` should have the decimals factor
  factored in. The statement should be something like `totalSupply = 10000000000 * DECIMALS_MULTIPLIER;`, and the following
  statement should be `balances[msg.sender] = totalSupply;`

  For an example, see [test/modifiedContracts/SnipCoin_firstreview_example.sol](test/modifiedContracts/SnipCoin_firstreview_example.sol)

  * [X] Fixed in [022fbf8](https://github.com/SnipToday/SnipCoin/commit/022fbf8f901cba0dcffe8121f97580bfdcc2ba0b)

* **LOW IMPORTANCE** The [ERC20 token standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
  defines `decimals` as `uint8`. Update the token contract to use `uint8` instead of `uint`

  For an example, see [test/modifiedContracts/SnipCoin_firstreview_example.sol](test/modifiedContracts/SnipCoin_firstreview_example.sol)

  * [X] Fixed in [022fbf8](https://github.com/SnipToday/SnipCoin/commit/022fbf8f901cba0dcffe8121f97580bfdcc2ba0b)

* **LOW IMPORTANCE** `DECIMALS_MULTIPLIER = 1000000000000000000;` is a constant, but `decimals` is initialised in the
  `SnipCoin.SnipCoin()` constructor. As both these are directly related, consider using the statement
  `uint8 public constant decimals = 18;`, then `uint public constant DECIMALS_MULTIPLIER = 10**uint(decimals);`. And
  remove `decimals = 18;` in `SnipCoin.SnipCoin()`

  For an example, see [test/modifiedContracts/SnipCoin_firstreview_example.sol](test/modifiedContracts/SnipCoin_firstreview_example.sol)

  * [X] Fixed in [022fbf8](https://github.com/SnipToday/SnipCoin/commit/022fbf8f901cba0dcffe8121f97580bfdcc2ba0b)

* **MEDIUM IMPORTANCE** `tokenName` and `tokenSymbol` should be named `name` and `symbol` respectively, as documented in
  the [ERC20 token standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md). Consider defining
  these as constant values in `SnipCoin` like `string public constant symbol = "SNP";` and
  `string public constant name = "SnipCoin";`, removing the assignments in `SnipCoin.SnipCoin()`

  For an example, see [test/modifiedContracts/SnipCoin_firstreview_example.sol](test/modifiedContracts/SnipCoin_firstreview_example.sol)

  * [X] Fixed in [022fbf8](https://github.com/SnipToday/SnipCoin/commit/022fbf8f901cba0dcffe8121f97580bfdcc2ba0b)

* **LOW IMPORTANCE** `SnipCoin.sendCoin(...)` provides the exact same functionality as `StandardToken.transfer(...)`.
  Consider removing `SnipCoin.sendCoin(...)`

  * [X] Fixed in [022fbf8](https://github.com/SnipToday/SnipCoin/commit/022fbf8f901cba0dcffe8121f97580bfdcc2ba0b)

* **LOW IMPORTANCE** `SnipCoin.function()` has the statement `if (!saleWalletAddress.send(msg.value)) revert();` that
  can be written as `saleWalletAddress.transfer(msg.value);` that will throw an exception when there is an error. See the
  [difference between `send(...)` and `transfer(...)`](https://github.com/ConsenSys/smart-contract-best-practices#be-aware-of-the-tradeoffs-between-send-transfer-and-callvalue)

  * [X] Fixed in [022fbf8](https://github.com/SnipToday/SnipCoin/commit/022fbf8f901cba0dcffe8121f97580bfdcc2ba0b)

* **LOW IMPORTANCE** The variable `SnipCoin.ownerAddress` is unused and can be removed

  * [X] Fixed in [022fbf8](https://github.com/SnipToday/SnipCoin/commit/022fbf8f901cba0dcffe8121f97580bfdcc2ba0b)

<br />

### Second Review Recommendations

For an example, see [test/modifiedContracts/SnipCoin.sol](test/modifiedContracts/SnipCoin.sol)

* **HIGH IMPORTANCE** The statement `transferFrom(...)` in the fallback `function ()` will not execute as expected because the
  `transferFrom(...)` transfer of tokens require an `approve(...)` function call before the tokens can be moved

* **MEDIUM IMPORTANCE** The functions `initializeSaleWalletAddress()`, `initializeEthReceived()` and `initializeUsdReceived()` have
  no access modifiers specified. Anyone can call these functions anytime to reset these variables. Mark these functions as `internal`
  to prevent these functions being executed by anyone

* **MEDIUM IMPORTANCE** The functions `getBalance(...)`, `getWeiToUsdExchangeRate()` should be marked `constant` 

* **LOW IMPORTANCE** Fix the compiler warnings - unused variables. Replace the empty function body `{}` with a `;` for the
  *Token* interface to declare the functions as un-implemented functions that will be overridden in the derived contract.

      SnipCoin.sol:6:46: Warning: Unused local variable
          function totalSupply() constant returns (uint256 supply) {}
                                                   ^------------^

  Note that in the example, `uint public totalSupply` is defined in *Token* because the automatically generated getter function
  does not match the abstract function `function totalSupply() constant returns (uint256 supply);`

* **LOW IMPORTANCE** Use `uint` or `uint256` consistently, not both

* **LOW IMPORTANCE** Consider moving `require((msg.sender == contractOwner) || (msg.sender == accountWithUpdatePermissions)); // Verify ownership`
  into a modifier like `onlyPermissioned` and using this modifier in function that would otherwise have repeated code

* **LOW IMPORTANCE** Consider converting `verifySaleNotOver()` and `verifyBuyerCanMakePurchase()` into modifiers and applying them to
  the fallback `function()`

* **LOW IMPORTANCE** `WEI_IN_ETHER = 1000 * 1000 * 1000 * 1000 * 1000 * 1000` is the same as `1 ether`. Consider using `1 ether`
  to simplify the code

* **LOW IMPORTANCE** Consider explicitly using the `public` on functions that are meant to be executed directly via transactions

* **LOW IMPORTANCE** Consider moving the statement `balances[_to] += _value;` after subtracting `_value` from the source account and
  the approval in `transferFrom(...)`

* **LOW IMPORTANCE** Consider adding the overflow check `balances[_to] + _value > balances[_to]` to `transfer(...)` and
  `transferFrom(...)` and removing the comments that it could be used

* **LOW IMPORTANCE** The event `Transfer({source}, {destination}, {value});` should be logged whenever there is a change in the
  balances mapping structure. Note that the event may not be logged in the `SnipCoin.SnipCoin()` constructor

* **LOW IMPORTANCE** Move `saleWalletAddress.transfer(msg.value);` to the last statement in the fallback `function ()` as
  good practice, even though the `saleWalletAddress` is under the control of the crowdsale project

* **LOW IMPORTANCE** Consider using the statement `balances[contractOwner] = totalSupply;` instead of
  `balances[msg.sender] = totalSupply;` in the `SnipCoin.SnipCoin()` constructor as this explicitly states that the tokens
  are all initially assigned to the `contractOwner`

* **LOW IMPORTANCE** The recently standardised [ERC20 standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#transfer)
   states that `Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.`. Consider updating
  `transfer(...)` and `transferFrom(...)` to treat 0 transfers as valid transfers

  The recently standardised ERC20 standard also states that
  `The function SHOULD throw if the _from account balance does not have enough tokens to spend.` for the `transfer(...)` function, and
  `The function SHOULD throw unless the _from account has deliberately authorized the sender of the message via some mechanism.` for
  the `transferFrom(...)` function. This `throw` behaviour has not been implemented in the example.

* **LOW IMPORTANCE** Consider making `contractOwner`, `accountWithUpdatePermissions` and `DECIMALS_MULTIPLIER` public to allow for easier
  validation

<br />

<hr />

## Potential Vulnerabilities

**TODO** Confirm that no potential vulnerabilities have been identified in the crowdsale and token contract.

<br />

<hr />

## Scope

This audit is into the technical aspects of the crowdsale contracts. The primary aim of this audit is to ensure that funds
contributed to these contracts are not easily attacked or stolen by third parties. The secondary aim of this audit is that
ensure the coded algorithms work as expected. This audit does not guarantee that that the code is bugfree, but intends to
highlight any areas of weaknesses.

<br />

<hr />

## Limitations

This audit makes no statements or warranties about the viability of the Snip's business proposition, the individuals
involved in this business or the regulatory regime for the business model.

<br />

<hr />

## Due Diligence

As always, potential participants in any crowdsale are encouraged to perform their due diligence on the business proposition
before funding any crowdsales.

Potential participants are also encouraged to only send their funds to the official crowdsale Ethereum address, published on
the crowdsale beneficiary's official communication channel.

Scammers have been publishing phishing address in the forums, twitter and other communication channels, and some go as far as
duplicating crowdsale websites. Potential participants should NOT just click on any links received through these messages.
Scammers have also hacked the crowdsale website to replace the crowdsale contract address with their scam address.
 
Potential participants should also confirm that the verified source code on EtherScan.io for the published crowdsale address
matches the audited source code, and that the deployment parameters are correctly set, including the constant parameters.

<br />

<hr />

## Risks

* The risk of funds getting stolen or hacked from the *Snip* contract is low as the contributed funds are immediately
  transferred to an external multisig, hardware or regular wallet.

<br />

<hr />

## Testing

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

* [ ] Deploy Crowdsale/Token contract
* [ ] Contribute to the crowdsale contract
* [ ] Finalise the crowdsale
* [ ] `transfer(...)` and `transferFrom(...)` the *CND* tokens

<br />

Details of the testing environment can be found in [test](test).

<br />

<hr />

## Code Review

* [ ] [code-review/SnipCoin.md](code-review/SnipCoin.md)
  * [ ] contract Token 
  * [ ] contract StandardToken is Token 
  * [ ] contract SnipCoin is StandardToken 


