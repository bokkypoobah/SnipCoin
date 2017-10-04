# SnipCoin Token Contract Audit

<br />

## Summary

[Snip](https://www.snip.today/) intends to run a [crowdsale](https://www.snip.network/sale/signup/?next=/sale/) commencing on
September 29 2017.

Bok Consulting Pty Ltd was commissioned to perform an audit on the Ethereum smart contracts for Snip's crowdsale.

This audit has been conducted on Snip's source code in commits
[547c295](https://github.com/SnipToday/SnipCoin/commit/547c295895700ce44ab5d63cab506978e2f01634),
[022fbf8](https://github.com/SnipToday/SnipCoin/commit/022fbf8f901cba0dcffe8121f97580bfdcc2ba0b),
[f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43),
[94ffa4d](https://github.com/SnipToday/SnipCoin/commit/94ffa4d4a3750c0cf584ac63a1df464dd4d6c3dc),
[07a5991](https://github.com/SnipToday/SnipCoin/commit/07a5991327b7c26e040e319aa67205ff96697a7d),
[a5c4d0d](https://github.com/SnipToday/SnipCoin/commit/a5c4d0d32dcfeb9aa120a208c4ba285fdacabe60),
[4cda853](https://github.com/SnipToday/SnipCoin/commit/4cda85368a553832b01e16ebfcff43c816ed6b02),
[bf168d8](https://github.com/SnipToday/SnipCoin/commit/bf168d8e22fa6b73792513e6ce4e611a2f8209eb) and
[44a48f3](https://github.com/SnipToday/SnipCoin/commit/44a48f3567c0c97b31371c7cbe77c071665677c2).

No potential vulnerabilities have been identified in the crowdsale and token contract.

Note that this crowdsale contract does not have a built in start and end date. The crowdsale contract can commence receiving
contributions when the crowdsale administrator executes `openOrCloseSale(true)`. The crowdsale contract closes when the
crowdsale administrator executes `openOrCloseSale(false)`. The tokens are transferable after the crowdsale administrator
executes `allowTransfers()`.

<br />

### Crowdsale Mainnet Addresses

Crowdsale and token contract deployed to [0x44f588aeeb8c44471439d1270b3603c66a9262f1](https://etherscan.io/address/0x44f588aeeb8c44471439d1270b3603c66a9262f1#code).

Crowdsale wallet at [0xb4ad56e564aab5409fe8e34637c33a6d3f2a0038](https://etherscan.io/address/0xb4ad56e564aab5409fe8e34637c33a6d3f2a0038).

<br />

### Crowdsale And Token Contract

The *SnipCoin* crowdsale and token contract will accept ethers (ETH) sent from Ethereum account to the contract address.

Accounts contributing to this crowdsale will have to be registered by Snip in either the capped or uncapped whitelist.

ETH contributed by participants to the *SnipCoin* crowdsale contract will result in SNIP tokens being allocated to the
participant's account in the token contract. The contributed ETHs are immediately transferred to the `saleWalletAddress`
wallet, reducing the risk of the loss of ETHs in this bespoke smart contract.

The crowdsale contract will generate `Transfer({contract owner}, {participantAddress}, {tokens})` events during the crowdsale
period and this event is used by token explorers to recognise the token contract and to display the ongoing token sale progress.

The *SnipCoin* token contract is [ERC20 token standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
compliant with the following features:

* `decimals` is correctly defined as `uint8` instead of `uint256`
* `name` is `SnipCoin`
* `symbol` is `SNIP`
* `transfer(...)` and `transferFrom(...)` will throw if there is an error instead of returning false. A 0 value transfer will
  return true
* `transfer(...)` and `transferFrom(...)` have not been built with a check on the size of the data being passed. This check is
  not an effective check anyway - refer to [Smart
  Contract Short Address Attack Mitigation Failure](https://blog.coinfabrik.com/smart-contract-short-address-attack-mitigation-failure/)
* `approve(...)` does require that a non-zero approval limit be set to 0 before a new non-zero limit can be set. Refer to
  [this](https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729) for further information

This *SnipCoin* token contract does not use *SafeMath* but has the checks to prevent unsigned integer math overflows and underflows.

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
  * [Crowdsale Mainnet Addresses](#crowdsale-mainnet-addresses)
  * [Crowdsale And Token Contract](#crowdsale-and-token-contract)
* [Recommendations](#recommendations)
  * [First Review Recommendations](#first-review-recommendations)
  * [Second Review Recommendations](#second-review-recommendations)
  * [Third Review Recommendations](#third-review-recommendations)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Testing](#testing)
  * [Contribution From Capped And Uncapped Whitelisted Accounts](#contribution-from-capped-and-uncapped-whitelisted-accounts)
  * [Contribution From Uncapped Whitelisted Accounts To Max USD Cap](#contribution-from-uncapped-whitelisted-accounts-to-max-usd-cap)
  * [Contribution From Capped Whitelisted Accounts To Account Cap](#contribution-from-capped-whitelisted-accounts-to-account-cap)
  * [New ERC20 Standard](#new-erc20-standard)
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

For an example, see [test/modifiedContracts/SnipCoin_secondreview_example.sol](test/modifiedContracts/SnipCoin_secondreview_example.sol)

* **HIGH IMPORTANCE** The statement `transferFrom(...)` in the fallback `function ()` will not execute as expected because the
  `transferFrom(...)` transfer of tokens require an `approve(...)` function call before the tokens can be moved

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **MEDIUM IMPORTANCE** The functions `initializeSaleWalletAddress()`, `initializeEthReceived()` and `initializeUsdReceived()` have
  no access modifiers specified. Anyone can call these functions anytime to reset these variables. Mark these functions as `internal`
  to prevent these functions being executed by anyone

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **MEDIUM IMPORTANCE** The functions `getBalance(...)`, `getWeiToUsdExchangeRate()` should be marked `constant` 


  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **MEDIUM IMPORTANCE** Consider disabling `transfer(...)` and `transferFrom(...)` while the sale is in progress

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43) and
    [94ffa4d](https://github.com/SnipToday/SnipCoin/commit/94ffa4d4a3750c0cf584ac63a1df464dd4d6c3dc)

* **MEDIUM IMPORTANCE** Prevent the crowdsale being reopened once the tokens are transferable

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **LOW IMPORTANCE** Fix the compiler warnings - unused variables. Replace the empty function body `{}` with a `;` for the
  *Token* interface to declare the functions as un-implemented functions that will be overridden in the derived contract.

      SnipCoin.sol:6:46: Warning: Unused local variable
          function totalSupply() constant returns (uint256 supply) {}
                                                   ^------------^

  Note that in the example, `uint public totalSupply` is defined in *Token* because the automatically generated getter function
  does not match the abstract function `function totalSupply() constant returns (uint256 supply);`

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **LOW IMPORTANCE** Use `uint` or `uint256` consistently, not both

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **LOW IMPORTANCE** Consider moving `require((msg.sender == contractOwner) || (msg.sender == accountWithUpdatePermissions)); // Verify ownership`
  into a modifier like `onlyPermissioned` and using this modifier in function that would otherwise have repeated code

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **LOW IMPORTANCE** Consider converting `verifySaleNotOver()` and `verifyBuyerCanMakePurchase()` into modifiers and applying them to
  the fallback `function()`

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **LOW IMPORTANCE** `WEI_IN_ETHER = 1000 * 1000 * 1000 * 1000 * 1000 * 1000` is the same as `1 ether`. Consider using `1 ether`
  to simplify the code

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **LOW IMPORTANCE** Consider explicitly using the `public` on functions that are meant to be executed directly via transactions

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **LOW IMPORTANCE** Consider moving the statement `balances[_to] += _value;` after subtracting `_value` from the source account and
  the approval in `transferFrom(...)`

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **LOW IMPORTANCE** Consider adding the overflow check `balances[_to] + _value > balances[_to]` to `transfer(...)` and
  `transferFrom(...)` and removing the comments that it could be used

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **LOW IMPORTANCE** The event `Transfer({source}, {destination}, {value});` should be logged whenever there is a change in the
  balances mapping structure

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **LOW IMPORTANCE** Move `saleWalletAddress.transfer(msg.value);` to the last statement in the fallback `function ()` as
  good practice, even though the `saleWalletAddress` is under the control of the crowdsale project

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **LOW IMPORTANCE** Consider using the statement `balances[contractOwner] = totalSupply;` instead of
  `balances[msg.sender] = totalSupply;` in the `SnipCoin.SnipCoin()` constructor as this explicitly states that the tokens
  are all initially assigned to the `contractOwner`

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **LOW IMPORTANCE** The recently standardised [ERC20 standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#transfer)
   states that `Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.`. Consider updating
  `transfer(...)` and `transferFrom(...)` to treat 0 transfers as valid transfers

  The recently standardised ERC20 standard also states that
  `The function SHOULD throw if the _from account balance does not have enough tokens to spend.` for the `transfer(...)` function, and
  `The function SHOULD throw unless the _from account has deliberately authorized the sender of the message via some mechanism.` for
  the `transferFrom(...)` function. This `throw` behaviour has not been implemented in the example

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

* **LOW IMPORTANCE** Consider making `contractOwner`, `accountWithUpdatePermissions` and `DECIMALS_MULTIPLIER` public to allow for easier
  validation

  * [x] Fixed in [f9d4c42](https://github.com/SnipToday/SnipCoin/commit/f9d4c4290dfa477e7d07578b10a6cd35e69cfa43)

<br />

### Third Review Recommendations

* **LOW IMPORTANCE** `getBalance(...)` is exact duplicate of the ERC20 standard function `balanceOf(...)`

  * [x] Fixed in [07a5991](https://github.com/SnipToday/SnipCoin/commit/07a5991327b7c26e040e319aa67205ff96697a7d)

* **LOW IMPORTANCE** The whitelisted cap amount applies to each transaction and not a participant's total contributions. Consider whether
  the cap amount should be applied to a participant's total contribution or to each individual transaction

  * [x] Fixed in [07a5991](https://github.com/SnipToday/SnipCoin/commit/07a5991327b7c26e040e319aa67205ff96697a7d)

* **LOW IMPORTANCE** `saleWalletAddress.transfer(msg.value);` should be the last statement in `function ()`. This is not very
  important as `saleWalletAddress` is under the control of the crowdsale administrator. But if the destination of this ETH transfer
  is a participants wallet, the program control flow can be hijacked

  * [x] Fixed in [4cda853](https://github.com/SnipToday/SnipCoin/commit/4cda85368a553832b01e16ebfcff43c816ed6b02)

* **LOW IMPORTANCE** Some of the recent tokens have a requirement that a non-0 approval amount must be set to 0 before being able to set it
  to a new non-0 approval amount. See [GimliToken.sol](https://github.com/bokkypoobah/GimliTokenContractAudit/blob/master/sol/GimliToken.sol#L79-L83)
  for an example, including the linked comment

  * [x] Fixed in [bf168d8](https://github.com/SnipToday/SnipCoin/commit/bf168d8e22fa6b73792513e6ce4e611a2f8209eb)

* **LOW IMPORTANCE** The `transfer(...)` and `transferFrom(...)` return a false if the transfer fails. Some of the newer tokens throw
  an error instead of returning false - search for "throw" in the [ERC20 standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)

  * [x] Fixed in [bf168d8](https://github.com/SnipToday/SnipCoin/commit/bf168d8e22fa6b73792513e6ce4e611a2f8209eb)

* **LOW IMPORTANCE** Fix compiler warning from using `throw` in `transfer(...)` and `transferFrom(...)` instead of `revert()`

  * [x] `throw` statement left as is

<br />

<hr />

## Potential Vulnerabilities

No potential vulnerabilities have been identified in the crowdsale and token contract.

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

### Contribution From Capped And Uncapped Whitelisted Accounts

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

* [x] Deploy Crowdsale/Token contract
* [x] Add accounts to capped and uncapped whitelists
* [x] Contribute before crowdsale start - rejected
* [x] Open crowdsale
* [x] Small contribution after crowdsale start
* [x] Large contribution after crowdsale start, past cap. Capped whitelisted contribution rejected. Uncapped whitelisted accepted 
* [x] Moderate contribution after crowdsale start, below cap. Both capped and uncapped contribution accepted 
* [x] Close crowdsale
* [x] Enable transfers
* [x] `transfer(...)` and `transferFrom(...)` the *SNIP* tokens

<br />

### Contribution From Uncapped Whitelisted Accounts To Max USD Cap

The following functions were tested using the script [test/02_test2.sh](test/02_test2.sh) with the summary results saved
in [test/test2results.txt](test/test2results.txt) and the detailed output saved in [test/test2output.txt](test/test2output.txt):

* [x] Deploy Crowdsale/Token contract
* [x] Add accounts to capped and uncapped whitelists
* [x] Open crowdsale
* [x] Contribute from uncapped account to just below the 8m USD cap
* [x] Contribute from uncapped account to just above the 8m USD cap - contribution rejected
* [x] Contribute from uncapped account to the 8m USD cap
* [x] Close crowdsale
* [x] Enable transfers
* [x] `transfer(...)` the *SNIP* tokens

<br />

### Contribution From Capped Whitelisted Accounts To Account Cap

The following functions were tested using the script [test/03_test3.sh](test/03_test3.sh) with the summary results saved
in [test/test3results.txt](test/test3results.txt) and the detailed output saved in [test/test3output.txt](test/test3output.txt):

* [x] Deploy Crowdsale/Token contract
* [x] Add accounts to capped and uncapped whitelists
* [x] Open crowdsale
* [x] Contribute from capped account to just below the capped amount
* [x] Contribute from uncapped account to just above the capped amount - contribution rejected
* [x] Contribute from uncapped account to the capped amount

<br />

### New ERC20 Standard

The following functions were tested using the script [test/04_test4.sh](test/04_test4.sh) with the summary results saved
in [test/test4results.txt](test/test4results.txt) and the detailed output saved in [test/test4output.txt](test/test4output.txt):

* [x] Deploy Crowdsale/Token contract
* [x] Add accounts to capped and uncapped whitelists
* [x] Open crowdsale
* [x] Contribute from capped and uncapped accounts
* [x] Transfer 0 tokens - NOT thrown
* [x] Transfer more tokens than accounts own - thrown
* [x] Change approval without setting to 0 - thrown
* [x] Change approval by setting to 0 first - NOT thrown

<br />

Details of the testing environment can be found in [test](test).

<br />

<hr />

## Code Review

* [x] [code-review/SnipCoin.md](code-review/SnipCoin.md)
  * [x] contract Token
  * [x] contract StandardToken is Token
  * [x] contract SnipCoin is StandardToken

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Snip - Oct 5 2017. The MIT Licence.