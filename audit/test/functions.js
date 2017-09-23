// Jun 12 2017
var ethPriceUSD = 380.39;

// -----------------------------------------------------------------------------
// Accounts
// -----------------------------------------------------------------------------
var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Contract Owner");
addAccount(eth.accounts[2], "Account #2 - Wallet");
addAccount(eth.accounts[3], "Account #3 - Prealloc");
addAccount(eth.accounts[4], "Account #4 - Prealloc");
addAccount(eth.accounts[5], "Account #5");
addAccount(eth.accounts[6], "Account #6");
addAccount(eth.accounts[7], "Account #7");
addAccount(eth.accounts[8], "Account #8");
addAccount(eth.accounts[9], "Account #9 - Vested 1 Tokens");
addAccount(eth.accounts[10], "Account #10 - Vested 2 Tokens");
addAccount("0xABcdEFABcdEFabcdEfAbCdefabcdeFABcDEFabCD", "Locked Tokens");


var minerAccount = eth.accounts[0];
var contractOwnerAccount = eth.accounts[1];
var wallet = eth.accounts[2];
var account3 = eth.accounts[3];
var account4 = eth.accounts[4];
var account5 = eth.accounts[5];
var account6 = eth.accounts[6];
var account7 = eth.accounts[7];
var account8 = eth.accounts[8];
var account9 = eth.accounts[9];
var account10 = eth.accounts[10];

var baseBlock = eth.blockNumber;

function unlockAccounts(password) {
  for (var i = 0; i < eth.accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}


// -----------------------------------------------------------------------------
// Token Contract
// -----------------------------------------------------------------------------
var tokenContractAddress = null;
var tokenContractAbi = null;

function addTokenContractAddressAndAbi(address, tokenAbi) {
  tokenContractAddress = address;
  tokenContractAbi = tokenAbi;
}


// -----------------------------------------------------------------------------
// Account ETH and token balances
// -----------------------------------------------------------------------------
function printBalances() {
  var token = tokenContractAddress == null || tokenContractAbi == null ? null : web3.eth.contract(tokenContractAbi).at(tokenContractAddress);
  var decimals = token == null ? 8 : token.decimals();
  var i = 0;
  var totalTokenBalance = new BigNumber(0);
  console.log("RESULT:  # Account                                             EtherBalanceChange                Token Name");
  console.log("RESULT: -- ------------------------------------------ --------------------------- -------------------- ---------------------------");
  accounts.forEach(function(e) {
    var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
    var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
    var tokenBalance = token == null ? new BigNumber(0) : token.balanceOf(e).shift(-decimals);
    totalTokenBalance = totalTokenBalance.add(tokenBalance);
    console.log("RESULT: " + pad2(i) + " " + e  + " " + pad(etherBalance) + " " + padToken(tokenBalance, decimals) + " " + accountNames[e]);
    i++;
  });
  console.log("RESULT: -- ------------------------------------------ --------------------------- -------------------- ---------------------------");
  console.log("RESULT:                                                                           " + padToken(totalTokenBalance, decimals) + " Total Token Balances");
  console.log("RESULT: -- ------------------------------------------ --------------------------- -------------------- ---------------------------");
  console.log("RESULT: ");
}

function pad2(s) {
  var o = s.toFixed(0);
  while (o.length < 2) {
    o = " " + o;
  }
  return o;
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function padToken(s, decimals) {
  var o = s.toFixed(decimals);
  var l = parseInt(decimals)+12;
  while (o.length < l) {
    o = " " + o;
  }
  return o;
}


// -----------------------------------------------------------------------------
// Transaction status
// -----------------------------------------------------------------------------
function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  var gasPrice = tx.gasPrice;
  var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
  var gasCostUSD = gasCostETH.mul(ethPriceUSD);
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed + " costETH=" + gasCostETH +
    " costUSD=" + gasCostUSD + " @ ETH/USD=" + ethPriceUSD + " gasPrice=" + gasPrice + " block=" + 
    txReceipt.blockNumber + " txIx=" + tx.transactionIndex + " txId=" + txId);
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

function gasEqualsGasUsed(tx) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: PASS " + msg);
    return 1;
  } else {
    console.log("RESULT: FAIL " + msg);
    return 0;
  }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
  if (contractAddress == null) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
      console.log("RESULT: FAIL " + msg);
      return 0;
    } else {
      console.log("RESULT: PASS " + msg);
      return 1;
    }
  }
}


