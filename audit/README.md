# SnipCoin Token Contract Audit

[https://www.snip.today/](https://www.snip.today/)

[https://www.snip.network/sale/signup/?next=/sale/](https://www.snip.network/sale/signup/?next=/sale/)

Status: To be commenced

<br />

## Summary

### Crowdsale And Token Contract

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
  * [Crowdsale And Token Contract](#crowdsale-and-token-contract)
* [Recommendations](#recommendations)
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

* **LOW IMPORTANCE** Fix the compiler warnings - address not checksummed. Paste the address in the [https://etherscan.io](https://etherscan.io)
  search box and the checksummed address will be displayed. Use this checksummed address, e.g., `0x686f152daD6490DF93B267E319f875A684Bd26e2`.

  For an example, see [test/modifiedContracts/SnipCoin.sol](test/modifiedContracts/SnipCoin.sol)

      SnipCoin.sol:107:29: Warning: This looks like an address but has an invalid checksum. If this is not used as an address, please prepend '00'.
              saleWalletAddress = 0x686f152dad6490df93b267e319f875a684bd26e2; // Change before the sale
                                  ^----------------------------------------^

* **LOW IMPORTANCE** Fix the compiler warnings - unused variables. Replace the empty function body `{}` with a `;` for the
  *Token* interface to declare the functions as un-implemented functions that will be overridden in the derived contract.

  For an example, see [test/modifiedContracts/SnipCoin.sol](test/modifiedContracts/SnipCoin.sol)

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

* **HIGH IMPORTANCE** The statement `totalSupply = 10000000000;` in `SnipCoin.SnipCoin()` should have the decimals factor
  factored in. The statement should be something like `totalSupply = 10000000000 * DECIMALS_MULTIPLIER;`, and the following
  statement should be `balances[msg.sender] = totalSupply;`

  For an example, see [test/modifiedContracts/SnipCoin.sol](test/modifiedContracts/SnipCoin.sol)

* **LOW IMPORTANCE** The [ERC20 token standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
  defines `decimals` as `uint8`. Update the token contract to use `uint8` instead of `uint`

  For an example, see [test/modifiedContracts/SnipCoin.sol](test/modifiedContracts/SnipCoin.sol)

* **LOW IMPORTANCE** `DECIMALS_MULTIPLIER = 1000000000000000000;` is a constant, but `decimals` is initialised in the
  `SnipCoin.SnipCoin()` constructor. As both these are directly related, consider using the statement
  `uint8 public constant decimals = 18;`, then `uint public constant DECIMALS_MULTIPLIER = 10**uint(decimals);`. And
  remove `decimals = 18;` in `SnipCoin.SnipCoin()`

  For an example, see [test/modifiedContracts/SnipCoin.sol](test/modifiedContracts/SnipCoin.sol)

* **MEDIUM IMPORTANCE** `tokenName` and `tokenSymbol` should be named `name` and `symbol` respectively, as documented in
  the [ERC20 token standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md). Consider defining
  these as constant values in `SnipCoin` like `string public constant symbol = "SNP";` and
  `string public constant name = "SnipCoin";`, removing the assignments in `SnipCoin.SnipCoin()`

  For an example, see [test/modifiedContracts/SnipCoin.sol](test/modifiedContracts/SnipCoin.sol)

* **LOW IMPORTANCE** `SnipCoin.sendCoin(...)` provides the exact same functionality as `StandardToken.transfer(...)`.
  Consider removing `SnipCoin.sendCoin(...)`

* **LOW IMPORTANCE** `SnipCoin.function()` has the statement `if (!saleWalletAddress.send(msg.value)) revert();` that
  can be written as `saleWalletAddress.transfer(msg.value);` that will throw an exception when there is an error. See the
  [difference between `send(...)` and `transfer(...)`](https://github.com/ConsenSys/smart-contract-best-practices#be-aware-of-the-tradeoffs-between-send-transfer-and-callvalue)

* **LOW IMPORTANCE** The variable `SnipCoin.ownerAddress` is unused and can be removed

<br />

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


