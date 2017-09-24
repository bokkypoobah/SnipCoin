#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

SOURCEDIR=`grep ^SOURCEDIR= settings.txt | sed "s/^.*=//"`

CROWDSALESOL=`grep ^CROWDSALESOL= settings.txt | sed "s/^.*=//"`
CROWDSALEJS=`grep ^CROWDSALEJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST3OUTPUT=`grep ^TEST3OUTPUT= settings.txt | sed "s/^.*=//"`
TEST3RESULTS=`grep ^TEST3RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

BLOCKSINDAY=10

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1m 10s in the future
  STARTTIME=`echo "$CURRENTTIME+90" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*3" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

printf "MODE            = '$MODE'\n" | tee $TEST3OUTPUT
printf "GETHATTACHPOINT = '$GETHATTACHPOINT'\n" | tee -a $TEST3OUTPUT
printf "PASSWORD        = '$PASSWORD'\n" | tee -a $TEST3OUTPUT
printf "SOURCEDIR       = '$SOURCEDIR'\n" | tee -a $TEST3OUTPUT
printf "CROWDSALESOL    = '$CROWDSALESOL'\n" | tee -a $TEST3OUTPUT
printf "CROWDSALEJS     = '$CROWDSALEJS'\n" | tee -a $TEST3OUTPUT
printf "DEPLOYMENTDATA  = '$DEPLOYMENTDATA'\n" | tee -a $TEST3OUTPUT
printf "INCLUDEJS       = '$INCLUDEJS'\n" | tee -a $TEST3OUTPUT
printf "TEST3OUTPUT     = '$TEST3OUTPUT'\n" | tee -a $TEST3OUTPUT
printf "TEST3RESULTS    = '$TEST3RESULTS'\n" | tee -a $TEST3OUTPUT
printf "CURRENTTIME     = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST3OUTPUT
printf "STARTTIME       = '$STARTTIME' '$STARTTIME_S'\n" | tee -a $TEST3OUTPUT
printf "ENDTIME         = '$ENDTIME' '$ENDTIME_S'\n" | tee -a $TEST3OUTPUT

# Make copy of SOL file and modify start and end times ---
# `cp modifiedContracts/SnipCoin.sol .`
`cp $SOURCEDIR/SnipCoin.sol .`

# --- Modify parameters ---
# `perl -pi -e "s/bool transferable/bool public transferable/" $TOKENSOL`
# `perl -pi -e "s/MULTISIG_WALLET_ADDRESS \= 0xc79ab28c5c03f1e7fbef056167364e6782f9ff4f;/MULTISIG_WALLET_ADDRESS \= 0xa22AB8A9D641CE77e06D98b7D7065d324D3d6976;/" GimliCrowdsale.sol`
# `perl -pi -e "s/START_DATE = 1505736000;.*$/START_DATE \= $STARTTIME; \/\/ $STARTTIME_S/" GimliCrowdsale.sol`
# `perl -pi -e "s/END_DATE = 1508500800;.*$/END_DATE \= $ENDTIME; \/\/ $ENDTIME_S/" GimliCrowdsale.sol`
# `perl -pi -e "s/VESTING_1_DATE = 1537272000;.*$/VESTING_1_DATE \= $VESTING1TIME; \/\/ $VESTING1TIME_S/" GimliCrowdsale.sol`
# `perl -pi -e "s/VESTING_2_DATE = 1568808000;.*$/VESTING_2_DATE \= $VESTING2TIME; \/\/ $VESTING2TIME_S/" GimliCrowdsale.sol`

DIFFS1=`diff $SOURCEDIR/$CROWDSALESOL $CROWDSALESOL`
echo "--- Differences $SOURCEDIR/$CROWDSALESOL $CROWDSALESOL ---" | tee -a $TEST3OUTPUT
echo "$DIFFS1" | tee -a $TEST3OUTPUT

echo "var tokenOutput=`solc --optimize --combined-json abi,bin,interface $CROWDSALESOL`;" > $CROWDSALEJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST3OUTPUT
loadScript("$CROWDSALEJS");
loadScript("functions.js");

var tokenAbi = JSON.parse(tokenOutput.contracts["$CROWDSALESOL:SnipCoin"].abi);
var tokenBin = "0x" + tokenOutput.contracts["$CROWDSALESOL:SnipCoin"].bin;

// console.log("DATA: tokenAbi=" + JSON.stringify(tokenAbi));
// console.log("DATA: tokenBin=" + JSON.stringify(tokenBin));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var tokenMessage = "Deploy Crowdsale/Token Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + tokenMessage);
var tokenContract = web3.eth.contract(tokenAbi);
// console.log(JSON.stringify(tokenContract));
var tokenTx = null;
var tokenAddress = null;

var token = tokenContract.new({from: contractOwnerAccount, data: tokenBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: tokenAddress=" + tokenAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("tokenAddress=" + tokenAddress, tokenTx);
printBalances();
failIfGasEqualsGasUsed(tokenTx, tokenMessage);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var whitelistMessage = "Whitelist";
// -----------------------------------------------------------------------------
console.log("RESULT: " + whitelistMessage);
var whitelist1Tx = token.addAddressToUncappedAddresses(account3, {from: contractOwnerAccount, gas: 400000});
var whitelist2Tx = token.addAddressToCappedAddresses(account4, {from: contractOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("whitelist1Tx", whitelist1Tx);
printTxData("whitelist2Tx", whitelist2Tx);
printBalances();
failIfGasEqualsGasUsed(whitelist1Tx, whitelistMessage + " - ac3 Whitelist Uncapped");
failIfGasEqualsGasUsed(whitelist2Tx, whitelistMessage + " - ac4 Whitelist Capped");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var openSaleMessage = "Open Sale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + openSaleMessage);
var openSaleTx = token.openOrCloseSale(true, {from: contractOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("openSaleTx", openSaleTx);
printBalances();
failIfGasEqualsGasUsed(openSaleTx, openSaleMessage);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution2Message = "Contribute Below Account Cap";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution2Message);
var sendContribution2Tx = eth.sendTransaction({from: account4, to: tokenAddress, gas: 400000, value: web3.toWei("10", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("sendContribution2Tx", sendContribution2Tx);
printBalances();
failIfGasEqualsGasUsed(sendContribution2Tx, sendContribution2Message + " - ac4 10 ETH = 2,850 USD = 3,000,000 SNIP");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution2Message = "Contribute Above Account Cap";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution2Message);
var sendContribution2Tx = eth.sendTransaction({from: account4, to: tokenAddress, gas: 400000, value: web3.toWei("10", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("sendContribution2Tx", sendContribution2Tx);
printBalances();
passIfGasEqualsGasUsed(sendContribution2Tx, sendContribution2Message + " - ac4 10 ETH = 2,850 USD = 3,000,000 SNIP - Rejected");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution2Message = "Contribute At Account Cap";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution2Message);
var sendContribution2Tx = eth.sendTransaction({from: account4, to: tokenAddress, gas: 400000, value: web3.toWei("5.785", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("sendContribution2Tx", sendContribution2Tx);
printBalances();
failIfGasEqualsGasUsed(sendContribution2Tx, sendContribution2Message + " - ac4 5.785 ETH = 1,648.725 USD = 1,735,500 SNIP");
printTokenContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST3OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST3OUTPUT | sed "s/RESULT: //" > $TEST3RESULTS
cat $TEST3RESULTS