//-----------------------------------------------------------------------------
// Token Contract
//-----------------------------------------------------------------------------
var tokenFromBlock = 0;
function printTokenContractDetails() {
  console.log("RESULT: tokenContractAddress=" + tokenContractAddress);
  if (tokenContractAddress != null && tokenContractAbi != null) {
    var contract = eth.contract(tokenContractAbi).at(tokenContractAddress);
    var decimals = contract.decimals();
    console.log("RESULT: token.owner=" + contract.owner());
    console.log("RESULT: token.MULTISIG_WALLET_ADDRESS=" + contract.MULTISIG_WALLET_ADDRESS());
    console.log("RESULT: token.symbol=" + contract.symbol());
    console.log("RESULT: token.name=" + contract.name());
    console.log("RESULT: token.version=" + contract.version());
    console.log("RESULT: token.decimals=" + decimals);
    console.log("RESULT: token.totalSupply=" + contract.totalSupply().shift(-decimals));
    var startDate = contract.START_DATE();
    console.log("RESULT: token.START_DATE=" + startDate + " " + new Date(startDate * 1000).toUTCString());
    var endDate = contract.END_DATE();
    console.log("RESULT: token.END_DATE=" + endDate + " " + new Date(endDate * 1000).toUTCString());
    var vesting1Date = contract.VESTING_1_DATE();
    console.log("RESULT: token.VESTING_1_DATE=" + vesting1Date + " " + new Date(vesting1Date * 1000).toUTCString());
    var vesting2Date = contract.VESTING_2_DATE();
    console.log("RESULT: token.VESTING_2_DATE=" + vesting2Date + " " + new Date(vesting2Date * 1000).toUTCString());
    console.log("RESULT: token.CROWDSALE_PRICE=" + contract.CROWDSALE_PRICE());
    console.log("RESULT: token.TOTAL_SUPPLY=" + contract.TOTAL_SUPPLY().shift(-decimals));
    console.log("RESULT: token.CROWDSALE_AMOUNT=" + contract.CROWDSALE_AMOUNT().shift(-decimals));
    console.log("RESULT: token.VESTING_1_AMOUNT=" + contract.VESTING_1_AMOUNT().shift(-decimals));
    console.log("RESULT: token.VESTING_2_AMOUNT=" + contract.VESTING_2_AMOUNT().shift(-decimals));
    console.log("RESULT: token.vesting1Withdrawn=" + contract.vesting1Withdrawn());
    console.log("RESULT: token.vesting2Withdrawn=" + contract.vesting2Withdrawn());
    console.log("RESULT: token.crowdsaleCanceled=" + contract.crowdsaleCanceled());
    console.log("RESULT: token.soldAmount=" + contract.soldAmount().shift(-decimals));
    console.log("RESULT: token.transferable=" + contract.transferable());

    var latestBlock = eth.blockNumber;
    var i;

    var ownershipTransferredEvent = contract.OwnershipTransferred({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    ownershipTransferredEvent.watch(function (error, result) {
      console.log("RESULT: OwnershipTransferred " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    ownershipTransferredEvent.stopWatching();

    var adminstratorAddedEvent = contract.AdminstratorAdded({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    adminstratorAddedEvent.watch(function (error, result) {
      console.log("RESULT: AdminstratorAdded " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    adminstratorAddedEvent.stopWatching();

    var adminstratorRemovedEvent = contract.AdminstratorRemoved({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    adminstratorRemovedEvent.watch(function (error, result) {
      console.log("RESULT: AdminstratorRemoved " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    adminstratorRemovedEvent.stopWatching();

    var approvalEvents = contract.Approval({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      console.log("RESULT: Approval " + i++ + " #" + result.blockNumber + " owner=" + result.args.owner + " spender=" + result.args.spender + " value=" +
        result.args.value.shift(-decimals));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      console.log("RESULT: Transfer " + i++ + " #" + result.blockNumber + ": from=" + result.args.from + " to=" + result.args.to +
        " value=" + result.args.value.shift(-decimals));
    });
    transferEvents.stopWatching();

    tokenFromBlock = latestBlock + 1;
  }
}
